pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell
import "../statusbar"

PanelWindow {
    id: controlCenter
    property ShellScreen targetScreen
    screen: targetScreen
    property bool isOpen: false
    property int controlCenterWidth: WhiteSurTheme.controlCenterWidth
    property int controlCenterHeight: WhiteSurTheme.controlCenterHeight
    property int controlCenterPadding: WhiteSurTheme.spacingLarge
    property int controlCenterSpacing: WhiteSurTheme.spacing
    color: "transparent"

    // Panel configuration for floating behavior
    exclusiveZone: 0 // Don't block other windows
    implicitWidth: controlCenterWidth
    implicitHeight: controlCenterHeight

    // Key: Use visible property to show/hide the entire PanelWindow
    visible: isOpen

    // Position below status bar with spacing
    anchors {
        right: true
        top: true
        bottom: true
    }

    // Content container that can be animated
    Rectangle {
        id: sidebarContent
        anchors.fill: parent
        color: "transparent"

        // macOS-style slide animation from right
        x: isOpen ? 0 : controlCenterWidth

        Behavior on x {
            animation: WhiteSurTheme.numberAnimation.createObject(this)
        }

        // Background with Apple HIG-compliant materials
        Rectangle {
            anchors.fill: parent
            color: WhiteSurTheme.controlCenterBackground
            opacity: 0.98
            radius: WhiteSurTheme.borderRadius

            // Border with Apple HIG separator colors
            border.width: 1
            border.color: WhiteSurTheme.borderSecondary
        }

        // Main content layout
        ColumnLayout {
            anchors.fill: parent
                    anchors.margins: controlCenterPadding
        spacing: controlCenterSpacing

            // Header section
            RowLayout {
                Layout.fillWidth: true
                spacing: WhiteSurTheme.spacing

                // App icon
                Text {
                    Layout.preferredWidth: 24
                    Layout.preferredHeight: 24
                    text: "󰋊"
                    color: WhiteSurTheme.accent
                    font.pixelSize: 20
                    font.family: "JetBrainsMono Nerd Font"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                // Title
                Text {
                    Layout.fillWidth: true
                    text: "Control Center"
                    color: WhiteSurTheme.textPrimary
                    font.pixelSize: 16
                    font.family: "Inter"
                    font.weight: 400
                }

                // Close button
                Rectangle {
                    Layout.preferredWidth: 28
                    Layout.preferredHeight: 28
                    radius: 14
                    color: closeButtonMouseArea.containsMouse ? (WhiteSurTheme.backgroundSecondary || "#1C1C21") : "transparent"
                    border.width: 1
                    border.color: closeButtonMouseArea.containsMouse ? (WhiteSurTheme.accent || "#007AFF") : (WhiteSurTheme.border || "#636366")

                    Text {
                        anchors.centerIn: parent
                        text: "✕"
                        color: closeButtonMouseArea.containsMouse ? (WhiteSurTheme.accent || "#007AFF") : (WhiteSurTheme.textSecondary || "#E5E5E7")
                        font.pixelSize: 12
                        font.family: "Inter"
                    }

                    MouseArea {
                        id: closeButtonMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor

                        onClicked: {
                            controlCenter.isOpen = false
                        }

                        // macOS-style press animation
                        onPressed: {
                            parent.scale = 0.98
                        }

                        onReleased: {
                            parent.scale = 1.0
                        }

                        onCanceled: {
                            parent.scale = 1.0
                        }
                    }

                    Behavior on color {
                        animation: WhiteSurTheme.colorAnimation ? WhiteSurTheme.colorAnimation.createObject(this) : null
                    }

                    Behavior on border.color {
                        animation: WhiteSurTheme.colorAnimation ? WhiteSurTheme.colorAnimation.createObject(this) : null
                    }

                    Behavior on scale {
                        animation: WhiteSurTheme.quickAnimation ? WhiteSurTheme.quickAnimation.createObject(this) : null
                    }
                }
            }

            // macOS-style separator
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: WhiteSurTheme.border || "#636366"
            }

            // WiFi Section
            ColumnLayout {
                Layout.fillWidth: true
                spacing: WhiteSurTheme.spacingSmall || 4

                // Section header
                RowLayout {
                    Layout.fillWidth: true
                    spacing: WhiteSurTheme.spacing || 8

                    Text {
                        Layout.preferredWidth: 20
                        Layout.preferredHeight: 20
                        text: "󰤨"
                        color: WhiteSurTheme.accent || "#007AFF"
                        font.pixelSize: 16
                        font.family: "JetBrainsMono Nerd Font"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    Text {
                        Layout.fillWidth: true
                        text: "WiFi"
                        color: WhiteSurTheme.textPrimary || "#FFFFFF"
                        font.pixelSize: 14
                        font.family: "Inter"
                        font.weight: Font.Medium
                    }

                    // WiFi toggle
                    Rectangle {
                        Layout.preferredWidth: 44
                        Layout.preferredHeight: 24
                        radius: 12
                        color: wifiToggleMouseArea.containsMouse ? WhiteSurTheme.controlCenterCard : WhiteSurTheme.controlCenterToggle
                        border.width: 1
                        border.color: wifiToggleMouseArea.containsMouse ? WhiteSurTheme.accentHover : WhiteSurTheme.controlCenterToggle

                        Text {
                            anchors.centerIn: parent
                            text: "ON"
                            color: WhiteSurTheme.accent
                            font.pixelSize: 10
                            font.family: "Inter"
                            font.weight: Font.Medium
                        }

                        MouseArea {
                            id: wifiToggleMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor

                            onClicked: {
                                // TODO: Implement WiFi toggle
                                console.log("WiFi toggle clicked")
                            }
                        }

                        Behavior on color {
                            animation: WhiteSurTheme.colorAnimation.createObject(this)
                        }

                        Behavior on border.color {
                            animation: WhiteSurTheme.colorAnimation.createObject(this)
                        }
                    }
                }

                // WiFi networks list
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 120
                    radius: WhiteSurTheme.borderRadius
                    color: WhiteSurTheme.controlCenterCard
                    border.width: 1
                    border.color: WhiteSurTheme.borderSecondary

                    // Placeholder for WiFi networks
                    Text {
                        anchors.centerIn: parent
                        text: "WiFi Networks\n(Coming Soon)"
                        color: WhiteSurTheme.textSecondary
                        font.pixelSize: 12
                        font.family: "Inter"
                        horizontalAlignment: Text.AlignHCenter
                    }
                }
            }

            // macOS-style separator
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: WhiteSurTheme.border
            }

            // Bluetooth Section
            ColumnLayout {
                Layout.fillWidth: true
                spacing: WhiteSurTheme.spacingSmall

                // Section header
                RowLayout {
                    Layout.fillWidth: true
                    spacing: WhiteSurTheme.spacing

                    Text {
                        Layout.preferredWidth: 20
                        Layout.preferredHeight: 20
                        text: "󰂯"
                        color: WhiteSurTheme.accent
                        font.pixelSize: 16
                        font.family: "JetBrainsMono Nerd Font"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    Text {
                        Layout.fillWidth: true
                        text: "Bluetooth"
                        color: WhiteSurTheme.textPrimary
                        font.pixelSize: 14
                        font.family: "Inter"
                        font.weight: Font.Medium
                    }

                    // Bluetooth toggle
                    Rectangle {
                        Layout.preferredWidth: 44
                        Layout.preferredHeight: 24
                        radius: 12
                        color: bluetoothToggleMouseArea.containsMouse ? WhiteSurTheme.controlCenterCard : WhiteSurTheme.controlCenterToggle
                        border.width: 1
                        border.color: bluetoothToggleMouseArea.containsMouse ? WhiteSurTheme.accentHover : WhiteSurTheme.controlCenterToggle

                        Text {
                            anchors.centerIn: parent
                            text: "ON"
                            color: WhiteSurTheme.accent
                            font.pixelSize: 10
                            font.family: "Inter"
                            font.weight: Font.Medium
                        }

                        MouseArea {
                            id: bluetoothToggleMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor

                            onClicked: {
                                // TODO: Implement Bluetooth toggle
                            }
                        }

                        Behavior on color {
                            animation: WhiteSurTheme.colorAnimation.createObject(this)
                        }

                        Behavior on border.color {
                            animation: WhiteSurTheme.colorAnimation.createObject(this)
                        }
                    }
                }

                // Bluetooth devices list
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 120
                    radius: WhiteSurTheme.borderRadius
                    color: WhiteSurTheme.controlCenterCard
                    border.width: 1
                    border.color: WhiteSurTheme.borderSecondary

                    // Placeholder for Bluetooth devices
                    Text {
                        anchors.centerIn: parent
                        text: "Bluetooth Devices\n(Coming Soon)"
                        color: WhiteSurTheme.textSecondary
                        font.pixelSize: 12
                        font.family: "Inter"
                        horizontalAlignment: Text.AlignHCenter
                    }
                }
            }

            // Spacer to push footer to bottom
            Item {
                Layout.fillHeight: true
            }

            // Quick Actions section (icon-only with tooltips)
            ColumnLayout {
                Layout.fillWidth: true
                spacing: WhiteSurTheme.spacingSmall

                // Section title
                Text {
                    Layout.fillWidth: true
                    text: "QUICK ACTIONS"
                    color: WhiteSurTheme.textSecondary
                    font.pixelSize: 11
                    font.family: "Inter"
                    font.weight: Font.Medium
                    font.capitalization: Font.AllUppercase
                    font.letterSpacing: 0.5
                }

                // Icon-only quick actions
                RowLayout {
                    Layout.fillWidth: true
                    spacing: WhiteSurTheme.spacing

                    // Settings icon
                    Rectangle {
                        Layout.preferredWidth: 40
                        Layout.preferredHeight: 40
                        radius: 20
                        color: settingsIconMouseArea.containsMouse ? WhiteSurTheme.controlCenterCard : "transparent"
                        border.width: 1
                        border.color: settingsIconMouseArea.containsMouse ? WhiteSurTheme.accent : WhiteSurTheme.borderSecondary

                        Text {
                            anchors.centerIn: parent
                            text: "⚙"
                            color: settingsIconMouseArea.containsMouse ? WhiteSurTheme.accent : WhiteSurTheme.textSecondary
                            font.pixelSize: 16
                        }

                        MouseArea {
                            id: settingsIconMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor

                            onClicked: {
                                Quickshell.execDetached(["gnome-control-center"])
                            }
                        }

                        Behavior on color {
                            animation: WhiteSurTheme.colorAnimation.createObject(this)
                        }

                        Behavior on border.color {
                            animation: WhiteSurTheme.colorAnimation.createObject(this)
                        }
                    }

                    // Terminal icon
                    Rectangle {
                        Layout.preferredWidth: 40
                        Layout.preferredHeight: 40
                        radius: 20
                        color: terminalIconMouseArea.containsMouse ? WhiteSurTheme.controlCenterCard : "transparent"
                        border.width: 1
                        border.color: terminalIconMouseArea.containsMouse ? WhiteSurTheme.accent : WhiteSurTheme.borderSecondary

                        Text {
                            anchors.centerIn: parent
                            text: "󰋊"
                            color: terminalIconMouseArea.containsMouse ? WhiteSurTheme.accent : WhiteSurTheme.textSecondary
                            font.pixelSize: 16
                            font.family: "JetBrainsMono Nerd Font"
                        }

                        MouseArea {
                            id: terminalIconMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor

                            onClicked: {
                                Quickshell.execDetached(["alacritty"])
                            }
                        }

                        Behavior on color {
                            animation: WhiteSurTheme.colorAnimation.createObject(this)
                        }

                        Behavior on border.color {
                            animation: WhiteSurTheme.colorAnimation.createObject(this)
                        }
                    }

                    // Files icon
                    Rectangle {
                        Layout.preferredWidth: 40
                        Layout.preferredHeight: 40
                        radius: 20
                        color: filesIconMouseArea.containsMouse ? WhiteSurTheme.controlCenterCard : "transparent"
                        border.width: 1
                        border.color: filesIconMouseArea.containsMouse ? WhiteSurTheme.accent : WhiteSurTheme.borderSecondary

                        Text {
                            anchors.centerIn: parent
                            text: "󰎄"
                            color: filesIconMouseArea.containsMouse ? WhiteSurTheme.accent : WhiteSurTheme.textSecondary
                            font.pixelSize: 16
                        }

                        MouseArea {
                            id: filesIconMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor

                            onClicked: {
                                Quickshell.execDetached(["nautilus"])
                            }
                        }

                        Behavior on color {
                            animation: WhiteSurTheme.colorAnimation.createObject(this)
                        }

                        Behavior on border.color {
                            animation: WhiteSurTheme.colorAnimation.createObject(this)
                        }
                    }
                }
            }
        }
    }
}
