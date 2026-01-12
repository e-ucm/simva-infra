import os
import sqlite3

# ---- Environment variables from docker-compose ----
SQL_SCRIPT_FOLDER = os.getenv("SQL_SCRIPT_FOLDER")
SQL_DB_FOLDER = os.getenv("SQL_DB_FOLDER")
SQL_DB_FILE = os.getenv("SQL_DB_FILE")

# ---- Connect to MySQL ----
sqlite_con = sqlite3.connect(f"{SQL_DB_FOLDER}/{SQL_DB_FILE}")
print("SQLite is available!")

cursor = sqlite_con.cursor()

with open(f"{SQL_SCRIPT_FOLDER}/01-schemas.sql", "r") as f:
    schema_sql = f.read()
    cursor.executescript(schema_sql)
    sqlite_con.commit()

with open(f"{SQL_SCRIPT_FOLDER}/02-views.sql", "r") as f:
    views_sql = f.read()
    cursor.executescript(views_sql)
    sqlite_con.commit()

print("Schemas and Views created!")
cursor.close()
sqlite_con.close()