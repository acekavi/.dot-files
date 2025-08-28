#!/bin/bash

# Hyprland Wallpaper Randomizer Script
# Switches wallpapers randomly from ~/Pictures/Wallpapers every time it's run
# Author: GitHub Copilot
# Usage: Run this script to change wallpaper, or set up with systemd timer for automation

WALLPAPER_DIR="$HOME/Pictures/Wallpapers"
HYPRPAPER_CONFIG="$HOME/.config/hypr/hyprpaper.conf"

# Function to check if hyprpaper is running
is_hyprpaper_running() {
    pgrep -x hyprpaper > /dev/null
}

# Function to get random wallpaper
get_random_wallpaper() {
    local wallpapers=()

    # Find all image files in wallpaper directory
    while IFS= read -r -d '' file; do
        wallpapers+=("$file")
    done < <(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.bmp" -o -iname "*.webp" \) -print0 2>/dev/null)

    if [ ${#wallpapers[@]} -eq 0 ]; then
        return 1
    fi

    # Select random wallpaper
    local random_index=$((RANDOM % ${#wallpapers[@]}))
    echo "${wallpapers[$random_index]}"
}

# Function to update hyprpaper config
update_hyprpaper_config() {
    local wallpaper_path="$1"

    cat > "$HYPRPAPER_CONFIG" << EOF
# Hyprpaper Configuration
# This file is dynamically updated by the wallpaper randomizer script
# Last updated: $(date)

# Preload wallpaper
preload = $wallpaper_path

# Set wallpaper for all monitors
wallpaper = ,$wallpaper_path

# Enable IPC for dynamic wallpaper changes
ipc = on

# Splash screen settings
splash = false
splash_offset = 2.0
EOF

}

# Function to reload hyprpaper
reload_hyprpaper() {
    if is_hyprpaper_running; then
        # Kill hyprpaper gracefully
        pkill hyprpaper
        sleep 1

        # Start hyprpaper again
        hyprpaper &
    else
        hyprpaper &
    fi
}

# Function to change wallpaper using hyprctl (if hyprpaper is already running)
change_wallpaper_live() {
    local wallpaper_path="$1"

    if is_hyprpaper_running && command -v hyprctl >/dev/null 2>&1; then
        # Try to preload the new wallpaper
        if hyprctl hyprpaper preload "$wallpaper_path" 2>/dev/null; then
            # Set the wallpaper for all monitors
            if hyprctl hyprpaper wallpaper ",$wallpaper_path" 2>/dev/null; then
                return 0
            fi
        fi
    fi
    return 1
}

# Main function
main() {
    # Check if wallpaper directory exists
    if [ ! -d "$WALLPAPER_DIR" ]; then
        exit 1
    fi

    # Get random wallpaper
    RANDOM_WALLPAPER=$(get_random_wallpaper)
    if [ $? -ne 0 ] || [ -z "$RANDOM_WALLPAPER" ]; then
        exit 1
    fi
    # Try to change wallpaper live first (faster)
    if change_wallpaper_live "$RANDOM_WALLPAPER"; then
        # Also update config for next restart
        update_hyprpaper_config "$RANDOM_WALLPAPER"
    else
        # Fallback: update config and reload hyprpaper
        update_hyprpaper_config "$RANDOM_WALLPAPER"
        reload_hyprpaper
    fi
}

# Handle command line arguments
case "${1:-}" in
    "--help"|"-h")
        echo "Hyprland Wallpaper Randomizer"
        echo "Usage: $0 [options]"
        echo ""
        echo "Options:"
        echo "  -h, --help     Show this help message"
        echo "  --status       Show current wallpaper status"
        echo ""
        echo "Configuration:"
        echo "  Wallpaper directory: $WALLPAPER_DIR"
        echo "  Config file: $HYPRPAPER_CONFIG"
        ;;
    "--status")
        echo "Wallpaper Randomizer Status:"
        echo "Wallpaper directory: $WALLPAPER_DIR"
        echo "Config file: $HYPRPAPER_CONFIG"
        echo "Hyprpaper running: $(is_hyprpaper_running && echo "Yes" || echo "No")"
        if [ -f "$HYPRPAPER_CONFIG" ]; then
            echo "Current wallpaper: $(grep "^wallpaper" "$HYPRPAPER_CONFIG" | cut -d',' -f2 | xargs)"
        fi
        echo "Available wallpapers: $(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.bmp" -o -iname "*.webp" \) 2>/dev/null | wc -l)"
        ;;
    *)
        main
        ;;
esac
