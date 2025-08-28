import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import "."

PanelWindow {
    id: statusbar

    // Process component for launching external applications
    property var rofiProcess: null

    anchors {
        top: true
        left: true
        right: true
    }

    implicitHeight: WhiteSurTheme.barHeight+8 // 8px margin top and bottom
    exclusiveZone: implicitHeight

    color: "transparent"

    Rectangle {
        id: background
        anchors.fill: parent
        anchors.margins: 4

        color: Qt.rgba(WhiteSurTheme.background.r, WhiteSurTheme.background.g, WhiteSurTheme.background.b, WhiteSurTheme.backgroundOpacity)
        radius: WhiteSurTheme.borderRadius
        border.width: 1
        border.color: WhiteSurTheme.border

        // Blur effect background
        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            color: "transparent"

            // This would need a blur shader effect in a real implementation
            opacity: 0.1
        }
    }

    RowLayout {
        anchors.fill: background
        spacing: WhiteSurTheme.spacing
        anchors.leftMargin: 4
        anchors.rightMargin: 6

        // Left section
        Row {
            Layout.alignment: Qt.AlignLeft
            spacing: WhiteSurTheme.spacing

            ArchLogo {
                anchors.verticalCenter: parent.verticalCenter
                onClicked: {
                    // Launch rofi using Quickshell.execDetached
                    Quickshell.execDetached(["uwsm", "app", "--", "rofi", "-show", "drun"])
                }
            }

            WorkspaceIndicator {
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        // Center section
        Item {
            Layout.fillWidth: true

            ClockWidget {
                anchors.centerIn: parent
                showDate: true
            }
        }

        // Right section
        Row {
            Layout.alignment: Qt.AlignRight
            spacing: WhiteSurTheme.spacing

            SystemTrayPopup {
                anchors.verticalCenter: parent.verticalCenter
            }

            // WiFi icon placeholder
            Rectangle {
                width: 24
                height: 24
                radius: WhiteSurTheme.borderRadius
                color: wifiMouseArea.containsMouse ? Qt.rgba(WhiteSurTheme.hover.r, WhiteSurTheme.hover.g, WhiteSurTheme.hover.b, WhiteSurTheme.hoverOpacity) : "transparent"

                Text {
                    anchors.centerIn: parent
                    text: "󰤨"  // WiFi icon
                    color: WhiteSurTheme.textPrimary
                    font.pixelSize: WhiteSurTheme.iconSize
                    font.family: "JetBrainsMono Nerd Font"
                }

                MouseArea {
                    id: wifiMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        // TODO: Open WiFi popup
                        console.log("WiFi clicked")
                    }
                }
            }

            // Bluetooth icon placeholder
            Rectangle {
                width: 24
                height: 24
                radius: WhiteSurTheme.borderRadius
                color: bluetoothMouseArea.containsMouse ? Qt.rgba(WhiteSurTheme.hover.r, WhiteSurTheme.hover.g, WhiteSurTheme.hover.b, WhiteSurTheme.hoverOpacity) : "transparent"

                Text {
                    anchors.centerIn: parent
                    text: "󰂯"  // Bluetooth icon
                    color: WhiteSurTheme.textPrimary
                    font.pixelSize: WhiteSurTheme.iconSize
                    font.family: "JetBrainsMono Nerd Font"
                }

                MouseArea {
                    id: bluetoothMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        // TODO: Open Bluetooth popup
                        console.log("Bluetooth clicked")
                    }
                }
            }

            BatteryWidget {
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }
}
