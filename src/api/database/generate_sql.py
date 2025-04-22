import sqlite3

# Path to the SQL file
sql_file_path = "organization_entities.sql"

print(f"Reading SQL commands from {sql_file_path}")

# Create a new file-based SQLite database
conn = sqlite3.connect("organizations.db")
cursor = conn.cursor()

# Read and execute SQL commands from the file
with open(sql_file_path, "r") as file:
    sql_script = file.read()

cursor.executescript(sql_script)
conn.commit()

# Query the database to confirm insertion
cursor.execute("SELECT * FROM organizations")
rows = cursor.fetchall()

# Display the results
for row in rows:
    print(row)

# Clean up
cursor.close()
conn.close()
