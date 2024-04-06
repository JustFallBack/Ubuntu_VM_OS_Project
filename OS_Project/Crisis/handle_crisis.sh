#!/bin/bash

CRISIS_DIR="/OS_Project/Crisis" # Fill in the path to the directory to OS_Project.
DATABASE="/OS_Project/main.db" # Fill in the path to the directory to OS_Project.
CHOICE_TXT="$CRISIS_DIR/choice.txt"
LOG_FILE="$CRISIS_DIR/log_handle_crisis.txt"
MAIL="$CRISIS_DIR/mail.py"


# Compare the latest value from the database with the specified value based on the user's choice.
# Default: 1. Number of processes > 200 (crisis.sh hasn't been executed).
check_crisis() {

    local choice=$1

    # Get the specified value from the database based on the user's choice.
    case $choice in
        1)
            specified_value=20
            column="number_of_process"
            ;;
        2)
            specified_value=1
            column="number_of_user"
            ;;
        3)
            specified_value=1200
            column="ram_usage"
            ;;
        *)
            # Should not reach here.
            echo "Invalid choice in handle_crisis.sh" > "$LOG_FILE"
            exit 1
            ;;
    esac

    # Retrieve the latest value from the database.
    latest_value=$(sqlite3 "$DATABASE" "SELECT $column FROM Probe_data ORDER BY dateT DESC LIMIT 1")

    # Check if the latest value exceeds the specified value. If so, send a crisis email.
    case $choice in
        1|2)
            if [ "$latest_value" -gt "$specified_value" ]; then
                python3 "$MAIL" "Crisis detected" "$column exceeded threshold $specified_value"
            fi
            exit 1
            ;;
        3)
            # Extract the integer part of the RAM usage value.
            ram_usage_integer=$(echo "$latest_value" | cut -d ' ' -f 1)

            if [ "$ram_usage_integer" -gt "$specified_value" ]; then
                python3 "$MAIL" "Crisis detected" "$column exceeded threshold $specified_value"
            fi
            exit 1
            ;;
        *)
            # Should not reach here.
            echo "Invalid choice in handle_crisis.sh" > "$LOG_FILE" 
            exit 1
            ;;
    esac
}

main() {
    # Get the user's choice from the choice.txt file. If the file hasn't been created, the default choice is 1.
    if [ -f $CHOICE_TXT ]; then
        choice=$(cat $CHOICE_TXT)
    else
        choice=1
    fi

    # Perform actions based on user's choice (from crisis.sh).
    case $choice in
        1|2|3)
            check_crisis "$choice"
            ;;
        *)
            # Should not reach here.
            echo "Invalid choice in handle_crisis.sh (main)" >> "$LOG_FILE"
            exit 1
            ;;
    esac
}

main "$@"
