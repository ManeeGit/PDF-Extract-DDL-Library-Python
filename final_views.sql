-- PRODUCTION-READY VIEW DDL STATEMENTS
-- Generated: 2025-06-26

CREATE VIEW v_document_analysis AS
SELECT d.document_id, d.document_name, d.document_type, d.document_version, d.extraction_date, d.table_count, d.quality_score, d.page_count,
       COUNT(t.field_name) as field_count, AVG(CASE WHEN t.nullable_flag = 'N' THEN 1 ELSE 0 END) * 100 as mandatory_field_percentage
FROM document_specification d
LEFT JOIN transaction_field_specification t ON d.document_id = t.source_document_id
GROUP BY d.document_id, d.document_name, d.document_type, d.document_version, d.extraction_date, d.table_count, d.quality_score, d.page_count
ORDER BY d.quality_score DESC, d.extraction_date DESC;

CREATE VIEW v_tran_current_month AS
SELECT t.trans_seq_num, t.acct_num, t.co_id, t.post_date, t.trans_date, t.trans_amt, t.trans_type_cd, t.trans_desc, t.atm_surcharge_fee, t.appl_id, t.asof_yyyymm, t.specification_source, a.acct_type_cd, a.acct_status_cd
FROM transaction_daily t
INNER JOIN account_master a ON t.acct_num = a.acct_num AND t.co_id = a.co_id
WHERE t.asof_yyyymm = EXTRACT(YEAR FROM CURRENT_DATE) * 100 + EXTRACT(MONTH FROM CURRENT_DATE) AND t.trans_type_cd NOT IN ('INTERNAL', 'INT_TRANSFER') AND a.acct_status_cd = 'ACTV';

CREATE VIEW v_tran_history AS
SELECT t.trans_seq_num, t.acct_num, t.co_id, t.post_date, t.trans_date, t.trans_amt, t.trans_type_cd, t.trans_desc, t.atm_surcharge_fee, t.asof_yyyymm, t.specification_source, a.acct_type_cd, a.acct_status_cd,
       CASE WHEN t.asof_yyyymm = EXTRACT(YEAR FROM CURRENT_DATE) * 100 + EXTRACT(MONTH FROM CURRENT_DATE) THEN 'CURRENT' ELSE 'HISTORICAL' END as period_type
FROM transaction_daily t
INNER JOIN account_master a ON t.acct_num = a.acct_num AND t.co_id = a.co_id
WHERE t.trans_type_cd NOT IN ('INTERNAL', 'INT_TRANSFER')
ORDER BY t.asof_yyyymm DESC, t.post_date DESC;

CREATE VIEW v_column_mapping_summary AS
SELECT c.source_document, c.pii_type, COUNT(*) as mapping_count, COUNT(CASE WHEN c.nullable_flag = 'N' THEN 1 END) as mandatory_fields,
       COUNT(CASE WHEN c.encryption_category IS NOT NULL THEN 1 END) as encrypted_fields, STRING_AGG(DISTINCT c.bmg_datatype, ', ') as data_types_used
FROM column_mapping_specification c
GROUP BY c.source_document, c.pii_type
ORDER BY c.source_document, c.pii_type;

