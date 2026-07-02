from flask_mail import Mail, Message



from werkzeug.security import generate_password_hash, check_password_hash
from tabnanny import check


from flask import Flask, render_template, request, redirect, session, flash, send_file
import sqlite3
import os

from reportlab.platypus import SimpleDocTemplate, Table, TableStyle, Paragraph
from reportlab.lib import colors
from reportlab.lib.styles import getSampleStyleSheet
from werkzeug.utils import secure_filename

app = Flask(__name__)
app.config["UPLOAD_FOLDER"] = "static/uploads"
app.config["DOCUMENT_FOLDER"] = "static/documents"
# ==========================
# Mail Configuration
# ==========================

app.config["MAIL_SERVER"] = "smtp.gmail.com"
app.config["MAIL_PORT"] = 587
app.config["MAIL_USE_TLS"] = True
app.config["MAIL_USERNAME"] = "wardshabdam@gmail.com"
app.config["MAIL_PASSWORD"] = "qaabaweousmmsrck"

mail = Mail(app)
ADMIN_EMAIL = "wardshabdam@gmail.com"

print("App file:", app.root_path)
print("Running app.py")
print("Document folder:", app.config.get("DOCUMENT_FOLDER"))
print("Templates folder:", app.template_folder)
app.secret_key = "wardshabdam2026"
def admin_required():

    if "admin_id" not in session:
        return redirect("/admin_login")

    return None
UPLOAD_FOLDER = "static/uploads"
@app.route("/admin_logout")
def admin_logout():

    session.pop("admin_id", None)
    session.pop("admin_username", None)

    return redirect("/admin_login")
@app.route("/")
def home():

    conn = sqlite3.connect("database/wardshabdam.db")
    conn.row_factory = sqlite3.Row
    cursor = conn.cursor()

    # Announcements
    cursor.execute("""
        SELECT *
        FROM announcements
        ORDER BY id DESC
    """)
    announcements = cursor.fetchall()

    # Complaint Statistics
    cursor.execute("SELECT COUNT(*) FROM complaints")
    total = cursor.fetchone()[0]

    cursor.execute("SELECT COUNT(*) FROM complaints WHERE status='Pending'")
    pending = cursor.fetchone()[0]

    cursor.execute("SELECT COUNT(*) FROM complaints WHERE status='In Progress'")
    progress = cursor.fetchone()[0]

    cursor.execute("SELECT COUNT(*) FROM complaints WHERE status='Resolved'")
    resolved = cursor.fetchone()[0]

    # Ward Members
    cursor.execute("""
        SELECT *
        FROM ward_members
        ORDER BY ward_no ASC
    """)
    ward_members = cursor.fetchall()

    conn.close()

    return render_template(
        "home.html",
        announcements=announcements,
        total=total,
        pending=pending,
        progress=progress,
        resolved=resolved,
        ward_members=ward_members
    )
@app.route("/report", methods=["GET", "POST"])
def report():

    if "citizen_id" not in session:
        return redirect("/login")

    if request.method == "POST":

        name = request.form["name"]
        mobile = request.form["mobile"]
        ward = request.form["ward"]
        category = request.form["category"]
        description = request.form["description"]
        photo = request.files["photo"]

        filename = ""

        if photo and photo.filename != "":
            filename = secure_filename(photo.filename)
            photo.save(
                os.path.join(
                    app.config["UPLOAD_FOLDER"],
                    filename
                )
            )

        conn = sqlite3.connect("database/wardshabdam.db")
        cursor = conn.cursor()

        cursor.execute("""
            INSERT INTO complaints
            (name, mobile, ward, category, description, photo)
            VALUES (?, ?, ?, ?, ?, ?)
        """, (
            name,
            mobile,
            ward,
            category,
            description,
            filename
        ))

        conn.commit()
        # Get the complaint ID that was just created
        complaint_id = cursor.lastrowid
        tracking_id = f"WS-2026-{complaint_id:06d}"

        cursor.execute("""
            UPDATE complaints
            SET tracking_id=?
            WHERE id=?
        """, (
            tracking_id,
            complaint_id
        ))

        conn.commit()
        cursor.execute("""
        SELECT email, name
        FROM ward_members
        WHERE ward_no = ?
        """, (ward,))

        ward_member = cursor.fetchone()
       
        # Save notification
        cursor.execute("""
        INSERT INTO notifications
        (citizen_id, title, message)
        VALUES (?, ?, ?)
    """, (
        session["citizen_id"],
        "Complaint Submitted",
        "Your complaint has been submitted successfully. We will review it soon."
    ))


        conn.commit()

        try:
            msg = Message(
                subject="Ward Shabdam - Complaint Submitted Successfully",
                sender=app.config["MAIL_USERNAME"],
                recipients=[session["email"]]
            )

            msg.body = f"""
Dear {session['citizen_name']},

Your complaint has been submitted successfully.

Complaint Details
-------------------------
Tracking ID : {tracking_id}
Name        : {name}
Ward        : {ward}
Category    : {category}
Status      : Pending

Please keep this Tracking ID for future reference.

Thank you for helping improve your Panchayath.

Ward Shabdam
"""

            mail.send(msg)

        except Exception as e:
            print("Citizen Email Error:", e)

        try:
            if ward_member and ward_member[0]:

                ward_msg = Message(
                    subject=f"New Complaint - {ward}",
                    sender=app.config["MAIL_USERNAME"],
                    recipients=[ward_member[0]]
                )

                ward_msg.body = f"""
Hello {ward_member[1]},

A new complaint has been submitted.

Complaint ID : {tracking_id}
Citizen      : {name}
Mobile       : {mobile}
Ward         : {ward}
Category     : {category}

Description:
{description}

Please log in to Ward Shabdam to review this complaint.
"""

                mail.send(ward_msg)

        except Exception as e:
            print("Ward Member Email Error:", e)

        try:
            admin_msg = Message(
                subject=f"New Complaint Submitted - {ward}",
                sender=app.config["MAIL_USERNAME"],
                recipients=[ADMIN_EMAIL]
            )

            admin_msg.body = f"""
A new complaint has been submitted.

Complaint ID : {tracking_id}

Citizen Name : {name}
Mobile       : {mobile}
Ward         : {ward}
Category     : {category}

Description:
{description}

Please log in to the Admin Dashboard to review this complaint.
"""

            mail.send(admin_msg)

        except Exception as e:
            print("Admin Email Error:", e)

        conn.close()

        flash("Complaint submitted successfully!", "success")

        return redirect("/dashboard")

    # ---------- GET REQUEST ----------

    conn = sqlite3.connect("database/wardshabdam.db")
    conn.row_factory = sqlite3.Row
    cursor = conn.cursor()

    cursor.execute(
        "SELECT * FROM citizens WHERE id=?",
        (session["citizen_id"],)
    )

    citizen = cursor.fetchone()

    conn.close()

    return render_template(
        "report.html",
        citizen=citizen
    )

