import gspread
import smtplib
from oauth2client.service_account import ServiceAccountCredentials
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart

# 🔹 Google Sheets Setup
GOOGLE_SHEET_NAME = "Mock_techrace_data"  # Change this to your sheet name
SERVICE_ACCOUNT_FILE = "service_account.json"  # Your credentials JSON file

# 🔹 Email Configuration
SENDER_EMAIL = "harishghanchi87@gmail.com"
SENDER_PASSWORD = "1234 5678 9101 2121"  # Use an App Password

expected_headers = [
    "Team Name", 
    "Team leader Name (participant 1)", 
    "Phone No. (Team Leader)", 
    "Participant 2 Name", 
    "Email Address (Team Leader)", 
    "Registered", 
    "Team ID", 
    "Password"
]

# Connect to Google Sheets
scope = ["https://spreadsheets.google.com/feeds", "https://www.googleapis.com/auth/drive"]
creds = ServiceAccountCredentials.from_json_keyfile_name(SERVICE_ACCOUNT_FILE, scope)
client = gspread.authorize(creds)
sheet = client.open(GOOGLE_SHEET_NAME).sheet1  # First sheet

def send_email(recipient_email, team_id, password):
    """Send email with team ID and password."""
    
    subject = "Your Treasure Hunt Team Credentials"
    body = f"""
    Hello,

    Congratulations! You have successfully registered for the Treasure Hunt.

    Here are your credentials:
    🔹 Team ID: {team_id}
    🔹 Password: {password}

    Use these to log in and participate in the event.

    Best of luck!
    - TechRace Team
    """

    # Set up email message
    msg = MIMEMultipart()
    msg["From"] = SENDER_EMAIL
    msg["To"] = recipient_email
    msg["Subject"] = subject
    msg.attach(MIMEText(body, "plain"))

    try:
        # Connect to Gmail SMTP server
        server = smtplib.SMTP("smtp.gmail.com", 587)
        server.starttls()  # Secure connection
        server.login(SENDER_EMAIL, SENDER_PASSWORD)
        
        # Send the email
        server.sendmail(SENDER_EMAIL, recipient_email, msg.as_string())
        server.quit()

        print(f"✅ Email sent successfully to {recipient_email}")
    except Exception as e:
        print(f"❌ Failed to send email to {recipient_email}: {e}")

# Get all participant data
users = sheet.get_all_records(expected_headers=expected_headers)

for i, user in enumerate(users):
    if user["Registered"] == "TRUE":  # Only send emails to registered users
        recipient_email = user["Email Address (Team Leader)"]
        team_id = user["Team ID"]
        password = user["Password"]

        # Send email
        send_email(recipient_email, team_id, password)
