#!/bin/bash
# Workspace Switcher Script
# Cycles through workspaces that have windows in them

# Get current workspace
current_workspace=$(hyprctl activeworkspace | head -1 | grep -o "workspace ID [0-9]*" | awk '{print $3}')

# Get all workspaces with windows (parse without jq)
workspaces_with_windows=$(hyprctl workspaces | grep -A2 "workspace ID" | grep -B2 "windows: [1-9]" | grep "workspace ID" | grep -o "workspace ID [0-9]*" | awk '{print $3}' | sort -n)

# Convert to array
workspace_array=($workspaces_with_windows)

# If no workspaces have windows, exit
if [ ${#workspace_array[@]} -eq 0 ]; then
    exit 0
fi

# Find current workspace index
current_index=-1
for i in "${!workspace_array[@]}"; do
    if [ "${workspace_array[$i]}" = "$current_workspace" ]; then
        current_index=$i
        break
    fi
done

# Determine direction
direction=${1:-"next"}

if [ "$direction" = "next" ]; then
    # Go to next workspace
    if [ $current_index -eq -1 ] || [ $current_index -eq $((${#workspace_array[@]} - 1)) ]; then
        # If current workspace not found or is the last one, go to first
        next_workspace=${workspace_array[0]}
    else
        # Go to next workspace
        next_workspace=${workspace_array[$((current_index + 1))]}
    fi
elif [ "$direction" = "prev" ]; then
    # Go to previous workspace
    if [ $current_index -eq -1 ] || [ $current_index -eq 0 ]; then
        # If current workspace not found or is the first one, go to last
        next_workspace=${workspace_array[$((${#workspace_array[@]} - 1))]}
    else
        # Go to previous workspace
        next_workspace=${workspace_array[$((current_index - 1))]}
    fi
fi

# Switch to the workspace
hyprctl dispatch workspace "$next_workspace"
