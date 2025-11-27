# USBCleaner

USBCleaner is a lightweight macOS utility designed to help you keep your USB drives clean and free of unwanted files. It scans connected drives for hidden system files (like `.DS_Store`, `._*`) and other clutter, allowing you to easily remove them with a single click.

**[Visit the Website](https://ddttom.github.io/usb-cleaner/)**

## Features

- **Scan USB Drives**: Automatically detects and scans selected folders or drives.
- **Deep Scan**: Recursively scan subfolders to find hidden files everywhere.
- **Identify Clutter**: Finds hidden macOS files (`.DS_Store`, `._*`) and Windows junk (`Thumbs.db`, `$RECYCLE.BIN`).
- **Preview & Select**: Review found files and choose which ones to keep or delete.
- **Cleaning History**: Track your lifetime cleaning stats (files and space recovered).
- **One-Click Cleaning**: Quickly delete all identified unwanted files with sound and haptic feedback.
- **Universal Build**: Runs natively on both Apple Silicon and Intel Macs.
- **Simple Interface**: Clean and easy-to-use SwiftUI interface with Dark Mode support.

## Requirements

- macOS 13.0 (Ventura) or later.

## Installation & Build

To build the application from source, follow these steps:

1. **Clone the repository:**

    ```bash
    git clone https://github.com/ddttom/usb-cleaner.git
    cd usb-cleaner
    ```

2. **Build the project:**
    Run the build script to compile the application for both Apple Silicon and Intel architectures.

    ```bash
    ./build.sh
    ```

3. **Package the application:**
    Create the `.app` bundle and a `.dmg` installer.

    ```bash
    ./package_app.sh
    ./create_dmg.sh
    ```

    The `USBCleaner.dmg` will be created in the current directory.

## Usage

1. Open `USBCleaner.app`.
2. Click **Select Disk** to choose the USB drive or folder you want to scan.
3. The app will list all found hidden/unwanted files.
4. (Optional) Uncheck any files you wish to keep.
5. Click **Clean [N] Files** to delete them permanently.
6. Once finished, you can eject your drive safely.

## Note

Since this application is ad-hoc signed (self-signed) and not notarized by Apple, you may need to right-click the app and select **Open** to bypass macOS security warnings on the first run, especially if you move the app to another computer.

## Privacy & Support

For information about how we handle your data and how to get help, please visit our website:

- **[Privacy Policy](https://ddttom.github.io/usb-cleaner/privacy.html)**
- **[Support](https://ddttom.github.io/usb-cleaner/support.html)**

## Contributing

We welcome contributions! Please see our [Contributing Guidelines](.github/CONTRIBUTING.md) for details on how to submit pull requests, report issues, and suggest improvements.

Please note that this project is released with a [Contributor Code of Conduct](.github/CODE_OF_CONDUCT.md). By participating in this project you agree to abide by its terms.
