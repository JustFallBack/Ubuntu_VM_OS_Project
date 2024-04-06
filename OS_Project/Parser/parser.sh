#!/bin/bash
# parser.sh
# This script downloads the feed of CERT alerts, parses the XML file, and stores the data in the database.


PARSER_DIR="/OS_Project/Parser" # Fill in the path to the directory to OS_Project.
DATABASE="/OS_Project/main.db" # Fill in the path to the directory to OS_Project.
LOG_FILE="$PARSER_DIR/log_parserSH.txt"
ALERT_FEED_XML="$PARSER_DIR/alerte_feed.xml"
PARS_TXT="$PARSER_DIR/pars.txt"

main() {

    # Download the feed of cert.
    url="https://www.cert.ssi.gouv.fr/alerte/feed/"
    wget -qO "$ALERT_FEED_XML" "$url"

    # Check if file has been downloaded.
    if [ -f "$ALERT_FEED_XML" ]; then
        echo "File has been successfully downloaded" > "$LOG_FILE"
    else
        echo "File has not been downloaded" > "$LOG_FILE"
    fi

    # Call the python script to parse the xml file (will write on pars.txt file).
    python3 "$PARSER_DIR/parser.py"
    if [ -f "$PARS_TXT" ]; then
        # Store the title (without the date) in 'title' var
        title=$(sed -n '1p' "$PARS_TXT" | sed 's/([^)]*//; s/)$//')
        link=$(sed -n '2p' "$PARS_TXT")
        # Store the date in 'dateT' var. The date is in the ISO 8601 format (done in parseur.py).
        dateT=$(sed -n '3p' "$PARS_TXT")
    else
        echo "File has not been created" >> "$LOG_FILE"
    fi
}

main

# Insert the data into the table Data_Cert (in main.db database). If the date already exists, the data will not be inserted.
sqlite3 "$DATABASE" <<EOF

-- Create the table if it doesn't already exist
CREATE TABLE IF NOT EXISTS Data_Cert (
    dateT TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    link TEXT NOT NULL
);

-- Insert data into the Data_Cert table, if it's not already there
INSERT OR IGNORE INTO Data_Cert (dateT, title, link) VALUES ('$dateT', '$title', '$link');

-- Delete all data from the Data_Cert table except the most recent one (the table contains only one data)
DELETE FROM Data_Cert WHERE dateT < (SELECT MAX(dateT) FROM Data_Cert);

EOF