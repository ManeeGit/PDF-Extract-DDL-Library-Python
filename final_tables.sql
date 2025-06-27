-- ===============================================
-- PRODUCTION-READY TABLE DDL STATEMENTS
-- Based on specification documents (PDF and DOCX analysis)
-- Database: BMGPDD (Bank Management Production)
-- Generated: 2025-06-26
-- Supports: PDF and DOCX specification sources
-- ===============================================

-- =============================================
-- COLUMN MAPPING SPECIFICATION TABLE
-- Contains mapping between source and target columns
-- Based on specification documents (PDF/DOCX analysis)
-- =============================================

CREATE TABLE column_mapping_specification (
    source_column_name VARCHAR(100) NOT NULL COMMENT 'Original column name from source system',
    source_datatype VARCHAR(50) COMMENT 'Data type in source system',
    transformation_logic TEXT COMMENT 'ETL transformation rules applied',
    bmg_column_name VARCHAR(100) NOT NULL COMMENT 'Target column name in BMG system',
    bmg_datatype VARCHAR(50) NOT NULL COMMENT 'Target data type in BMG system',
    nullable_flag CHAR(1) DEFAULT 'Y' COMMENT 'Y=Nullable, N=Not Nullable',
    business_name VARCHAR(200) COMMENT 'Business-friendly column name',
    description TEXT COMMENT 'Detailed column description and business rules',
    pii_type VARCHAR(50) COMMENT 'PII classification (NONE, SENSITIVE, RESTRICTED)',
    encryption_category VARCHAR(50) COMMENT 'Encryption requirements',
    source_document VARCHAR(100) COMMENT 'Source specification document (PDF/DOCX)',
    
    -- Constraints
    CONSTRAINT pk_column_mapping PRIMARY KEY (source_column_name, bmg_column_name),
    CONSTRAINT chk_nullable CHECK (nullable_flag IN ('Y', 'N')),
    CONSTRAINT chk_pii_type CHECK (pii_type IN ('NONE', 'SENSITIVE', 'RESTRICTED', 'CONFIDENTIAL'))
);

-- Sample data based on specification documents
/*
Example rows from PDF/DOCX:
- source_column_name: 'CR0001.R-ACT-NO', bmg_column_name: 'ACCT_NUM', bmg_datatype: 'DECIMAL(18,0)', business_name: 'Account Number'
- source_column_name: 'CR0001.R-CO-ID', bmg_column_name: 'CO_ID', bmg_datatype: 'SMALLINT', business_name: 'Company Identifier'
- source_column_name: 'CR0001.R-TRANS-NO', bmg_column_name: 'TRANS_SEQ_NUM', bmg_datatype: 'INTEGER', business_name: 'Transaction Sequence Number'
*/


-- =============================================
-- DOCUMENT SPECIFICATION TABLE
-- Tracks specification documents and their content
-- =============================================

CREATE TABLE document_specification (
    document_id VARCHAR(50) NOT NULL COMMENT 'Unique document identifier',
    document_name VARCHAR(200) NOT NULL COMMENT 'Document file name',
    document_type VARCHAR(10) NOT NULL COMMENT 'File type (PDF, DOCX)',
    document_version VARCHAR(20) COMMENT 'Document version number',
    extraction_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'When tables were extracted',
    table_count INTEGER DEFAULT 0 COMMENT 'Number of tables found',
    quality_score DECIMAL(5,2) COMMENT 'Overall extraction quality score',
    file_size_bytes BIGINT COMMENT 'Document file size',
    page_count INTEGER COMMENT 'Number of pages/sections',
    processing_notes TEXT COMMENT 'Extraction processing notes',
    
    -- Constraints
    CONSTRAINT pk_document_spec PRIMARY KEY (document_id),
    CONSTRAINT chk_doc_type CHECK (document_type IN ('PDF', 'DOCX', 'DOC')),
    CONSTRAINT chk_quality_score CHECK (quality_score BETWEEN 0 AND 100)
);


-- =============================================
-- TRANSACTION FIELD SPECIFICATION TABLE
-- Contains field specifications for transaction processing
-- Supports both PDF and DOCX source specifications
-- =============================================

