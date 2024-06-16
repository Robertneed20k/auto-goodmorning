#!/bin/bash

# Variables
GITHUB_USER="Robertneed20k"
REPO_NAME="Auto-goodmorning"
BRANCH="main"
FOLDER="sounds"
FILES=("lofi.mp3" "one-piece.mp3" "iphone.mp3" "iphone1.mp3" "pokemon.mp3" "messenger.mp3" "welcome_messages.sh")
DESTINATION_DIR="/data/data/com.termux/files/home/sounds"

# Create destination directory if it doesn't exist
mkdir -p "$DESTINATION_DIR"

# Download each file
for FILE in "${FILES[@]}"; do
    GITHUB_URL="https://raw.githubusercontent.com/$GITHUB_USER/$REPO_NAME/$BRANCH/$FOLDER/$FILE"
    DESTINATION="$DESTINATION_DIR/$FILE"
    
    # Download the file
    curl -L "$GITHUB_URL" -o "$DESTINATION"
    
    # Check if the download was successful
    if [ $? -eq 0 ]; then
        echo "File $FILE downloaded successfully to $DESTINATION"
    else
        echo "Failed to download the file $FILE"
    fi
done
