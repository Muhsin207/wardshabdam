import sqlite3

conn = sqlite3.connect("database/wardshabdam.db")
conn.row_factory = sqlite3.Row

cursor = conn.cursor()

cursor.execute("SELECT id, fullname, mobile FROM citizens")

rows = cursor.fetchall()

print("Citizens:\n")

for row in rows:
    print(dict(row))

conn.close()