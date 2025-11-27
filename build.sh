#!/bin/bash

# Build the project for both Apple Silicon and Intel
echo "Building USBCleaner (Universal)..."
swift build -c release --arch arm64 --arch x86_64

# Check if build was successful
if [ $? -eq 0 ]; then
    echo "Build successful!"
    echo "Executable is located at: .build/release/USBCleaner"
    echo "To run the app: ./.build/release/USBCleaner"
else
    echo "Build failed."
    exit 1
fi
