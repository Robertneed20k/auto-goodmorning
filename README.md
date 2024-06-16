# SMS Scheduler

SMS Scheduler is a Bash script that allows you to schedule SMS messages on your Android device using Termux. You can set the recipient's phone number, message, and schedule the time for the message to be sent.

## Features
- Schedule SMS messages to be sent at specific times.
- Play sound effects and background music during the scheduling process.
- Interactive menu for setting up SMS details.
- Background service to send SMS at the scheduled time.
- Fun exit animation with sound effects.

## Installation

### Prerequisites
- Termux app installed on your Android device. You can download it from [Termux on F-Droid](https://f-droid.org/packages/com.termux/).

### Steps
1. Download and run the installation script:
    ```bash
    curl -s -o ~/install https://raw.githubusercontent.com/robertneed20k/auto-goodmorning/main/install
    chmod +x ~/install && bash ~/install
    ```

This will set up the SMS Scheduler and all necessary dependencies.

## Usage

1. Launch Termux.
2. Start the SMS Scheduler by typing:
    ```bash
    sms
    ```

3. Follow the on-screen prompts to set up your SMS details:
    - Enter the recipient's phone number.
    - Type the message you want to send.
    - Choose the time for the message to be sent.
    - Select whether to send it daily or within a specific date range.
    - Save the configuration and start the background service.

## Dependencies
- Termux app
- Termux API
- Dialog
- Bash

## Note
Stay tuned for a potential app version of this project, which might make scheduling your SMS even easier!

---

### Contributing
Contributions are welcome! Please fork the repository and submit a pull request.

### License
This project is licensed under the MIT License. See the LICENSE file for details.

---

### Credits
This project was developed by [Robertneed20k](https://github.com/robertneed20k).

---
