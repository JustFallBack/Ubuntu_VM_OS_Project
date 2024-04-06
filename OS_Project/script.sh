#!/bin/bash

DATA_DIR="/OS_Project" # Fill in the path to the directory to OS_Project.
PARSER_DIR="$DATA_DIR/Parser"
GRAPH_DIR="$DATA_DIR/Graph"
CRISIS_DIR="$DATA_DIR/Crisis"
LOG_FILE="$DATA_DIR/log_script.txt"

# Function to get system information and write it to a JSON file.
getSystemInfo () {
    # Get system information.
    date=$(date +"%Y-%m-%d %H:%M:%S")
    cpu_usage_percentage=$(awk '{u=$2+$4; t=$2+$4+$5; if (NR==1){u1=u; t1=t;} else print ($2+$4-u1) * 100 / (t-t1) "%"; }' \
<(grep 'cpu ' /proc/stat) <(sleep 1;grep 'cpu ' /proc/stat))
    ram_usage=$(free -m | awk '/Mem:/ {print $3}')
    number_of_process=$(ps -aux | wc -l)
    number_of_user=$(who | wc -l)
    disk_usage=$(df -h | awk '$NF=="/"{printf "%s", $5}')

    # Get boot time in seconds.
    boot_time_seconds=$(python3 -c "import psutil, time; print(int(time.time() - psutil.boot_time()))")
    # Calculate hours, minutes, and remaining seconds.
    hours=$((boot_time_seconds / 3600))
    minutes=$(( (boot_time_seconds % 3600) / 60 ))
    seconds=$((boot_time_seconds % 60))
    # Format the time.
    uptime_formatted=$(printf "%02d:%02d:%02d" $hours $minutes $seconds)

    file="$DATA_DIR/data.json"

    # Check if file exists.
    if [ -f "$file" ]; then
        # Check if file is not empty.
        if [ -s "$file" ]; then
            sed -i '$ s/.$/,/' "$file"  # Remove last character of file and add a comma.

            {
                echo "\"$date\":"
                echo "{"
                echo "\"cpu_usage_percentage\": \"$cpu_usage_percentage\","
                echo "\"ram_usage\": \"$ram_usage MB\","
                echo "\"number_of_process\": \"$number_of_process\","
                echo "\"number_of_user\": \"$number_of_user\","
                echo "\"disk_usage\": \"$disk_usage\","
                echo "\"uptime\": \"$uptime_formatted\""
                echo "}"
                echo ""
                echo "}"

            } >> "$file"  # Save system information to JSON file.

        else # If file is empty, add first object.
            {
                echo "{"
                echo ""
                echo "\"$date\":"
                echo "{"
                echo "\"cpu_usage_percentage\": \"$cpu_usage_percentage\","
                echo "\"ram_usage\": \"$ram_usage MB\","
                echo "\"number_of_process\": \"$number_of_process\","
                echo "\"number_of_user\": \"$number_of_user\","
                echo "\"disk_usage\": \"$disk_usage\","
                echo "\"uptime\": \"$uptime_formatted\""
                echo "}"
                echo ""
                echo "}"
            } >> "$file"
            echo "{" >> "$file"
        fi

    else # If file does not exist, create it.
        {
        echo "{"
        echo ""
        echo "\"$date\":"
        echo "{"
        echo "\"cpu_usage_percentage\": \"$cpu_usage_percentage\","
        echo "\"ram_usage\": \"$ram_usage MB\","
        echo "\"number_of_process\": \"$number_of_process\","
        echo "\"number_of_user\": \"$number_of_user\","
        echo "\"disk_usage\": \"$disk_usage\","
        echo "\"uptime\": \"$uptime_formatted\""
        echo "}"
        echo ""
        echo "}"
    } >> "$file"
    fi
}

# Call function to get system information and write it to a JSON file.
getSystemInfo 

 # Call parseur.sh to get CERT alerts and store them in the database.
bash "$PARSER_DIR/parser.sh"
echo "CERT alerts added to database" > "$LOG_FILE"

# Call historique.py to delete obsolete values in data.json.
python3 "$DATA_DIR/history.py" 
echo "Obsolete values deleted from data.json" >> "$LOG_FILE"

# Call probe.py to add probe data that are in Json to database.
python3 "$GRAPH_DIR/probe.py" 
echo "Probe data added to database" >> "$LOG_FILE"

# Call crisis.sh to check if a crisis is happening and send an email if so.
bash "$CRISIS_DIR/handle_crisis.sh" "$choice" 