@app.route("/admin")
def admin():

    check = admin_required()

    if check:
        return check
    search = request.args.get("search", "")
    status_filter = request.args.get("status", "")
    conn = sqlite3.connect("database/wardshabdam.db")
    conn.row_factory = sqlite3.Row
    cursor = conn.cursor()

    if search:

        cursor.execute("""
            SELECT *
            FROM complaints
            WHERE
                name LIKE ?
                OR mobile LIKE ?
                OR ward LIKE ?
                OR category LIKE ?
                OR status LIKE ?
         ORDER BY id DESC
        """, (

            "%" + search + "%",
            "%" + search + "%",
            "%" + search + "%",
            "%" + search + "%",
            "%" + search + "%"

        ))

    elif status_filter:

        cursor.execute(
            "SELECT * FROM complaints WHERE status=? ORDER BY id DESC",
            (status_filter,)
        )

    else:

        cursor.execute(
            "SELECT * FROM complaints ORDER BY id DESC"
        )

    complaints = cursor.fetchall()

    cursor.execute("SELECT COUNT(*) FROM complaints")
    total = cursor.fetchone()[0]

    cursor.execute("SELECT COUNT(*) FROM complaints WHERE status='Pending'")
    pending = cursor.fetchone()[0]

    cursor.execute("SELECT COUNT(*) FROM complaints WHERE status='In Progress'")
    progress = cursor.fetchone()[0]

    cursor.execute("SELECT COUNT(*) FROM complaints WHERE status='Resolved'")
    resolved = cursor.fetchone()[0]

    conn.close()

    return render_template(
        "admin.html",
        complaints=complaints,
        total=total,
        pending=pending,
        progress=progress,
        resolved=resolved
    )
    

@app.route("/citizens")
def citizens():

    check = admin_required()

    if check:
        return check

    conn = sqlite3.connect("database/wardshabdam.db")
    conn.row_factory = sqlite3.Row

    cursor = conn.cursor()

    cursor.execute("""
        SELECT *
        FROM citizens
        ORDER BY id DESC
    """)

    citizens = cursor.fetchall()

    conn.close()

    return render_template(
        "citizens.html",
        citizens=citizens
    )

@app.route("/download_pdf")
def download_pdf():

    check = admin_required()

    if check:
        return check

    conn = sqlite3.connect("database/wardshabdam.db")
    conn.row_factory = sqlite3.Row

    cursor = conn.cursor()

    cursor.execute("""
        SELECT id,name,ward,category,status
        FROM complaints
        ORDER BY id DESC
    """)

    complaints = cursor.fetchall()

    conn.close()

    import os

    pdf_folder = os.path.join(app.root_path, "static", "reports")

    os.makedirs(pdf_folder, exist_ok=True)

    pdf_path = os.path.join(pdf_folder, "complaints_report.pdf")

    doc = SimpleDocTemplate(pdf_path)



    elements = []

    styles =getSampleStyleSheet()

    title = Paragraph("<b>WARD SHABDAM - Complaint Report</b>", styles["Heading1"])

    elements.append(title)

    data = [["ID","Name","Ward","Category","Status"]]

    for complaint in complaints:

        data.append([
            complaint["tracking_id"],
            complaint["name"],
            complaint["ward"],
            complaint["category"],
            complaint["status"]
        ])

    table = Table(data)

    table.setStyle(TableStyle([

        ("BACKGROUND",(0,0),(-1,0),colors.blue),

        ("TEXTCOLOR",(0,0),(-1,0),colors.white),

        ("GRID",(0,0),(-1,-1),1,colors.black),

        ("BACKGROUND",(0,1),(-1,-1),colors.beige),

        ("ALIGN",(0,0),(-1,-1),"CENTER"),

        ("BOTTOMPADDING",(0,0),(-1,0),12)

    ]))

    elements.append(table)
    print("Saving PDF to:", pdf_path)
    doc.build(elements)

    return send_file(
    pdf_path,
    mimetype="application/pdf",
    as_attachment=True,
    download_name="complaints_report.pdf"
)
@app.route("/about")
def about():
    return render_template("about.html")

@app.route("/contact")
def contact():
    return render_template("contact.html")


@app.route("/view/<int:id>")
def admin_view(id):
    
    check = admin_required()

    if check:
     return check

    conn = sqlite3.connect("database/wardshabdam.db")
    conn.row_factory = sqlite3.Row

    cursor = conn.cursor()

    cursor.execute(
        "SELECT * FROM complaints WHERE id=?",
        (id,)
    )

    complaint = cursor.fetchone()

    conn.close()

    return render_template(
        "view.html",
        complaint=complaint
    )
    
    
