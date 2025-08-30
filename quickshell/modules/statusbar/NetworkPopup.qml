import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import "."

LazyLoader {
    id: root

    property Item hoverTarget
    property bool popupOpen: false

    active: popupOpen

    component: PanelWindow {
        id: popupWindow
        color: "transparent"

        anchors.top: true
        anchors.right: true

        implicitWidth: popupBackground.implicitWidth + 16
        implicitHeight: popupBackground.implicitHeight + 16

        exclusionMode: ExclusionMode.Ignore
        exclusiveZone: 0
        WlrLayershell.margins.top: 40
        WlrLayershell.margins.right: 8
        WlrLayershell.namespace: "quickshell:networkPopup"
        WlrLayershell.layer: WlrLayer.Overlay

        // Click outside to close
        MouseArea {
            anchors.fill: parent
            onClicked: root.popupOpen = false
        }

        Rectangle {
            id: popupBackground
            anchors.centerIn: parent
            implicitWidth: 320
            implicitHeight: Math.min(600, contentColumn.implicitHeight + 40)
            color: WhiteSurTheme.background
            radius: WhiteSurTheme.borderRadius
            border.width: 1
            border.color: WhiteSurTheme.border

            // Prevent closing when clicking inside
            MouseArea {
                anchors.fill: parent
                onClicked: {} // Consume click
            }

            Column {
                id: contentColumn
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: 20
                spacing: 16

                // Header
                Row {
                    width: parent.width
                    spacing: 8

                    Text {
                        id: wifiIcon
                        anchors.verticalCenter: parent.verticalCenter
                        text: "󰤨" // WiFi icon
                        color: WhiteSurTheme.textPrimary
                        font.pixelSize: 18
                        font.family: "JetBrainsMono Nerd Font"
                    }

                    Text {
                        id: titleText
                        anchors.verticalCenter: parent.verticalCenter
                        text: "Wi-Fi Networks"
                        color: WhiteSurTheme.textPrimary
                        font.pixelSize: 14
                        font.weight: Font.Medium
                    }

                    Item { width: parent.width - wifiIcon.width - titleText.width - toggleButton.width - 16; height: 1 }

                    // WiFi toggle
                    Rectangle {
                        id: toggleButton
                        width: 48
                        height: 24
                        radius: 12
                        color: NetworkService.wifiEnabled ? WhiteSurTheme.accent : WhiteSurTheme.backgroundSecondary

                        Behavior on color {
                            ColorAnimation {
                                duration: WhiteSurTheme.animationDuration ? WhiteSurTheme.animationDuration : 300
                                easing.type: WhiteSurTheme.animationEasing ? WhiteSurTheme.animationEasing : Easing.OutCubic
                            }
                        }

                        Rectangle {
                            width: 20
                            height: 20
                            radius: 10
                            color: "white"
                            x: NetworkService.wifiEnabled ? parent.width - width - 2 : 2
                            y: 2

                            Behavior on x {
                                NumberAnimation {
                                    duration: WhiteSurTheme.animationDuration ? WhiteSurTheme.animationDuration : 300
                                    easing.type: WhiteSurTheme.animationEasing ? WhiteSurTheme.animationEasing : Easing.OutCubic
                                }
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: NetworkService.toggleWifi()
                        }
                    }
                }

                // Current connection
                Rectangle {
                    visible: NetworkService.active !== null
                    width: parent.width
                    height: currentConnectionText.implicitHeight + 16
                    radius: WhiteSurTheme.borderRadius
                    color: Qt.rgba(WhiteSurTheme.accent.r, WhiteSurTheme.accent.g, WhiteSurTheme.accent.b, 0.1)
                    border.width: 1
                    border.color: WhiteSurTheme.accent

                    Row {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        spacing: 8

                        Text {
                            id: checkIcon
                            text: "󰄬"  // check icon
                            color: WhiteSurTheme.accent
                            font.pixelSize: 12
                            font.family: "JetBrainsMono Nerd Font"
                        }

                        Text {
                            id: currentConnectionText
                            text: `Connected to ${NetworkService.networkName}`
                            color: WhiteSurTheme.textPrimary
                            font.pixelSize: 11
                        }

                        Item { width: parent.width - checkIcon.width - currentConnectionText.width - disconnectButton.width - 16; height: 1 }

                        Rectangle {
                            id: disconnectButton
                            width: 70
                            height: 20
                            radius: WhiteSurTheme.borderRadius
                            color: disconnectMouseArea.containsMouse ? Qt.rgba(WhiteSurTheme.error.r, WhiteSurTheme.error.g, WhiteSurTheme.error.b, 0.1) : "transparent"
                            border.width: 1
                            border.color: WhiteSurTheme.error

                            Text {
                                anchors.centerIn: parent
                                text: "Disconnect"
                                color: WhiteSurTheme.error
                                font.pixelSize: 9
                            }

                            MouseArea {
                                id: disconnectMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: NetworkService.disconnectWifiNetwork()
                            }
                        }
                    }
                }

                // Available networks
                Column {
                    width: parent.width
                    spacing: 4

                    Text {
                        text: "Available Networks"
                        color: WhiteSurTheme.textSecondary
                        font.pixelSize: 11
                        font.weight: Font.Medium
                    }

                    // Refresh button
                    Rectangle {
                        width: parent.width
                        height: 32
                        radius: WhiteSurTheme.borderRadius
                        color: refreshMouseArea.containsMouse ? WhiteSurTheme.backgroundSecondary : "transparent"
                        border.width: 1
                        border.color: WhiteSurTheme.border

                        Row {
                            anchors.centerIn: parent
                            spacing: 6

                            Text {
                                text: "󰑐"  // refresh icon
                                color: WhiteSurTheme.textPrimary
                                font.pixelSize: 12
                                font.family: "JetBrainsMono Nerd Font"
                            }

                            Text {
                                text: "Scan for networks"
                                color: WhiteSurTheme.textPrimary
                                font.pixelSize: 11
                            }
                        }

                        MouseArea {
                            id: refreshMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: NetworkService.rescanWifi()
                        }
                    }
                }

                // Networks list
                Rectangle {
                    width: parent.width
                    height: Math.min(300, networksColumn.implicitHeight + 16)
                    radius: WhiteSurTheme.borderRadius
                    color: WhiteSurTheme.backgroundSecondary
                    clip: true

                    ScrollView {
                        anchors.fill: parent
                        anchors.margins: 8

                        Column {
                            id: networksColumn
                            width: parent.width
                            spacing: 2

                            Repeater {
                                model: NetworkService.wifiNetworks
                                delegate: NetworkItem {
                                    required property QtObject modelData
                                    width: networksColumn.width
                                    network: modelData
                                    onConnectRequested: (ssid, password) => {
                                        NetworkService.connectToWifiNetwork(ssid, password)
                                    }
                                }
                            }

                            // Empty state
                            Text {
                                visible: NetworkService.wifiNetworks.length === 0
                                width: parent.width
                                height: 60
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                text: NetworkService.wifiEnabled ? "No networks found" : "Wi-Fi is disabled"
                                color: WhiteSurTheme.textSecondary
                                font.pixelSize: 11
                            }
                        }
                    }
                }

                // Footer buttons
                Row {
                    width: parent.width
                    spacing: 8

                    Rectangle {
                        width: (parent.width - 8) / 2
                        height: 32
                        radius: WhiteSurTheme.borderRadius
                        color: settingsMouseArea.containsMouse ? WhiteSurTheme.backgroundSecondary : "transparent"
                        border.width: 1
                        border.color: WhiteSurTheme.border

                        Text {
                            anchors.centerIn: parent
                            text: "Network Settings"
                            color: WhiteSurTheme.textPrimary
                            font.pixelSize: 10
                        }

                        MouseArea {
                            id: settingsMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                Quickshell.execDetached(["nm-connection-editor"])
                                root.popupOpen = false
                            }
                        }
                    }

                    Rectangle {
                        width: (parent.width - 8) / 2
                        height: 32
                        radius: WhiteSurTheme.borderRadius
                        color: closeMouseArea.containsMouse ? Qt.rgba(WhiteSurTheme.accent.r, WhiteSurTheme.accent.g, WhiteSurTheme.accent.b, 0.1) : WhiteSurTheme.accent

                        Text {
                            anchors.centerIn: parent
                            text: "Close"
                            color: WhiteSurTheme.textSelected
                            font.pixelSize: 10
                            font.weight: Font.Medium
                        }

                        MouseArea {
                            id: closeMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: root.popupOpen = false
                        }
                    }
                }
            }
        }
    }
}
