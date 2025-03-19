import json
import gspread
import requests
import random
import string
from oauth2client.service_account import ServiceAccountCredentials

# 1️⃣ Google Sheets Setup
GOOGLE_SHEET_NAME = "Mock_techrace_data"
API_ENDPOINT = "http://localhost:5000/api/users/new_user"  # Local server
YOUR_AUTH_TOKEN_HERE="abcd"
def generate_password(length=8):
    """Generate a random password"""
    return ''.join(random.choices(string.ascii_letters + string.digits, k=length))

def get_google_sheet_data():
    """Fetches data from Google Sheets"""
    scope = ["https://spreadsheets.google.com/feeds", "https://www.googleapis.com/auth/drive"]
    creds = ServiceAccountCredentials.from_json_keyfile_name("service_account.json", scope)
    client = gspread.authorize(creds)
    sheet = client.open(GOOGLE_SHEET_NAME).sheet1  # First sheet
    return sheet

def register_users():
    """Reads data and registers users"""
    
    sheet = get_google_sheet_data()
    
    # Define expected headers based on your sheet structure
    expected_headers = [
        "Team Name", 
        "Team leader Name (participant 1)", 
        "Phone No. (Team Leader)", 
        "Participant 2 Name", 
        "Email Address (Team Leader)", 
        "Registered", 
    ]

    users = sheet.get_all_records(expected_headers=expected_headers)

    for i in range(len(users)):
        user = users[i]
        if user["Registered"] == "FALSE":
            team_id = {random.randint(1000, 9999)}  # Example: TR-1234
            password = generate_password()
            
            payload = {  
                "team_name": user["Team Name"],
                "p1": user["Team leader Name (participant 1)"],
                "phone1": user["Phone No. (Team Leader)"],
                "p2": user["Participant 2 Name"],
                "email": user["Email Address (Team Leader)"],
                "tid": team_id,
                "password": password
            }
        
            headers = {"Authorization": f"Bearer {YOUR_AUTH_TOKEN_HERE}", "Content-Type": "application/json"}
            response = requests.post(API_ENDPOINT, json=payload, headers=headers)
            
            # Update the Google Sheet
            sheet.update_cell(i+2, 6, "TRUE")
            sheet.update_cell(i+2, 7, team_id)
            sheet.update_cell(i+2, 8, password)
        
            if response.status_code == 201:
                print(f"✅ Registered {user['Team leader Name (participant 1)']} with Team ID: {team_id}")
            else:
                print(f"❌ Failed to register {user['Team leader Name (participant 1)']} - Error: {response.text}")

if __name__ == "__main__":
    register_users()