@app.route("/edit/<int:id>", methods=["GET", "POST"])
def edit(id):

    check = admin_required()
    if check:
        return check

    conn = sqlite3.connect("database/wardshabdam.db")
    conn.row_factory = sqlite3.Row
    cursor = conn.cursor()

    # Get complaint
    cursor.execute(
        "SELECT * FROM complaints WHERE id=?",
        (id,)
    )
    complaint = cursor.fetchone()

    if not complaint:
        conn.close()
        return "Complaint not found."

    # Get citizen email
    cursor.execute(
        "SELECT * FROM citizens WHERE mobile=?",
        (complaint["mobile"],)
    )
    citizen = cursor.fetchone()

    if request.method == "POST":

        status = request.form["status"]
        admin_reply = request.form["admin_reply"]

        cursor.execute("""
            UPDATE complaints
            SET status=?,
                admin_reply=?
            WHERE id=?
        """, (
            status,
            admin_reply,
            id
        ))

        conn.commit()
        # Save notification

        cursor.execute("""
            INSERT INTO notifications
            (citizen_id, title, message)
            VALUES (?, ?, ?)
        """, (
            citizen["id"],
            "Complaint Updated",
            f"Your complaint #{complaint['id']} status has been changed to '{status}'."
        ))

        conn.commit()

        # Send email to citizen
        if citizen and citizen["email"]:

                if status == "Resolved":
                    subject = "🟢 Ward Shabdam - Complaint Resolved"

                elif status == "In Progress":
                    subject = "🟡 Ward Shabdam - Complaint In Progress"

                else:
                    subject = "📋 Ward Shabdam - Complaint Updated"

                msg = Message(
                    subject=subject,
                    sender=app.config["MAIL_USERNAME"],
                    recipients=[citizen["email"]]
                )

                if status == "Resolved":

                    msg.body = f"""
Dear {citizen['fullname']},

🎉 Good News!

Your complaint has been successfully resolved.

Complaint Details
-------------------------
Complaint ID : {complaint['tracking_id']}
Category     : {complaint['category']}
Ward         : {complaint['ward']}
Status       : {status}

Admin Reply:
{admin_reply}

Thank you for helping improve Thachanattukkara Grama Panchayat.

Ward Shabdam
"""

                elif status == "In Progress":

                    msg.body = f"""
Dear {citizen['fullname']},

🛠 Your complaint is now In Progress.

Our team has started working on your complaint.

Complaint Details
-------------------------
Complaint ID : {complaint['tracking_id']}
Category     : {complaint['category']}
Ward         : {complaint['ward']}
Status       : {status}

Admin Reply:
{admin_reply}

Thank you for your patience.

Ward Shabdam
"""

                else:

                    msg.body = f"""
Dear {citizen['fullname']},

Your complaint has been updated.

Complaint Details
-------------------------
Complaint ID : {complaint['tracking_id']}
Category     : {complaint['category']}
Ward         : {complaint['ward']}
Status       : {status}

Admin Reply:
{admin_reply}

Ward Shabdam
"""
                mail.send(msg)

        conn.close()

        return redirect("/admin")

    conn.close()

    return render_template(
        "edit.html",
        complaint=complaint
    )


@app.route("/delete/<int:id>")
def delete(id):
    check = admin_required()

    if check:
     return check

    conn = sqlite3.connect("database/wardshabdam.db")
    cursor = conn.cursor()

    cursor.execute(
        "DELETE FROM complaints WHERE id=?",
        (id,)
    )

    conn.commit()
    conn.close()

    return redirect("/admin")

@app.route("/register", methods=["GET", "POST"])
def register():

    if request.method == "POST":

        fullname = request.form["fullname"]
        mobile = request.form["mobile"]
        email = request.form["email"]
        ward = request.form["ward"]

        password = request.form["password"]
        confirm_password = request.form["confirm_password"]

        # Check passwords before hashing
        if password != confirm_password:
            return "Passwords do not match!"

        # Hash the password
        hashed_password = generate_password_hash(password)

        import os

        print("Current Working Directory:", os.getcwd())
        print("Database Path:", os.path.abspath("database/wardshabdam.db"))
       
        conn = sqlite3.connect("database/wardshabdam.db")
        cursor = conn.cursor()

        cursor.execute("PRAGMA table_info(citizens)")
        print("Citizens Table:", cursor.fetchall())

        # Check if mobile already exists
        cursor.execute(
            "SELECT * FROM citizens WHERE mobile=?",
            (mobile,)
        )

        existing_user = cursor.fetchone()

        if existing_user:
            conn.close()
            return """
            <h2 style='color:red;text-align:center;'>
            Mobile number already registered!
            </h2>

            <p style='text-align:center;'>
            <a href='/register'>Go Back</a>
            </p>
            """

        cursor.execute("""
            INSERT INTO citizens
            (fullname, mobile, email, ward, password)
            VALUES (?, ?, ?, ?, ?)
        """, (
            fullname,
            mobile,
            email,
            ward,
            hashed_password
        ))

        conn.commit()
        conn.close()

        return redirect("/login")

    return render_template("register.html")

@app.route("/login", methods=["GET", "POST"])
def login():

    if request.method == "POST":

        mobile = request.form["mobile"]
        password = request.form["password"]

        conn = sqlite3.connect("database/wardshabdam.db")
        conn.row_factory = sqlite3.Row

        cursor = conn.cursor()

        cursor.execute(
            "SELECT * FROM citizens WHERE mobile=?",
            (mobile,)
        )

        citizen = cursor.fetchone()

        conn.close()

        if citizen and check_password_hash(citizen["password"], password):

            session["citizen_id"] = citizen["id"]
            session["citizen_name"] = citizen["fullname"]
            session["mobile"] = citizen["mobile"]
            session["email"] = citizen["email"]
            session["ward"] = citizen["ward"]

            return redirect("/dashboard")

        return """
        <h2 style='color:red;text-align:center;'>
        Invalid Mobile Number or Password
        </h2>

        <p style='text-align:center;'>
        <a href='/login'>Try Again</a>
        </p>
        """

    return render_template("login.html")

@app.route("/forgot_password", methods=["GET", "POST"])
def forgot_password():

    if request.method == "POST":

        mobile = request.form["mobile"].strip()
        email = request.form["email"].strip().lower()

        print("Mobile:", mobile)
        print("Email:", email)

        conn = sqlite3.connect("database/wardshabdam.db")
        conn.row_factory = sqlite3.Row

        cursor = conn.cursor()

        cursor.execute("""
            SELECT *
            FROM citizens
            WHERE mobile=? AND LOWER(email)=?
        """, (
            mobile,
            email
        ))

        citizen = cursor.fetchone()

        print("Citizen:", citizen)

        conn.close()

        if citizen:
            print("Redirecting to reset_password...")
            session["reset_mobile"] = mobile
            return redirect("/reset_password")
        else:
            print("Citizen NOT found!")

        return """
        <h2 style='color:red;text-align:center;'>
        Invalid Mobile Number or Email.
        </h2>

        <p style='text-align:center;'>
            <a href='/forgot_password'>Try Again</a>
        </p>
        """

    return render_template("forgot_password.html")
@app.route("/reset_password", methods=["GET", "POST"])
def reset_password():

    if "reset_mobile" not in session:
        return redirect("/forgot_password")

    if request.method == "POST":

        password = request.form["password"]
        confirm_password = request.form["confirm_password"]

        if password != confirm_password:
            return "Passwords do not match."

        hashed_password = generate_password_hash(password)

        conn = sqlite3.connect("database/wardshabdam.db")
        cursor = conn.cursor()

        cursor.execute("""
            UPDATE citizens
            SET password=?
            WHERE mobile=?
        """, (
            hashed_password,
            session["reset_mobile"]
        ))

        conn.commit()
        conn.close()

        session.pop("reset_mobile", None)

        return """
        <h2 style='color:green;text-align:center;'>
        Password Updated Successfully!
        </h2>

        <p style='text-align:center;'>
        <a href='/login'>Go to Login</a>
        </p>
        """

    return render_template("reset_password.html")

