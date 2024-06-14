#!/bin/bash

CONFIG_FILE=~/sms_config.txt

# Function to get user input for configuration
setup_config() {
    read -p "Enter the phone number to send the message to: " phone_number
    read -p "Enter the message to send: " message
    read -p "Enter the time to send the message (HH:MM): " time
    read -p "Enter the date to send the message (YYYY-MM-DD): " date

    echo "PHONE_NUMBER=$phone_number" > $CONFIG_FILE
    echo "MESSAGE=\"$message\"" >> $CONFIG_FILE
    echo "TIME=$time" >> $CONFIG_FILE
    echo "DATE=$date" >> $CONFIG_FILE

    # Set up the cron job based on user input
    setup_cron
}

# Function to setup cron job
setup_cron() {
    # Remove any existing cron job for send_sms.sh
    crontab -l | grep -v "sms send" | crontab -

    # Schedule the new cron job
    minute=$(echo $TIME | cut -d':' -f2)
    hour=$(echo $TIME | cut -d':' -f1)
    day=$(echo $DATE | cut -d'-' -f3)
    month=$(echo $DATE | cut -d'-' -f2)

    (crontab -l 2>/dev/null; echo "$minute $hour $day $month * ~/bin/sms send") | crontab -
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
