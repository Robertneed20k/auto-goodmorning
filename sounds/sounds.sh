#!/bin/bash

# Variables
GITHUB_URL="https://raw.githubusercontent.com/sample-user/sample-repo/main/audio/music.mp3"
DESTINATION="/data/data/com.termux/files/home/music.mp3"

# Create destination directory if it doesn't exist
mkdir -p $(dirname "$DESTINATION")

# Download the file
curl -L $GITHUB_URL -o $DESTINATION

# Check if the download was successful
if [ $? -eq 0 ]; then
    echo "File downloaded successfully to $DESTINATION"
else
    echo "Failed to download the file"
fi
