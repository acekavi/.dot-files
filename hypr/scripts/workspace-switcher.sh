#!/bin/bash

# Intelligent Workspace Switcher for Hyprland
# Switches to next/previous workspace with windows or finds empty workspaces
# No external dependencies required

get_current_workspace() {
    hyprctl activeworkspace | grep -oP 'workspace ID \K\d+'
}

get_workspaces_with_windows() {
    hyprctl workspaces | grep -E "workspace ID|windows:" | \
    awk '/workspace ID/ {id=$3} /windows:/ && $2 > 0 {print id}' | sort -n | tr '\n' ' '
}

get_all_workspaces() {
    hyprctl workspaces | grep -oP 'workspace ID \K\d+' | sort -n | tr '\n' ' '
}

get_empty_workspaces() {
    # Get all existing workspaces with 0 windows, plus non-existent workspaces 1-10
    local empty_workspaces=()
    
    # Check existing workspaces for ones with 0 windows
    local existing_empty=($(hyprctl workspaces | grep -E "workspace ID|windows:" | \
        awk '/workspace ID/ {id=$3} /windows:/ && $2 == 0 {print id}'))
    
    for ws in $existing_empty; do
        empty_workspaces+=($ws)
    done
    
    # Check for non-existent workspaces (6-10 that don't appear in hyprctl workspaces)
    local all_existing=($(hyprctl workspaces | grep -oP 'workspace ID \K\d+'))
    for ws in $(seq 6 10); do
        local exists=0
        for existing in $all_existing; do
            if [ "$ws" = "$existing" ]; then
                exists=1
                break
            fi
        done
        if [ $exists -eq 0 ]; then
            empty_workspaces+=($ws)
        fi
    done
    
    # Remove duplicates and sort
    printf '%s\n' "${empty_workspaces[@]}" | sort -nu | tr '\n' ' '
}

switch_to_next_with_windows() {
    local current=$(get_current_workspace)
    local workspaces_with_windows=($(get_workspaces_with_windows))
    
    if [ ${#workspaces_with_windows[@]} -eq 0 ]; then
        echo "No workspaces with windows found"
        return 1
    fi
    
    # Find current workspace in the array
    local current_index=-1
    for i in "${!workspaces_with_windows[@]}"; do
        if [ "${workspaces_with_windows[$i]}" -eq "$current" ]; then
            current_index=$i
            break
        fi
    done
    
    # If current workspace is not in the list (no windows), go to first workspace with windows
    if [ $current_index -eq -1 ]; then
        hyprctl dispatch workspace "${workspaces_with_windows[0]}" 2>/dev/null
        echo "Switched to workspace ${workspaces_with_windows[0]} (first with windows)"
        return 0
    fi
    
    # Go to next workspace with windows (wrap around)
    local next_index=$(( (current_index + 1) % ${#workspaces_with_windows[@]} ))
    hyprctl dispatch workspace "${workspaces_with_windows[$next_index]}" 2>/dev/null
    echo "Switched to workspace ${workspaces_with_windows[$next_index]} (next with windows)"
}

switch_to_prev_with_windows() {
    local current=$(get_current_workspace)
    local workspaces_with_windows=($(get_workspaces_with_windows))
    
    if [ ${#workspaces_with_windows[@]} -eq 0 ]; then
        echo "No workspaces with windows found"
        return 1
    fi
    
    # Find current workspace in the array
    local current_index=-1
    for i in "${!workspaces_with_windows[@]}"; do
        if [ "${workspaces_with_windows[$i]}" -eq "$current" ]; then
            current_index=$i
            break
        fi
    done
    
    # If current workspace is not in the list (no windows), go to last workspace with windows
    if [ $current_index -eq -1 ]; then
        hyprctl dispatch workspace "${workspaces_with_windows[-1]}" 2>/dev/null
        echo "Switched to workspace ${workspaces_with_windows[-1]} (last with windows)"
        return 0
    fi
    
    # Go to previous workspace with windows (wrap around)
    local prev_index=$(( current_index - 1 ))
    if [ $prev_index -lt 0 ]; then
        prev_index=$(( ${#workspaces_with_windows[@]} - 1 ))
    fi
    hyprctl dispatch workspace "${workspaces_with_windows[$prev_index]}" 2>/dev/null
    echo "Switched to workspace ${workspaces_with_windows[$prev_index]} (previous with windows)"
}

switch_to_nearest_empty() {
    local empty_workspaces=($(get_empty_workspaces))
    
    if [ ${#empty_workspaces[@]} -eq 0 ]; then
        echo "No empty workspaces available"
        return 1
    fi
    
    # Just pick the first empty workspace
    local first_empty="${empty_workspaces[0]}"
    hyprctl dispatch workspace "$first_empty" 2>/dev/null
    echo "Switched to empty workspace $first_empty"
}

# Debug function (uncomment for troubleshooting)
debug_info() {
    echo "Current workspace: $(get_current_workspace)"
    echo "Workspaces with windows: $(get_workspaces_with_windows)"
    echo "All workspaces: $(get_all_workspaces)"
    
    # Debug empty workspace detection
    echo "=== Empty Workspace Debug ==="
    echo "Existing workspaces with 0 windows:"
    hyprctl workspaces | grep -E "workspace ID|windows:" | awk '/workspace ID/ {id=$3} /windows:/ && $2 == 0 {print id}'
    echo "Non-existent workspaces (6-10):"
    local all_existing=($(hyprctl workspaces | grep -oP 'workspace ID \K\d+'))
    for ws in $(seq 6 10); do
        local exists=0
        for existing in $all_existing; do
            if [ "$ws" = "$existing" ]; then
                exists=1
                break
            fi
        done
        if [ $exists -eq 0 ]; then
            echo "$ws"
        fi
    done
    echo "Final empty workspaces: $(get_empty_workspaces)"
}

# Main logic
case "$1" in
    "next")
        switch_to_next_with_windows
        ;;
    "prev")
        switch_to_prev_with_windows
        ;;
    "empty")
        switch_to_nearest_empty
        ;;
    "debug")
        debug_info
        ;;
    *)
        echo "Usage: $0 {next|prev|empty|debug}"
        echo "  next  - Switch to next workspace with windows"
        echo "  prev  - Switch to previous workspace with windows"
        echo "  empty - Switch to nearest empty workspace"
        echo "  debug - Show debug information"
        exit 1
        ;;
esac