import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import "."

Rectangle {
    id: root

    width: 300
    height: 200
    color: WhiteSurTheme.background
    radius: WhiteSurTheme.borderRadius
    border.width: 1
    border.color: WhiteSurTheme.border

    // Debug info
    property string debugInfo: ""

    function updateDebugInfo() {
        let info = "=== Hyprland Debug Info ===\n"

        // Check Hyprland object
        info += `Hyprland object: ${Hyprland ? 'Available' : 'Not available'}\n`

        // Check workspaces
        if (Hyprland.workspaces) {
            info += `Workspaces object: Available\n`
            info += `Workspaces.values: ${Hyprland.workspaces.values ? 'Available' : 'Not available'}\n`

            if (Hyprland.workspaces.values) {
                info += `Workspace count: ${Hyprland.workspaces.values.length}\n`

                Hyprland.workspaces.values.forEach((ws, idx) => {
                    info += `\nWorkspace ${idx}:\n`
                    info += `  ID: ${ws.id}\n`
                    info += `  Name: ${ws.name}\n`
                    info += `  Monitor: ${ws.monitor}\n`
                    info += `  Windows: ${ws.windows ? ws.windows.length : 'undefined'}\n`
                    if (ws.windows) {
                        ws.windows.forEach((win, winIdx) => {
                            info += `    Window ${winIdx}: ${win}\n`
                        })
                    }
                })
            }
        } else {
            info += `Workspaces object: Not available\n`
        }

        // Check monitor
        if (Hyprland.monitors) {
            info += `\nMonitors: ${Hyprland.monitors.values ? Hyprland.monitors.values.length : 'undefined'}\n`
        }

        // Check active workspace
        if (Hyprland.activeWorkspace) {
            info += `Active workspace: ${Hyprland.activeWorkspace.id}\n`
        }

        debugInfo = info
        console.log(info)
    }

    Component.onCompleted: {
        updateDebugInfo()
        debugTimer.start()
    }

    Timer {
        id: debugTimer
        interval: 2000
        repeat: true
        onTriggered: updateDebugInfo()
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: WhiteSurTheme.spacing

        Text {
            text: "Hyprland Debug Info"
            color: WhiteSurTheme.textPrimary
            font.pixelSize: 14
            font.weight: Font.Bold
        }

        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true

            TextArea {
                text: root.debugInfo
                color: WhiteSurTheme.textSecondary
                font.pixelSize: 10
                font.family: "Monospace"
                readOnly: true
                wrapMode: TextArea.Wrap
            }
        }

        RowLayout {
            Layout.fillWidth: true

            Button {
                text: "Refresh"
                onClicked: root.updateDebugInfo()
            }

            Item { Layout.fillWidth: true }

            Button {
                text: "Close"
                onClicked: root.visible = false
            }
        }
    }
}
