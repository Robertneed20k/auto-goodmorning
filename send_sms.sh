#!/bin/bash

# Function to check for updates
function check_for_updates() {
    echo "Checking for updates..."
    curl -s -o ~/update.sh https://raw.githubusercontent.com/robertneed20k/auto-goodmorning/main/update.sh
    chmod +x ~/update.sh
    ~/update.sh
}

# Call function to check for updates before displaying the main menu
check_for_updates

# welcome script
bash ~/$home/sounds/welcome_messages.sh

# Configuration file
CONFIG_FILE="$HOME/sms_config.txt"

# Paths to sound effect and music files
MUSIC_FILES=(
    "$HOME/sounds/lofi.mp3"
    
)
SEND_EXIT_SOUND_FILES=(
    "$HOME/sounds/iphone1.mp3"
    "$HOME/sounds/iphone.mp3"
)

# Function to play a random music file from a given array of files
play_random_music() {
    local files=("$@")
    local random_file=${files[RANDOM % ${#files[@]}]}
    termux-media-player stop
    termux-media-player play "$random_file"
}

# Function to display an error message and exit
show_error_and_exit() {
    local message="$1"
    dialog --clear --backtitle "SMS Scheduler" --title "Error" --msgbox "$message" 10 60
    exit 1
}

# Function to display the main menu using dialog
show_menu() {
    while true; do
        OPTION=$(dialog --clear \
                        --backtitle "SMS Scheduler" \
                        --title "Main Menu" \
                        --menu "Enter the details for scheduling the SMS:" 15 60 7 \
                        1 "Phone Number: ${PHONE_NUMBER:-Not set}" \
                        2 "Message: ${MESSAGE:-Not set}" \
                        3 "Time: ${HOUR}:${MINUTE} ${AMPM:-Not set}" \
                        4 "Schedule: ${DAILY:-Not set}" \
                        5 "Save and start background sending" \
                        6 "Send Now (for testing)" \
                        7 "Exit Menu" \
                        2>&1 >/dev/tty)

        clear

        case $OPTION in
            1) enter_phone_number ;;
            2) enter_message ;;
            3) select_time ;;
            4) select_schedule ;;
            5) save_and_schedule ;;
            6) send_now ;;
            7) cool_exit ;;
            *) show_error_and_exit "Invalid option. Please try again." ;;
        esac
    done
}

# Function to handle phone number input
enter_phone_number() {
    PHONE_NUMBER=$(dialog --clear \
                         --backtitle "SMS Scheduler" \
                         --title "Phone Number" \
                         --inputbox "Enter phone number (11 digits):" 10 60 "${PHONE_NUMBER:-}" \
                         2>&1 >/dev/tty)
    validate_phone_number
}

# Function to validate phone number format
validate_phone_number() {
    if [[ ! $PHONE_NUMBER =~ ^[0-9]{11}$ ]]; then
        dialog --clear --backtitle "SMS Scheduler" --title "Error" --msgbox "Invalid phone number. It must be 11 digits." 10 60
        PHONE_NUMBER=""
    fi
}

# Function to handle message input
enter_message() {
    MESSAGE=$(dialog --clear \
                     --backtitle "SMS Scheduler" \
                     --title "Message" \
                     --inputbox "Enter message:" 10 60 "${MESSAGE:-}" \
                     2>&1 >/dev/tty)
}

# Function to handle time selection
select_time() {
    HOUR=$(dialog --clear \
                  --backtitle "SMS Scheduler" \
                  --title "Select Hour" \
                  --menu "Select hour:" 15 60 12 \
                  01 "01" 02 "02" 03 "03" 04 "04" 05 "05" 06 "06" \
                  07 "07" 08 "08" 09 "09" 10 "10" 11 "11" 12 "12" \
                  2>&1 >/dev/tty)

    MINUTE=$(dialog --clear \
                    --backtitle "SMS Scheduler" \
                    --title "Enter Minutes" \
                    --inputbox "Enter minutes (00-59):" 10 60 "${MINUTE:-}" \
                    2>&1 >/dev/tty)

    AMPM=$(dialog --clear \
                  --backtitle "SMS Scheduler" \
                  --title "Select AM or PM" \
                  --menu "Select AM or PM:" 15 60 2 \
                  AM "AM" PM "PM" \
                  2>&1 >/dev/tty)
}

