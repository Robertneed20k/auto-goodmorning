#!/bin/bash

# Array of welcome messages
welcome_messages=(
    "Welcome to the SMS Scheduler!"
    "Hello! Ready to schedule some SMS?"
    "Greetings! Let's schedule your SMS."
    "Welcome back! Let's manage your SMS."
    "Hello there! Time to schedule some messages."
    "Good day! Let's manage your SMS scheduling."
    "Hi there! Ready to set up SMS schedules?"
    "Welcome! Let's start scheduling your messages."
    "Greetings! Let's manage your SMS scheduling."
    "Hello! Let's set up your SMS schedules."
    "Good day! Ready to manage your SMS schedules."
    "Welcome back! Let's start scheduling SMS."
    "Hello there! Let's manage your SMS scheduling."
    "Greetings! Ready to set up SMS schedules?"
    "Hi there! Let's start managing your SMS."
    "Welcome! Let's manage your SMS scheduling."
    "Hello! Let's schedule some SMS."
    "Good day! Let's set up your SMS schedules."
    "Welcome back! Ready to schedule some messages?"
    "Hello there! Let's set up your SMS schedules."
)

# Select a random message from the array
random_message=${welcome_messages[$RANDOM % ${#welcome_messages[@]}]}

# Display the random message using termux-toast
termux-toast "$random_message"

bash /data/data/com.termux/files/home/bin/sms
