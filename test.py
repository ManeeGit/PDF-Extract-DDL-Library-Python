import os
import re
import pandas as pd

# --- adjust these imports to your environment ---
from docx import Document
import camelot.io     # pip install camelot-py[cv]
# optional: from tabula import read_pdf as tabula_read_pdf

# -------------------------------------------------------------------
def clean_column_name(col):
    """Normalize a header string into a valid SQL identifier."""
    c = re.sub(r'\s+', '_', col.strip())
    c = re.sub(r'[^\w]', '', c)
    c = c.upper()
    if c and c[0].isdigit():
        c = "C_" + c
    return c or "COL"

def infer_sql_type(series: pd.Series) -> str:
    """Map a pandas series dtype to a simple SQL type."""
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

# -------------------------------------------------------------------
def extract_pdf_tables():
    """Return a list of ( 'pdf', idx, wrapper, accuracy, filename )."""
    results = []
    for fname in os.listdir('.'):
        if not fname.lower().endswith('.pdf'):
            continue
        tables = camelot.io.read_pdf(fname, pages="all", flavor="lattice", strip_text='\n', split_text=True)
        for i, table in enumerate(tables, start=1):
            # wrap the camelot.Table so we have a consistent .df
            wrapper = type("W", (), {"df": table.df, "source_file": fname, "table_index": i})
            results.append(("pdf", i, wrapper, table.accuracy, fname))
    return results

def extract_docx_tables():
    """Return a list of ( 'docx', idx, wrapper, quality, filename )."""
    results = []
    for fname in os.listdir('.'):
        if not fname.lower().endswith('.docx') or fname.startswith('~'):
            continue
        doc = Document(fname)
        for i, tbl in enumerate(doc.tables, start=1):
            # build DataFrame from rows
            data = []
            maxc = max(len(r.cells) for r in tbl.rows)
            for row in tbl.rows:
                cells = [re.sub(r'\s+', ' ', c.text.strip()) for c in row.cells]
                cells += [""] * (maxc - len(cells))
                data.append(cells)
            if len(data) < 2:
                continue
            df = pd.DataFrame(data[1:], columns=data[0])
            # crude quality: proportion filled
            total = df.size
            filled = df.astype(bool).sum().sum()
            quality = filled / total
            wrapper = type("W", (), {"df": df, "source_file": fname, "table_index": i})
            results.append(("docx", i, wrapper, quality, fname))
    return results

def extract_best_tables():
    all_tbls = extract_pdf_tables() + extract_docx_tables()
    # sort by quality_score desc
    return sorted(all_tbls, key=lambda x: x[3], reverse=True)

# -------------------------------------------------------------------
def create_final_ddl(tables):
    """Generate a final_ddl.sql containing one CREATE TABLE per extracted table."""
    with open("final_ddl.sql", "w") as out:
        for source_type, idx, wrapper, score, fname in tables:
            df = wrapper.df.copy()
            # if first row looks like headers, promote it
            if any(cell.isalpha() for cell in df.iloc[0].astype(str)):
                df.columns = df.iloc[0]
                df = df.drop(df.index[0]).reset_index(drop=True)
            # clean column names
            df.columns = [ clean_column_name(col) for col in df.columns ]
            # drop empty cols
            df = df.dropna(how="all", axis=1)
            if df.shape[1] < 1:
                continue

            tblname = f"{os.path.splitext(fname)[0]}_{source_type}_{idx}"
            tblname = tblname.upper().replace(".", "_").replace(" ", "_")

            out.write(f"-- DDL for table #{idx} from {fname} ({source_type}, quality={score:.2f})\n")
            out.write(f"CREATE TABLE {tblname} (\n")
            cols_ddl = []
            for col in df.columns:
                sql_type = infer_sql_type(df[col])
                cols_ddl.append(f"    {col} {sql_type}")
            out.write(",\n".join(cols_ddl))
            out.write("\n);\n\n")

    print(f"✅ Written final_ddl.sql with {len(tables)} tables.")

# -------------------------------------------------------------------
if __name__ == "__main__":
    best = extract_best_tables()
    create_final_ddl(best)
