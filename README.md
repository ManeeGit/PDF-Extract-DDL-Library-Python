# DOCX-First Table Extraction to DDL Generator

This project extracts tables from **DOCX Word documents (primary)** and **PDF files (secondary)** to generate clean, production-ready SQL DDL (Data Definition Language) files for tables and views.

## 🚀 Features

### **DOCX-First Approach**
- **📝 Primary: DOCX Processing** - Enhanced Word document table extraction
- **📄 Secondary: PDF Processing** - Optional PDF support when libraries available
- **🔍 Smart Quality Scoring** - Advanced completeness and consistency analysis
- **🛡️ Error Resilience** - Graceful handling when PDF libraries unavailable

### **Enhanced Extraction**
- **📊 Multi-Table Support** - Extract multiple tables from single documents
- **🧹 Data Cleaning** - Advanced text normalization and whitespace handling
- **📏 Column Consistency** - Handle varying column counts across rows
- **📈 Quality Metrics** - Detailed quality analysis with completeness scores

### **Production-Ready Output**
- **🏗️ 5 Core Tables** - Comprehensive database schema
- **👁️ 4 Business Views** - Smart views with document lineage
- **⚡ Performance Indexes** - Optimized for query performance
- **🔗 Document Tracking** - Full specification source attribution

## 📋 Requirements

### **Core Dependencies**
```bash
# Essential (always required)
pip install python-docx pandas numpy

# Optional (for PDF support)
pip install camelot-py[cv] tabula-py

# Additional processing
pip install ddlgenerator pdfplumber
```

### **System Dependencies (Optional - for PDF support)**
- **Ghostscript**: Required for PDF processing
- **Java**: Required for tabula-py

## 🔧 Usage

### **Quick Start**
```bash
python final_extraction.py
```

### **Supported File Types**
- **📝 DOCX files** (Primary): `*.docx` - Automatically detected
- **📄 PDF files** (Secondary): `*.pdf` - Optional, when libraries available

### **Input Files**
Place your specification documents in the same directory:
- Any `*.docx` files (automatically detected and processed)
- `specification_document.pdf` (optional, processed if PDF libraries available)

### **Output Files**
- `final_tables.sql` - Production-ready table DDL (5 tables)
- `final_views.sql` - Business logic views DDL (4 views)

## 📊 Enhanced Table Structure

### Core Tables
1. **column_mapping_specification** - Source to target column mappings
2. **document_specification** - Document metadata and quality tracking
3. **transaction_field_specification** - Field specifications with document lineage
4. **account_master** - Core account information
5. **transaction_daily** - Daily transaction records

### Enhanced Views
1. **v_document_analysis** - Cross-document analysis and quality metrics
2. **v_tran_current_month** - Current month transactions
3. **v_tran_history** - Historical transaction data
4. **v_column_mapping_summary** - Mapping statistics by document source

## 🔍 Quality Analysis

The script provides detailed quality analysis:
- **PDF Tables**: Accuracy percentage from Camelot extraction
- **DOCX Tables**: Completeness score based on non-empty cells
- **Ranking**: Tables sorted by quality score (highest first)
- **Source Tracking**: Clear identification of PDF vs DOCX sources

## 📈 Example Output

```
🚀 DOCX-First Table Extraction and DDL Generator
============================================================
� Primary: DOCX Word documents (.docx)
� Secondary: PDF documents (.pdf) - if available

📝 DOCX Processing:
📝 Found 1 DOCX file(s): sample_specification.docx
🔍 Extracting tables from DOCX: sample_specification.docx
Found 3 tables in sample_specification.docx
DOCX Table 1: Shape (7, 4), Quality: 92.0%
  └─ Completeness: 100.0%, Row Density: 100.0%

📊 EXTRACTION SUMMARY:
📝 DOCX tables found: 3
📄 PDF tables found: 5 (if available)
🏆 Total high-quality tables: 8

🏆 Top quality tables:
   1. DOCX Table 1 from sample_specification.docx: 92.0% [7x4]
   2. PDF  Table 3 from specification_document.pdf: 100.0% [11x2]
```

## 🗂️ File Structure

```
project/
├── sample_specification.docx       # Primary DOCX specifications
├── specification_document.pdf      # Optional PDF specifications  
├── final_extraction.py            # Main extraction script (DOCX-first)
├── final_tables.sql               # Generated table DDL (5 tables)
├── final_views.sql                # Generated view DDL (4 views)
├── requirements.txt               # Full dependencies
├── requirements-minimal.txt       # Essential dependencies only
└── README.md                      # This documentation
```

## 🎯 Key Improvements

### **DOCX-First Architecture**
- **📝 Primary Focus**: Word documents for modern specification workflows
- **🛡️ Error Resilience**: Works even when PDF libraries unavailable
- **📊 Enhanced Quality**: Advanced DOCX table analysis and scoring
- **🔧 Flexible Installation**: Core functionality with minimal dependencies

### **Enhanced DDL Quality**
- **🔗 Document Lineage**: Track specification sources (DOCX/PDF)
- **⚡ Performance Optimization**: Smart indexes and constraints
- **🏗️ Production Structure**: Enterprise-grade table and view definitions
- **📋 Comprehensive Metadata**: Full document processing history

### **Business Intelligence**
- **📊 Quality Metrics**: Detailed completeness and consistency scoring
- **🔍 Cross-Format Analysis**: Unified ranking across document types
- **📈 Processing Analytics**: Document extraction statistics and insights
- **🎯 Source Attribution**: Clear tracking of specification origins

## ⚡ Performance Features

- **Smart Table Detection**: Automatically identifies high-quality tables
- **Parallel Processing**: Efficient handling of multiple documents
- **Memory Optimization**: Processes large documents without memory issues
- **Error Handling**: Robust error handling for various document formats

## 🔧 Customization

### Adding New Document Types
The architecture supports easy extension to additional formats:
1. Add extraction function (e.g., `extract_xlsx_tables()`)
2. Update `extract_best_tables()` to include new format
3. Modify DDL generation to track new source types

### Custom Table Structures
Modify the `create_final_ddl()` function to customize:
- Table schemas
- Business rules
- Constraints
- Indexes

## 📝 Notes

- **DOCX files work best** with clear table structure and consistent columns
- **PDF processing is optional** - requires additional system dependencies
- **Mixed content (DOCX + PDF)** provides the most comprehensive specifications
- **Quality scores help identify** the most reliable extracted data
- **Works offline** - no cloud dependencies or API keys required

## 🎉 Production Ready

The generated DDL files are ready for:
- ✅ **Database implementation** (MySQL, PostgreSQL, Oracle, SQL Server)
- ✅ **Code review and validation** 
- ✅ **Production deployment**
- ✅ **DOCX-first specification processing**
- ✅ **Enterprise data governance**
- ✅ **Cross-platform compatibility**
