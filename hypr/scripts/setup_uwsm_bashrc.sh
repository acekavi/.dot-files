#!/bin/bash

# Script to add UWSM Hyprland configuration to .bashrc
# Part of the Freedom Theme Hyprland configuration

BASHRC_FILE="$HOME/.bashrc"
BACKUP_FILE="$HOME/.bashrc.backup.$(date +%Y%m%d_%H%M%S)"

echo "🚀 UWSM Hyprland Setup Script"
echo "=============================="

# Check if UWSM is installed
if ! command -v uwsm &> /dev/null; then
    echo "❌ UWSM is not installed. Please install it first:"
    echo "   Arch: sudo pacman -S uwsm libnewt"
    exit 1
fi

# Create backup
if [ -f "$BASHRC_FILE" ]; then
    cp "$BASHRC_FILE" "$BACKUP_FILE"
    echo "✅ Backup created: $BACKUP_FILE"
fi

# Check if UWSM configuration already exists
if grep -q "uwsm check may-start" "$BASHRC_FILE" 2>/dev/null; then
    echo "⚠️  UWSM configuration already exists in .bashrc"
    echo "   Please check your .bashrc file manually"
    exit 0
fi

# Present options to user
echo ""
echo "Choose UWSM launch option:"
echo "1) TTY1-specific launch (recommended)"
echo "2) Auto-launch on any TTY"
echo "3) Launch with compositor selection menu"
echo "4) Cancel"
echo ""
read -p "Enter your choice (1-4): " choice

case $choice in
    1)
        echo "" >> "$BASHRC_FILE"
        echo "# UWSM Hyprland auto-launch (Freedom Theme)" >> "$BASHRC_FILE"
        echo "if [ \"\$(tty)\" = \"/dev/tty1\" ] && uwsm check may-start; then" >> "$BASHRC_FILE"
        echo "    exec uwsm start hyprland-uwsm.desktop" >> "$BASHRC_FILE"
        echo "fi" >> "$BASHRC_FILE"
        echo "✅ TTY1-specific UWSM launch added to .bashrc"
        ;;
    2)
        echo "" >> "$BASHRC_FILE"
        echo "# UWSM Hyprland auto-launch (Freedom Theme)" >> "$BASHRC_FILE"
        echo "if uwsm check may-start; then" >> "$BASHRC_FILE"
        echo "    exec uwsm start hyprland-uwsm.desktop" >> "$BASHRC_FILE"
        echo "fi" >> "$BASHRC_FILE"
        echo "✅ Auto-launch UWSM configuration added to .bashrc"
        ;;
    3)
        echo "" >> "$BASHRC_FILE"
        echo "# UWSM Hyprland auto-launch with selection (Freedom Theme)" >> "$BASHRC_FILE"
        echo "if uwsm check may-start && uwsm select; then" >> "$BASHRC_FILE"
        echo "    exec uwsm start default" >> "$BASHRC_FILE"
        echo "fi" >> "$BASHRC_FILE"
        echo "✅ UWSM with selection menu added to .bashrc"
        ;;
    4)
        echo "❌ Setup cancelled"
        exit 0
        ;;
    *)
        echo "❌ Invalid choice"
        exit 1
        ;;
esac

echo ""
echo "🎉 Setup complete!"
echo "📝 Next steps:"
echo "   1. Log out completely"
echo "   2. Switch to TTY1 (Ctrl+Alt+F1)"
echo "   3. Log in - UWSM should start automatically"
echo ""
echo "📚 For more information, see:"
echo "   - ~/.config/hypr/UWSM_SETUP.md"
echo "   - ~/.config/hypr/README.md"
