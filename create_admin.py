import sqlite3
from werkzeug.security import generate_password_hash

conn = sqlite3.connect("database/wardshabdam.db")
cursor = conn.cursor()

username = "mc1011"
password = "mm1011"

hashed_password = generate_password_hash(password)

cursor.execute("""
INSERT INTO admins (username, password)
VALUES (?, ?)
""", (username, hashed_password))

conn.commit()
conn.close()

print("Admin Created Successfully!")