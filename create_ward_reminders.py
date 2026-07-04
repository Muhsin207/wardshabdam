import sqlite3

conn = sqlite3.connect("database/wardshabdam.db")
cursor = conn.cursor()

cursor.execute("""
CREATE TABLE IF NOT EXISTS ward_reminders (

    id INTEGER PRIMARY KEY AUTOINCREMENT,

    ward_member_id INTEGER NOT NULL,

    reminder TEXT NOT NULL,

    reminder_date DATE NOT NULL,

    completed INTEGER DEFAULT 0,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP

)
""")

conn.commit()
conn.close()

print("✅ ward_reminders table created successfully!")