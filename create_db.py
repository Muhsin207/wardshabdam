import sqlite3


def add_column_if_missing(conn, table_name, column_name, column_sql):
    columns = conn.execute(f"PRAGMA table_info({table_name})").fetchall()
    if any(column[1] == column_name for column in columns):
        return
    conn.execute(f"ALTER TABLE {table_name} ADD COLUMN {column_name} {column_sql}")


conn = sqlite3.connect("database/wardshabdam.db")
cursor = conn.cursor()

cursor.execute("""
CREATE TABLE IF NOT EXISTS complaints (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    citizen_id INTEGER,
    tracking_id TEXT,
    name TEXT NOT NULL,
    mobile TEXT NOT NULL,
    ward TEXT NOT NULL,
    category TEXT NOT NULL,
    description TEXT NOT NULL,
    photo TEXT,
    status TEXT DEFAULT 'Pending',
    admin_reply TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
""")

add_column_if_missing(conn, "complaints", "citizen_id", "INTEGER")
add_column_if_missing(conn, "complaints", "tracking_id", "TEXT")
add_column_if_missing(conn, "complaints", "name", "TEXT NOT NULL DEFAULT ''")
add_column_if_missing(conn, "complaints", "mobile", "TEXT NOT NULL DEFAULT ''")
add_column_if_missing(conn, "complaints", "ward", "TEXT NOT NULL DEFAULT ''")
add_column_if_missing(conn, "complaints", "category", "TEXT NOT NULL DEFAULT ''")
add_column_if_missing(conn, "complaints", "description", "TEXT NOT NULL DEFAULT ''")
add_column_if_missing(conn, "complaints", "photo", "TEXT")
add_column_if_missing(conn, "complaints", "status", "TEXT DEFAULT 'Pending'")
add_column_if_missing(conn, "complaints", "admin_reply", "TEXT")
add_column_if_missing(conn, "complaints", "created_at", "TIMESTAMP DEFAULT CURRENT_TIMESTAMP")

cursor.execute("""
CREATE TABLE IF NOT EXISTS announcements (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    photo TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
""")

cursor.execute("""
CREATE TABLE IF NOT EXISTS citizens (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    fullname TEXT NOT NULL,
    mobile TEXT UNIQUE NOT NULL,
    email TEXT,
    password TEXT NOT NULL,
    ward TEXT
);
""")

add_column_if_missing(conn, "citizens", "fullname", "TEXT NOT NULL DEFAULT ''")
add_column_if_missing(conn, "citizens", "mobile", "TEXT UNIQUE NOT NULL DEFAULT ''")
add_column_if_missing(conn, "citizens", "email", "TEXT")
add_column_if_missing(conn, "citizens", "password", "TEXT NOT NULL DEFAULT ''")
add_column_if_missing(conn, "citizens", "ward", "TEXT")

cursor.execute("""
CREATE TABLE IF NOT EXISTS admins (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    username TEXT UNIQUE NOT NULL,
    password TEXT NOT NULL
);
""")

cursor.execute("""
CREATE TABLE IF NOT EXISTS programs (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    photo TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
""")

cursor.execute("""
CREATE TABLE IF NOT EXISTS ward_members (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    ward_no TEXT NOT NULL,
    name TEXT NOT NULL,
    designation TEXT,
    phone TEXT,
    email TEXT,
    photo TEXT,
    username TEXT UNIQUE,
    password TEXT
);
""")

add_column_if_missing(conn, "ward_members", "username", "TEXT UNIQUE")
add_column_if_missing(conn, "ward_members", "password", "TEXT")

cursor.execute("""
CREATE TABLE IF NOT EXISTS notifications (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    citizen_id INTEGER NOT NULL,
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_read INTEGER DEFAULT 0
);
""")

cursor.execute("""
CREATE TABLE IF NOT EXISTS surveys (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    question TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
""")

cursor.execute("""
CREATE TABLE IF NOT EXISTS survey_options (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    survey_id INTEGER NOT NULL,
    option_text TEXT NOT NULL,
    votes INTEGER DEFAULT 0
);
""")

cursor.execute("""
CREATE TABLE IF NOT EXISTS survey_votes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    survey_id INTEGER NOT NULL,
    citizen_id INTEGER NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(survey_id, citizen_id)
);
""")

cursor.execute("""
CREATE TABLE IF NOT EXISTS password_reset_codes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    citizen_id INTEGER NOT NULL,
    code_hash TEXT NOT NULL,
    expires_at TIMESTAMP NOT NULL,
    used INTEGER DEFAULT 0
);
""")

cursor.execute("""
CREATE TABLE IF NOT EXISTS feedback (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    complaint_id INTEGER,
    citizen_id INTEGER,
    rating INTEGER,
    comment TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
""")

cursor.execute("""
CREATE TABLE IF NOT EXISTS ward_notes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    ward_member_id INTEGER NOT NULL,
    title TEXT,
    note TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
""")

cursor.execute("""
CREATE TABLE IF NOT EXISTS ward_reminders (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    ward_member_id INTEGER NOT NULL,
    reminder TEXT NOT NULL,
    reminder_date DATE NOT NULL,
    completed INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
""")

conn.commit()
conn.close()

print("Database Created Successfully!")