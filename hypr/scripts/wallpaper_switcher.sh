#!/bin/bash
# #######################################################################################
# WORKSPACE WALLPAPER SWITCHER
# Automatically switches wallpapers based on odd/even workspaces
# Integrated with Dracula theme and Hyprpaper
# #######################################################################################

# Configuration
WALLPAPER_DIR="/home/reaper/Pictures/Wallpapers"
ODD_WALLPAPER="$WALLPAPER_DIR/Zoro-01.png"      # Workspaces 1,3,5,7,9
EVEN_WALLPAPER="$WALLPAPER_DIR/Zoro-02.png"     # Workspaces 2,4,6,8,10

# Color scheme for notifications (Dracula colors)
NOTIFICATION_TIMEOUT=2000

# Function to get current workspace
get_current_workspace() {
    hyprctl activewindow -j | jq -r '.workspace.id' 2>/dev/null || echo "1"
}

# Function to check if number is odd
is_odd() {
    [ $(($1 % 2)) -eq 1 ]
}

# Function to send notification (optional)
send_notification() {
    local message="$1"
    local wallpaper_name="$2"
    
    if command -v notify-send >/dev/null 2>&1; then
        notify-send \
            --app-name="Hyprpaper" \
            --expire-time=$NOTIFICATION_TIMEOUT \
            --icon="$wallpaper_name" \
            "Wallpaper Changed" \
            "$message"
    fi
}

# Function to set wallpaper for workspace
set_wallpaper_for_workspace() {
    local workspace=$1
    
    # Default to workspace 1 if no argument provided
    if [ -z "$workspace" ]; then
        workspace=$(get_current_workspace)
    fi
    
    # Determine wallpaper based on odd/even
    if is_odd $workspace; then
        TARGET_WALLPAPER="$ODD_WALLPAPER"
        WORKSPACE_TYPE="Odd"
        WALLPAPER_NAME="Zoro-01"
    else
        TARGET_WALLPAPER="$EVEN_WALLPAPER" 
        WORKSPACE_TYPE="Even"
        WALLPAPER_NAME="Zoro-02"
    fi
    
    # Check if wallpaper file exists
    if [ ! -f "$TARGET_WALLPAPER" ]; then
        echo "ERROR: Wallpaper file not found: $TARGET_WALLPAPER"
        exit 1
    fi
    
    # Set the wallpaper using hyprpaper
    hyprctl hyprpaper wallpaper ",$TARGET_WALLPAPER" >/dev/null 2>&1
    
    # Optional notification
    if [ "$2" = "--notify" ]; then
        send_notification \
            "$WORKSPACE_TYPE workspace ($workspace) - $WALLPAPER_NAME" \
            "$TARGET_WALLPAPER"
    fi
    
    echo "Wallpaper set for workspace $workspace ($WORKSPACE_TYPE): $WALLPAPER_NAME"
}

# Function to preload wallpapers
preload_wallpapers() {
    echo "Preloading wallpapers..."
    hyprctl hyprpaper preload "$ODD_WALLPAPER" 2>/dev/null
    hyprctl hyprpaper preload "$EVEN_WALLPAPER" 2>/dev/null
    echo "Wallpapers preloaded successfully!"
}

# Function to setup workspace monitoring (using hyprctl)
monitor_workspaces() {
    echo "Starting workspace monitoring..."
    
    # Preload wallpapers first
    preload_wallpapers
    
    # Set initial wallpaper
    set_wallpaper_for_workspace $(get_current_workspace)
    
    # Monitor workspace changes
    socat -u UNIX-CONNECT:/tmp/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock - | while read -r line; do
        case $line in
            workspace*)
                workspace=$(echo "$line" | cut -d'>' -f2)
                set_wallpaper_for_workspace "$workspace"
                ;;
        esac
    done
}

# Main script logic
case "$1" in
    "preload")
        preload_wallpapers
        ;;
    "monitor")
        monitor_workspaces
        ;;
    "set")
        if [ -n "$2" ]; then
            set_wallpaper_for_workspace "$2" "$3"
        else
            set_wallpaper_for_workspace $(get_current_workspace) "$3"
        fi
        ;;
    "current")
        set_wallpaper_for_workspace $(get_current_workspace) "--notify"
        ;;
    *)
        echo "Usage: $0 {preload|monitor|set [workspace] [--notify]|current}"
        echo ""
        echo "Commands:"
        echo "  preload  - Preload wallpapers into hyprpaper"
        echo "  monitor  - Start monitoring workspace changes (daemon mode)"  
        echo "  set [ws] - Set wallpaper for specific workspace (or current)"
        echo "  current  - Set wallpaper for current workspace with notification"
        echo ""
        echo "Wallpaper mapping:"
        echo "  Odd workspaces  (1,3,5,7,9): $ODD_WALLPAPER"
        echo "  Even workspaces (2,4,6,8,10): $EVEN_WALLPAPER"
        exit 1
        ;;
esac
