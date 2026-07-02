import sqlite3

conn = sqlite3.connect("database/wardshabdam.db")
cursor = conn.cursor()

cursor.execute("PRAGMA table_info(complaints)")

for column in cursor.fetchall():
    print(column)

conn.close()