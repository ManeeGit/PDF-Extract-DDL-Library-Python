-- ===============================================
-- PRODUCTION-READY TABLE DDL STATEMENTS
-- Primary Source: DOCX Word documents
-- Secondary Source: PDF documents (if available)
-- Database: BMGPDD (Bank Management Production)
-- Generated: 2025-06-26
-- ===============================================

CREATE TABLE column_mapping_specification (
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
    CONSTRAINT pk_column_mapping PRIMARY KEY (source_column_name, bmg_column_name),
    CONSTRAINT chk_nullable CHECK (nullable_flag IN ('Y', 'N')),
    CONSTRAINT chk_pii_type CHECK (pii_type IN ('NONE', 'SENSITIVE', 'RESTRICTED', 'CONFIDENTIAL'))
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
    CONSTRAINT pk_document_spec PRIMARY KEY (document_id),
    CONSTRAINT chk_doc_type CHECK (document_type IN ('PDF', 'DOCX', 'DOC')),
    CONSTRAINT chk_quality_score CHECK (quality_score BETWEEN 0 AND 100)
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
    CONSTRAINT pk_transaction_field PRIMARY KEY (field_name),
    CONSTRAINT chk_trans_nullable CHECK (nullable_flag IN ('Y', 'N')),
    CONSTRAINT chk_max_length CHECK (max_length > 0),
    CONSTRAINT fk_trans_field_doc FOREIGN KEY (source_document_id) 
        REFERENCES document_specification(document_id)
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
    updated_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT pk_account_master PRIMARY KEY (acct_num, co_id),
    CONSTRAINT chk_balance CHECK (balance_amt >= 0),
    CONSTRAINT chk_status CHECK (acct_status_cd IN ('ACTV', 'CLSD', 'SUSP')),
    CONSTRAINT chk_dates CHECK (close_date IS NULL OR close_date >= open_date),
    CONSTRAINT chk_spec_source CHECK (specification_source IN ('PDF', 'DOCX', 'MULTI'))
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
    CONSTRAINT pk_transaction_daily PRIMARY KEY (trans_seq_num, post_date),
    CONSTRAINT fk_trans_account FOREIGN KEY (acct_num, co_id) 
        REFERENCES account_master(acct_num, co_id),
    CONSTRAINT chk_asof_format CHECK (asof_yyyymm BETWEEN 190001 AND 999912),
    CONSTRAINT chk_trans_dates CHECK (trans_date <= post_date),
    CONSTRAINT chk_trans_spec_source CHECK (specification_source IN ('PDF', 'DOCX', 'MULTI'))
);



-- ===============================================
-- INDEXES FOR PERFORMANCE
-- ===============================================

-- Document Specification Indexes
CREATE INDEX idx_document_spec_type ON document_specification(document_type);
CREATE INDEX idx_document_spec_quality ON document_specification(quality_score);
CREATE INDEX idx_document_spec_date ON document_specification(extraction_date);

-- Account Master Indexes
CREATE INDEX idx_account_master_status ON account_master(acct_status_cd);
CREATE INDEX idx_account_master_type ON account_master(acct_type_cd);
CREATE INDEX idx_account_master_dates ON account_master(open_date, close_date);
CREATE INDEX idx_account_master_spec_source ON account_master(specification_source);

-- Transaction Daily Indexes  
CREATE INDEX idx_transaction_daily_post_date ON transaction_daily(post_date);
CREATE INDEX idx_transaction_daily_acct ON transaction_daily(acct_num, co_id);
CREATE INDEX idx_transaction_daily_asof ON transaction_daily(asof_yyyymm);
CREATE INDEX idx_transaction_daily_type ON transaction_daily(trans_type_cd);
CREATE INDEX idx_transaction_daily_amount ON transaction_daily(trans_amt);
CREATE INDEX idx_transaction_daily_spec_source ON transaction_daily(specification_source);

-- Column Mapping Indexes
CREATE INDEX idx_column_mapping_bmg_col ON column_mapping_specification(bmg_column_name);
CREATE INDEX idx_column_mapping_pii ON column_mapping_specification(pii_type);
CREATE INDEX idx_column_mapping_source ON column_mapping_specification(source_column_name);
CREATE INDEX idx_column_mapping_doc ON column_mapping_specification(source_document);

-- Transaction Field Specification Indexes
CREATE INDEX idx_trans_field_doc ON transaction_field_specification(source_document_id);
CREATE INDEX idx_trans_field_section ON transaction_field_specification(specification_section);
CREATE INDEX idx_trans_field_nullable ON transaction_field_specification(nullable_flag);

