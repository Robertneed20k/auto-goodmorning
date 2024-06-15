#!/bin/bash

# Configuration file
CONFIG_FILE="$HOME/sms_config.txt"

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
                        5 "Save configuration and start background sending" \
                        6 "Send Now" \
                        7 "Exit without saving" \
                        2>&1 >/dev/tty)

        clear

        case $OPTION in
            1) enter_phone_number ;;
            2) enter_message ;;
            3) select_time ;;
            4) select_schedule ;;
            5) save_and_schedule ;;
            6) send_now ;;
            7) echo "Exiting without saving..."; exit 0 ;;
            *) show_error "Invalid option. Please try again." ;;
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
        show_error "Invalid phone number. It must be 11 digits."
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
                  01 "01" \
                  02 "02" \
                  03 "03" \
                  04 "04" \
                  05 "05" \
                  06 "06" \
                  07 "07" \
                  08 "08" \
                  09 "09" \
                  10 "10" \
                  11 "11" \
                  12 "12" \
                  2>&1 >/dev/tty)

    MINUTE=$(dialog --clear \
                    --backtitle "SMS Scheduler" \
                    --title "Select Minutes" \
                    --menu "Select minutes:" 15 60 4 \
                    00 "00" \
                    15 "15" \
                    30 "30" \
                    45 "45" \
                    2>&1 >/dev/tty)

    AMPM=$(dialog --clear \
                  --backtitle "SMS Scheduler" \
                  --title "Select AM or PM" \
                  --menu "Select AM or PM:" 15 60 2 \
                  AM "AM" \
                  PM "PM" \
                  2>&1 >/dev/tty)
}

# Function to handle schedule selection
select_schedule() {
    DAILY=$(dialog --clear \
                   --backtitle "SMS Scheduler" \
                   --title "Select Schedule" \
                   --menu "Select schedule option:" 15 60 2 \
                   "Every day" "Every day" \
                   "Specific date range" "Specific date range" \
                   2>&1 >/dev/tty)

    case $DAILY in
        "Every day")
            START_DATE=""
            END_DATE=""
            ;;
        "Specific date range")
            enter_start_date
            enter_end_date
            ;;
        *) show_error "Invalid option. Please try again." ;;
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
        show_error "Invalid date format. Please use YYYY-MM-DD."
        START_DATE=""
        END_DATE=""
    fi
}

# Function to send SMS immediately using Termux
send_now() {
    if [[ -z $PHONE_NUMBER ]]; then
        show_error "Phone number not set. Please enter a valid phone number."
        return
    fi

    if [[ -z $MESSAGE ]]; then
        show_error "Message not set. Please enter a message."
        return
    fi

    termux-sms-send -n "$PHONE_NUMBER" "$MESSAGE"
    show_success "Message sent successfully."
}

# Function to display success message dialog
show_success() {
    local message="$1"
    dialog --clear \
           --backtitle "SMS Scheduler" \
           --title "Success" \
           --msgbox "$message" 10 60 \
           2>&1 >/dev/tty
}

# Function to save configuration and setup cron job
save_and_schedule() {
    save_configuration
    setup_cron
    clear
    echo "Messages will be sent in the background as scheduled."
    exit 0
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
        if [ "$DAILY" == "no" ]; then
            echo "START_DATE=\"$START_DATE\""
            echo "END_DATE=\"$END_DATE\""
        fi
    } > "$CONFIG_FILE"
}

# Function to setup cron job
setup_cron() {
    crontab -l | grep -v "send_sms.sh" | crontab -

    local cron_expression
    if [ "$DAILY" == "yes" ]; then
        cron_expression="$MINUTE $HOUR * * * $HOME/bin/send_sms.sh"
    else
        local start_day=$(date -d "$START_DATE" "+%-d")
        local start_month=$(date -d "$START_DATE" "+%-m")
        local end_day=$(date -d "$END_DATE" "+%-d")
        local end_month=$(date -d "$END_DATE" "+%-m")
        cron_expression="$MINUTE $HOUR $start_day-$end_day $start_month-$end_month * $HOME/bin/send_sms.sh"
    fi

    (crontab -l 2>/dev/null; echo "$cron_expression") | crontab -

    show_success "Configuration saved.\n\nMessages will be sent as scheduled."
}

# Function to display error message dialog
show_error() {
    local message="$1"
    dialog --clear \
           --backtitle "SMS Scheduler" \
           --title "Error" \
           --msgbox "$message" 10 60 \
           2>&1 >/dev/tty
}

# Main script execution
initialize_or_load_config
show_menu