CREATE TABLE transaction_field_specification (
    field_name VARCHAR(100) NOT NULL COMMENT 'Field name in transaction record',
    source_field VARCHAR(100) COMMENT 'Source field mapping',
    data_type VARCHAR(50) NOT NULL COMMENT 'Data type specification',
    max_length INTEGER COMMENT 'Maximum field length',
    nullable_flag CHAR(1) DEFAULT 'Y' COMMENT 'Null allowed flag',
    business_description TEXT COMMENT 'Business purpose and rules',
    validation_rules TEXT COMMENT 'Data validation requirements',
    notes TEXT COMMENT 'Additional implementation notes',
    source_document_id VARCHAR(50) COMMENT 'Reference to specification document',
    specification_section VARCHAR(100) COMMENT 'Section/table within document',
    
    -- Constraints
    CONSTRAINT pk_transaction_field PRIMARY KEY (field_name),
    CONSTRAINT chk_trans_nullable CHECK (nullable_flag IN ('Y', 'N')),
    CONSTRAINT chk_max_length CHECK (max_length > 0),
    CONSTRAINT fk_trans_field_doc FOREIGN KEY (source_document_id) 
        REFERENCES document_specification(document_id)
);


-- =============================================
-- ACCOUNT MASTER TABLE
-- Core account information based on specification
-- Supports data from both PDF and DOCX specifications
-- =============================================

CREATE TABLE account_master (
    acct_num DECIMAL(18,0) NOT NULL COMMENT 'Account number from source system',
    co_id SMALLINT NOT NULL COMMENT 'Company identifier',
    acct_type_cd VARCHAR(10) COMMENT 'Account type code',
    acct_status_cd VARCHAR(5) DEFAULT 'ACTV' COMMENT 'Account status',
    open_date DATE COMMENT 'Account opening date',
    close_date DATE COMMENT 'Account closure date',
    balance_amt DECIMAL(18,2) DEFAULT 0.00 COMMENT 'Current account balance',
    last_trans_date DATE COMMENT 'Date of last transaction',
    specification_source VARCHAR(20) DEFAULT 'MULTI' COMMENT 'PDF, DOCX, or MULTI',
    created_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Constraints
    CONSTRAINT pk_account_master PRIMARY KEY (acct_num, co_id),
    CONSTRAINT chk_balance CHECK (balance_amt >= 0),
    CONSTRAINT chk_status CHECK (acct_status_cd IN ('ACTV', 'CLSD', 'SUSP')),
    CONSTRAINT chk_dates CHECK (close_date IS NULL OR close_date >= open_date),
    CONSTRAINT chk_spec_source CHECK (specification_source IN ('PDF', 'DOCX', 'MULTI'))
);


-- =============================================
-- TRANSACTION DAILY TABLE
-- Daily transaction records as per specification
-- Supports both PDF and DOCX specification sources
-- =============================================

CREATE TABLE transaction_daily (
    trans_seq_num INTEGER NOT NULL COMMENT 'Transaction sequence number',
    acct_num DECIMAL(18,0) NOT NULL COMMENT 'Account number',
    co_id SMALLINT NOT NULL COMMENT 'Company identifier',
    post_date DATE NOT NULL COMMENT 'Transaction posting date',
    trans_date DATE NOT NULL COMMENT 'Transaction occurrence date',
    trans_amt DECIMAL(18,2) NOT NULL COMMENT 'Transaction amount',
    trans_type_cd VARCHAR(10) NOT NULL COMMENT 'Transaction type code',
    trans_desc VARCHAR(255) COMMENT 'Transaction description',
    atm_surcharge_fee DECIMAL(18,2) DEFAULT 0.00 COMMENT 'ATM surcharge fee amount',
    card_num_encrypted VARCHAR(32) COMMENT 'Encrypted card number',
    appl_id CHAR(2) DEFAULT 'HD' COMMENT 'Application identifier',
    asof_yyyymm INTEGER NOT NULL COMMENT 'As-of year-month (YYYYMM)',
    specification_source VARCHAR(20) DEFAULT 'MULTI' COMMENT 'PDF, DOCX, or MULTI',
    created_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Constraints
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

