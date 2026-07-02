import sqlite3

conn = sqlite3.connect("database/wardshabdam.db")
cursor = conn.cursor()

tables = [
    "citizens",
    "complaints",
    "notifications",
    "announcements",
    "programs",
    "gallery",
    "surveys",
    "survey_options",
    "survey_votes",
    "feedback"
]

for table in tables:
    try:
        cursor.execute(f"DELETE FROM {table}")
        print(f"✅ {table} cleared")
    except Exception:
        print(f"⚠️ {table} table not found")

# Reset auto-increment IDs
for table in tables:
    try:
        cursor.execute(
            "DELETE FROM sqlite_sequence WHERE name=?",
            (table,)
        )
    except Exception:
        pass

conn.commit()
conn.close()

print("\n🎉 Ward Shabdam has been reset successfully!")
print("The website is now clean and ready for public use.")