#!/bin/bash
# Automatic monitor switching script for Hyprland
# Switches between external HDMI and laptop display based on connection status

# Monitor names (adjust if needed)
EXTERNAL_MONITOR="HDMI-A-1"
LAPTOP_MONITOR="eDP-1"

# Check if external monitor is connected
if hyprctl monitors | grep -q "$EXTERNAL_MONITOR"; then
    echo "External monitor detected: $EXTERNAL_MONITOR"
    
    # External monitor is connected - disable laptop screen
    hyprctl keyword monitor "$LAPTOP_MONITOR,disable"
    hyprctl keyword monitor "$EXTERNAL_MONITOR,1920x1080@144,0x0,1"
    
    echo "Laptop screen disabled, using external monitor"
else
    echo "External monitor not detected"
    
    # External monitor not connected - enable laptop screen
    hyprctl keyword monitor "$LAPTOP_MONITOR,2240x1400@60,0x0,1.46"
    
    echo "Using laptop screen"
fi
