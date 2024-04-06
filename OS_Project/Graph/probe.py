# probe.py

# This script reads data from a JSON file, inserts it into an SQLite database, and executes a plot script.

import sqlite3
import json
import os

DATA_DIR = "/OS_Project"  # Fill in the path to the directory to OS_Project.
DATA_JSON = os.path.join(DATA_DIR, "data.json")
DATABASE = os.path.join(DATA_DIR, "main.db")
PLOT = os.path.join(DATA_DIR, "Graph", "plot.py")


# Load data from JSON file.
with open(DATA_JSON, 'r') as file:
    data = json.load(file)

# Connect to SQLite database.
conn = sqlite3.connect(DATABASE)
cursor = conn.cursor()

# Create the Data table if it doesn't exist already.
cursor.execute('''
    CREATE TABLE IF NOT EXISTS Probe_data (
        dateT TEXT PRIMARY KEY,
        cpu_usage_percentage TEXT,
        ram_usage TEXT,
        number_of_process TEXT,
        number_of_user TEXT,
        disk_usage TEXT,
        uptime TEXT
    )
''')

# Clear the table before inserting new data.
cursor.execute('''DELETE FROM Probe_data''')

# Insert data into the table.
for date, values in data.items():
    cursor.execute('''
        INSERT INTO Probe_data (dateT, cpu_usage_percentage, ram_usage, number_of_process, number_of_user, disk_usage, uptime)
        VALUES (?, ?, ?, ?, ?, ?, ?)
    ''', (date, values['cpu_usage_percentage'], values['ram_usage'], values['number_of_process'], values['number_of_user'], values['disk_usage'], values['uptime']))

# Commit the changes and close the connection.
conn.commit()
conn.close()

# Execute the plot script.
exec(open(PLOT).read())
