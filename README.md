# USBCleaner

USBCleaner is a lightweight macOS utility designed to help you keep your USB drives clean and free of unwanted files. It scans connected drives for hidden system files (like `.DS_Store`, `._*`) and other clutter, allowing you to easily remove them with a single click.

**[Visit the Website](https://ddttom.github.io/usb-cleaner/)**

## Features

- **Scan USB Drives**: Automatically detects and scans selected folders or drives.
- **Identify Clutter**: Finds hidden files and system artifacts that can clutter up non-Mac file systems.
- **One-Click Cleaning**: Quickly delete all identified unwanted files.
- **Universal Build**: Runs natively on both Apple Silicon and Intel Macs.
- **Simple Interface**: Clean and easy-to-use SwiftUI interface.

## Requirements

- macOS 11.0 (Big Sur) or later.

## Installation & Build

To build the application from source, follow these steps:

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/ddttom/usb-cleaner.git
    cd usb-cleaner
    ```

2.  **Build the project:**
    Run the build script to compile the application for both Apple Silicon and Intel architectures.
    ```bash
    ./build.sh
    ```

3.  **Package the application:**
    Create the `.app` bundle.
    ```bash
    ./package_app.sh
    ```

    The `USBCleaner.app` will be created in the current directory.

## Usage

1.  Open `USBCleaner.app`.
2.  Click **Select Disk** to choose the USB drive or folder you want to scan.
3.  The app will list all found hidden/unwanted files.
4.  Click **Clean [N] Files** to delete them permanently.
5.  Once finished, you can eject your drive safely.

## Note

Since this application is not signed with an Apple Developer ID, you may need to right-click the app and select **Open** to bypass macOS security warnings on the first run.

## Privacy & Support

For information about how we handle your data and how to get help, please visit our website:

- **[Privacy Policy](https://ddttom.github.io/usb-cleaner/privacy.html)**
- **[Support](https://ddttom.github.io/usb-cleaner/support.html)**

## Contributing

We welcome contributions! Please see our [Contributing Guidelines](.github/CONTRIBUTING.md) for details on how to submit pull requests, report issues, and suggest improvements.

Please note that this project is released with a [Contributor Code of Conduct](.github/CODE_OF_CONDUCT.md). By participating in this project you agree to abide by its terms.
