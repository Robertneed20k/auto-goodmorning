#!/bin/bash

CONFIG_FILE=~/sms_config.txt

# Function to display the main menu using dialog
show_menu() {
    local options=(
        1 "Phone Number: ${PHONE_NUMBER:-Not set}"
        2 "Message: ${MESSAGE:-Not set}"
        3 "Time: ${HOUR}:${MINUTE} ${AMPM:-Not set}"
        4 "Schedule: ${DAILY:-Not set}"
        5 "Save configuration and exit"
        6 "Exit without saving"
    )

    while true; do
        option=$(dialog \
            --clear \
            --backtitle "SMS Scheduler" \
            --title "Main Menu" \
            --menu "Enter the details for scheduling the SMS:" \
            20 60 10 \
            "${options[@]}" \
            2>&1 >/dev/tty)

        case $option in
            1)
                PHONE_NUMBER=$(dialog --inputbox "Enter phone number:" 8 60 "${PHONE_NUMBER:-}" 2>&1 >/dev/tty)
                validate_phone_number
                ;;
            2)
                MESSAGE=$(dialog --inputbox "Enter message:" 8 60 "${MESSAGE:-}" 2>&1 >/dev/tty)
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
                echo "Invalid option. Please try again."
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
        dialog --msgbox "Invalid phone number. It must be 11 digits." 8 60
        PHONE_NUMBER=""
    fi
}

# Function to setup cron job
setup_cron() {
    # Remove any existing cron job for sms
    crontab -l | grep -v "sms send" | crontab -

    # Extract configuration values
    source "$CONFIG_FILE"

    # Convert time to 24-hour format
    local time_24hr=$(convert_time_to_24hr "$HOUR:$MINUTE $AMPM")
    local hour=$(echo "$time_24hr" | cut -d':' -f1)
    local minute=$(echo "$time_24hr" | cut -d':' -f2)

    if [ "$DAILY" == "yes" ]; then
        (crontab -l 2>/dev/null; echo "$minute $hour * * * ~/bin/sms send") | crontab -
    else
        local start_day=$(echo "$START_DATE" | cut -d'-' -f3)
        local start_month=$(echo "$START_DATE" | cut -d'-' -f2)
        local end_day=$(echo "$END_DATE" | cut -d'-' -f3)
        local end_month=$(echo "$END_DATE" | cut -d'-' -f2)

        (crontab -l 2>/dev/null; echo "$minute $hour $start_day-$end_day $start_month-$end_month * ~/bin/sms send") | crontab -
    fi
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
    dialog --msgbox "Configuration saved." 8 60
    exit 0
}

# Function to display time selection menu using dialog
select_time() {
    HOUR=$(dialog --menu "Select hour:" 20 60 10 \
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

    MINUTE=$(dialog --menu "Select minutes:" 20 60 10 \
        00 "00" \
        15 "15" \
        30 "30" \
        45 "45" \
        2>&1 >/dev/tty)

    AMPM=$(dialog --menu "Select AM or PM:" 20 60 10 \
        AM "AM" \
        PM "PM" \
        2>&1 >/dev/tty)
}

# Function to select schedule type using dialog
select_schedule() {
    DAILY=$(dialog --menu "Select schedule option:" 20 60 10 \
        "Every day" "Every day" \
        "Specific date range" "Specific date range" \
        2>&1 >/dev/tty)

    case $DAILY in
        "Every day")
            START_DATE=""
            END_DATE=""
            ;;
        "Specific date range")
            START_DATE=$(dialog --inputbox "Enter the start date to send the message (YYYY-MM-DD):" 8 60 "${START_DATE:-}" 2>&1 >/dev/tty)
            validate_date "$START_DATE"
            END_DATE=$(dialog --inputbox "Enter the end date to stop sending the message (YYYY-MM-DD):" 8 60 "${END_DATE:-}" 2>&1 >/dev/tty)
            validate_date "$END_DATE"
            ;;
        *)
            echo "Invalid option. Please try again."
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
        dialog --msgbox "Invalid date format. Please enter in YYYY-MM-DD format." 8 60
        echo ""
    fi
}

# Main script execution
initialize_or_load_config
show_menu