@app.route("/dashboard")
def dashboard():

    if "citizen_id" not in session:
        return redirect("/login")

    conn = sqlite3.connect("database/wardshabdam.db")
    conn.row_factory = sqlite3.Row
    cursor = conn.cursor()

    # Get citizen details
    cursor.execute(
        "SELECT * FROM citizens WHERE id=?",
        (session["citizen_id"],)
    )

    citizen = cursor.fetchone()

    # Get unread notification count
    cursor.execute("""
        SELECT COUNT(*)
        FROM notifications
        WHERE citizen_id=?
        AND is_read=0
    """, (session["citizen_id"],))

    notification_count = cursor.fetchone()[0]

    conn.close()

    return render_template(
        "dashboard.html",
        citizen=citizen,
        notification_count=notification_count
    )
@app.route("/notifications")
def notifications():

    if "citizen_id" not in session:
        return redirect("/login")

    conn = sqlite3.connect("database/wardshabdam.db")
    conn.row_factory = sqlite3.Row
    cursor = conn.cursor()

    cursor.execute("""
        SELECT *
        FROM notifications
        WHERE citizen_id=?
        ORDER BY created_at DESC
    """, (session["citizen_id"],))

    notifications = cursor.fetchall()

    # Mark all notifications as read
    cursor.execute("""
        UPDATE notifications
        SET is_read=1
        WHERE citizen_id=?
    """, (session["citizen_id"],))

    conn.commit()
    conn.close()

    return render_template(
        "notifications.html",
        notifications=notifications
    )        
        
@app.route("/profile")
def profile():

    if "citizen_id" not in session:
        return redirect("/login")

    conn = sqlite3.connect("database/wardshabdam.db")
    conn.row_factory = sqlite3.Row
    cursor = conn.cursor()

    cursor.execute(
        "SELECT * FROM citizens WHERE id=?",
        (session["citizen_id"],)
    )

    citizen = cursor.fetchone()

    conn.close()

    return render_template(
        "profile.html",
        citizen=citizen
    )
@app.route("/change_password", methods=["GET", "POST"])
def change_password():

    if "citizen_id" not in session:
        return redirect("/login")

    if request.method == "POST":

        current_password = request.form["current_password"]
        new_password = generate_password_hash(request.form["new_password"])
        confirm_password = request.form["confirm_password"]

        conn = sqlite3.connect("database/wardshabdam.db")
        conn.row_factory = sqlite3.Row
        cursor = conn.cursor()

        cursor.execute(
            "SELECT * FROM citizens WHERE id=?",
            (session["citizen_id"],)
        )

        citizen = cursor.fetchone()

        if citizen["password"] != current_password:
            conn.close()
            return "<h2 style='color:red'>Current password is incorrect.</h2><a href='/change_password'>Try Again</a>"

        if new_password != confirm_password:
            conn.close()
            return "<h2 style='color:red'>New passwords do not match.</h2><a href='/change_password'>Try Again</a>"

        cursor.execute(
            "UPDATE citizens SET password=? WHERE id=?",
            (new_password, session["citizen_id"])
        )

        conn.commit()
        conn.close()

        return """
        <h2 style='color:green'>
        Password changed successfully!
        </h2>
        <a href='/dashboard'>Back to Dashboard</a>
        """

    return render_template("change_password.html")
@app.route("/logout")
def logout():

    session.pop("citizen_id", None)
    session.pop("citizen_name", None)
    session.pop("mobile", None)

    return redirect("/")

@app.route("/announcement/<int:id>")
def announcement(id):

    conn = sqlite3.connect("database/wardshabdam.db")
    conn.row_factory = sqlite3.Row
    cursor = conn.cursor()

    cursor.execute(
        "SELECT * FROM announcements WHERE id=?",
        (id,)
    )

    announcement = cursor.fetchone()

    conn.close()

    return render_template(
        "announcement.html",
        announcement=announcement
    )
@app.route("/add_announcement", methods=["GET", "POST"])
def add_announcement():
    check = admin_required()

    if check:
     return check

    if request.method == "POST":

        title = request.form["title"]
        description = request.form["description"]

        photo = request.files["photo"]

        filename = ""

        if photo and photo.filename != "":
            filename = secure_filename(photo.filename)

            photo.save(
                os.path.join(
                    app.config["UPLOAD_FOLDER"],
                    filename
                )
            )

        conn = sqlite3.connect("database/wardshabdam.db")
        cursor = conn.cursor()

        cursor.execute("""
            INSERT INTO announcements
            (title, description, photo)
            VALUES (?, ?, ?)
        """, (title, description, filename))

        conn.commit()
        conn.close()

        return redirect("/")

    return render_template("add_announcement.html")
@app.context_processor
def notification_context():

    if "citizen_id" not in session:
        return {"notification_count": 0}

    conn = sqlite3.connect("database/wardshabdam.db")
    cursor = conn.cursor()

    cursor.execute("""
        SELECT COUNT(*)
        FROM notifications
        WHERE citizen_id=?
        AND is_read=0
    """, (session["citizen_id"],))

    count = cursor.fetchone()[0]

    conn.close()

    return {"notification_count": count}
@app.route("/announcements")
def announcements():

    conn = sqlite3.connect("database/wardshabdam.db")
    conn.row_factory = sqlite3.Row
    cursor = conn.cursor()

    cursor.execute("""
        SELECT *
        FROM announcements
        ORDER BY created_at DESC
    """)

    announcements = cursor.fetchall()

    conn.close()

    return render_template(
        "announcements.html",
        announcements=announcements
    )

@app.route("/admin_login", methods=["GET", "POST"])
def admin_login():

    if request.method == "POST":

        username = request.form["username"]
        password = request.form["password"]

        conn = sqlite3.connect("database/wardshabdam.db")
        conn.row_factory = sqlite3.Row

        cursor = conn.cursor()

        cursor.execute(
            "SELECT * FROM admins WHERE username=?",
            (username,)
        )

        admin = cursor.fetchone()

        print("Admin record:", admin)

        if admin:
            print("Stored password:", admin["password"])
            print("Password entered:", password)
            print("Password check:", check_password_hash(admin["password"], password))

        conn.close()

        if admin and check_password_hash(admin["password"], password):

            session["admin_id"] = admin["id"]
            session["admin_username"] = admin["username"]

            return redirect("/admin")

        return """
        <h2 style='color:red;text-align:center;'>
        Invalid Username or Password
        </h2>

        <p style='text-align:center;'>
        <a href='/admin_login'>Try Again</a>
        </p>
        """

    return render_template("admin_login.html")
