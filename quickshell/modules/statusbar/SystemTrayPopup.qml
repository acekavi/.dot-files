import QtQuick
import QtQuick.Layouts
import Quickshell.Services.SystemTray
import "."

Item {
    id: root

    property bool popupOpen: false

    signal clicked()

    implicitWidth: WhiteSurTheme.iconSize + WhiteSurTheme.spacingLarge
    implicitHeight: WhiteSurTheme.barHeight

    // macOS-style Secondary Button - System Tray
    Rectangle {
        id: trayButton
        anchors.fill: parent
        radius: WhiteSurTheme.borderRadius

        // macOS-style button states
        color: {
            if (trayMouseArea.pressed) return WhiteSurTheme.backgroundSecondary
            if (trayMouseArea.containsMouse) return WhiteSurTheme.backgroundSecondary
            return "transparent"
        }

        border.width: 1
        border.color: trayMouseArea.containsMouse ? WhiteSurTheme.accent : WhiteSurTheme.border

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
            text: "󱃔" // Chevron up/down icon
            color: trayMouseArea.containsMouse ? WhiteSurTheme.accent : WhiteSurTheme.textPrimary
            font.pixelSize: WhiteSurTheme.iconSize
            font.family: "JetBrainsMono Nerd Font"
            font.weight: trayMouseArea.containsMouse ? Font.Medium : Font.Normal
            rotation: popupOpen ? 180 : 0

            Behavior on color {
                animation: WhiteSurTheme.colorAnimation.createObject(this)
            }

            Behavior on font.weight {
                animation: WhiteSurTheme.numberAnimation.createObject(this)
            }

            Behavior on rotation {
                animation: WhiteSurTheme.numberAnimation.createObject(this)
            }
        }

        MouseArea {
            id: trayMouseArea
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

    // Popup window for system tray items
    Rectangle {
        id: popup
        visible: popupOpen
        width: Math.max(WhiteSurTheme.popupWidth, trayGrid.implicitWidth + WhiteSurTheme.spacingLarge)
        height: trayGrid.implicitHeight + WhiteSurTheme.spacingLarge
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

        // Close popup when clicking outside
        MouseArea {
            anchors.fill: parent
            propagateComposedEvents: true
            onPressed: mouse.accepted = false
        }

        GridLayout {
            id: trayGrid
            anchors.centerIn: parent
            columns: Math.ceil(Math.sqrt(Math.max(1, SystemTray.items.values.length)))
            columnSpacing: WhiteSurTheme.spacing
            rowSpacing: WhiteSurTheme.spacing

            Repeater {
                model: SystemTray.items.values

                delegate: Rectangle {
                    required property var modelData

                    Layout.preferredWidth: WhiteSurTheme.iconSize * 2
                    Layout.preferredHeight: WhiteSurTheme.iconSize * 2
                    radius: WhiteSurTheme.borderRadius
                    color: itemMouseArea.containsMouse ? WhiteSurTheme.backgroundSecondary : "transparent"
                    border.width: 1
                    border.color: itemMouseArea.containsMouse ? WhiteSurTheme.accent : WhiteSurTheme.border

                    Behavior on color {
                        animation: WhiteSurTheme.colorAnimation.createObject(this)
                    }

                    Behavior on border.color {
                        animation: WhiteSurTheme.colorAnimation.createObject(this)
                    }

                    Image {
                        anchors.centerIn: parent
                        source: modelData.icon
                        width: WhiteSurTheme.iconSize
                        height: WhiteSurTheme.iconSize
                        smooth: true
                    }

                    MouseArea {
                        id: itemMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor

                        onClicked: {
                            if (modelData.activate) {
                                modelData.activate()
                            }
                        }

                        onPressed: (mouse) => {
                                       // macOS-style press animation
                                       parent.scale = 0.98

                                       // Handle right-click context menu
                                       if (mouse.button === Qt.RightButton) {
                                           if (modelData.contextMenu) {
                                               modelData.contextMenu.open()
                                           }
                                       }
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

                    // Tooltip
                    Rectangle {
                        visible: itemMouseArea.containsMouse && modelData.tooltip
                        color: WhiteSurTheme.backgroundTertiary
                        radius: WhiteSurTheme.borderRadius
                        width: tooltipText.implicitWidth + WhiteSurTheme.spacing
                        height: tooltipText.implicitHeight + WhiteSurTheme.spacingSmall
                        anchors.bottom: parent.top
                        anchors.bottomMargin: WhiteSurTheme.spacingSmall
                        anchors.horizontalCenter: parent.horizontalCenter

                        Text {
                            id: tooltipText
                            anchors.centerIn: parent
                            text: modelData.tooltip || ""
                            color: WhiteSurTheme.textPrimary
                            font.pixelSize: 10
                        }
                    }
                }
            }
        }

        // Empty state
        Text {
            anchors.centerIn: parent
            text: "No system tray items"
            color: WhiteSurTheme.textSecondary
            font.pixelSize: 12
            visible: SystemTray.items.values.length === 0
        }
    }
}
