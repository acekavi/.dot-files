import QtQuick
pragma Singleton

QtObject {
    id: root

    // Apple HIG Dark Mode Color System
    // Primary Background Colors
    readonly property color background: Qt.rgba(0.06, 0.06, 0.08, 1.0) // #0F0F14 - System Background
    readonly property color backgroundSecondary: Qt.rgba(0.11, 0.11, 0.13, 1.0) // #1C1C21 - Secondary System Background
    readonly property color backgroundTertiary: Qt.rgba(0.16, 0.16, 0.18, 1.0) // #29292E - Tertiary System Background

    // Semantic Colors (Apple HIG Standard)
    readonly property color accent: Qt.rgba(0.0, 0.48, 1.0, 1.0) // #007AFF - System Blue
    readonly property color accentHover: Qt.rgba(0.04, 0.52, 1.0, 1.0) // #0A84FF - System Blue (Pressed)
    readonly property color success: Qt.rgba(0.2, 0.78, 0.35, 1.0) // #34C759 - System Green
    readonly property color warning: Qt.rgba(1.0, 0.58, 0.0, 1.0) // #FF9500 - System Orange
    readonly property color error: Qt.rgba(1.0, 0.23, 0.19, 1.0) // #FF3B30 - System Red

    // Text Colors (Apple HIG Typography Standards)
    readonly property color textPrimary: Qt.rgba(1.0, 1.0, 1.0, 1.0) // Primary Label
    readonly property color textSecondary: Qt.rgba(0.92, 0.92, 0.96, 0.6) // Secondary Label
    readonly property color textTertiary: Qt.rgba(0.92, 0.92, 0.96, 0.3) // Tertiary Label
    readonly property color textSelected: Qt.rgba(1.0, 1.0, 1.0, 1.0) // Selected Text

    // Interactive Colors (Apple HIG Interactive Elements)
    readonly property color selected: Qt.rgba(0.0, 0.48, 1.0, 1.0) // #007AFF - System Blue
    readonly property color hover: Qt.rgba(0.39, 0.39, 0.4, 0.3) // Hover State
    readonly property color pressed: Qt.rgba(0.39, 0.39, 0.4, 0.5) // Pressed State

    // Border and Separator Colors (Apple HIG Materials)
    readonly property color border: Qt.rgba(0.39, 0.39, 0.4, 0.22) // Separator
    readonly property color borderSecondary: Qt.rgba(0.33, 0.33, 0.35, 0.65) // Outline

    // Workspace-specific colors
    readonly property color workspaceActive: Qt.rgba(0.0, 0.48, 1.0, 1.0) // #007AFF - Active workspace
    readonly property color workspaceOccupied: Qt.rgba(0.0, 0.48, 1.0, 0.15) // Workspace with windows
    readonly property color workspaceEmpty: Qt.rgba(0.92, 0.92, 0.96, 0.3) // Empty workspace
    readonly property color workspaceHover: Qt.rgba(0.0, 0.48, 1.0, 0.25) // Hover state

    // Control Center Specific Colors (Apple HIG)
    readonly property color controlCenterBackground: Qt.rgba(0.06, 0.06, 0.08, 0.95) // Control Center background
    readonly property color controlCenterCard: Qt.rgba(0.11, 0.11, 0.13, 0.8) // Control Center card background
    readonly property color controlCenterToggle: Qt.rgba(0.0, 0.48, 1.0, 1.0) // Toggle switch active
    readonly property color controlCenterToggleInactive: Qt.rgba(0.39, 0.39, 0.4, 0.6) // Toggle switch inactive

    // Status Indicator Colors (Apple HIG Semantic Colors)
    readonly property color statusOnline: Qt.rgba(0.2, 0.78, 0.35, 1.0) // #34C759 - Online/Connected
    readonly property color statusOffline: Qt.rgba(0.92, 0.92, 0.96, 0.4) // Offline/Disconnected
    readonly property color statusWarning: Qt.rgba(1.0, 0.58, 0.0, 1.0) // #FF9500 - Warning state
    readonly property color statusError: Qt.rgba(1.0, 0.23, 0.19, 1.0) // #FF3B30 - Error state

    // 8pt Grid System (following Apple HIG)
    readonly property int spacing: 8 // Base spacing unit
    readonly property int spacingSmall: 4 // Half spacing
    readonly property int spacingMedium: 8 // Base spacing
    readonly property int spacingLarge: 16 // Double spacing
    readonly property int spacingXLarge: 24 // Triple spacing

    // Sizing (following 8pt grid)
    readonly property int barHeight: 32 // 4 * 8pt
    readonly property int iconSize: 16 // 2 * 8pt
    readonly property int padding: 12 // 1.5 * 8pt (acceptable for padding)
    readonly property int borderRadius: 12 // 1.5 * 8pt (acceptable for radius)
    readonly property int fullRadius: 999

    // Component-specific dimensions
    readonly property int buttonHeight: 32 // 4 * 8pt
    readonly property int buttonWidth: 80 // 10 * 8pt
    readonly property int popupWidth: 320 // 40 * 8pt
    readonly property int popupMaxHeight: 600 // 75 * 8pt

    // Control Center dimensions
    readonly property int controlCenterWidth: 320 // 40 * 8pt - wider for better content
    readonly property int controlCenterHeight: 480 // 60 * 8pt - more compact height

    // Workspace-specific dimensions - properly proportioned for status bar
    readonly property int workspaceSize: 20 // 2.5 * 8pt (smaller, better proportioned)
    readonly property int workspaceDotSize: 3 // 0.375 * 8pt (smaller dot)
    readonly property int workspaceBorderActive: 2 // Active workspace border
    readonly property int workspaceBorderOccupied: 1 // Workspace with windows border

    // Animation components for easy reuse
    readonly property Component numberAnimation: Component {
        NumberAnimation {
            duration: 300
            easing.type: Easing.OutCubic
        }
    }

    readonly property Component colorAnimation: Component {
        ColorAnimation {
            duration: 300
            easing.type: Easing.OutCubic
        }
    }

    readonly property Component quickAnimation: Component {
        NumberAnimation {
            duration: 150
            easing.type: Easing.OutCubic
        }
    }
}
