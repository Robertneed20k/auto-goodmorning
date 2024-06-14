#!/bin/bash

# Configuration file
CONFIG_FILE=~/sms_config.txt

# Function to display the main menu using dialog
show_menu() {
    while true; do
        # Display the main menu
        OPTION=$(dialog --clear \
                        --backtitle "SMS Scheduler" \
                        --title "Main Menu" \
                        --menu "Enter the details for scheduling the SMS:" 15 60 6 \
                        1 "Phone Number: ${PHONE_NUMBER:-Not set}" \
                        2 "Message: ${MESSAGE:-Not set}" \
                        3 "Time: ${HOUR}:${MINUTE} ${AMPM:-Not set}" \
                        4 "Schedule: ${DAILY:-Not set}" \
                        5 "Save configuration and exit" \
                        6 "Exit without saving" \
                        2>&1 >/dev/tty)

        # Clear the screen after dialog exits
        clear

        # Handle user selection
        case $OPTION in
            1)
                PHONE_NUMBER=$(dialog --clear \
                                     --backtitle "SMS Scheduler" \
                                     --title "Phone Number" \
                                     --inputbox "Enter phone number:" 10 60 "${PHONE_NUMBER:-}" \
                                     2>&1 >/dev/tty)
                validate_phone_number
                ;;
            2)
                MESSAGE=$(dialog --clear \
                                 --backtitle "SMS Scheduler" \
                                 --title "Message" \
                                 --inputbox "Enter message:" 10 60 "${MESSAGE:-}" \
                                 2>&1 >/dev/tty)
                ;;
            3)
                select_time
                ;;
            4)
                select_schedule
                ;;
            5)
                save_configuration
                ;;
            6)
                echo "Exiting without saving..."
                exit 0
                ;;
            *)
                dialog --clear \
                       --backtitle "SMS Scheduler" \
                       --title "Error" \
                       --msgbox "Invalid option. Please try again." 10 60 \
                       2>&1 >/dev/tty
                ;;
        esac
    done
}

# Function to initialize or load configuration
initialize_or_load_config() {
    if [ -f "$CONFIG_FILE" ]; then
        source "$CONFIG_FILE"
    else
        initialize_config
    fi
}

# Function to initialize default configuration
initialize_config() {
    PHONE_NUMBER=""
    MESSAGE=""
    HOUR=""
    MINUTE=""
    AMPM=""
    DAILY=""
    START_DATE=""
    END_DATE=""
}

# Function to validate phone number
validate_phone_number() {
    if [[ ! $PHONE_NUMBER =~ ^[0-9]{11}$ ]]; then
        dialog --clear \
               --backtitle "SMS Scheduler" \
               --title "Error" \
               --msgbox "Invalid phone number. It must be 11 digits." 10 60 \
               2>&1 >/dev/tty
        PHONE_NUMBER=""
    fi
}

# Function to setup cron job
setup_cron() {
    # Remove any existing cron job for sms
    crontab -l | grep -v "send_sms.sh" | crontab -

    # Extract configuration values
    source "$CONFIG_FILE"

    # Convert time to 24-hour format
    local time_24hr=$(convert_time_to_24hr "$HOUR:$MINUTE $AMPM")
    local hour=$(echo "$time_24hr" | cut -d':' -f1)
    local minute=$(echo "$time_24hr" | cut -d':' -f2)

    if [ "$DAILY" == "yes" ]; then
        (crontab -l 2>/dev/null; echo "$minute $hour * * * ~/bin/send_sms.sh") | crontab -
    else
        local start_day=$(echo "$START_DATE" | cut -d'-' -f3)
        local start_month=$(echo "$START_DATE" | cut -d'-' -f2)
        local end_day=$(echo "$END_DATE" | cut -d'-' -f3)
        local end_month=$(echo "$END_DATE" | cut -d'-' -f2)

        (crontab -l 2>/dev/null; echo "$minute $hour $start_day-$end_day $start_month-$end_month * ~/bin/send_sms.sh") | crontab -
    fi

    dialog --clear \
           --backtitle "SMS Scheduler" \
           --title "Success" \
           --msgbox "Configuration saved.\n\nMessages will be sent as scheduled." 10 60 \
           2>&1 >/dev/tty
}

# Function to save configuration
save_configuration() {
    echo "Saving configuration..."
    echo "PHONE_NUMBER=\"$PHONE_NUMBER\"" > "$CONFIG_FILE"
    echo "MESSAGE=\"$MESSAGE\"" >> "$CONFIG_FILE"
    echo "HOUR=\"$HOUR\"" >> "$CONFIG_FILE"
    echo "MINUTE=\"$MINUTE\"" >> "$CONFIG_FILE"
    echo "AMPM=\"$AMPM\"" >> "$CONFIG_FILE"
    echo "DAILY=\"$DAILY\"" >> "$CONFIG_FILE"
    if [ "$DAILY" == "no" ]; then
        echo "START_DATE=\"$START_DATE\"" >> "$CONFIG_FILE"
        echo "END_DATE=\"$END_DATE\"" >> "$CONFIG_FILE"
    fi
    setup_cron
    clear  # Clear the screen after setup_cron dialog
    exit 0
}

# Function to display time selection menu using dialog
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

# Function to select schedule type using dialog
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
            START_DATE=$(dialog --clear \
                                --backtitle "SMS Scheduler" \
                                --title "Start Date" \
                                --inputbox "Enter the start date to send the message (YYYY-MM-DD):" 10 60 "${START_DATE:-}" \
                                2>&1 >/dev/tty)
            validate_date "$START_DATE"

            END_DATE=$(dialog --clear \
                              --backtitle "SMS Scheduler" \
                              --title "End Date" \
                              --inputbox "Enter the end date to stop sending the message (YYYY-MM-DD):" 10 60 "${END_DATE:-}" \
                              2>&1 >/dev/tty)
            validate_date "$END_DATE"
            ;;
        *)
            dialog --clear \
                   --backtitle "SMS Scheduler" \
                   --title "Error" \
                   --msgbox "Invalid option. Please try again." 10 60 \
                   2>&1 >/dev/tty
            ;;
    esac
}

# Function to convert time to 24-hour format
convert_time_to_24hr() {
    local time12=$1
    local time24=$(date -d "$time12" +%H:%M 2>/dev/null)
    echo ${time24:-invalid}
}

# Function to validate date
validate_date() {
    local date=$1
    if ! date -d "$date" >/dev/null 2>&1; then
        dialog --clear \
               --backtitle "SMS Scheduler" \
               --title "Error" \
               --msgbox "Invalid date format. Please enter in YYYY-MM-DD format." 10 60 \
               2>&1 >/dev/tty
        echo ""
    fi
}

# Main script execution
initialize_or_load_config
show_menu
