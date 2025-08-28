import QtQuick
pragma Singleton

QtObject {
    id: root

    // macOS WhiteSur Dark Theme Colors
    readonly property color background: Qt.rgba(0.11, 0.11, 0.12, 1.0)              // #1C1C1E
    readonly property color backgroundSecondary: Qt.rgba(0.17, 0.17, 0.18, 1.0)     // #2C2C2E
    readonly property color backgroundTertiary: Qt.rgba(0.23, 0.23, 0.24, 1.0)      // #3A3A3C
    readonly property color selected: Qt.rgba(0.0, 0.48, 1.0, 1.0)                  // #007AFF
    readonly property color hover: Qt.rgba(0.39, 0.39, 0.4, 1.0)                    // #636366

    readonly property color textPrimary: Qt.rgba(1.0, 1.0, 1.0, 0.95)              // Primary text
    readonly property color textSecondary: Qt.rgba(0.92, 0.92, 0.96, 0.6)          // Secondary text
    readonly property color textTertiary: Qt.rgba(0.92, 0.92, 0.96, 0.3)           // Tertiary text
    readonly property color textSelected: Qt.rgba(1.0, 1.0, 1.0, 1.0)              // Selected text

    readonly property color accent: Qt.rgba(0.0, 0.48, 1.0, 1.0)                   // #007AFF
    readonly property color accentHover: Qt.rgba(0.04, 0.52, 1.0, 1.0)             // #0A84FF
    readonly property color success: Qt.rgba(0.2, 0.78, 0.35, 1.0)                 // #34C759
    readonly property color warning: Qt.rgba(1.0, 0.58, 0.0, 1.0)                  // #FF9500
    readonly property color error: Qt.rgba(1.0, 0.23, 0.19, 1.0)                   // #FF3B30

    readonly property color border: Qt.rgba(0.39, 0.39, 0.4, 0.22)                 // Separator
    readonly property color borderSecondary: Qt.rgba(0.33, 0.33, 0.35, 0.65)       // Outline

    // Transparency levels
    readonly property real backgroundOpacity: 0.98
    readonly property real contentOpacity: 0.95
    readonly property real hoverOpacity: 0.3

    // Animation settings
    readonly property int animationDuration: 300
    readonly property int animationEasing: Easing.OutCubic

    // Sizing
    readonly property int barHeight: 32
    readonly property int iconSize: 16
    readonly property int spacing: 8
    readonly property int padding: 12
    readonly property int borderRadius: 12
    readonly property int fullRadius: 999
}
