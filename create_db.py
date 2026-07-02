import sqlite3

conn = sqlite3.connect("database/wardshabdam.db")

cursor = conn.cursor()

# Complaints Table
cursor.execute("""
CREATE TABLE IF NOT EXISTS complaints (

    id INTEGER PRIMARY KEY AUTOINCREMENT,
               citizen_id INTEGER

    name TEXT NOT NULL,

    mobile TEXT NOT NULL,

    ward TEXT NOT NULL,

    category TEXT NOT NULL,

    description TEXT NOT NULL,

    photo TEXT,

    status TEXT DEFAULT 'Pending',

    admin_reply TEXT

);
""")

# Announcements Table
cursor.execute("""
CREATE TABLE IF NOT EXISTS announcements (

    id INTEGER PRIMARY KEY AUTOINCREMENT,

    title TEXT NOT NULL,

    description TEXT NOT NULL,

    photo TEXT,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP

);
""")

# Citizens Table
cursor.execute("""
CREATE TABLE IF NOT EXISTS citizens (

    id INTEGER PRIMARY KEY AUTOINCREMENT,

    fullname TEXT NOT NULL,

    mobile TEXT UNIQUE NOT NULL,

    email TEXT,

    password TEXT NOT NULL

);
""")

cursor.execute("""
CREATE TABLE IF NOT EXISTS admins (

    id INTEGER PRIMARY KEY AUTOINCREMENT,

    username TEXT UNIQUE NOT NULL,

    password TEXT NOT NULL

)
""")
cursor.execute("""
CREATE TABLE IF NOT EXISTS programs (

    id INTEGER PRIMARY KEY AUTOINCREMENT,

    title TEXT NOT NULL,

    description TEXT NOT NULL,

    photo TEXT,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP

)
""")

conn.commit()
conn.close()

print("Database Created Successfully!")