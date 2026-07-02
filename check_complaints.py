import sqlite3

conn = sqlite3.connect("database/wardshabdam.db")
conn.row_factory = sqlite3.Row

cursor = conn.cursor()

cursor.execute("SELECT id, name, mobile, category FROM complaints")

rows = cursor.fetchall()

print("Complaints in database:\n")

for row in rows:
    print(dict(row))

conn.close()