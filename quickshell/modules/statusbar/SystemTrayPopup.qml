import QtQuick
import QtQuick.Layouts
import Quickshell.Services.SystemTray
import "."

Item {
    id: root

    property bool popupOpen: false

    signal clicked()

    implicitWidth: 24
    implicitHeight: 24

    Rectangle {
        id: trayButton
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

        Text {
            anchors.centerIn: parent
            text: "󱃔"  // Chevron up/down icon
            color: WhiteSurTheme.textPrimary
            font.pixelSize: WhiteSurTheme.iconSize
            font.family: "JetBrainsMono Nerd Font"
            rotation: popupOpen ? 180 : 0

            Behavior on rotation {
                NumberAnimation {
                    duration: WhiteSurTheme.animationDuration
                    easing.type: WhiteSurTheme.animationEasing
                }
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

    // Popup window for system tray items
    Rectangle {
        id: popup
        visible: popupOpen
        width: Math.max(200, trayGrid.implicitWidth + 20)
        height: trayGrid.implicitHeight + 20
        color: WhiteSurTheme.background
        radius: WhiteSurTheme.borderRadius
        border.width: 1
        border.color: WhiteSurTheme.border

        anchors.top: parent.bottom
        anchors.topMargin: 8
        anchors.horizontalCenter: parent.horizontalCenter

        // Close popup when clicking outside
        MouseArea {
            anchors.fill: parent
            propagateComposedEvents: true
            onPressed: mouse.accepted = false
        }

        Grid {
            id: trayGrid
            anchors.centerIn: parent
            columns: Math.ceil(Math.sqrt(Math.max(1, SystemTray.items.values.length)))
            columnSpacing: 8
            rowSpacing: 8

            Repeater {
                model: SystemTray.items.values

                delegate: Rectangle {
                    required property var modelData

                    width: 32
                    height: 32
                    radius: WhiteSurTheme.borderRadius
                    color: itemMouseArea.containsMouse ? WhiteSurTheme.backgroundSecondary : "transparent"

                    Image {
                        anchors.centerIn: parent
                        source: modelData.icon
                        width: 16
                        height: 16
                        smooth: true
                    }

                    MouseArea {
                        id: itemMouseArea
                        anchors.fill: parent
                        hoverEnabled: true

                        onClicked: {
                            if (modelData.activate) {
                                modelData.activate()
                            }
                        }

                        onPressed: (mouse) => {
                            if (mouse.button === Qt.RightButton) {
                                if (modelData.contextMenu) {
                                    modelData.contextMenu.open()
                                }
                            }
                        }
                    }

                    // Tooltip
                    Rectangle {
                        visible: itemMouseArea.containsMouse && modelData.tooltip
                        color: WhiteSurTheme.backgroundTertiary
                        radius: 4
                        width: tooltipText.implicitWidth + 8
                        height: tooltipText.implicitHeight + 4
                        anchors.bottom: parent.top
                        anchors.bottomMargin: 4
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
