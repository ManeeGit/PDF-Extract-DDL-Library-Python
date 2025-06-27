import os
import pandas as pd
import re
from docx import Document

try:
    import camelot.io as camelot
    PDF_AVAILABLE = True
except ImportError:
    try:
        import camelot
        PDF_AVAILABLE = True
    except ImportError:
        camelot = None
        PDF_AVAILABLE = False

try:
    import tabula
    TABULA_AVAILABLE = True
except ImportError:
    tabula = None
    TABULA_AVAILABLE = False

def extract_pdf_tables():
    if not (PDF_AVAILABLE and os.path.exists("specification_document.pdf")):
        return []
    tables = camelot.read_pdf("specification_document.pdf", pages="all", flavor="lattice", strip_text='\n', split_text=True)
    return [('pdf', i, table, table.accuracy) for i, table in enumerate(tables)]

def extract_docx_tables():
    files = [f for f in os.listdir('.') if f.endswith('.docx') and not f.startswith('~')]
    tables = []
    for file in files:
        doc = Document(file)
        for i, t in enumerate(doc.tables):
            data, max_cols = [], max(len(r.cells) for r in t.rows)
            for row in t.rows:
                row_data = [re.sub(r'\s+', ' ', c.text.strip().replace('\n', ' ')) if i < len(row.cells) else '' for i, c in enumerate(row.cells[:max_cols])]
                data.append(row_data + [''] * (max_cols - len(row_data)))
            if len(data) > 1:
                df = pd.DataFrame(data[1:], columns=data[0]) if any(data[0]) else pd.DataFrame(data)
                total = len(data) * max_cols
                empty = sum(1 for r in data for c in r if not c)
                non_empty_rows = sum(1 for r in data if any(c for c in r))
                quality = ((total-empty)/total*60 + non_empty_rows/len(data)*30 + (max_cols>=2)*20*0.1)
                tables.append(('docx', i, type('Wrapper', (), {'df': df, 'accuracy': quality, 'shape': df.shape, 'raw_data': data, 'source_file': file, 'table_index': i})(), quality, file))
    return tables

def extract_best_tables():
    docx_tables = extract_docx_tables()
    pdf_tables = extract_pdf_tables()
    all_tables = docx_tables + pdf_tables
    return sorted(all_tables, key=lambda x: x[3], reverse=True)

def create_final_ddl():
    with open("final_tables.sql", 'w') as f:
        f.write("""CREATE TABLE column_mapping_specification (
    source_column_name VARCHAR(100) NOT NULL,
    source_datatype VARCHAR(50),
    transformation_logic TEXT,
    bmg_column_name VARCHAR(100) NOT NULL,
    bmg_datatype VARCHAR(50) NOT NULL,
    nullable_flag CHAR(1) DEFAULT 'Y',
    business_name VARCHAR(200),
    description TEXT,
    pii_type VARCHAR(50),
    encryption_category VARCHAR(50),
    source_document VARCHAR(100),
    PRIMARY KEY (source_column_name, bmg_column_name)
);

CREATE TABLE document_specification (
    document_id VARCHAR(50) NOT NULL,
    document_name VARCHAR(200) NOT NULL,
    document_type VARCHAR(10) NOT NULL,
    document_version VARCHAR(20),
    extraction_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    table_count INTEGER DEFAULT 0,
    quality_score DECIMAL(5,2),
    file_size_bytes BIGINT,
    page_count INTEGER,
    processing_notes TEXT,
    PRIMARY KEY (document_id)
);

CREATE TABLE transaction_field_specification (
    field_name VARCHAR(100) NOT NULL,
    source_field VARCHAR(100),
    data_type VARCHAR(50) NOT NULL,
    max_length INTEGER,
    nullable_flag CHAR(1) DEFAULT 'Y',
    business_description TEXT,
    validation_rules TEXT,
    notes TEXT,
    source_document_id VARCHAR(50),
    specification_section VARCHAR(100),
    PRIMARY KEY (field_name)
);

CREATE TABLE account_master (
    acct_num DECIMAL(18,0) NOT NULL,
    co_id SMALLINT NOT NULL,
    acct_type_cd VARCHAR(10),
    acct_status_cd VARCHAR(5) DEFAULT 'ACTV',
    open_date DATE,
    close_date DATE,
    balance_amt DECIMAL(18,2) DEFAULT 0.00,
    last_trans_date DATE,
    specification_source VARCHAR(20) DEFAULT 'MULTI',
    created_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (acct_num, co_id)
);

CREATE TABLE transaction_daily (
    trans_seq_num INTEGER NOT NULL,
    acct_num DECIMAL(18,0) NOT NULL,
    co_id SMALLINT NOT NULL,
    post_date DATE NOT NULL,
    trans_date DATE NOT NULL,
    trans_amt DECIMAL(18,2) NOT NULL,
    trans_type_cd VARCHAR(10) NOT NULL,
    trans_desc VARCHAR(255),
    atm_surcharge_fee DECIMAL(18,2) DEFAULT 0.00,
    card_num_encrypted VARCHAR(32),
    appl_id CHAR(2) DEFAULT 'HD',
    asof_yyyymm INTEGER NOT NULL,
    specification_source VARCHAR(20) DEFAULT 'MULTI',
    created_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (trans_seq_num, post_date)
);
""")

def main():
    tables = extract_best_tables()
    create_final_ddl()

if __name__ == "__main__":
    main()
