# PDF and DOCX Table Extraction to DDL Generator

This project extracts tables from **PDF and DOCX specification documents** and generates clean, production-ready SQL DDL (Data Definition Language) files for tables and views.

## 🚀 Features

### Multi-Format Support
- **PDF Processing**: Uses Camelot library for high-accuracy table extraction
- **DOCX Processing**: Uses python-docx library for Word document table extraction
- **Quality Scoring**: Automatically ranks tables by extraction quality
- **Cross-Format Analysis**: Combines tables from both PDF and DOCX sources

### Enhanced DDL Generation
- **Production-Ready Tables**: Clean, structured table definitions with proper constraints
- **Business Views**: Meaningful views with business logic and filtering
- **Document Tracking**: Metadata tables to track specification sources
- **Performance Indexes**: Optimized indexes for database performance
- **Specification Lineage**: Track which tables came from which document types

## 📋 Requirements

### Python Packages
```bash
pip install camelot-py[cv] tabula-py ddlgenerator pandas python-docx
```

### System Dependencies
- **Ghostscript**: Required for PDF processing
- **Java**: Required for tabula-py
- **OpenCV**: Included with camelot-py[cv]

## 🔧 Usage

### Basic Usage
```bash
python final_extraction.py
```

### Supported File Types
- **PDF files**: `*.pdf` (automatically detected)
- **DOCX files**: `*.docx` (automatically scanned in current directory)

### Input Files
Place your specification documents in the same directory:
- `specification_document.pdf` (primary PDF)
- Any `*.docx` files (automatically detected)

### Output Files
- `final_tables.sql` - Production-ready table DDL
- `final_views.sql` - Business logic views DDL

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
🚀 Generating Final Clean DDL from PDF and DOCX Files
============================================================
🔍 Extracting tables from PDF and DOCX files with focus on quality...
🔍 Extracting tables from PDF: specification_document.pdf
Found 5 tables with Camelot Lattice
🔍 Extracting tables from DOCX: business_requirements.docx
Found 3 tables in business_requirements.docx

📊 Total tables found: 8
🏆 Top quality tables:
  1. PDF Table 3 from specification_document.pdf: 100.0%
  2. DOCX Table 1 from business_requirements.docx: 95.2%
  3. PDF Table 4 from specification_document.pdf: 100.0%
```

## 🗂️ File Structure

```
project/
├── specification_document.pdf      # Primary PDF specification
├── business_requirements.docx      # Additional DOCX specifications  
├── final_extraction.py            # Main extraction script
├── final_tables.sql               # Generated table DDL
├── final_views.sql                # Generated view DDL
└── README.md                      # This documentation
```

## 🎯 Key Improvements

### Multi-Format Processing
- Unified extraction pipeline for PDF and DOCX
- Quality scoring across different formats
- Document metadata tracking

### Enhanced DDL Quality
- Proper foreign key relationships
- Check constraints and data validation
- Performance-optimized indexes
- Clear documentation and comments

### Business Intelligence
- Document lineage tracking
- Cross-format analysis views
- Quality metrics and reporting
- Specification source attribution

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

- PDF extraction requires proper table structure (gridlines work best)
- DOCX tables should have clear row/column structure
- Mixed content (PDF + DOCX) provides the most comprehensive specifications
- Quality scores help identify the most reliable extracted data

## 🎉 Production Ready

The generated DDL files are ready for:
- ✅ Database implementation (MySQL, PostgreSQL, Oracle, etc.)
- ✅ Code review and validation
- ✅ Production deployment
- ✅ Multi-source specification processing
- ✅ Enterprise data governance
