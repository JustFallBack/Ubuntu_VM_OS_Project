# mail.py

# This script is called by handle_crisis.sh if a crisis is detected. It sends an e-mail with appropriate content.

import sys
import smtplib
from email.message import EmailMessage

LOG_FILE = "/OS_Project/Crisis/log_handle_crisis.txt" # Fill in the path to the directory to OS_Project.

# Mail configuration.
config = {
    "smtp_server": "",
    "smtp_port": 587,
    "smtp_username": "",
    "smtp_password": "",
    "sender_email": "",
    "recipient_email": ""
}

# Send an mail with the specified subject and body.
def send_email(subject, body):
    msg = EmailMessage()
    msg.set_content(body)
    msg['Subject'] = subject
    msg['From'] = config["sender_email"]
    msg['To'] = config["recipient_email"]

    try:
        with smtplib.SMTP_SSL(config["smtp_server"], config["smtp_port"]) as server:
            server.login(config["smtp_username"], config["smtp_password"])
            server.send_message(msg)
    except Exception as e:
        with open(LOG_FILE, "w") as file:
            file.write("An error occurred while sending the email: {}\n".format(e))
        sys.exit(1)

def main():
    # Check if the subject and body arguments are provided.
    if len(sys.argv) != 3:
        with open(LOG_FILE, "a") as file:
            file.write("Crisis detected, but no arguments provided for subject and body.\n")
        sys.exit(1)
    
    subject = sys.argv[1]
    body = sys.argv[2]
    send_email(subject, body)

if __name__ == "__main__":
    main()