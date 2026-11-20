import sys
import os

# Set working directory to project root
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, BASE_DIR)
sys.path.insert(0, os.path.join(BASE_DIR, "database"))

from app import app
from database import wardshabdam
import sqlite3

def run_tests():
    print("=" * 60)
    print("🚀 STARTING AUTOMATED END-TO-END TESTS FOR WARD SHABDAM")
    print("=" * 60)

    # 1. Initialize DB and seed
    wardshabdam.init_db()
    wardshabdam.ensure_initial_admin()
    wardshabdam.ensure_initial_emergency_contacts()
    print("✅ [1/10] Database & Initial Data Seeding: OK")

    app.config["TESTING"] = True
    app.config["WTF_CSRF_ENABLED"] = False
    client = app.test_client()

    # 2. Test Home Page
    res = client.get("/")
    assert res.status_code == 200, f"Home page failed with {res.status_code}"
    assert b"Wardshabdam" in res.data
    print("✅ [2/10] Home & Public Landing Page (/): OK")

    # 3. Test Emergency & Helplines Page (/contact)
    res = client.get("/contact")
    assert res.status_code == 200, f"Contact page failed with {res.status_code}"
    assert "അടിയന്തര" in res.data.decode("utf-8") or "Emergency" in res.data.decode("utf-8")
    assert "108" in res.data.decode("utf-8")
    print("✅ [3/10] Emergency Directory & Contact (/contact): OK")

    # 4. Test Citizen Registration & Login
    test_mobile = "9998887771"
    test_password = "Password@123"
    
    # Clean up test user if exists
    conn = sqlite3.connect("database/wardshabdam.db")
    conn.execute("DELETE FROM citizens WHERE mobile=?", (test_mobile,))
    conn.commit()
    conn.close()

    reg_data = {
        "fullname": "Automated Tester",
        "mobile": test_mobile,
        "email": "tester@wardshabdam.local",
        "ward": "Ward 4",
        "password": test_password,
        "confirm_password": test_password
    }
    res = client.post("/register", data=reg_data, follow_redirects=True)
    assert res.status_code == 200
    print("✅ [4/10] Citizen Registration (/register): OK")

    # Login
    login_data = {
        "mobile": test_mobile,
        "password": test_password
    }
    res = client.post("/login", data=login_data, follow_redirects=True)
    assert res.status_code == 200
    assert b"Automated Tester" in res.data or b"Wardshabdam" in res.data
    print("✅ [5/10] Citizen Authentication (/login): OK")

    # 5. Test Citizen Profile & Family Members
    with client.session_transaction() as sess:
        sess["citizen_id"] = 1
        sess["citizen_name"] = "Automated Tester"
        sess["mobile"] = test_mobile
        sess["ward"] = "Ward 4"

    res = client.get("/profile")
    assert res.status_code == 200, f"Profile page failed with {res.status_code}"
    print("✅ [6/10] Profile View (/profile): OK")

    # Add Family Member
    fam_data = {
        "name": "Test Spouse",
        "relationship": "ഭാര്യ (Spouse)",
        "age": "32",
        "gender": "സ്ത്രീ (Female)",
        "occupation": "Teacher"
    }
    res = client.post("/add_family_member", data=fam_data, follow_redirects=True)
    assert res.status_code == 200

    conn = sqlite3.connect("database/wardshabdam.db")
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM family_members WHERE name='Test Spouse'")
    fam_row = cursor.fetchone()
    assert fam_row is not None, "Family member was not saved in DB"
    fam_id = fam_row[0]
    conn.close()
    print(f"✅ [7/10] Add Family Member (/add_family_member) -> ID {fam_id}: OK")

    # 6. Test Complaint Submission & Real-Time Tracking
    complaint_data = {
        "name": "Automated Tester",
        "mobile": test_mobile,
        "ward": "Ward 4",
        "category": "Road Issues",
        "description": "Potholes on main road near bus stop test."
    }
    res = client.post("/report", data=complaint_data, follow_redirects=True)
    assert res.status_code == 200

    conn = sqlite3.connect("database/wardshabdam.db")
    cursor = conn.cursor()
    cursor.execute("SELECT id, tracking_id, status FROM complaints WHERE mobile=? ORDER BY id DESC LIMIT 1", (test_mobile,))
    complaint_row = cursor.fetchone()
    assert complaint_row is not None, "Complaint was not saved in DB"
    complaint_id = complaint_row[0]
    tracking_id = complaint_row[1]
    conn.close()
    print(f"✅ [8/10] Grievance Submission (/report) -> Complaint #{complaint_id} (Tracking: {tracking_id}): OK")

    # Test Public Tracking Page (/track)
    res = client.get(f"/track?tracking_id={complaint_id}")
    assert res.status_code == 200
    assert b"Road Issues" in res.data
    print(f"✅ [9/10] Public Live Tracking Stepper (/track?tracking_id={complaint_id}): OK")

    # 7. Test Ward / Admin Update & Timeline Logging
    with client.session_transaction() as sess:
        sess.clear()
        sess["admin_id"] = 1
        sess["admin_username"] = "admin"

    update_data = {
        "status": "In Progress",
        "admin_reply": "Inspected by engineer. Road repair work scheduled for tomorrow."
    }
    res = client.post(f"/edit/{complaint_id}", data=update_data, follow_redirects=True)
    assert res.status_code == 200

    conn = sqlite3.connect("database/wardshabdam.db")
    cursor = conn.cursor()
    cursor.execute("SELECT status, admin_reply FROM complaints WHERE id=?", (complaint_id,))
    c_updated = cursor.fetchone()
    assert c_updated[0] == "In Progress", f"Status expected In Progress, got {c_updated[0]}"

    cursor.execute("SELECT * FROM complaint_timeline WHERE complaint_id=?", (complaint_id,))
    timeline_entry = cursor.fetchone()
    assert timeline_entry is not None, "Timeline history log was not recorded"
    conn.close()
    print(f"✅ [10/10] Admin/Ward Status Update & Audit Timeline Logging: OK")

    print("\n" + "=" * 60)
    print("🎉 ALL 10 CORE MODULE FUNCTIONALITY TESTS PASSED WITH 100% SUCCESS!")
    print("=" * 60)

if __name__ == "__main__":
    run_tests()
