#!/usr/bin/env bash
set -e

QUICKSHELL_DIR="$HOME/.config/quickshell"
COMMON_DIR="$QUICKSHELL_DIR/Common"
SETTINGS_FILE="$HOME/.cache/dankshell/settings.json"
HYPR_DIR="$HOME/.config/hypr"

# Function to show usage
usage() {
    echo "Usage: $0 [material|macos]"
    echo "Switch between Material Design and macOS themes"
    exit 1
}

# Check argument
if [ $# -ne 1 ]; then
    usage
fi

THEME="$1"

case "$THEME" in
    material)
        echo "Switching to Material Design theme..."
        
        # Update shell theme mode in settings
        if [ -f "$SETTINGS_FILE" ]; then
            jq '.shellThemeMode = "material"' "$SETTINGS_FILE" > "$SETTINGS_FILE.tmp" && mv "$SETTINGS_FILE.tmp" "$SETTINGS_FILE"
        else
            mkdir -p "$(dirname "$SETTINGS_FILE")"
            echo '{"shellThemeMode": "material"}' > "$SETTINGS_FILE"
        fi
        
        # Copy Material theme as the active theme
        cp "$COMMON_DIR/ThemeMaterial.qml" "$COMMON_DIR/Theme.qml"
        
        # Restore default Hyprland theme
        cat > "$HYPR_DIR/theme.conf" << 'EOF'
# Default Material Design theme configuration
decoration {
    rounding = 12
    active_opacity = 1.0
    inactive_opacity = 0.97
    
    blur {
        enabled = yes
        size = 8
        passes = 2
        ignore_opacity = no
        new_optimizations = on
    }
    
    # Shadows are now configured per-window in rules
}

general {
    gaps_in = 4
    gaps_out = 8
    border_size = 2
    col.active_border = rgba(8AB4F8FF) rgba(8AB4F8FF) 45deg
    col.inactive_border = rgba(44464F66)
}

animations {
    enabled = yes
    bezier = overshot, 0.05, 0.9, 0.1, 1.05
    bezier = smoothOut, 0.5, 0, 0.99, 0.99
    bezier = smoothIn, 0.5, -0.5, 0.68, 1.5
    
    animation = windows, 1, 4, overshot, slide
    animation = windowsOut, 1, 4, smoothOut, slide
    animation = windowsIn, 1, 4, smoothOut, slide
    animation = windowsMove, 1, 4, smoothIn, slide
    animation = border, 1, 5, default
    animation = fade, 1, 5, smoothIn
    animation = fadeDim, 1, 5, smoothIn
    animation = workspaces, 1, 4, overshot, slidevert
    animation = specialWorkspace, 1, 4, overshot, slidevert
}

misc {
    disable_hyprland_logo = false
    disable_splash_rendering = false
    animate_manual_resizes = yes
    animate_mouse_windowdragging = yes
    layers_hog_keyboard_focus = false
    mouse_move_focuses_monitor = false
}

input {
    follow_mouse = 2
    mouse_refocus = false
    float_switch_override_focus = 0
    
    touchpad {
        natural_scroll = yes
        disable_while_typing = yes
        tap-to-click = yes
    }
}
EOF
        ;;
        
    macos|macOS)
        echo "Switching to macOS theme..."
        
        # Update shell theme mode in settings
        if [ -f "$SETTINGS_FILE" ]; then
            jq '.shellThemeMode = "macOS"' "$SETTINGS_FILE" > "$SETTINGS_FILE.tmp" && mv "$SETTINGS_FILE.tmp" "$SETTINGS_FILE"
        else
            mkdir -p "$(dirname "$SETTINGS_FILE")"
            echo '{"shellThemeMode": "macOS"}' > "$SETTINGS_FILE"
        fi
        
        # Copy macOS theme as the active theme
        cp "$COMMON_DIR/ThemeMac.qml" "$COMMON_DIR/Theme.qml"
        
        # Apply macOS Hyprland theme
        "$HYPR_DIR/scripts/apply-macos-theme.sh"
        ;;
        
    *)
        echo "Unknown theme: $THEME"
        usage
        ;;
esac

# Reload Hyprland
echo "Reloading Hyprland..."
hyprctl reload

# Kill and restart quickshell
echo "Restarting Quickshell..."
pkill -f quickshell || true
sleep 1
quickshell -p "$QUICKSHELL_DIR" &

echo "Theme switched to $THEME successfully!"
