import sqlite3

conn = sqlite3.connect("database/wardshabdam.db")
cursor = conn.cursor()

cursor.execute("""
CREATE TABLE IF NOT EXISTS ward_notes (

    id INTEGER PRIMARY KEY AUTOINCREMENT,

    ward_member_id INTEGER NOT NULL,

    title TEXT,

    note TEXT NOT NULL,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP

)
""")

conn.commit()
conn.close()

print("✅ ward_notes table created successfully!")