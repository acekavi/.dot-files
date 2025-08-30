import QtQuick
import QtQuick.Layouts
import Quickshell.Services.UPower
import "."

Item {
    id: root

    property bool popupOpen: false
    readonly property var chargeState: UPower.displayDevice.state
    readonly property bool isCharging: chargeState === UPowerDeviceState.Charging
    readonly property bool isPluggedIn: isCharging || chargeState === UPowerDeviceState.PendingCharge
    readonly property real percentage: UPower.displayDevice.percentage
    readonly property bool isLow: percentage < 0.25 // Below 25%

    signal clicked()

    implicitWidth: batteryButton.implicitWidth
    implicitHeight: WhiteSurTheme.barHeight

    // macOS-style Secondary Button - Battery Widget
    Rectangle {
        id: batteryButton
        anchors.fill: parent
        radius: WhiteSurTheme.borderRadius

        // macOS-style button states
        color: {
            if (batteryMouseArea.pressed) return WhiteSurTheme.backgroundSecondary
            if (batteryMouseArea.containsMouse) return WhiteSurTheme.backgroundSecondary
            return "transparent"
        }

        border.width: 1
        border.color: batteryMouseArea.containsMouse ? WhiteSurTheme.accent : WhiteSurTheme.border

        // Fallback shadow effect using multiple borders
        Rectangle {
            anchors.fill: parent
            anchors.margins: 1
            radius: parent.radius - 1
            color: "transparent"
            border.width: 1
            border.color: Qt.rgba(0, 0, 0, 0.08)
            z: -1
        }

        Behavior on color {
            animation: WhiteSurTheme.colorAnimation.createObject(this)
        }

        Behavior on border.color {
            animation: WhiteSurTheme.colorAnimation.createObject(this)
        }

        RowLayout {
            anchors.centerIn: parent
            spacing: WhiteSurTheme.spacingSmall

            Text {
                Layout.alignment: Qt.AlignVCenter
                text: {
                    let pct = percentage * 100 // Convert to 0-100 range
                    if (isCharging) return "󰂄" // Charging icon
                    if (isPluggedIn) return "󰚥" // Plugged icon
                    if (pct > 75) return "󰁹" // Full battery
                    if (pct > 50) return "󰂀" // 3/4 battery
                    if (pct > 25) return "󰁾" // Half battery
                    if (pct > 10) return "󰁼" // Low battery
                    return "󰁺" // Empty battery
                }
                color: {
                    if (batteryMouseArea.containsMouse) return WhiteSurTheme.accent
                    if (isLow && !isCharging) return WhiteSurTheme.error
                    if (isCharging) return WhiteSurTheme.success
                    return WhiteSurTheme.textPrimary
                }
                font.pixelSize: WhiteSurTheme.iconSize
                font.family: "JetBrainsMono Nerd Font"
                font.weight: batteryMouseArea.containsMouse ? Font.Medium : Font.Normal

                Behavior on color {
                    animation: WhiteSurTheme.colorAnimation.createObject(this)
                }

                Behavior on font.weight {
                    animation: WhiteSurTheme.numberAnimation.createObject(this)
                }
            }

            Text {
                Layout.alignment: Qt.AlignVCenter
                text: Math.round(percentage * 100) + "%"
                color: {
                    if (batteryMouseArea.containsMouse) return WhiteSurTheme.accent
                    if (isLow && !isCharging) return WhiteSurTheme.error
                    return WhiteSurTheme.textPrimary
                }
                font.pixelSize: 11
                font.weight: batteryMouseArea.containsMouse ? Font.Medium : Font.Normal

                Behavior on color {
                    animation: WhiteSurTheme.colorAnimation.createObject(this)
                }

                Behavior on font.weight {
                    animation: WhiteSurTheme.numberAnimation.createObject(this)
                }
            }
        }

        MouseArea {
            id: batteryMouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            onClicked: {
                root.popupOpen = !root.popupOpen
                root.clicked()
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

        Behavior on scale {
            animation: WhiteSurTheme.quickAnimation.createObject(this)
        }
    }

    // Battery popup
    Rectangle {
        id: popup
        visible: popupOpen
        width: WhiteSurTheme.popupWidth
        height: contentColumn.implicitHeight + WhiteSurTheme.spacingLarge
        color: WhiteSurTheme.background
        radius: WhiteSurTheme.borderRadius
        border.width: 1
        border.color: WhiteSurTheme.border

        anchors.top: parent.bottom
        anchors.topMargin: WhiteSurTheme.spacing
        anchors.horizontalCenter: parent.horizontalCenter

        // Fallback shadow effect using multiple borders
        Rectangle {
            anchors.fill: parent
            anchors.margins: 2
            radius: parent.radius - 2
            color: "transparent"
            border.width: 1
            border.color: Qt.rgba(0, 0, 0, 0.15)
            z: -1
        }

        ColumnLayout {
            id: contentColumn
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: WhiteSurTheme.padding
            spacing: WhiteSurTheme.spacing

            // Battery info
            RowLayout {
                Layout.fillWidth: true
                spacing: WhiteSurTheme.spacing

                Text {
                    text: "Battery"
                    color: WhiteSurTheme.textPrimary
                    font.pixelSize: 13
                    font.weight: Font.Medium
                }

                Item { Layout.fillWidth: true }

                Text {
                    text: Math.round(percentage * 100) + "%"
                    color: WhiteSurTheme.textPrimary
                    font.pixelSize: 13
                    font.weight: Font.Medium
                }
            }

            // Battery bar
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 6
                radius: 3
                color: WhiteSurTheme.backgroundSecondary

                Rectangle {
                    width: parent.width * percentage
                    height: parent.height
                    radius: parent.radius
                    color: isLow && !isCharging ? WhiteSurTheme.error :
                                                  isCharging ? WhiteSurTheme.success : WhiteSurTheme.accent

                    Behavior on width {
                        animation: WhiteSurTheme.numberAnimation.createObject(this)
                    }
                }
            }

            // Power mode selector (placeholder)
            Text {
                text: "Power Modes"
                color: WhiteSurTheme.textSecondary
                font.pixelSize: 11
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: WhiteSurTheme.spacingSmall

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 28
                    radius: WhiteSurTheme.borderRadius
                    color: WhiteSurTheme.backgroundSecondary

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: WhiteSurTheme.spacing
                        anchors.verticalCenter: parent.verticalCenter
                        text: "󰓅 Performance"
                        color: WhiteSurTheme.textPrimary
                        font.pixelSize: 11
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 28
                    radius: WhiteSurTheme.borderRadius
                    color: WhiteSurTheme.accent

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: WhiteSurTheme.spacing
                        anchors.verticalCenter: parent.verticalCenter
                        text: "󰗑 Balanced"
                        color: WhiteSurTheme.textSelected
                        font.pixelSize: 11
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 28
                    radius: WhiteSurTheme.borderRadius
                    color: WhiteSurTheme.backgroundSecondary

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: WhiteSurTheme.spacing
                        anchors.verticalCenter: parent.verticalCenter
                        text: "󰾆 Power Saver"
                        color: WhiteSurTheme.textPrimary
                        font.pixelSize: 11
                    }
                }
            }
        }
    }
}