@app.route("/create_admin_hash")
def create_admin_hash():

    hashed = generate_password_hash("admin123")

    conn = sqlite3.connect("database/wardshabdam.db")
    cursor = conn.cursor()

    cursor.execute("""
        UPDATE admins
        SET password=?
        WHERE username='admin'
    """, (hashed,))

    conn.commit()
    conn.close()

    return "Admin password updated successfully."
@app.route("/add_program", methods=["GET", "POST"])
def add_program():

    check = admin_required()

    if check:
        return check

    
    
    if request.method == "POST":

        title = request.form["title"]
        description = request.form["description"]

        photo = request.files["photo"]

        filename = ""

        if photo and photo.filename != "":
            filename = secure_filename(photo.filename)

            photo.save(
                os.path.join(
                    app.config["UPLOAD_FOLDER"],
                    filename
                )
            )

        conn = sqlite3.connect("database/wardshabdam.db")
        cursor = conn.cursor()

        cursor.execute("""
            INSERT INTO programs
            (title, description, photo)
            VALUES (?, ?, ?)
        """, (title, description, filename))

        conn.commit()
        conn.close()

        return redirect("/programs")

    return render_template("add_program.html")

@app.route("/programs")
def programs():

    conn = sqlite3.connect("database/wardshabdam.db")
    conn.row_factory = sqlite3.Row

    cursor = conn.cursor()

    cursor.execute("""
        SELECT *
        FROM programs
        ORDER BY id DESC
    """)

    programs = cursor.fetchall()

    conn.close()

    return render_template(
        "programs.html",
        programs=programs
    )

@app.route("/program/<int:id>")
def program(id):

    conn = sqlite3.connect("database/wardshabdam.db")
    conn.row_factory = sqlite3.Row
    cursor = conn.cursor()

    cursor.execute(
        "SELECT * FROM programs WHERE id=?",
        (id,)
    )

    program = cursor.fetchone()

    conn.close()

    return render_template(
        "program.html",
        program=program
    )

@app.route("/my_complaints")
def my_complaints():

    if "citizen_id" not in session:
        return redirect("/login")

    mobile = session["mobile"]

    conn = sqlite3.connect("database/wardshabdam.db")
    conn.row_factory = sqlite3.Row

    cursor = conn.cursor()

    cursor.execute("""
        SELECT complaints.*,
            feedback.id AS feedback_id
        FROM complaints
        LEFT JOIN feedback
        ON complaints.id = feedback.complaint_id
        AND feedback.citizen_id = ?
        WHERE complaints.mobile = ?
        ORDER BY complaints.id DESC
        """, (
            session["citizen_id"],
            mobile
        ))

    complaints = cursor.fetchall()

    conn.close()

    return render_template(
        "my_complaints.html",
        complaints=complaints
    )
@app.route("/my_complaint/<int:id>")
def my_complaint(id):

    if "citizen_id" not in session:
        return redirect("/login")

    conn = sqlite3.connect("database/wardshabdam.db")
    conn.row_factory = sqlite3.Row
    cursor = conn.cursor()

    cursor.execute(
        "SELECT * FROM complaints WHERE id=?",
        (id,)
    )

    complaint = cursor.fetchone()

    conn.close()

    if complaint is None:
        return "Complaint Not Found", 404

    # Security: make sure the complaint belongs to the logged-in citizen
    if complaint["mobile"] != session["mobile"]:
        return "Access Denied", 403

    return render_template(
        "my_complaint.html",
        complaint=complaint
    )

@app.route("/edit_profile", methods=["GET", "POST"])
def edit_profile():

    if "citizen_id" not in session:
        return redirect("/login")

    conn = sqlite3.connect("database/wardshabdam.db")
    conn.row_factory = sqlite3.Row
    cursor = conn.cursor()

    if request.method == "POST":

        fullname = request.form["fullname"]
        email = request.form["email"]

        cursor.execute("""
            UPDATE citizens
            SET fullname=?,
                email=?
            WHERE id=?
        """, (
            fullname,
            email,
            session["citizen_id"]
        ))

        conn.commit()

        # Update session name
        session["citizen_name"] = fullname

        conn.close()

        return redirect("/profile")

    cursor.execute(
        "SELECT * FROM citizens WHERE id=?",
        (session["citizen_id"],)
    )

    citizen = cursor.fetchone()

    conn.close()

    return render_template(
        "edit_profile.html",
        citizen=citizen
    )


@app.route("/delete_program/<int:id>")
def delete_program(id):
    check = admin_required()

    if check:
     return check
    conn = sqlite3.connect("database/wardshabdam.db")
    cursor = conn.cursor()

    cursor.execute(
        "DELETE FROM programs WHERE id=?",
        (id,)
    )

    conn.commit()
    conn.close()

    return redirect("/programs")

@app.route("/test_email")
def test_email():

    try:
        msg = Message(
            subject="Ward Shabdam Test Email",
            sender=app.config["MAIL_USERNAME"],
            recipients=["YOUR_PERSONAL_EMAIL@gmail.com"]  # Replace with your email
        )

        msg.body = """
Hello,

This is a test email from Ward Shabdam.

Congratulations!
Your email configuration is working successfully.

Ward Shabdam
"""

        mail.send(msg)

        return "✅ Test email sent successfully!"

    except Exception as e:
        return f"❌ Error: {e}"
    
@app.route("/ward-members")
def ward_members():

    conn = sqlite3.connect("database/wardshabdam.db")
    conn.row_factory = sqlite3.Row

    cursor = conn.cursor()

    cursor.execute("""
        SELECT *
        FROM ward_members
        ORDER BY ward_no
    """)

    members = cursor.fetchall()

    conn.close()

    return render_template(
        "ward_members.html",
        members=members
    )
@app.route("/admin/add-ward-member", methods=["GET", "POST"])
def add_ward_member():

    admin_required()

    if request.method == "POST":

        ward_no = request.form["ward_no"]
        name = request.form["name"]
        designation = request.form["designation"]
        phone = request.form["phone"]
        email = request.form["email"]

        photo = request.files["photo"]

        filename = ""

        if photo and photo.filename != "":
            filename = secure_filename(photo.filename)
            photo.save(os.path.join(app.config["UPLOAD_FOLDER"], filename))
        print("DB PATH =", os.path.abspath("database/wardshabdam.db"))
        conn = sqlite3.connect("database/wardshabdam.db")
        cursor = conn.cursor()

        cursor.execute("""
            INSERT INTO ward_members
            (ward_no, name, designation, phone, email, photo)
            VALUES (?, ?, ?, ?, ?, ?)
        """, (
            ward_no,
            name,
            designation,
            phone,
            email,
            filename
        ))

        conn.commit()
        conn.close()

        return redirect("/ward-members")

    return render_template("add_ward_member.html")

