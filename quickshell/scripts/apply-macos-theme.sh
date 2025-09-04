#!/usr/bin/env bash
set -e

QUICKSHELL_DIR="$HOME/.config/quickshell"
COMMON_DIR="$QUICKSHELL_DIR/Common"
SETTINGS_FILE="$HOME/.cache/dankshell/settings.json"

echo "Switching to macOS theme..."

# Update shell theme mode in settings
if [ -f "$SETTINGS_FILE" ]; then
    # Update existing settings
    jq '.shellThemeMode = "macOS"' "$SETTINGS_FILE" > "$SETTINGS_FILE.tmp" && mv "$SETTINGS_FILE.tmp" "$SETTINGS_FILE"
else
    # Create new settings file
    mkdir -p "$(dirname "$SETTINGS_FILE")"
    echo '{"shellThemeMode": "macOS"}' > "$SETTINGS_FILE"
fi

# Copy macOS theme as the active theme
cp "$COMMON_DIR/ThemeMac.qml" "$COMMON_DIR/Theme.qml"

# Kill and restart quickshell
pkill -f quickshell || true
sleep 1
quickshell -p "$QUICKSHELL_DIR" &

echo "macOS theme applied successfully!"
