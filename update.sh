#!/bin/bash

# URL of the latest version of the script
SCRIPT_URL="https://raw.githubusercontent.com/robertneed20k/auto-goodmorning/main/send_sms.sh"

# Path to the current script
SCRIPT_PATH="$PREFIX/bin/sms"

# Function to check internet connection
check_internet() {
    echo "Checking for internet connection..."
    wget -q --spider http://google.com

    if [ $? -eq 0 ]; then
        echo -e "\e[1;32mInternet connection available.\e[0m"
        return 0
    else
        echo -e "\e[1;31mNo internet connection. Cannot check for updates.\e[0m"
        return 1
    fi
}

# Function to update the script
update_script() {
    echo "Checking for updates..."
    curl -s -o ~/sms_latest.sh "$SCRIPT_URL"

    if ! cmp -s ~/sms_latest.sh "$SCRIPT_PATH"; then
        echo -e "\e[1;32mNew version found. Updating...\e[0m"
        mv ~/sms_latest.sh "$SCRIPT_PATH"
        chmod +x "$SCRIPT_PATH"
        echo -e "\e[1;32mUpdate complete!\e[0m"
    else
        echo -e "\e[1;32mYou are already using the latest version.\e[0m"
        rm ~/sms_latest.sh
    fi
}

# Call the functions
if check_internet; then
    update_script
fi