@app.route("/admin/ward-members")
def manage_ward_members():

    admin_required()

    conn = sqlite3.connect("database/wardshabdam.db")
    conn.row_factory = sqlite3.Row

    cursor = conn.cursor()

    cursor.execute("""
        SELECT *
        FROM ward_members
        ORDER BY ward_no
    """)

    members = cursor.fetchall()

    conn.close()

    return render_template(
        "manage_ward_members.html",
        members=members
    )
@app.route("/admin/edit-ward-member/<int:id>", methods=["GET", "POST"])
def edit_ward_member(id):

    admin_required()

    conn = sqlite3.connect("database/wardshabdam.db")
    conn.row_factory = sqlite3.Row

    cursor = conn.cursor()

    if request.method == "POST":

        ward_no = request.form["ward_no"]
        name = request.form["name"]
        designation = request.form["designation"]
        phone = request.form["phone"]
        email = request.form["email"]

        cursor.execute("""
            UPDATE ward_members
            SET ward_no=?,
                name=?,
                designation=?,
                phone=?,
                email=?
            WHERE id=?
        """, (
            ward_no,
            name,
            designation,
            phone,
            email,
            id
        ))

        conn.commit()
        conn.close()

        return redirect("/admin/ward-members")

    cursor.execute(
        "SELECT * FROM ward_members WHERE id=?",
        (id,)
    )

    member = cursor.fetchone()

    conn.close()

    return render_template(
        "edit_ward_member.html",
        member=member
    )
@app.route("/admin/delete-ward-member/<int:id>")
def delete_ward_member(id):

    admin_required()

    conn = sqlite3.connect("database/wardshabdam.db")
    cursor = conn.cursor()

    cursor.execute(
        "DELETE FROM ward_members WHERE id=?",
        (id,)
    )

    conn.commit()
    conn.close()

    return redirect("/admin/ward-members")
@app.route("/admin/add-survey", methods=["GET", "POST"])
def add_survey():

    admin_required()

    if request.method == "POST":

        question = request.form["question"]

        option1 = request.form["option1"]
        option2 = request.form["option2"]
        option3 = request.form["option3"]
        option4 = request.form["option4"]

        conn = sqlite3.connect("database/wardshabdam.db")
        cursor = conn.cursor()

        cursor.execute("""
            INSERT INTO surveys (question)
            VALUES (?)
        """, (question,))

        survey_id = cursor.lastrowid

        options = [
            option1,
            option2,
            option3,
            option4
        ]

        for option in options:

            cursor.execute("""
                INSERT INTO survey_options
                (survey_id, option_text)
                VALUES (?, ?)
            """, (
                survey_id,
                option
            ))

        conn.commit()
        conn.close()

        return redirect("/admin")

    return render_template("add_survey.html")

@app.route("/survey", methods=["GET", "POST"])
def survey():

    if "citizen_id" not in session:
        return redirect("/login")

    conn = sqlite3.connect("database/wardshabdam.db")
    conn.row_factory = sqlite3.Row
    cursor = conn.cursor()

    cursor.execute("""
        SELECT *
        FROM surveys
        ORDER BY id DESC
        LIMIT 1
    """)

    survey = cursor.fetchone()

    if not survey:
        conn.close()
        return "No survey available."

    if request.method == "POST":

        citizen_id = session["citizen_id"]

        cursor.execute("""
            SELECT *
            FROM survey_votes
            WHERE survey_id=? AND citizen_id=?
        """, (
            survey["id"],
            citizen_id
        ))

        existing_vote = cursor.fetchone()

        if existing_vote:
            conn.close()

            return """
            <h2 style='color:red;text-align:center;'>
            You have already voted in this survey.
            </h2>

            <p style='text-align:center;'>
            <a href='/survey-results'>View Results</a>
            </p>
            """

        option_id = request.form["option_id"]

        cursor.execute("""
            UPDATE survey_options
            SET votes = votes + 1
            WHERE id=?
        """, (option_id,))

        cursor.execute("""
            INSERT INTO survey_votes
            (survey_id, citizen_id)
            VALUES (?, ?)
        """, (
            survey["id"],
            citizen_id
        ))

        conn.commit()
        conn.close()

        return redirect("/survey-results")

    cursor.execute("""
        SELECT *
        FROM survey_options
        WHERE survey_id=?
    """, (survey["id"],))

    options = cursor.fetchall()

    conn.close()

    return render_template(
        "survey.html",
        survey=survey,
        options=options
    )
@app.route("/survey-results")
def survey_results():

    conn = sqlite3.connect("database/wardshabdam.db")
    conn.row_factory = sqlite3.Row

    cursor = conn.cursor()

    cursor.execute("""
        SELECT *
        FROM surveys
        ORDER BY id DESC
        LIMIT 1
    """)

    survey = cursor.fetchone()

    cursor.execute("""
        SELECT *
        FROM survey_options
        WHERE survey_id=?
    """, (survey["id"],))

    options = cursor.fetchall()

    conn.close()

    return render_template(
        "survey_results.html",
        survey=survey,
        options=options
    )

@app.route("/admin/add-gallery", methods=["GET", "POST"])
def add_gallery():

    check = admin_required()
    if check:
        return check

    if request.method == "POST":

        title = request.form["title"]
        description = request.form["description"]
        event_date = request.form["event_date"]

        photo = request.files["photo"]

        filename = ""

        if photo and photo.filename != "":
            filename = secure_filename(photo.filename)
            photo.save(os.path.join(app.config["UPLOAD_FOLDER"], filename))

        conn = sqlite3.connect("database/wardshabdam.db")
        cursor = conn.cursor()

        cursor.execute("""
            INSERT INTO gallery
            (title, description, photo, event_date)
            VALUES (?, ?, ?, ?)
        """, (
            title,
            description,
            filename,
            event_date
        ))

        conn.commit()
        conn.close()

        return redirect("/admin")

    return render_template("add_gallery.html")
@app.route("/gallery")
def gallery():

    search = request.args.get("search", "")

    conn = sqlite3.connect("database/wardshabdam.db")
    conn.row_factory = sqlite3.Row
    cursor = conn.cursor()

    if search:

        cursor.execute("""
            SELECT *
            FROM gallery
            WHERE title LIKE ?
            ORDER BY id DESC
        """, ("%" + search + "%",))

    else:

        cursor.execute("""
            SELECT *
            FROM gallery
            ORDER BY id DESC
        """)

    photos = cursor.fetchall()

    conn.close()

    return render_template(
        "gallery.html",
        photos=photos
    )

