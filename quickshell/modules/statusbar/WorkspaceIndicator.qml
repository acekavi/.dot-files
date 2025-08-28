import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import "."

Item {
    id: root

    property bool showNumbers: false
    readonly property HyprlandMonitor monitor: Hyprland.monitorFor(root.QsWindow.window?.screen)
    property list<bool> workspaceOccupied: []

    signal workspaceClicked(int workspaceId)

    implicitWidth: workspaceRow.implicitWidth
    implicitHeight: WhiteSurTheme.barHeight

    function updateWorkspaceOccupied() {
        workspaceOccupied = Array.from({ length: 5 }, (_, i) => {
            return Hyprland.workspaces.values.some(ws => ws.id === i + 1);
        })
    }

    Component.onCompleted: updateWorkspaceOccupied()

    Connections {
        target: Hyprland.workspaces
        function onValuesChanged() {
            updateWorkspaceOccupied();
        }
    }

    Connections {
        target: Hyprland
        function onFocusedWorkspaceChanged() {
            updateWorkspaceOccupied();
        }
    }

    Row {
        id: workspaceRow
        anchors.centerIn: parent
        spacing: 4

        Repeater {
            model: 5

            Rectangle {
                id: workspaceButton

                property int workspaceId: index + 1
                property bool isActive: monitor?.activeWorkspace?.id === workspaceId
                property bool hasWindows: workspaceOccupied[index]

                width: 15
                height: 15
                radius: WhiteSurTheme.fullRadius

                color: {
                    if (isActive) return WhiteSurTheme.accent
                    if (hasWindows) return Qt.rgba(WhiteSurTheme.accent.r, WhiteSurTheme.accent.g, WhiteSurTheme.accent.b, 0.3)
                    return "transparent"
                }

                border.width: hasWindows && !isActive ? 1 : 0
                border.color: Qt.rgba(WhiteSurTheme.accent.r, WhiteSurTheme.accent.g, WhiteSurTheme.accent.b, 0.5)

                Behavior on color {
                    ColorAnimation {
                        duration: WhiteSurTheme.animationDuration
                        easing.type: WhiteSurTheme.animationEasing
                    }
                }

                Behavior on border.width {
                    NumberAnimation {
                        duration: WhiteSurTheme.animationDuration
                        easing.type: WhiteSurTheme.animationEasing
                    }
                }

                Text {
                    anchors.centerIn: parent
                    text: workspaceId.toString()
                    color: isActive ? WhiteSurTheme.textSelected :
                                      hasWindows ? WhiteSurTheme.accent : WhiteSurTheme.textSecondary
                    font.pixelSize: 11
                    font.weight: Font.Medium
                    visible: showNumbers || (!hasWindows && !isActive)

                    Behavior on color {
                        ColorAnimation {
                            duration: WhiteSurTheme.animationDuration
                            easing.type: WhiteSurTheme.animationEasing
                        }
                    }
                }

                // Activity indicator dot when not showing numbers
                Rectangle {
                    anchors.centerIn: parent
                    width: 5
                    height: 5
                    radius: 3
                    color: isActive ? WhiteSurTheme.textSelected : WhiteSurTheme.accent
                    visible: !showNumbers && hasWindows && !isActive
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true

                    onEntered: workspaceButton.color = Qt.lighter(workspaceButton.color, 1.1)
                    onExited: workspaceButton.color = Qt.binding(function() {
                        if (workspaceButton.isActive) return WhiteSurTheme.accent
                        if (workspaceButton.hasWindows) return Qt.rgba(WhiteSurTheme.accent.r, WhiteSurTheme.accent.g, WhiteSurTheme.accent.b, 0.3)
                        return "transparent"
                    })

                    onClicked: {
                        Hyprland.dispatch(`workspace ${workspaceId}`)
                        root.workspaceClicked(workspaceId)
                    }
                }
            }
        }
    }
}
