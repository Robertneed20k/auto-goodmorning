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

}

# update repository
# Repository information
REPO_URL="git@github.com:Robertneed20k/auto-goodmorning.git"
REPO_PATH="$HOME/auto-goodmorning"
BRANCH="main"

# Commit message
COMMIT_MSG="Auto-update: $(date '+%Y-%m-%d %H:%M:%S')"

# Function to clone the repository if it does not exist
clone_repo() {
    if [ ! -d "$REPO_PATH" ]; then
        echo "Cloning the repository..."
        git clone "$REPO_URL" "$REPO_PATH"
    fi
}

# Function to check if there are any changes
check_changes() {
    cd "$REPO_PATH" || exit
    git fetch origin "$BRANCH"

    # Check for local changes
    if ! git diff-index --quiet HEAD --; then
        return 0
    fi

    # Check for remote changes
    LOCAL=$(git rev-parse @)
    REMOTE=$(git rev-parse @{u})
    BASE=$(git merge-base @ @{u})

    if [ $LOCAL = $REMOTE ]; then
        return 1
    elif [ $LOCAL = $BASE ]; then
        return 0
    elif [ $REMOTE = $BASE ]; then
        return 0
    else
        return 1
    fi
}

# Function to update the repository
update_repo() {
    echo "Updating repository..."
    cd "$REPO_PATH" || exit

    # Pull the latest changes
    git pull origin "$BRANCH"

    # Add all new or modified files
    git add .

    # Commit the changes
    git commit -m "$COMMIT_MSG"

    # Push the changes to the remote repository
    git push origin "$BRANCH"

    echo -e "\e[1;32mRepository updated successfully!\e[0m"
}

# Clone the repository if it does not exist
clone_repo

# Check for changes and update the repository if any are found
if check_changes; then
    update_repo
else
    echo -e "\e[1;32mNo changes detected. Repository is up-to-date.\e[0m"
fi
