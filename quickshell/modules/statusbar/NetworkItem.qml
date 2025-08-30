import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "."

Item {
    id: root

    required property QtObject network
    property bool showPassword: false

    signal connectRequested(string ssid, string password)

    implicitWidth: contentLayout.implicitWidth
    implicitHeight: contentLayout.implicitHeight + 16

    Rectangle {
        anchors.fill: parent
        radius: WhiteSurTheme.borderRadius
        color: mouseArea.containsMouse ? Qt.rgba(WhiteSurTheme.hover.r, WhiteSurTheme.hover.g, WhiteSurTheme.hover.b, WhiteSurTheme.hoverOpacity) : "transparent"

        Behavior on color {
            ColorAnimation {
                duration: WhiteSurTheme.animationDuration
                easing.type: WhiteSurTheme.animationEasing
            }
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            onClicked: {
                if (root.network.isSecure && !root.network.active) {
                    root.showPassword = !root.showPassword
                } else {
                    root.connectRequested(root.network.ssid, "")
                }
            }
        }
    }

    Column {
        id: contentLayout
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 8
        spacing: 8

        // Network info row
        Row {
            width: parent.width
            spacing: 8

            // Signal strength icon
            Text {
                id: signalIcon
                anchors.verticalCenter: parent.verticalCenter
                text: {
                    const strength = root.network.strength
                    if (strength > 80) return "󰤨" // signal_wifi_4_bar
                    if (strength > 60) return "󰤥" // signal_wifi_3_bar
                    if (strength > 40) return "󰤢" // signal_wifi_2_bar
                    if (strength > 20) return "󰤟" // signal_wifi_1_bar
                    return "󰤯" // signal_wifi_0_bar
                }
                color: WhiteSurTheme.textPrimary || "white"
                font.pixelSize: WhiteSurTheme.iconSize || 16
                font.family: "JetBrainsMono Nerd Font"
            }

            // SSID
            Text {
                id: ssidText
                anchors.verticalCenter: parent.verticalCenter
                text: root.network.ssid
                color: WhiteSurTheme.textPrimary
                font.pixelSize: 12
                font.weight: root.network.active ? Font.Bold : Font.Normal
            }

            Item { width: parent.width - lockIcon.width - signalIcon.width - ssidText.width - 24; height: 1 }

            // Status icons
            Row {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 4

                Text {
                    id: lockIcon
                    visible: root.network.isSecure
                    text: "󰌾"  // lock icon
                    color: WhiteSurTheme.textSecondary
                    font.pixelSize: 10
                    font.family: "JetBrainsMono Nerd Font"
                }

                Text {
                    visible: root.network.active
                    text: "󰄬"  // check icon
                    color: WhiteSurTheme.success
                    font.pixelSize: 10
                    font.family: "JetBrainsMono Nerd Font"
                }
            }
        }

        // Password input (when needed)
        Column {
            visible: root.showPassword
            width: parent.width
            spacing: 8

            TextField {
                id: passwordInput
                width: parent.width
                height: 32
                echoMode: TextInput.Password
                placeholderText: "Password"
                font.pixelSize: 11
                selectByMouse: true

                background: Rectangle {
                    radius: WhiteSurTheme.borderRadius
                    color: WhiteSurTheme.backgroundSecondary
                    border.width: passwordInput.activeFocus ? 1 : 0
                    border.color: WhiteSurTheme.accent
                }

                color: WhiteSurTheme.textPrimary

                onAccepted: {
                    if (passwordInput.text.length > 0) {
                        root.connectRequested(root.network.ssid, passwordInput.text)
                        root.showPassword = false
                        passwordInput.text = ""
                    }
                }
            }

            // Auto-focus when password field becomes visible
            Connections {
                target: root
                function onShowPasswordChanged() {
                    if (root.showPassword) {
                        passwordInput.forceActiveFocus()
                    }
                }
            }            Row {
                width: parent.width
                spacing: 8

                Item { Layout.fillWidth: true }

                Rectangle {
                    width: 60
                    height: 24
                    radius: WhiteSurTheme.borderRadius
                    color: cancelMouseArea.containsMouse ? WhiteSurTheme.backgroundSecondary : "transparent"

                    Text {
                        anchors.centerIn: parent
                        text: "Cancel"
                        color: WhiteSurTheme.textSecondary
                        font.pixelSize: 10
                    }

                    MouseArea {
                        id: cancelMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: root.showPassword = false
                    }
                }

                Rectangle {
                    width: 60
                    height: 24
                    radius: WhiteSurTheme.borderRadius
                    color: connectMouseArea.containsMouse ? Qt.rgba(WhiteSurTheme.accent.r, WhiteSurTheme.accent.g, WhiteSurTheme.accent.b, 0.1) : WhiteSurTheme.accent

                    Text {
                        anchors.centerIn: parent
                        text: "Connect"
                        color: WhiteSurTheme.textSelected
                        font.pixelSize: 10
                        font.weight: Font.Medium
                    }

                    MouseArea {
                        id: connectMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            if (passwordInput.text.length > 0) {
                                root.connectRequested(root.network.ssid, passwordInput.text)
                                root.showPassword = false
                                passwordInput.text = ""
                            }
                        }
                    }
                }
            }
        }
    }
}
