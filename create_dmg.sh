#!/bin/bash

APP_NAME="USBCleaner"
DMG_NAME="$APP_NAME.dmg"
APP_BUNDLE="$APP_NAME.app"

if [ ! -d "$APP_BUNDLE" ]; then
    echo "Error: $APP_BUNDLE not found. Run ./package_app.sh first."
    exit 1
fi

echo "Creating $DMG_NAME..."

# Create a temporary directory for the DMG content
mkdir -p dmg_content
cp -r "$APP_BUNDLE" dmg_content/
ln -s /Applications dmg_content/Applications

# Create the DMG
hdiutil create -volname "$APP_NAME" -srcfolder dmg_content -ov -format UDZO "$DMG_NAME"

# Clean up
rm -rf dmg_content

echo "DMG created at $DMG_NAME"
