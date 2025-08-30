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
    exclusiveZone: WhiteSurTheme.barHeight + WhiteSurTheme.spacing
    implicitHeight: WhiteSurTheme.barHeight + WhiteSurTheme.spacingSmall

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
        top: WhiteSurTheme.spacingSmall
        left: WhiteSurTheme.spacing
        right: WhiteSurTheme.spacing
    }

    Rectangle {
        anchors.fill: parent
        radius: WhiteSurTheme.borderRadius
        color: Qt.rgba(WhiteSurTheme.background.r, WhiteSurTheme.background.g, WhiteSurTheme.background.b, WhiteSurTheme.backgroundOpacity)
        border.width: 1
        border.color: WhiteSurTheme.border

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: WhiteSurTheme.spacing
            anchors.rightMargin: WhiteSurTheme.spacing
            anchors.topMargin: WhiteSurTheme.spacingSmall
            spacing: WhiteSurTheme.spacing

            // Left section - Arch logo and workspaces
            RowLayout {
                Layout.alignment: Qt.AlignLeft
                Layout.fillHeight: true
                spacing: WhiteSurTheme.spacing

                // Character Button - Arch Logo (simplified, no button styling)
                Text {
                    id: archLogoText
                    Layout.preferredWidth: WhiteSurTheme.iconSize + WhiteSurTheme.spacingLarge
                    Layout.preferredHeight: WhiteSurTheme.iconSize + WhiteSurTheme.spacingLarge
                    text: "󰣇"
                    color: archLogoMouseArea.containsMouse ? WhiteSurTheme.accent : WhiteSurTheme.textPrimary
                    font.pixelSize: WhiteSurTheme.iconSize
                    font.family: "JetBrainsMono Nerd Font"
                    font.weight: archLogoMouseArea.containsMouse ? Font.Bold : Font.Medium
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter

                    Behavior on color {
                        animation: WhiteSurTheme.colorAnimation.createObject(this)
                    }

                    Behavior on font.weight {
                        animation: WhiteSurTheme.numberAnimation.createObject(this)
                    }

                    MouseArea {
                        id: archLogoMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor

                        onClicked: {
                            Quickshell.execDetached(["uwsm", "app", "--","rofi", "-show", "drun"])
                        }
                    }
                }

                WorkspaceIndicator {
                    id: workspaceIndicator
                    Layout.fillHeight: true
                }
            }

            // Center spacer - Clock widget
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                ClockWidget {
                    id: clockWidget
                    anchors.centerIn: parent
                }
            }

            // Right side - System widgets
            RowLayout {
                Layout.alignment: Qt.AlignRight
                Layout.fillHeight: true
                spacing: WhiteSurTheme.spacingLarge

                // WiFi Button
                Rectangle {
                    id: wifiButton
                    Layout.preferredWidth: WhiteSurTheme.iconSize + WhiteSurTheme.spacingLarge
                    Layout.preferredHeight: WhiteSurTheme.iconSize + WhiteSurTheme.spacingLarge
                    radius: WhiteSurTheme.borderRadius

                    // macOS-style secondary button states
                    color: {
                        if (wifiMouseArea.pressed) return WhiteSurTheme.backgroundSecondary
                        if (wifiMouseArea.containsMouse) return WhiteSurTheme.backgroundSecondary
                        return "transparent"
                    }

                    border.width: 1
                    border.color: wifiMouseArea.containsMouse ? WhiteSurTheme.accent : WhiteSurTheme.border

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
                        color: wifiMouseArea.containsMouse ? WhiteSurTheme.accent : WhiteSurTheme.textPrimary
                        font.pixelSize: WhiteSurTheme.iconSize
                        font.family: "JetBrainsMono Nerd Font"
                        font.weight: wifiMouseArea.containsMouse ? Font.Medium : Font.Normal

                        Behavior on color {
                            animation: WhiteSurTheme.colorAnimation.createObject(this)
                        }

                        Behavior on font.weight {
                            animation: WhiteSurTheme.numberAnimation.createObject(this)
                        }
                    }

                    MouseArea {
                        id: wifiMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor

                        onClicked: {
                            networkPopup.popupOpen = !networkPopup.popupOpen;
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

                // Bluetooth Button
                Rectangle {
                    id: bluetoothButton
                    Layout.preferredWidth: WhiteSurTheme.iconSize + WhiteSurTheme.spacingLarge
                    Layout.preferredHeight: WhiteSurTheme.iconSize + WhiteSurTheme.spacingLarge
                    radius: WhiteSurTheme.borderRadius

                    // macOS-style secondary button states
                    color: {
                        if (bluetoothMouseArea.pressed) return WhiteSurTheme.backgroundSecondary
                        if (bluetoothMouseArea.containsMouse) return WhiteSurTheme.backgroundSecondary
                        return "transparent"
                    }

                    border.width: 1
                    border.color: bluetoothMouseArea.containsMouse ? WhiteSurTheme.accent : WhiteSurTheme.border

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

                    Text {
                        anchors.centerIn: parent
                        text: "󰂯" // bluetooth icon
                        color: bluetoothMouseArea.containsMouse ? WhiteSurTheme.accent : WhiteSurTheme.textPrimary
                        font.pixelSize: WhiteSurTheme.iconSize
                        font.family: "JetBrainsMono Nerd Font"
                        font.weight: bluetoothMouseArea.containsMouse ? Font.Medium : Font.Normal

                        Behavior on color {
                            animation: WhiteSurTheme.colorAnimation.createObject(this)
                        }

                        Behavior on font.weight {
                            animation: WhiteSurTheme.numberAnimation.createObject(this)
                        }
                    }

                    MouseArea {
                        id: bluetoothMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor

                        onClicked: {
                            // TODO: Add bluetooth popup or settings
                            Quickshell.execDetached(["blueman-manager"])
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

                // Volume Button
                Rectangle {
                    id: volumeButton
                    Layout.preferredWidth: WhiteSurTheme.iconSize + WhiteSurTheme.spacingLarge
                    Layout.preferredHeight: WhiteSurTheme.iconSize + WhiteSurTheme.spacingLarge
                    radius: WhiteSurTheme.borderRadius

                    // macOS-style secondary button states
                    color: {
                        if (volumeMouseArea.pressed) return WhiteSurTheme.backgroundSecondary
                        if (volumeMouseArea.containsMouse) return WhiteSurTheme.backgroundSecondary
                        return "transparent"
                    }

                    border.width: 1
                    border.color: volumeMouseArea.containsMouse ? WhiteSurTheme.accent : WhiteSurTheme.border

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

                    Text {
                        anchors.centerIn: parent
                        text: "󰕾" // volume icon
                        color: volumeMouseArea.containsMouse ? WhiteSurTheme.accent : WhiteSurTheme.textPrimary
                        font.pixelSize: WhiteSurTheme.iconSize
                        font.family: "JetBrainsMono Nerd Font"
                        font.weight: volumeMouseArea.containsMouse ? Font.Medium : Font.Normal

                        Behavior on color {
                            animation: WhiteSurTheme.colorAnimation.createObject(this)
                        }

                        Behavior on font.weight {
                            animation: WhiteSurTheme.numberAnimation.createObject(this)
                        }
                    }

                    MouseArea {
                        id: volumeMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor

                        onClicked: {
                            // TODO: Add volume popup or settings
                            Quickshell.execDetached(["pavucontrol"])
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

                BatteryWidget {
                    id: batteryWidget
                    Layout.fillHeight: true
                }

            }
        }
    }
}
