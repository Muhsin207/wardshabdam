import sqlite3

conn = sqlite3.connect("database/wardshabdam.db")
cursor = conn.cursor()

try:
    cursor.execute("""
        ALTER TABLE complaints
        ADD COLUMN tracking_id TEXT
    """)

    conn.commit()
    print("✅ tracking_id column added successfully.")

except Exception as e:
    print("Error:", e)

conn.close()