# Function to handle schedule selection
select_schedule() {
    DAILY=$(dialog --clear \
                   --backtitle "SMS Scheduler" \
                   --title "Select Schedule" \
                   --menu "Select schedule option:" 15 60 2 \
                   1 "Every day" 2 "Specific date range" \
                   2>&1 >/dev/tty)

    case $DAILY in
        1)
            DAILY="Every day"
            START_DATE=""
            END_DATE=""
            ;;
        2)
            DAILY="Specific date range"
            enter_start_date
            enter_end_date
            ;;
        *) show_error_and_exit "Invalid option. Please try again." ;;
    esac
}

# Function to handle start date input
enter_start_date() {
    START_DATE=$(dialog --clear \
                        --backtitle "SMS Scheduler" \
                        --title "Start Date" \
                        --inputbox "Enter start date (YYYY-MM-DD):" 10 60 "${START_DATE:-}" \
                        2>&1 >/dev/tty)
    validate_date "$START_DATE"
}

# Function to handle end date input
enter_end_date() {
    END_DATE=$(dialog --clear \
                      --backtitle "SMS Scheduler" \
                      --title "End Date" \
                      --inputbox "Enter end date (YYYY-MM-DD):" 10 60 "${END_DATE:-}" \
                      2>&1 >/dev/tty)
    validate_date "$END_DATE"
}

# Function to validate date format
validate_date() {
    local date=$1
    if ! date -d "$date" >/dev/null 2>&1; then
        dialog --clear --backtitle "SMS Scheduler" --title "Error" --msgbox "Invalid date format. Please use YYYY-MM-DD." 10 60
        if [[ $DAILY == "Specific date range" ]]; then
            START_DATE=""
            END_DATE=""
        fi
    fi
}

# Function to send SMS immediately using Termux
send_now() {
    if [[ -z $PHONE_NUMBER ]]; then
        dialog --clear --backtitle "SMS Scheduler" --title "Error" --msgbox "Phone number not set. Please enter a valid phone number." 10 60
        return
    fi

    if [[ -z $MESSAGE ]]; then
        dialog --clear --backtitle "SMS Scheduler" --title "Error" --msgbox "Message not set. Please enter a message." 10 60
        return
    fi

    termux-sms-send -n "$PHONE_NUMBER" "$MESSAGE"
    play_random_music "${SEND_EXIT_SOUND_FILES[@]}"
    show_success "Message sent successfully."
}

# Function to display success message dialog
show_success() {
    local message="$1"
    dialog --clear --backtitle "SMS Scheduler" --title "Success" --msgbox "$message" 10 60
}

# Function to save configuration and setup background sending
save_and_schedule() {
    save_configuration
    start_background_sending &
    clear
    echo "Messages will be sent in the background as scheduled."
    cool_exit
}

# Function to save configuration to file
save_configuration() {
    echo "Saving configuration..."
    {
        echo "PHONE_NUMBER=\"$PHONE_NUMBER\""
        echo "MESSAGE=\"$MESSAGE\""
        echo "HOUR=\"$HOUR\""
        echo "MINUTE=\"$MINUTE\""
        echo "AMPM=\"$AMPM\""
        echo "DAILY=\"$DAILY\""
        if [ "$DAILY" == "Specific date range" ]; then
            echo "START_DATE=\"$START_DATE\""
            echo "END_DATE=\"$END_DATE\""
        fi
    } > "$CONFIG_FILE"
}

# Function to start background sending based on schedule
start_background_sending() {
    while true; do
        current_hour=$(date +%I)
        current_minute=$(date +%M)
        current_ampm=$(date +%p | tr '[:lower:]' '[:upper:]')
        
        if [[ "$current_hour" == "$HOUR" && "$current_minute" == "$MINUTE" && "$current_ampm" == "$AMPM" ]]; then
            termux-sms-send -n "$PHONE_NUMBER" "$MESSAGE"
            echo "Sent SMS to $PHONE_NUMBER: $MESSAGE"
            sleep 60  # Sleep for 60 seconds to prevent repeated sending in the same minute
        fi
        
        sleep 10  # Check every 10 seconds
    done
}
# Function for cool exit animation
cool_exit() {
    # Run the ASCII animation
    bash ~/$home/exit.sh
    
    # Play the exit sound effect
    play_random_music "${SEND_EXIT_SOUND_FILES[@]}"

    # Define the animation frames
    frames=(
        "Thank you for using SMS Scheduler!"
        "Goodbye!"
    )

    # Loop through frames with delays for animation effect
    for frame in "${frames[@]}"; do
        echo "$frame"
        sleep 1
        clear
    done

    exit 0

}

# Start background music when script is launched
play_random_music "${MUSIC_FILES[@]}"

# Main script execution
show_menu
