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

    // Workspace-specific colors
    readonly property color workspaceActive: Qt.rgba(0.0, 0.48, 1.0, 1.0) // #007AFF - Active workspace
    readonly property color workspaceOccupied: Qt.rgba(0.0, 0.48, 1.0, 0.15) // Workspace with windows
    readonly property color workspaceEmpty: Qt.rgba(0.92, 0.92, 0.96, 0.3) // Empty workspace
    readonly property color workspaceHover: Qt.rgba(0.0, 0.48, 1.0, 0.25) // Hover state

    // Transparency levels
    readonly property real backgroundOpacity: 0.98
    readonly property real contentOpacity: 0.95
    readonly property real hoverOpacity: 0.3

    // macOS-Standard Animation Settings (following Apple HIG)
    readonly property int animationDuration: {
        // Quick: 200-300ms for micro-interactions
        // Standard: 400-500ms for state changes
        // Slow: 600-800ms for major transitions
        return 400 // Standard duration for state changes
    }

    readonly property int animationDurationQuick: 200 // Micro-interactions
    readonly property int animationDurationStandard: 400 // State changes
    readonly property int animationDurationSlow: 600 // Major transitions

    // macOS-Standard Bezier Curves (from Apple HIG)
    readonly property list<real> animationCurveStandard: [0.32, 0.97, 0.53, 1.0] // Standard curve
    readonly property list<real> animationCurveQuick: [0.34, 0.80, 0.34, 1.00] // Quick curve
    readonly property list<real> animationCurveSlow: [0.39, 1.29, 0.35, 0.98] // Slow curve

    readonly property int animationEasing: Easing.BezierSpline
    readonly property list<real> animationBezierCurve: animationCurveStandard

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

    // Workspace-specific dimensions - properly proportioned for status bar
    readonly property int workspaceSize: 20 // 2.5 * 8pt (smaller, better proportioned)
    readonly property int workspaceDotSize: 3 // 0.375 * 8pt (smaller dot)
    readonly property int workspaceBorderActive: 2 // Active workspace border
    readonly property int workspaceBorderOccupied: 1 // Workspace with windows border

    // Animation components for easy reuse
    readonly property Component numberAnimation: Component {
        NumberAnimation {
            duration: root.animationDuration
            easing.type: root.animationEasing
            easing.bezierCurve: root.animationBezierCurve
        }
    }

    readonly property Component colorAnimation: Component {
        ColorAnimation {
            duration: root.animationDuration
            easing.type: root.animationEasing
            easing.bezierCurve: root.animationBezierCurve
        }
    }

    readonly property Component quickAnimation: Component {
        NumberAnimation {
            duration: root.animationDurationQuick
            easing.type: root.animationEasing
            easing.bezierCurve: root.animationCurveQuick
        }
    }
}
