# USBCleaner Roadmap

This document outlines potential improvements and features to enhance USBCleaner.

## 🚀 Features

### Enhanced Cleaning

- **Custom Blocklist**: Allow users to define which file extensions or names to ignore (e.g., preserve `.git` repositories).

### User Experience

- **Drag & Drop**: Allow users to drag a drive icon directly onto the app window to start scanning.
- **Auto-Eject**: Add an option to automatically eject the drive after a successful clean.

### Safety & History

- **Trash Integration**: Option to move files to the Trash instead of permanently deleting them immediately.

## 🛠 Technical Improvements

- **Unit Tests**: Add comprehensive tests for `FileScanner` to ensure it correctly identifies (and ignores) specific files.
- **Localization**: Prepare the app for translation into other languages.
- **Notarization**: Set up Apple Notarization (requires Developer ID) to remove security warnings for other users.
- **Sparkle Integration**: Add an auto-updater mechanism.

## 📦 Distribution

- **Homebrew Cask**: Submit the app to Homebrew for easy installation via `brew install --cask usb-cleaner`.