@app.route("/admin/delete-gallery/<int:id>")
def delete_gallery(id):

    check = admin_required()
    if check:
        return check

    conn = sqlite3.connect("database/wardshabdam.db")
    cursor = conn.cursor()

    cursor.execute("DELETE FROM gallery WHERE id=?", (id,))

    conn.commit()
    conn.close()

    return redirect("/gallery")

@app.route("/ward-login", methods=["GET", "POST"])
def ward_login():

    if request.method == "POST":

        username = request.form["username"]
        password = request.form["password"]

        conn = sqlite3.connect("database/wardshabdam.db")
        conn.row_factory = sqlite3.Row
        cursor = conn.cursor()

        print("Username entered:", username)
        print("Password entered:", password)
        cursor.execute("""
            SELECT *
            FROM ward_members
            WHERE username=? AND password=?
        """, (
            username,
            password
        ))

        member = cursor.fetchone()

        conn.close()

        if member:

            session["ward_member_id"] = member["id"]
            session["ward_name"] = member["name"]
            session["ward_no"] = member["ward_no"]

            return redirect("/ward-dashboard")

        return """
        <h2 style='color:red;text-align:center;'>
        Invalid Username or Password
        </h2>

        <p style='text-align:center;'>
        <a href='/ward-login'>Try Again</a>
        </p>
        """

    return render_template("ward_login.html")

@app.route("/ward-dashboard")
def ward_dashboard():

    if "ward_member_id" not in session:
        return redirect("/ward-login")

    ward_no = session["ward_no"]

    conn = sqlite3.connect("database/wardshabdam.db")
    conn.row_factory = sqlite3.Row
    cursor = conn.cursor()

    # Complaints of this ward
    cursor.execute("""
        SELECT *
        FROM complaints
        WHERE ward=?
        ORDER BY id DESC
    """, ("Ward " + str(ward_no),))

    complaints = cursor.fetchall()

    # Statistics
    cursor.execute(
        "SELECT COUNT(*) FROM complaints WHERE ward=?",
        ("Ward " + str(ward_no),)
    )
    total = cursor.fetchone()[0]

    cursor.execute(
        "SELECT COUNT(*) FROM complaints WHERE ward=? AND status='Pending'",
        ("Ward " + str(ward_no),)
    )
    pending = cursor.fetchone()[0]

    cursor.execute(
        "SELECT COUNT(*) FROM complaints WHERE ward=? AND status='In Progress'",
        ("Ward " + str(ward_no),)
    )
    progress = cursor.fetchone()[0]

    cursor.execute(
        "SELECT COUNT(*) FROM complaints WHERE ward=? AND status='Resolved'",
        ("Ward " + str(ward_no),)
    )
    resolved = cursor.fetchone()[0]

    conn.close()

    return render_template(
        "ward_dashboard.html",
        complaints=complaints,
        ward_no=ward_no,
        total=total,
        pending=pending,
        progress=progress,
        resolved=resolved
    )
@app.route("/ward-edit/<int:id>", methods=["GET", "POST"])
def ward_edit(id):

    if "ward_member_id" not in session:
        return redirect("/ward-login")

    conn = sqlite3.connect("database/wardshabdam.db")
    conn.row_factory = sqlite3.Row
    cursor = conn.cursor()

    # Get complaint
    cursor.execute(
        "SELECT * FROM complaints WHERE id=?",
        (id,)
    )
    complaint = cursor.fetchone()

    if not complaint:
        conn.close()
        return "Complaint not found."

    # Security: only allow complaints from the ward member's ward
    if complaint["ward"] != "Ward " + str(session["ward_no"]):
        conn.close()
        return "Access Denied"

    # Get citizen details
    cursor.execute(
        "SELECT * FROM citizens WHERE mobile=?",
        (complaint["mobile"],)
    )
    citizen = cursor.fetchone()

    if request.method == "POST":

        status = request.form["status"]
        reply = request.form["reply"]

        cursor.execute("""
            UPDATE complaints
            SET status=?, admin_reply=?
            WHERE id=?
        """, (
            status,
            reply,
            id
        ))

        conn.commit()
        # Save notification

        cursor.execute("""
            INSERT INTO notifications
            (citizen_id, title, message)
            VALUES (?, ?, ?)
        """, (
            citizen["id"],
            "Complaint Updated",
            f"Your Ward Member updated complaint #{complaint['id']} to '{status}'."
        ))

        conn.commit()

        # Send email
        if citizen and citizen["email"]:
            try:

                msg = Message(
                    subject="Ward Shabdam - Complaint Updated",
                    sender=app.config["MAIL_USERNAME"],
                    recipients=[citizen["email"]]
                )

                msg.body = f"""
Dear {citizen['fullname']},

Your complaint has been updated by your Ward Member.

Complaint Details
-------------------------
Complaint ID : {complaint['id']}
Ward         : {complaint['ward']}
Category     : {complaint['category']}

New Status:
{status}

Ward Member Reply:
{reply}

Thank you,
Ward Shabdam
"""

                mail.send(msg)

            except Exception as e:
                print("Email Error:", e)

        conn.close()

        return redirect("/ward-dashboard")

    conn.close()

    return render_template(
        "ward_edit.html",
        complaint=complaint
    )

@app.route("/ward-logout")
def ward_logout():

    session.pop("ward_member_id", None)
    session.pop("ward_name", None)
    session.pop("ward_no", None)

    return redirect("/")

@app.route("/admin/add-download", methods=["GET", "POST"])
def add_download():

    check = admin_required()
    if check:
        return check

    if request.method == "POST":

        title = request.form["title"]
        category = request.form["category"]
        description = request.form["description"]

        pdf = request.files["pdf"]

        filename = ""

        if pdf and pdf.filename != "":

            filename = secure_filename(pdf.filename)

            pdf.save(
                os.path.join(
                    "static/documents",
                    filename
                )
            )

        conn = sqlite3.connect("database/wardshabdam.db")
        cursor = conn.cursor()

        cursor.execute("""
            INSERT INTO downloads
            (title, category, description, file_name)
            VALUES (?, ?, ?, ?)
        """, (
            title,
            category,
            description,
            filename
        ))

        conn.commit()
        conn.close()

        return redirect("/admin")

    return render_template("add_download.html")
