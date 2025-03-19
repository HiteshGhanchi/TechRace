import json
import gspread
import requests
from oauth2client.service_account import ServiceAccountCredentials

# 1️⃣ Google Sheets Setup
GOOGLE_SHEET_NAME = "mock_clue_data"
API_ENDPOINT = "http://localhost:5000/api/game/add_clue"  # Replace with your local API endpoint
YOUR_AUTH_TOKEN_HERE = "abcd"
def get_google_sheet_data():
    """Fetches data from Google Sheets"""
    scope = ["https://spreadsheets.google.com/feeds", "https://www.googleapis.com/auth/drive"]
    creds = ServiceAccountCredentials.from_json_keyfile_name("service_account.json", scope)
    client = gspread.authorize(creds)
    sheet = client.open(GOOGLE_SHEET_NAME).sheet1  # First sheet
    return sheet

def register_clues():
    """Reads data and sends clues to the API"""
    
    sheet = get_google_sheet_data()
    clues = sheet.get_all_records()  # Assuming sheet has headers
    print(len(clues))
    for i in range(len(clues)):
        clue = clues[i]
        
        # Directly using column names as the payload keys
        payload = {  
            "cid": clue["cid"],  # Clue ID
            "clue": clue["clue"],  # Clue text
            "clue_type": clue["clue_type"],  # Clue type (e.g., text or image)
            "hint_1": clue["hint_1"],  # First hint
            "hint_1_type": clue["hint_1_type"],  # Hint 1 type (e.g., text or image)
            "hint_2": clue["hint_2"],  # Second hint
            "hint_2_type": clue["hint_2_type"],  # Hint 2 type (e.g., text or image)
            "lat": clue["lat"],  # Latitude
            "long": clue["long"],  # Longitude
        }
    
        headers = {"Authorization": f"Bearer {YOUR_AUTH_TOKEN_HERE}", "Content-Type": "application/json"}
        response = requests.post(API_ENDPOINT, json=payload, headers=headers)
        
        # Log the response
        if response.status_code == 201:
            print(f"✅ Successfully registered Clue {clue['cid']}: {clue['clue']}")
        else:
            print(f"❌ Failed to register Clue {clue['cid']} - Error: {response.text}")

if __name__ == "__main__":
    register_clues()
