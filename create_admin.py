import os
import sys
from werkzeug.security import generate_password_hash

base_dir = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(base_dir, "database"))
from database import wardshabdam

username = os.getenv("WARD_SHABDAM_ADMIN_USERNAME", "admin")
password = os.getenv("WARD_SHABDAM_ADMIN_PASSWORD", "Admin@1234")

conn = wardshabdam.get_connection()
cursor = conn.cursor()

hashed_password = generate_password_hash(password)

cursor.execute("SELECT id FROM admins WHERE username = ?", (username,))
existing = cursor.fetchone()

if existing:
    cursor.execute("UPDATE admins SET password = ? WHERE username = ?", (hashed_password, username))
    print(f"[+] Admin '{username}' updated successfully.")
else:
    cursor.execute("INSERT INTO admins (username, password) VALUES (?, ?)", (username, hashed_password))
    print(f"[+] Admin '{username}' created successfully.")

conn.commit()
conn.close()
