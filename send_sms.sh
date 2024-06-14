#!/bin/bash

CONFIG_FILE=~/sms_config.txt

# Function to get user input for configuration
setup_config() {
    while true; do
        echo "Enter the details for scheduling the SMS:"
        
        read -p "Enter the phone number to send the message to: " phone_number
        read -p "Enter the message to send: " message
        read -p "Enter the time to send the message (HH:MM AM/PM): " time
        read -p "Do you want to send the message every day? (yes/no): " daily

        if [ "$daily" == "no" ]; then
            read -p "Enter the start date to send the message (YYYY-MM-DD): " start_date
            read -p "Enter the end date to stop sending the message (YYYY-MM-DD): " end_date
        fi

        echo "Summary of your input:"
        echo "Phone Number: $phone_number"
        echo "Message: $message"
        echo "Time: $time"
        [ "$daily" == "yes" ] && echo "Schedule: Daily" || echo "Start Date: $start_date" && echo "End Date: $end_date"
        
        read -p "Is this information correct? (yes to confirm, no to re-enter): " confirm
        if [ "$confirm" == "yes" ]; then
            break
        fi
    done

    # Save configuration
    echo "PHONE_NUMBER=$phone_number" > $CONFIG_FILE
    echo "MESSAGE=\"$message\"" >> $CONFIG_FILE
    echo "TIME=$time" >> $CONFIG_FILE
    echo "DAILY=$daily" >> $CONFIG_FILE
    [ "$daily" == "no" ] && echo "START_DATE=$start_date" >> $CONFIG_FILE && echo "END_DATE=$end_date" >> $CONFIG_FILE

    # Set up the cron job based on user input
    setup_cron
}

# Function to convert time to 24-hour format
convert_time_to_24hr() {
    local time=$1
    local hour=$(echo $time | cut -d':' -f1)
    local minute=$(echo $time | cut -d':' -f2 | cut -d' ' -f1)
    local ampm=$(echo $time | cut -d' ' -f2 | tr '[:lower:]' '[:upper:]')

    if [ "$ampm" == "PM" ] && [ $hour -ne 12 ]; then
        hour=$((hour + 12))
    elif [ "$ampm" == "AM" ] && [ $hour -eq 12 ]; then
        hour=0
    fi

    printf "%02d:%02d" $hour $minute
}

# Function to setup cron job
setup_cron() {
    # Remove any existing cron job for sms
    crontab -l | grep -v "sms send" | crontab -

    # Extract configuration values
    source $CONFIG_FILE
    local time_24hr=$(convert_time_to_24hr "$TIME")
    local hour=$(echo $time_24hr | cut -d':' -f1)
    local minute=$(echo $time_24hr | cut -d':' -f2)

    if [ "$DAILY" == "yes" ]; then
        (crontab -l 2>/dev/null; echo "$minute $hour * * * ~/bin/sms send") | crontab -
    else
        local start_day=$(echo $START_DATE | cut -d'-' -f3)
        local start_month=$(echo $START_DATE | cut -d'-' -f2)
        local end_day=$(echo $END_DATE | cut -d'-' -f3)
        local end_month=$(echo $END_DATE | cut -d'-' -f2)

        (crontab -l 2>/dev/null; echo "$minute $hour $start_day-$end_day $start_month-$end_month * ~/bin/sms send") | crontab -
    fi
}

# Function to send the SMS
send_sms() {
    source $CONFIG_FILE
    termux-sms-send -n $PHONE_NUMBER "$MESSAGE"
}

# Main script execution
if [ "$1" == "send" ]; then
    send_sms
else
    setup_config
fi
