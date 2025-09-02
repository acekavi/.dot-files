#!/bin/bash

# macOS Theme Application Script for Hyprland
# This script generates a macOS-inspired color scheme and applies it system-wide

set -e

# Configuration
MATUGEN_DIR="$HOME/.config/quickshell/dms/matugen"
DANK16_SCRIPT="$MATUGEN_DIR/dank16.py"
HYPR_DIR="$HOME/.config/hypr"
COLORS_FILE="$HYPR_DIR/colors.conf"

# Default macOS colors (can be overridden)
MACOS_BLUE="#007AFF"
MACOS_PURPLE="#5856D6"
MACOS_PINK="#FF2D92"
MACOS_RED="#FF3B30"
MACOS_ORANGE="#FF9500"
MACOS_YELLOW="#FFCC00"
MACOS_GREEN="#34C759"

# Function to display usage
usage() {
    echo "Usage: $0 [OPTIONS] [COLOR]"
    echo ""
    echo "Apply macOS-inspired theming to Hyprland with color generation"
    echo ""
    echo "OPTIONS:"
    echo "  -h, --help          Show this help message"
    echo "  -l, --light         Generate light theme (default: dark)"
    echo "  -p, --preset NAME   Use preset color (blue, purple, pink, red, orange, yellow, green)"
    echo "  -w, --wallpaper     Extract color from current wallpaper"
    echo "  -r, --reload        Reload Hyprland configuration after applying"
    echo "  -v, --verbose       Verbose output"
    echo ""
    echo "COLOR:"
    echo "  Hex color code (e.g., #007AFF) to use as primary color"
    echo "  If not provided, defaults to macOS blue"
    echo ""
    echo "Examples:"
    echo "  $0 --preset blue --reload"
    echo "  $0 #FF2D92 --light"
    echo "  $0 --wallpaper --verbose"
}

# Function to log messages
log() {
    if [[ "$VERBOSE" == "true" ]]; then
        echo "[$(date '+%H:%M:%S')] $1"
    fi
}

# Function to get preset colors
get_preset_color() {
    case "$1" in
        blue) echo "$MACOS_BLUE" ;;
        purple) echo "$MACOS_PURPLE" ;;
        pink) echo "$MACOS_PINK" ;;
        red) echo "$MACOS_RED" ;;
        orange) echo "$MACOS_ORANGE" ;;
        yellow) echo "$MACOS_YELLOW" ;;
        green) echo "$MACOS_GREEN" ;;
        *) echo "$MACOS_BLUE" ;;
    esac
}

