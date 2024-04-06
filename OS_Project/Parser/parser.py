# parser.py

# This script parses an XML file and extracts information from the first item using BeautifulSoup.

from bs4 import BeautifulSoup
from datetime import datetime
import sys
import os

PARSER_DIR = "/OS_Project/Parser" # Fill in the path to the directory to OS_Project.
ALERT_FEED_XML = os.path.join(PARSER_DIR, "alerte_feed.xml")
LOG_FILE = os.path.join(PARSER_DIR, "log_parserPY.txt")
PARS_TXT = os.path.join(PARSER_DIR, "pars.txt")

# Redirect stderr to error log file.
sys.stderr = open(os.path.join(PARSER_DIR, LOG_FILE), 'w')

try:
    # Open the XML file.
    with open(ALERT_FEED_XML, "r") as file:
        # Create a BeautifulSoup object
        soup = BeautifulSoup(file, 'xml')

    # Retrieve the first item.
    first_item = soup.find("item")

    # Retrieve information from the first item.
    title = first_item.find("title").text
    link = first_item.find("link").text
    date_text = first_item.find("pubDate").text

    # Log success.
    with open(LOG_FILE, "w") as file3:
        file3.write("Parsing done\n")

    # Raise an exception if parsing fails.
except Exception as e:
    with open(LOG_FILE, "a") as file3:
        file3.write("Parsing failed\n")
    raise e

# Convert the date to ISO format.
date_object = datetime.strptime(date_text, "%a, %d %b %Y %H:%M:%S %z")
date = date_object.strftime("%Y-%m-%d %H:%M:%S")

# Write the extracted information to a text file.
with open(PARS_TXT, "w") as file2:
    file2.write(title + "\n")
    file2.write(link + "\n")
    file2.write(date + "\n")
