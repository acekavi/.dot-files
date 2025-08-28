#!/bin/bash

# Hyprland Wallpaper Control Script
# Provides easy commands to control the wallpaper cycler

SCRIPT_DIR="/home/acekavi/.config/hypr/scripts"
CYCLER_SCRIPT="$SCRIPT_DIR/wallpaper-randomizer.sh"

show_help() {
    echo "Hyprland Wallpaper Control"
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  change, next    Change to next wallpaper in sequence"
    echo "  status          Show current wallpaper and timer status"
    echo "  reset           Reset cycle to first wallpaper"
    echo "  start           Start the automatic timer"
    echo "  stop            Stop the automatic timer"
    echo "  restart         Restart the automatic timer"
    echo "  enable          Enable timer to start on boot"
    echo "  disable         Disable timer from starting on boot"
    echo "  help            Show this help message"
}

case "${1:-help}" in
    "change"|"next")
        echo "Changing to next wallpaper..."
        "$CYCLER_SCRIPT"
        ;;
    "status")
        echo "=== Wallpaper Status ==="
        "$CYCLER_SCRIPT" --status
        echo ""
        echo "=== Timer Status ==="
        systemctl --user status wallpaper-randomizer.timer --no-pager -l
        ;;
    "reset")
        echo "=== Resetting Wallpaper Cycle ==="
        "$CYCLER_SCRIPT" --reset
        ;;
    "start")
        echo "Starting wallpaper timer..."
        systemctl --user start wallpaper-randomizer.timer
        echo "Timer started."
        ;;
    "stop")
        echo "Stopping wallpaper timer..."
        systemctl --user stop wallpaper-randomizer.timer
        echo "Timer stopped."
        ;;
    "restart")
        echo "Restarting wallpaper timer..."
        systemctl --user restart wallpaper-randomizer.timer
        echo "Timer restarted."
        ;;
    "enable")
        echo "Enabling wallpaper timer to start on boot..."
        systemctl --user enable wallpaper-randomizer.timer
        echo "Timer enabled."
        ;;
    "disable")
        echo "Disabling wallpaper timer from starting on boot..."
        systemctl --user disable wallpaper-randomizer.timer
        echo "Timer disabled."
        ;;
    "help"|"-h"|"--help")
        show_help
        ;;
    *)
        echo "Unknown command: $1"
        echo ""
        show_help
        exit 1
        ;;
esac
