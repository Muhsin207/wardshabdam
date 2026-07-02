import sqlite3

conn = sqlite3.connect("database/wardshabdam.db")
cursor = conn.cursor()

try:
    cursor.execute("""
    ALTER TABLE complaints
    ADD COLUMN admin_reply TEXT
    """)
    print("Column added successfully!")

except Exception as e:
    print(e)

conn.commit()
conn.close()