# Function to extract color from wallpaper
extract_wallpaper_color() {
    log "Extracting color from wallpaper..."
    
    # Try to get current wallpaper from various sources
    local wallpaper=""
    
    # Check hyprpaper
    if command -v hyprctl >/dev/null 2>&1; then
        wallpaper=$(hyprctl hyprpaper listloaded 2>/dev/null | head -n1 || true)
    fi
    
    # Check swaybg or other wallpaper setters
    if [[ -z "$wallpaper" ]]; then
        wallpaper=$(pgrep -a swaybg | grep -o '/[^[:space:]]*\.(jpg\|jpeg\|png\|webp)' | head -n1 || true)
    fi
    
    # Fallback to common wallpaper locations
    if [[ -z "$wallpaper" ]]; then
        for dir in "$HOME/Pictures/Wallpapers" "$HOME/.config/wallpapers" "$HOME/Pictures"; do
            if [[ -d "$dir" ]]; then
                wallpaper=$(find "$dir" -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.webp" \) | head -n1 || true)
                [[ -n "$wallpaper" ]] && break
            fi
        done
    fi
    
    if [[ -z "$wallpaper" || ! -f "$wallpaper" ]]; then
        echo "Error: Could not find current wallpaper" >&2
        return 1
    fi
    
    log "Found wallpaper: $wallpaper"
    
    # Extract dominant color using imagemagick
    if command -v convert >/dev/null 2>&1; then
        local color=$(convert "$wallpaper" -resize 1x1\! -format '%[pixel:u]' info:- 2>/dev/null || true)
        if [[ -n "$color" ]]; then
            # Convert to hex format
            echo "$color" | sed 's/srgb(\([0-9]*\),\([0-9]*\),\([0-9]*\))/\1 \2 \3/' | \
            awk '{printf "#%02x%02x%02x\n", $1, $2, $3}'
            return 0
        fi
    fi
    
    # Fallback: use matugen if available
    if command -v matugen >/dev/null 2>&1; then
        log "Using matugen to extract color..."
        matugen image "$wallpaper" --dry-run 2>/dev/null | grep -o '#[0-9A-Fa-f]\{6\}' | head -n1 || echo "$MACOS_BLUE"
    else
        echo "$MACOS_BLUE"
    fi
}

# Function to generate and apply theme
apply_theme() {
    local primary_color="$1"
    local is_light="$2"
    
    log "Applying theme with primary color: $primary_color"
    
    # Validate color format
    if [[ ! "$primary_color" =~ ^#[0-9A-Fa-f]{6}$ ]]; then
        echo "Error: Invalid color format. Use #RRGGBB format." >&2
        return 1
    fi
    
    # Generate dank16 palette
    log "Generating color palette with dank16.py..."
    local dank16_args=("$primary_color")
    [[ "$is_light" == "true" ]] && dank16_args+=("--light")
    
    if [[ ! -f "$DANK16_SCRIPT" ]]; then
        echo "Error: dank16.py not found at $DANK16_SCRIPT" >&2
        return 1
    fi
    
    # Generate palette and save to temporary file
    local temp_palette=$(mktemp)
    python3 "$DANK16_SCRIPT" "${dank16_args[@]}" > "$temp_palette" 2>/dev/null || {
        echo "Error: Failed to generate color palette" >&2
        rm -f "$temp_palette"
        return 1
    }
    
    log "Generated palette:"
    [[ "$VERBOSE" == "true" ]] && cat "$temp_palette"
    
    # Apply colors using matugen
    log "Applying colors with matugen..."
    cd "$MATUGEN_DIR"
    
    if command -v matugen >/dev/null 2>&1; then
        # Use matugen with the primary color
        matugen color "$primary_color" --config ./configs/base.toml 2>/dev/null || {
            echo "Error: Failed to apply colors with matugen" >&2
            rm -f "$temp_palette"
            return 1
        }
    else
        echo "Warning: matugen not found, colors may not be fully applied" >&2
    fi
    
    # Clean up
    rm -f "$temp_palette"
    
    log "Theme applied successfully!"
}

# Function to reload Hyprland configuration
reload_hyprland() {
    log "Reloading Hyprland configuration..."
    if command -v hyprctl >/dev/null 2>&1; then
        hyprctl reload >/dev/null 2>&1 || {
            echo "Warning: Failed to reload Hyprland configuration" >&2
            return 1
        }
        log "Hyprland configuration reloaded"
    else
        echo "Warning: hyprctl not found, please reload manually" >&2
    fi
}

# Parse command line arguments
LIGHT_MODE="false"
PRESET=""
USE_WALLPAPER="false"
RELOAD_CONFIG="false"
VERBOSE="false"
PRIMARY_COLOR=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            usage
            exit 0
            ;;
        -l|--light)
            LIGHT_MODE="true"
            shift
            ;;
        -p|--preset)
            PRESET="$2"
            shift 2
            ;;
        -w|--wallpaper)
            USE_WALLPAPER="true"
            shift
            ;;
        -r|--reload)
            RELOAD_CONFIG="true"
            shift
            ;;
        -v|--verbose)
            VERBOSE="true"
            shift
            ;;
        -*)
            echo "Error: Unknown option $1" >&2
            usage
            exit 1
            ;;
        *)
            if [[ -z "$PRIMARY_COLOR" ]]; then
                PRIMARY_COLOR="$1"
            else
                echo "Error: Multiple colors specified" >&2
                usage
                exit 1
            fi
            shift
            ;;
    esac
done

# Determine primary color
if [[ "$USE_WALLPAPER" == "true" ]]; then
    PRIMARY_COLOR=$(extract_wallpaper_color) || exit 1
elif [[ -n "$PRESET" ]]; then
    PRIMARY_COLOR=$(get_preset_color "$PRESET")
elif [[ -z "$PRIMARY_COLOR" ]]; then
    PRIMARY_COLOR="$MACOS_BLUE"
fi

# Ensure color starts with #
[[ ! "$PRIMARY_COLOR" =~ ^# ]] && PRIMARY_COLOR="#$PRIMARY_COLOR"

log "Using primary color: $PRIMARY_COLOR"
[[ "$LIGHT_MODE" == "true" ]] && log "Using light mode"

# Apply the theme
apply_theme "$PRIMARY_COLOR" "$LIGHT_MODE" || exit 1

# Reload configuration if requested
[[ "$RELOAD_CONFIG" == "true" ]] && reload_hyprland

echo "macOS theme applied successfully!"
echo "Primary color: $PRIMARY_COLOR"
[[ "$LIGHT_MODE" == "true" ]] && echo "Mode: Light" || echo "Mode: Dark"
echo ""
echo "To reload Hyprland manually: hyprctl reload"
echo "To change colors: $0 --preset [color] --reload"
