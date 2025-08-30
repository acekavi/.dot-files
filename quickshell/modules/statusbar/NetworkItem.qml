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

    Column {
        id: contentLayout
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 8
        spacing: 8

        // Network info row with hover effect
        Rectangle {
            width: parent.width
            height: 32
            radius: WhiteSurTheme.borderRadius || 8
            color: mouseArea.containsMouse ? Qt.rgba((WhiteSurTheme.hover || "#636366").r, (WhiteSurTheme.hover || "#636366").g, (WhiteSurTheme.hover || "#636366").b, (WhiteSurTheme.hoverOpacity || 0.3)) : "transparent"

            Behavior on color {
                ColorAnimation {
                    duration: WhiteSurTheme.animationDuration ? WhiteSurTheme.animationDuration : 300
                    easing.type: WhiteSurTheme.animationEasing ? WhiteSurTheme.animationEasing : Easing.OutCubic
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

            // Network info content
            Row {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: 8
                anchors.rightMargin: 8
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
                    color: WhiteSurTheme.textPrimary || "#FFFFFF"
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
                        text: "󰌾" // lock icon
                        color: WhiteSurTheme.textSecondary || "#E5E5E7"
                        font.pixelSize: 10
                        font.family: "JetBrainsMono Nerd Font"
                    }

                    Text {
                        visible: root.network.active
                        text: "󰄬" // check icon
                        color: WhiteSurTheme.success || "#34C759"
                        font.pixelSize: 10
                        font.family: "JetBrainsMono Nerd Font"
                    }
                }
            }
        }

        // Password input (when needed)
        Column {
            visible: root.showPassword
            width: parent.width
            spacing: 8

            // Password input using TextInput instead of TextField for better compatibility
            Rectangle {
                width: parent.width
                height: 32
                radius: WhiteSurTheme.borderRadius || 8
                color: WhiteSurTheme.backgroundSecondary || "#1C1C21"
                border.width: passwordInput.activeFocus ? 1 : 0
                border.color: WhiteSurTheme.accent || "#007AFF"

                TextInput {
                    id: passwordInput
                    anchors.fill: parent
                    anchors.margins: 8
                    echoMode: TextInput.Password
                    font.pixelSize: 11
                    selectByMouse: true
                    focus: true

                    // Debug logging for focus and input events
                    onActiveFocusChanged: {
                        console.log("Password input focus changed:", activeFocus)
                    }

                    onTextChanged: {
                        console.log("Password input text changed:", text.length, "characters")
                    }

                    // Test if we can receive any input at all
                    Keys.onPressed: (event) => {
                                        console.log("Password input key pressed:", event.key, event.text)
                                    }

                    Keys.onReleased: (event) => {
                                         console.log("Password input key released:", event.key)
                                     }

                    // Additional debugging
                    Component.onCompleted: {
                        console.log("Password input component completed")
                        console.log("Initial focus state:", activeFocus)
                        console.log("Initial text:", text)
                    }

                    color: WhiteSurTheme.textPrimary || "#FFFFFF"
                }

                // Placeholder text when empty
                Text {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.leftMargin: 8
                    text: "Password"
                    color: WhiteSurTheme.textSecondary || "#E5E5E7"
                    font.pixelSize: 11
                    visible: !passwordInput.activeFocus && passwordInput.text.length === 0
                }
            }

            // Button row
            Row {
                width: parent.width
                spacing: 8

                Item { Layout.fillWidth: true }

                // Cancel button
                Rectangle {
                    width: 60
                    height: 24
                    radius: WhiteSurTheme.borderRadius || 8
                    color: cancelMouseArea.containsMouse ? (WhiteSurTheme.backgroundSecondary || "#1C1C21") : "transparent"
                    border.width: 1
                    border.color: WhiteSurTheme.border || "#636366"

                    Text {
                        anchors.centerIn: parent
                        text: "Cancel"
                        color: WhiteSurTheme.textSecondary || "#E5E5E7"
                        font.pixelSize: 10
                    }

                    MouseArea {
                        id: cancelMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            root.showPassword = false
                            passwordInput.text = ""
                        }
                    }
                }

                // Connect button
                Rectangle {
                    width: 60
                    height: 24
                    radius: WhiteSurTheme.borderRadius || 8
                    color: connectMouseArea.containsMouse ? Qt.rgba((WhiteSurTheme.accent || "#007AFF").r, (WhiteSurTheme.accent || "#007AFF").g, (WhiteSurTheme.accent || "#007AFF").b, 0.1) : (WhiteSurTheme.accent || "#007AFF")

                    Text {
                        anchors.centerIn: parent
                        text: "Connect"
                        color: WhiteSurTheme.textSelected || "#FFFFFF"
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

            // Auto-focus when password field becomes visible
            Connections {
                target: root
                function onShowPasswordChanged() {
                    console.log("Show password changed to:", root.showPassword)
                    if (root.showPassword) {
                        console.log("Attempting to force focus on password input")
                        passwordInput.forceActiveFocus()
                        console.log("Password input focus after forceActiveFocus:", passwordInput.activeFocus)
                    }
                }
            }
        }
    }
}
