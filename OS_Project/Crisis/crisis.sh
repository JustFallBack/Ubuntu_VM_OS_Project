#!/bin/bash


LOG_FILE="/OS_Project/Crisis/log_crisis.txt" # Fill in the path to the directory to OS_Project.
CHOICE_TXT="/OS_Project/Crisis/choice.txt" # Fill in the path to the directory to OS_Project.

# Function to get user's choice.
get_user_choice() {
    read -p "Enter your choice (1-3): " choice
    # Validate user input
    if [[ "$choice" =~ ^[1-3]$ ]]; then
        return "$choice"
    else
        echo "Invalid choice. Please enter a number between 1 and 3."
        get_user_choice
    fi
}

main() {
    echo "Select the crisis requirement:"
    echo "1. Number of processes > 200"
    echo "2. Number of users > 1"
    echo "3. RAM usage > 1200 MB"
    get_user_choice
    # "$?" contains the return value of the last command (get_user_choice).
    choice="$?"

    # Perform actions based on user's choice.
    case $choice in
        1)
            echo "1" > $CHOICE_TXT
            ;;
        2)
            echo "2" > $CHOICE_TXT
            ;;
        3)
            echo "3" > $CHOICE_TXT
            ;;
        *)
            # Should not reach here.
            echo "Invalid choice in crisis.sh" >> "$LOG_FILE"
            exit 1
            ;;
    esac
}

main
