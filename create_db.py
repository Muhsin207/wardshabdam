import os
import sys

base_dir = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, base_dir)
sys.path.insert(0, os.path.join(base_dir, "database"))

from database import wardshabdam

if __name__ == "__main__":
    print("[*] Initializing Ward Shabdam Database...")
    wardshabdam.init_db()
    wardshabdam.ensure_initial_admin()
    print("[+] Database Initialized Successfully at:", wardshabdam.get_database_path())
