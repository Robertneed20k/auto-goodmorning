#!/bin/bash

# Function for animated "ENJOY" message with custom colors
enjoy_animation() {
    clear

    # Define colors and styles
    colors=("37" "34" "36")  # White, Blue, Sky Blue
    reset='\e[0m'

    # Calculate center position for horizontal and vertical alignment
    cols=$(tput cols)
    rows=$(tput lines)
    mid_row=$((rows / 2))
    mid_col=$((cols / 2))

    # Array containing each line of the "ENJOY" big letters
    lines=("  ____  _  ENJOY___  _    _  "
           " |  _ \| | | |/ ___|| |  | |"
           " | | | | | | |\___ \| |  | |"
           " | |_| | |_| | ___) | |__| |"
           " |____/ \___/ |____/ \____/ ")

    # Calculate starting position for the big letters to be centered
    start_row=$((mid_row - ${#lines[@]} / 2))
    start_col=$((mid_col - ${#lines[0]} / 2))

    # Determine the initial color and step size for fading effect
    initial_color=0
    color_step=1

    # Animation loop for faster fading effect
    for ((fade = 0; fade < 6; fade++)); do  # Iterate through 6 levels of fading
        for ((j = 0; j < ${#lines[@]}; j++)); do
            tput cup $((start_row + j)) $start_col

            # Calculate current color index with wrap-around
            color_index=$(( (initial_color + j) % ${#colors[@]} ))

            # Print each line of big letters with the current faded color
            echo -e "\e[1;${colors[$color_index]}m${lines[$j]}${reset}"
        done

        sleep 0.05  # Adjust sleep duration for faster fading effect

        # Increment initial color index for next fading step
        initial_color=$(( (initial_color + color_step) % ${#colors[@]} ))
    done

    clear
}

# Main script execution
enjoy_animation
