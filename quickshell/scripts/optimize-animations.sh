#!/bin/bash

# Quickshell Animation Optimization Script
# Replaces all createObject() animation calls with inline animations for better performance

set -e

CONFIG_DIR="$HOME/.config/quickshell"
BACKUP_DIR="$CONFIG_DIR/backups/$(date +%Y%m%d_%H%M%S)"

echo "🔧 Quickshell Animation Optimization Script"
echo "=========================================="

# Create backup directory
mkdir -p "$BACKUP_DIR"
echo "📁 Creating backup in: $BACKUP_DIR"

# Function to backup and optimize a file
optimize_file() {
    local file="$1"
    local backup_file="$BACKUP_DIR/$(basename "$file")"

    if [[ -f "$file" ]]; then
        echo "🔄 Optimizing: $file"

        # Create backup
        cp "$file" "$backup_file"

        # Replace color animations
        sed -i 's/animation: WhiteSurTheme\.colorAnimation\.createObject(this)/ColorAnimation { duration: 300; easing.type: Easing.OutCubic }/g' "$file"

        # Replace number animations
        sed -i 's/animation: WhiteSurTheme\.numberAnimation\.createObject(this)/NumberAnimation { duration: 300; easing.type: Easing.OutCubic }/g' "$file"

        # Replace quick animations
        sed -i 's/animation: WhiteSurTheme\.quickAnimation\.createObject(this)/NumberAnimation { duration: 150; easing.type: Easing.OutCubic }/g' "$file"

        echo "✅ Optimized: $file"
    else
        echo "⚠️  File not found: $file"
    fi
}

# Optimize all QML files
echo ""
echo "🎯 Starting optimization process..."

# Status bar modules
optimize_file "$CONFIG_DIR/modules/statusbar/StatusBar.qml"
optimize_file "$CONFIG_DIR/modules/statusbar/WorkspaceIndicator.qml"
optimize_file "$CONFIG_DIR/modules/statusbar/ClockWidget.qml"
optimize_file "$CONFIG_DIR/modules/statusbar/BatteryWidget.qml"
optimize_file "$CONFIG_DIR/modules/statusbar/NetworkPopup.qml"
optimize_file "$CONFIG_DIR/modules/statusbar/NetworkItem.qml"
optimize_file "$CONFIG_DIR/modules/statusbar/SystemTrayPopup.qml"
optimize_file "$CONFIG_DIR/modules/statusbar/ArchLogo.qml"

# Sidebar modules
optimize_file "$CONFIG_DIR/modules/sidebar/CentralSidebar.qml"

echo ""
echo "🎉 Optimization complete!"
echo "📁 Backups saved in: $BACKUP_DIR"
echo ""
echo "💡 Next steps:"
echo "   1. Test Quickshell with: quickshell -v"
echo "   2. Check for any syntax errors"
echo "   3. Monitor performance improvements"
echo "   4. If issues occur, restore from backup"
echo ""
echo "🔄 To restore from backup:"
echo "   cp $BACKUP_DIR/*.qml $CONFIG_DIR/modules/statusbar/"
echo "   cp $BACKUP_DIR/*.qml $CONFIG_DIR/modules/sidebar/"

