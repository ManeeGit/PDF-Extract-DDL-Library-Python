import os
import re
import pandas as pd
from docx import Document

# ─── configure here ────────────────────────────────────────
# Folder containing your .docx specs, or leave as "." for cwd
SOURCE_DIR = r"C:\path\to\your\docx\files"
# Or point to a single file:
# SOURCE_FILE = r"C:\path\to\your\specification.docx"
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
    # fallback to text
    max_len = series.astype(str).str.len().max()
    if max_len <= 50:
        return "VARCHAR(50)"
    if max_len <= 255:
        return "VARCHAR(255)"
    return "TEXT"

def extract_docx_tables_from_file(docx_path):
    """Return a list of (table_index, DataFrame) for every table in the .docx."""
    doc = Document(docx_path)
    extracted = []
    for idx, tbl in enumerate(doc.tables, start=1):
        # build raw rows
        data = []
        maxc = max(len(r.cells) for r in tbl.rows)
        for row in tbl.rows:
            cells = [re.sub(r'\s+', ' ', c.text.strip()) for c in row.cells]
            cells += [""] * (maxc - len(cells))
            data.append(cells)
        # skip tiny tables
        if len(data) < 2:
            continue
        # first row = header?
        df = pd.DataFrame(data[1:], columns=data[0])
        extracted.append((idx, df))
    return extracted

def create_final_ddl(docx_tables):
    with open("final_ddl.sql", "w") as out:
        for fname, tables in docx_tables.items():
            base = os.path.splitext(os.path.basename(fname))[0].upper()
            for idx, df in tables:
                # promote header if first row looks textual
                if any(str(x).isalpha() for x in df.columns):
                    df.columns = df.columns
                # clean and drop empty cols
                df.columns = [clean_column_name(col) for col in df.columns]
                df = df.dropna(how="all", axis=1)
                if df.shape[1] == 0:
                    continue

                tblname = f"{base}_TABLE_{idx}"
                out.write(f"-- DDL for {fname}, table #{idx}\n")
                out.write(f"CREATE TABLE {tblname} (\n")
                cols = []
                for col in df.columns:
                    t = infer_sql_type(df[col])
                    cols.append(f"    {col} {t}")
                out.write(",\n".join(cols))
                out.write("\n);\n\n")
    print("✅ final_ddl.sql written.")

def main():
    # discover files
    files = []
    # 1) single-file mode?
    # if 'SOURCE_FILE' in globals():
    #     files = [SOURCE_FILE]
    # else:
    for f in os.listdir(SOURCE_DIR):
        if f.lower().endswith(".docx") and not f.startswith("~$"):
            files.append(os.path.join(SOURCE_DIR, f))

    # extract tables
    docx_tables = {}
    for f in files:
        tables = extract_docx_tables_from_file(f)
        if tables:
            docx_tables[f] = tables

    # generate DDL
    create_final_ddl(docx_tables)

if __name__ == "__main__":
    main()
