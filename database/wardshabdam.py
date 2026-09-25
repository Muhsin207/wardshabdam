import sqlite3
from pathlib import Path

def get_connection():
    database_path = Path(__file__).resolve().with_name("wardshabdam.db")
    conn = sqlite3.connect(database_path)
    conn.row_factory = sqlite3.Row
    return conn