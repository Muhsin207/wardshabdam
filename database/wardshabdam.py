import os
import sqlite3
from pathlib import Path
from werkzeug.security import generate_password_hash

BASE_DIR = Path(__file__).resolve().parent.parent

def get_database_path() -> Path:
    env_path = os.getenv("WARD_SHABDAM_DB_PATH")
    if env_path:
        db_path = Path(env_path).resolve()
    else:
        db_path = Path(__file__).resolve().with_name("wardshabdam.db")
    db_path.parent.mkdir(parents=True, exist_ok=True)
    return db_path

def get_connection() -> sqlite3.Connection:
    database_path = get_database_path()
    conn = sqlite3.connect(database_path)
    conn.row_factory = sqlite3.Row
    return conn

def add_column_if_missing(conn: sqlite3.Connection, table_name: str, column_name: str, column_sql: str):
    columns = conn.execute(f"PRAGMA table_info({table_name})").fetchall()
    if any(column[1] == column_name for column in columns):
        return
    conn.execute(f"ALTER TABLE {table_name} ADD COLUMN {column_name} {column_sql}")

def init_db(conn: sqlite3.Connection | None = None) -> None:
    close_after = False
    if conn is None:
        conn = get_connection()
        close_after = True

    cursor = conn.cursor()

    cursor.execute("""
    CREATE TABLE IF NOT EXISTS complaints (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        citizen_id INTEGER,
        tracking_id TEXT,
        name TEXT NOT NULL DEFAULT '',
        mobile TEXT NOT NULL DEFAULT '',
        ward TEXT NOT NULL DEFAULT '',
        category TEXT NOT NULL DEFAULT '',
        description TEXT NOT NULL DEFAULT '',
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
    add_column_if_missing(conn, "complaints", "created_at", "TIMESTAMP")
    conn.execute("UPDATE complaints SET created_at = CURRENT_TIMESTAMP WHERE created_at IS NULL")

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
    add_column_if_missing(conn, "citizens", "house_no", "TEXT DEFAULT ''")
    add_column_if_missing(conn, "citizens", "ration_card_no", "TEXT DEFAULT ''")

    # Family Members for household management
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS family_members (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        citizen_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        relationship TEXT NOT NULL,
        age INTEGER,
        gender TEXT,
        occupation TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
    """)

    # Real-time Complaint Lifecycle Timeline
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS complaint_timeline (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        complaint_id INTEGER NOT NULL,
        status TEXT NOT NULL,
        remarks TEXT NOT NULL DEFAULT '',
        updated_by TEXT NOT NULL DEFAULT '',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
    """)
    add_column_if_missing(conn, "complaints", "resolution_photo", "TEXT")

    # Emergency Directory Services
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS emergency_contacts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        service_name TEXT NOT NULL,
        contact_person TEXT,
        phone TEXT NOT NULL,
        category TEXT NOT NULL DEFAULT 'General',
        ward TEXT DEFAULT 'All'
    );
    """)

    # Grama Sabha Suggestions & Public Interaction
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS gramasabha_suggestions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        citizen_id INTEGER,
        citizen_name TEXT,
        ward TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        upvotes INTEGER DEFAULT 0,
        status TEXT DEFAULT 'Under Review',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
    """)

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
    ensure_initial_emergency_contacts(conn)
    if close_after:
        conn.close()

def ensure_initial_emergency_contacts(conn: sqlite3.Connection | None = None) -> None:
    close_after = False
    if conn is None:
        conn = get_connection()
        close_after = True

    cursor = conn.cursor()
    cursor.execute("SELECT COUNT(*) FROM emergency_contacts")
    if cursor.fetchone()[0] == 0:
        defaults = [
            ("പഞ്ചായത്ത് ഓഫീസ് (Panchayat Office)", "സെക്രട്ടറി / Secretary", "04924-232233", "Office", "All"),
            ("പോലീസ് സ്റ്റേഷൻ (Local Police)", "എസ്.ഐ / Sub-Inspector", "112 / 04924-222100", "Police", "All"),
            ("അഗ്നിശമന സേന (Fire Force)", "ഫയർ സ്റ്റേഷൻ / Fire Officer", "101 / 04924-222101", "Fire", "All"),
            ("ആംബുലൻസ് സർവീസ് (24x7 Ambulance)", "പഞ്ചായത്ത് ആംബുലൻസ്", "108 / 9847000108", "Health", "All"),
            ("കെ.എസ്.ഇ.ബി ഇലക്ട്രിസിറ്റി (KSEB)", "സെക്ഷൻ ഓഫീസ്", "1912 / 04924-233112", "Electricity", "All"),
            ("വാട്ടർ അതോറിറ്റി (Kerala Water Authority)", "പൈപ്പ് ലൈൻ സൂപ്പർവൈസർ", "1916 / 04924-231916", "Water", "All"),
            ("പ്രാഥമിക ആരോഗ്യ കേന്ദ്രം (PHC / Health Centre)", "മെഡിക്കൽ ഓഫീസർ", "04924-234500", "Health", "All"),
            ("കുടുംബശ്രീ ഹെൽപ്പ് ലൈൻ (Kudumbashree)", "സി.ഡി.എസ് ചെയർപേഴ്സൺ", "9495000001", "Social", "All")
        ]
        cursor.executemany(
            "INSERT INTO emergency_contacts (service_name, contact_person, phone, category, ward) VALUES (?, ?, ?, ?, ?)",
            defaults
        )
        conn.commit()

    if close_after:
        conn.close()

def ensure_initial_admin(conn: sqlite3.Connection | None = None) -> None:
    close_after = False
    if conn is None:
        conn = get_connection()
        close_after = True

    cursor = conn.cursor()
    cursor.execute("SELECT COUNT(*) FROM admins")
    count = cursor.fetchone()[0]

    if count == 0:
        username = os.getenv("WARD_SHABDAM_ADMIN_USERNAME", "admin")
        password = os.getenv("WARD_SHABDAM_ADMIN_PASSWORD", "Admin@1234")
        hashed_password = generate_password_hash(password)
        cursor.execute("INSERT INTO admins (username, password) VALUES (?, ?)", (username, hashed_password))
        conn.commit()
        print(f"[*] Initial admin created with username: '{username}'")

    if close_after:
        conn.close()
