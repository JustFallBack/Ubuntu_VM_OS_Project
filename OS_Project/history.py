# history.py

# This script removes outdated data from a JSON file based on a time interval.

import json
from datetime import datetime, timedelta
import os


DATA_JSON = "/OS_Project/data.json" # Fill in the path to the directory to OS_Project.

# Load data from the JSON file.
with open(DATA_JSON, 'r') as file:
    data = json.load(file)

# Get the oldest and newest dates from the data.
old_date = min(data.keys())
last_date = max(data.keys())

# Convert dates to datetime objects for comparison.
old_date_dt = datetime.strptime(old_date, '%Y-%m-%d %H:%M:%S')
last_date_dt = datetime.strptime(last_date, '%Y-%m-%d %H:%M:%S')

# Calculate the time difference.
time_difference = last_date_dt - old_date_dt

# Set a time interval.
delta_time = timedelta(days=1)

# Check if the difference is greater than one day.
if time_difference > delta_time:
    # Remove outdated data
    for date_key in list(data.keys()):
        date_dt = datetime.strptime(date_key, '%Y-%m-%d %H:%M:%S')
        if last_date_dt - date_dt > delta_time:
            del data[date_key]

# Write the updated data to the JSON file.
with open(DATA_JSON, 'w') as file:
    json.dump(data, file, indent=1)