@app.route("/admin/downloads")
def manage_downloads():

    check = admin_required()
    if check:
        return check

    conn = sqlite3.connect("database/wardshabdam.db")
    conn.row_factory = sqlite3.Row
    cursor = conn.cursor()

    cursor.execute("""
        SELECT *
        FROM downloads
        ORDER BY id DESC
    """)

    downloads = cursor.fetchall()

    conn.close()

    return render_template(
        "downloads.html",
        downloads=downloads
    )
@app.route("/delete-download/<int:id>")
def delete_download(id):

    check = admin_required()
    if check:
        return check

    conn = sqlite3.connect("database/wardshabdam.db")
    conn.row_factory = sqlite3.Row
    cursor = conn.cursor()

    # Get file name
    cursor.execute(
        "SELECT * FROM downloads WHERE id=?",
        (id,)
    )

    file = cursor.fetchone()

    if file:

        pdf_path = os.path.join(
            "static/documents",
            file["file_name"]
        )

        if os.path.exists(pdf_path):
            os.remove(pdf_path)

        cursor.execute(
            "DELETE FROM downloads WHERE id=?",
            (id,)
        )

        conn.commit()

    conn.close()

    return redirect("/admin/downloads")
@app.route("/edit-download/<int:id>", methods=["GET", "POST"])
def edit_download(id):

    check = admin_required()
    if check:
        return check

    conn = sqlite3.connect("database/wardshabdam.db")
    conn.row_factory = sqlite3.Row
    cursor = conn.cursor()

    cursor.execute(
        "SELECT * FROM downloads WHERE id=?",
        (id,)
    )

    download = cursor.fetchone()

    if not download:
        conn.close()
        return "Document not found."

    if request.method == "POST":

        title = request.form["title"]
        category = request.form["category"]
        description = request.form["description"]

        cursor.execute("""
            UPDATE downloads
            SET title=?,
                category=?,
                description=?
            WHERE id=?
        """, (
            title,
            category,
            description,
            id
        ))

        conn.commit()
        conn.close()

        return redirect("/admin/downloads")

    conn.close()

    return render_template(
        "edit_download.html",
        download=download
    )
@app.route("/downloads")
def downloads():

    conn = sqlite3.connect("database/wardshabdam.db")
    conn.row_factory = sqlite3.Row
    cursor = conn.cursor()

    search = request.args.get("search", "")
    category = request.args.get("category", "")

    query = "SELECT * FROM downloads WHERE 1=1"
    values = []

    if search:
        query += " AND title LIKE ?"
        values.append("%" + search + "%")

    if category:
        query += " AND category=?"
        values.append(category)

    query += " ORDER BY id DESC"

    cursor.execute(query, values)

    downloads = cursor.fetchall()

    conn.close()

    return render_template(
        "downloads_public.html",
        downloads=downloads,
        search=search,
        category=category
    )
@app.route("/admin/add-circular", methods=["GET", "POST"])
def add_circular():

    check = admin_required()
    if check:
        return check

    if request.method == "POST":
        print(">>> NEW ADD CIRCULAR ROUTE IS RUNNING <<<")

        title = request.form["title"]
        description = request.form["description"]

        important = 1 if "important" in request.form else 0

        pdf = request.files["pdf"]

        filename = ""

        if pdf and pdf.filename != "":

            filename = secure_filename(pdf.filename)

            pdf.save(
                os.path.join(
                "static/documents",
                filename
            )
)

        conn = sqlite3.connect("database/wardshabdam.db")
        cursor = conn.cursor()

        cursor.execute("""
            INSERT INTO circulars
            (title, description, pdf_file, important)
            VALUES (?, ?, ?, ?)
        """, (
            title,
            description,
            filename,
            important
        ))

        conn.commit()
        conn.close()

        return redirect("/admin/circulars")

    return render_template("add_circular.html")
@app.route("/admin/circulars")
def manage_circulars():

    check = admin_required()
    if check:
        return check

    conn = sqlite3.connect("database/wardshabdam.db")
    conn.row_factory = sqlite3.Row
    cursor = conn.cursor()

    cursor.execute("""
        SELECT *
        FROM circulars
        ORDER BY created_at DESC
    """)

    circulars = cursor.fetchall()

    conn.close()

    return render_template(
        "manage_circulars.html",
        circulars=circulars
    )
@app.route("/edit-circular/<int:id>", methods=["GET", "POST"])
def edit_circular(id):

    check = admin_required()
    if check:
        return check

    conn = sqlite3.connect("database/wardshabdam.db")
    conn.row_factory = sqlite3.Row
    cursor = conn.cursor()

    cursor.execute(
        "SELECT * FROM circulars WHERE id=?",
        (id,)
    )

    circular = cursor.fetchone()

    if not circular:
        conn.close()
        return "Circular not found."

    if request.method == "POST":

        title = request.form["title"]
        description = request.form["description"]
        important = 1 if "important" in request.form else 0

        cursor.execute("""
            UPDATE circulars
            SET title=?,
                description=?,
                important=?
            WHERE id=?
        """, (
            title,
            description,
            important,
            id
        ))

        conn.commit()
        conn.close()

        return redirect("/admin/circulars")

    conn.close()

    return render_template(
        "edit_circular.html",
        circular=circular
    )
@app.route("/delete-circular/<int:id>")
def delete_circular(id):

    check = admin_required()
    if check:
        return check

    conn = sqlite3.connect("database/wardshabdam.db")
    conn.row_factory = sqlite3.Row
    cursor = conn.cursor()

    cursor.execute(
        "SELECT * FROM circulars WHERE id=?",
        (id,)
    )

    circular = cursor.fetchone()

    if circular:

        if circular["pdf_file"]:

            pdf_path = os.path.join(
                "static/documents",
                circular["pdf_file"]
            )

            if os.path.exists(pdf_path):
                os.remove(pdf_path)

        cursor.execute(
            "DELETE FROM circulars WHERE id=?",
            (id,)
        )

        conn.commit()

    conn.close()

    return redirect("/admin/circulars")
@app.route("/circulars")
def circulars():

    conn = sqlite3.connect("database/wardshabdam.db")
    conn.row_factory = sqlite3.Row
    cursor = conn.cursor()

    search = request.args.get("search", "")

    if search:

        cursor.execute("""
            SELECT *
            FROM circulars
            WHERE title LIKE ?
            ORDER BY important DESC, created_at DESC
        """, ("%" + search + "%",))

    else:

        cursor.execute("""
            SELECT *
            FROM circulars
            ORDER BY important DESC, created_at DESC
        """)

    circulars = cursor.fetchall()

    conn.close()

    return render_template(
        "circulars.html",
        circulars=circulars,
        search=search
    )


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
