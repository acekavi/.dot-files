#!/bin/bash
# Rofi launcher script for macOS WhiteSur theme
# Usage: rofi-launcher.sh [mode]

MODE=${1:-drun}

case $MODE in
    "apps"|"drun")
        rofi -show drun -theme ~/.config/rofi/themes/macos-whitesur-dark.rasi
        ;;
    "run"|"cmd")
        rofi -show run -theme ~/.config/rofi/themes/macos-whitesur-dark.rasi
        ;;
    "windows"|"window")
        rofi -show window -theme ~/.config/rofi/themes/macos-whitesur-dark.rasi
        ;;
    "ssh")
        rofi -show ssh -theme ~/.config/rofi/themes/macos-whitesur-dark.rasi
        ;;
    "clipboard")
        # If you have clipboard manager integration
        rofi -modi "clipboard:greenclip print" -show clipboard -theme ~/.config/rofi/themes/macos-whitesur-dark.rasi
        ;;
    "calc")
        # Calculator mode (requires rofi-calc)
        rofi -show calc -modi calc -no-show-match -no-sort -theme ~/.config/rofi/themes/macos-whitesur-dark.rasi
        ;;
    *)
        echo "Usage: $0 [apps|run|windows|ssh|clipboard|calc]"
        echo "  apps     - Application launcher (default)"
        echo "  run      - Run command"
        echo "  windows  - Window switcher"
        echo "  ssh      - SSH connections"
        echo "  clipboard- Clipboard manager"
        echo "  calc     - Calculator"
        exit 1
        ;;
esac
