pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import "."

PanelWindow {
    id: statusbar

    property ShellScreen targetScreen
    screen: targetScreen

    // Process component for launching external applications
    property var rofiProcess: null
    color: "transparent"
    exclusiveZone: WhiteSurTheme.barHeight+8
    implicitHeight: WhiteSurTheme.barHeight+4

    // Network popup
    NetworkPopup {
        id: networkPopup
    }

    anchors {
        top: true
        left: true
        right: true
    }

    margins {
        top: 4
        left: 8
        right: 8
    }

    Rectangle {
        anchors.fill: parent
        radius: WhiteSurTheme.borderRadius
        color: Qt.rgba(WhiteSurTheme.background.r, WhiteSurTheme.background.g, WhiteSurTheme.background.b, WhiteSurTheme.backgroundOpacity)
        border.width: 1
        border.color: WhiteSurTheme.border

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 8
            anchors.rightMargin: 8
            anchors.topMargin: 2

            // Left side - Arch logo and workspaces
            RowLayout {
                spacing: 8

                ArchLogo {
                    id: archLogo
                    onClicked: {
                        Quickshell.execDetached(["uwsm", "app", "--","rofi", "-show", "drun"])
                    }
                }

                WorkspaceIndicator {
                    id: workspaceIndicator
                }
            }

            // Center spacer
            Item {
                Layout.fillWidth: true

                ClockWidget {
                    id: clockWidget
                    anchors.centerIn: parent
                }
            }

            // Right side - System widgets
            RowLayout {
                spacing: 8

                // Network widget
                Rectangle {
                    Layout.preferredWidth: 32
                    Layout.preferredHeight: 32
                    radius: WhiteSurTheme.borderRadius
                    color: wifiMouseArea.containsMouse ? Qt.rgba(WhiteSurTheme.hover.r, WhiteSurTheme.hover.g, WhiteSurTheme.hover.b, WhiteSurTheme.hoverOpacity) : "transparent"

                    Text {
                        anchors.centerIn: parent
                        text: {
                            const strength = NetworkService.networkStrength;
                            if (!NetworkService.wifiEnabled)
                            return "󰤮"; // wifi_off
                            if (NetworkService.ethernet)
                            return "󰌗"; // lan
                            if (strength > 80)
                            return "󰤨"; // signal_wifi_4_bar
                            if (strength > 60)
                            return "󰤥"; // signal_wifi_3_bar
                            if (strength > 40)
                            return "󰤢"; // signal_wifi_2_bar
                            if (strength > 20)
                            return "󰤟"; // signal_wifi_1_bar
                            return "󰤯"; // signal_wifi_0_bar
                        }
                        color: WhiteSurTheme.textPrimary
                        font.pixelSize: WhiteSurTheme.iconSize
                        font.family: "JetBrainsMono Nerd Font"
                    }

                    MouseArea {
                        id: wifiMouseArea
                        anchors.fill: parent
                        hoverEnabled: true

                        onClicked: {
                            networkPopup.popupOpen = !networkPopup.popupOpen;
                        }
                    }
                }

                BatteryWidget {
                    id: batteryWidget
                }

                SystemTrayPopup {
                    id: systemTrayPopup
                }
            }
        }
    }
}
