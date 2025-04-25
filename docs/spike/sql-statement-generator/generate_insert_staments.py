import csv

input_file = '/workspaces/ai-agent/docs/spike/sql-statement-generator/fortune-500-companies'
output_file = '/workspaces/ai-agent/docs/spike/sql-statement-generator/fortune500_inserts.sql'

def clean_currency(value):
    return value.replace('$', '').replace(',', '').strip()

def escape_quotes(value):
    return value.replace("'", "''")

with open(input_file, 'r', encoding='utf-8') as infile, open(output_file, 'w', encoding='utf-8') as outfile:
    reader = csv.reader(infile, delimiter='\t')
    next(reader)  # Skip header row

    outfile.write("INSERT INTO organizations (name, ticker, industry, headquarters, website, ceo, employees) VALUES\n")

    rows = []
    for row in reader:
        if len(row) < 13:
            continue  # Skip incomplete rows

        name = escape_quotes(row[1])
        ticker = row[11] if row[11] else 'NULL'
        ticker = f"'{ticker}'" if ticker != 'NULL' else 'NULL'
        industry = escape_quotes(row[2])
        headquarters = escape_quotes(f"{row[3]}, {row[4]}")
        website = f"https://{row[6]}" if not row[6].startswith('http') else row[6]
        employees = row[7] if row[7] else 'NULL'
        ceo = escape_quotes(row[12]) if row[12] else 'NULL'
        rows.append(f"('{name}', {ticker}, '{industry}', '{headquarters}', '{website}', '{employees}', '{ceo}')")

    outfile.write(",\n".join(rows) + ";\n")

print(f"SQL insert statements generated successfully in {output_file}")