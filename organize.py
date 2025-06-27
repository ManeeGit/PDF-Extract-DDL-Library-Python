import os
import re
import pandas as pd
from docx import Document

# ─── CONFIG ────────────────────────────────────────────────
SOURCE_DIR = r"C:\Users\K149072\Gen AI POC"   # folder containing your .docx
OUTPUT_DIR = "ddl_output"                     # where per-table SQL files will go
# ──────────────────────────────────────────────────────────

def clean_column_name(col):
    c = re.sub(r'\s+', '_', str(col).strip())
    c = re.sub(r'[^\w]', '', c)
    c = c.upper()
    if c and c[0].isdigit():
        c = "C_" + c
    return c or "COL"

def infer_sql_type(series: pd.Series) -> str:
    import pandas.api.types as ptypes
    if ptypes.is_integer_dtype(series):
        return "INTEGER"
    if ptypes.is_float_dtype(series):
        return "DECIMAL(18,2)"
    if ptypes.is_bool_dtype(series):
        return "BOOLEAN"
    if ptypes.is_datetime64_any_dtype(series):
        return "TIMESTAMP"
    max_len = series.astype(str).str.len().max()
    if max_len <= 50:
        return "VARCHAR(50)"
    if max_len <= 255:
        return "VARCHAR(255)"
    return "TEXT"

def extract_docx_tables_from_file(docx_path):
    """Return list of (table_index, DataFrame) for each table in docx_path."""
    doc = Document(docx_path)
    extracted = []
    for idx, tbl in enumerate(doc.tables, start=1):
        rows = []
        maxc = max(len(r.cells) for r in tbl.rows)
        for row in tbl.rows:
            cells = [re.sub(r'\s+', ' ', c.text.strip()) for c in row.cells]
            cells += [""] * (maxc - len(cells))
            rows.append(cells)
        if len(rows) < 2:
            continue
        df = pd.DataFrame(rows[1:], columns=rows[0])
        extracted.append((idx, df))
    return extracted

def write_per_table_ddl(docx_tables):
    """For each (file → tables), write one .sql per table into OUTPUT_DIR."""
    os.makedirs(OUTPUT_DIR, exist_ok=True)

    for filepath, tables in docx_tables.items():
        base = os.path.splitext(os.path.basename(filepath))[0].upper()
        subfolder = os.path.join(OUTPUT_DIR, base)
        os.makedirs(subfolder, exist_ok=True)

        for idx, df in tables:
            # promote header if it looks like text headers
            if any(str(x).isalpha() for x in df.columns):
                df.columns = df.columns
            df.columns = [clean_column_name(c) for c in df.columns]
            df = df.dropna(how="all", axis=1)
            if df.shape[1] == 0:
                continue

            tblname = f"{base}_TABLE_{idx}"
            filename = os.path.join(subfolder, f"{tblname}.sql")
            with open(filename, "w", encoding="utf-8") as f:
                f.write(f"-- DDL for {os.path.basename(filepath)}, table #{idx}\n")
                f.write(f"CREATE TABLE {tblname} (\n")
                col_ddls = []
                for col in df.columns:
                    sql_t = infer_sql_type(df[col])
                    col_ddls.append(f"    {col} {sql_t}")
                f.write(",\n".join(col_ddls))
                f.write("\n);\n")
            print(f"→ Wrote {filename}")

def main():
    # gather .docx files
    files = [
        os.path.join(SOURCE_DIR, f)
        for f in os.listdir(SOURCE_DIR)
        if f.lower().endswith(".docx") and not f.startswith("~$")
    ]

    # extract tables
    docx_tables = {}
    for f in files:
        tables = extract_docx_tables_from_file(f)
        if tables:
            docx_tables[f] = tables

    # write DDL per table
    write_per_table_ddl(docx_tables)
    print("✅ All tables written under", OUTPUT_DIR)

if __name__ == "__main__":
    main()
