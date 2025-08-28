import QtQuick
import QtQuick.Layouts
import Quickshell.Services.UPower
import "."

Item {
    id: root

    property bool popupOpen: false
    readonly property var battery: UPower.displayDevice
    readonly property bool isCharging: battery?.state === UPowerDevice.Charging
    readonly property bool isPluggedIn: battery?.state === UPowerDevice.FullyCharged || isCharging
    readonly property real percentage: battery?.percentage || 0
    readonly property bool isLow: percentage <= 20

    signal clicked()

    implicitWidth: batteryRow.implicitWidth
    implicitHeight: 24

    Rectangle {
        id: batteryButton
        anchors.fill: parent
        radius: WhiteSurTheme.borderRadius
        color: popupOpen ? WhiteSurTheme.backgroundSecondary :
               mouseArea.containsMouse ? Qt.rgba(WhiteSurTheme.hover.r, WhiteSurTheme.hover.g, WhiteSurTheme.hover.b, WhiteSurTheme.hoverOpacity) :
               "transparent"

        Behavior on color {
            ColorAnimation {
                duration: WhiteSurTheme.animationDuration
                easing.type: WhiteSurTheme.animationEasing
            }
        }

        Row {
            id: batteryRow
            anchors.centerIn: parent
            spacing: 4

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: {
                    if (isCharging) return "󰂄"  // Charging icon
                    if (isPluggedIn) return "󰚥"  // Plugged icon
                    if (percentage > 75) return "󰁹"  // Full battery
                    if (percentage > 50) return "󰂀"  // 3/4 battery
                    if (percentage > 25) return "󰁾"  // Half battery
                    if (percentage > 10) return "󰁼"  // Low battery
                    return "󰁺"  // Empty battery
                }
                color: isLow && !isCharging ? WhiteSurTheme.error :
                       isCharging ? WhiteSurTheme.success :
                       WhiteSurTheme.textPrimary
                font.pixelSize: WhiteSurTheme.iconSize
                font.family: "JetBrainsMono Nerd Font"
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: Math.round(percentage) + "%"
                color: isLow && !isCharging ? WhiteSurTheme.error : WhiteSurTheme.textPrimary
                font.pixelSize: 11
                font.weight: Font.Medium
            }
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true

            onClicked: {
                root.popupOpen = !root.popupOpen
                root.clicked()
            }
        }
    }

    // Battery popup
    Rectangle {
        id: popup
        visible: popupOpen
        width: 250
        height: contentColumn.implicitHeight + 20
        color: WhiteSurTheme.background
        radius: WhiteSurTheme.borderRadius
        border.width: 1
        border.color: WhiteSurTheme.border

        anchors.top: parent.bottom
        anchors.topMargin: 8
        anchors.horizontalCenter: parent.horizontalCenter

        Column {
            id: contentColumn
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 10
            spacing: 12

            // Battery info
            Row {
                spacing: 8
                width: parent.width

                Text {
                    text: "Battery"
                    color: WhiteSurTheme.textPrimary
                    font.pixelSize: 13
                    font.weight: Font.Medium
                }

                Item { Layout.fillWidth: true }

                Text {
                    text: Math.round(percentage) + "%"
                    color: WhiteSurTheme.textPrimary
                    font.pixelSize: 13
                    font.weight: Font.Medium
                }
            }

            // Battery bar
            Rectangle {
                width: parent.width
                height: 6
                radius: 3
                color: WhiteSurTheme.backgroundSecondary

                Rectangle {
                    width: parent.width * (percentage / 100)
                    height: parent.height
                    radius: parent.radius
                    color: isLow && !isCharging ? WhiteSurTheme.error :
                           isCharging ? WhiteSurTheme.success : WhiteSurTheme.accent

                    Behavior on width {
                        NumberAnimation {
                            duration: WhiteSurTheme.animationDuration
                            easing.type: WhiteSurTheme.animationEasing
                        }
                    }
                }
            }

            // Power mode selector (placeholder)
            Text {
                text: "Power Modes"
                color: WhiteSurTheme.textSecondary
                font.pixelSize: 11
            }

            Column {
                width: parent.width
                spacing: 4

                Rectangle {
                    width: parent.width
                    height: 28
                    radius: WhiteSurTheme.borderRadius
                    color: WhiteSurTheme.backgroundSecondary

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: 8
                        anchors.verticalCenter: parent.verticalCenter
                        text: "󰓅 Performance"
                        color: WhiteSurTheme.textPrimary
                        font.pixelSize: 11
                    }
                }

                Rectangle {
                    width: parent.width
                    height: 28
                    radius: WhiteSurTheme.borderRadius
                    color: WhiteSurTheme.accent

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: 8
                        anchors.verticalCenter: parent.verticalCenter
                        text: "󰗑 Balanced"
                        color: WhiteSurTheme.textSelected
                        font.pixelSize: 11
                    }
                }

                Rectangle {
                    width: parent.width
                    height: 28
                    radius: WhiteSurTheme.borderRadius
                    color: WhiteSurTheme.backgroundSecondary

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: 8
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
