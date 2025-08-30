import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import "."

Item {
    id: root

    property bool showNumbers: true
    readonly property HyprlandMonitor monitor: Hyprland.monitorFor(root.QsWindow.window?.screen)
    property list<bool> workspaceOccupied: []
    property list<string> workspaceNames: ["1", "2", "3", "4", "5"]

    signal workspaceClicked(int workspaceId)

    implicitWidth: workspaceRow.implicitWidth
    implicitHeight: WhiteSurTheme.barHeight

    function updateWorkspaceOccupied() {
        // More robust workspace detection with multiple fallback methods
        let newOccupied = []

        for (let i = 0; i < 5; i++) {
            const workspaceId = i + 1
            let hasWindows = false

            // Method 1: Check if workspace exists and has windows property
            if (Hyprland.workspaces.values) {
                const workspace = Hyprland.workspaces.values.find(ws => ws.id === workspaceId)
                if (workspace) {
                    // Check for windows property
                    if (workspace.windows) {
                        hasWindows = workspace.windows.length > 0
                    }

                    // Check for windows array
                    if (!hasWindows && Array.isArray(workspace.windows)) {
                        hasWindows = workspace.windows.length > 0
                    }

                    // Check for windows object
                    if (!hasWindows && typeof workspace.windows === 'object' && workspace.windows !== null) {
                        const windowKeys = Object.keys(workspace.windows)
                        hasWindows = windowKeys.length > 0
                    }
                }
            }

            // Method 2: Alternative check using some()
            if (!hasWindows && Hyprland.workspaces.values) {
                hasWindows = Hyprland.workspaces.values.some(ws => {
                                                                 if (ws.id === workspaceId) {
                                                                     if (ws.windows) {
                                                                         if (Array.isArray(ws.windows)) {
                                                                             return ws.windows.length > 0
                                                                         } else if (typeof ws.windows === 'object' && ws.windows !== null) {
                                                                             return Object.keys(ws.windows).length > 0
                                                                         }
                                                                     }
                                                                 }
                                                                 return false
                                                             })
            }

            // Method 3: Check if workspace is not empty (fallback)
            if (!hasWindows && Hyprland.workspaces.values) {
                const workspace = Hyprland.workspaces.values.find(ws => ws.id === workspaceId)
                if (workspace) {
                    // Check if workspace has any content (monitors, names, etc.)
                    hasWindows = workspace.monitor || workspace.name || workspace.id
                }
            }

            newOccupied.push(hasWindows)
        }

        workspaceOccupied = newOccupied

        // Try command-line fallback if API methods failed
        if (!newOccupied.some(occupied => occupied)) {
            tryCommandLineFallback()
        }
    }

    function tryCommandLineFallback() {
        // Try to get workspace info from hyprctl as a fallback
        Quickshell.execDetached(["sh", "-c", "hyprctl workspaces | grep -A2 'workspace ID' | grep -B2 'windows: [1-9]' | grep 'workspace ID' | grep -o 'workspace ID [0-9]*' | awk '{print $3}'"], function(exitCode, stdout, stderr) {
            if (exitCode === 0 && stdout) {
                // Parse the output to find workspaces with windows
                const workspaceIds = stdout.trim().split('\n').filter(id => id && !isNaN(id))

                // Update the occupied states based on CLI output
                let newOccupied = []
                for (let i = 0; i < 5; i++) {
                    const workspaceId = i + 1
                    newOccupied.push(workspaceIds.includes(workspaceId.toString()))
                }
                workspaceOccupied = newOccupied
            }
        })
    }

    Component.onCompleted: {
        updateWorkspaceOccupied()
        // Force update after a short delay to ensure Hyprland is ready
        updateTimer.start()
    }

    Timer {
        id: updateTimer
        interval: 1000
        repeat: false
        onTriggered: updateWorkspaceOccupied()
    }

    Connections {
        target: Hyprland.workspaces
        function onValuesChanged() {
            updateWorkspaceOccupied()
        }
    }

    Connections {
        target: Hyprland
        function onFocusedWorkspaceChanged() {
            updateWorkspaceOccupied()
        }
    }

    // Also listen for window changes
    Connections {
        target: Hyprland
        function onWindowCreated() {
            updateWorkspaceOccupied()
        }

        function onWindowClosed() {
            updateWorkspaceOccupied()
        }

        function onWindowMoved() {
            updateWorkspaceOccupied()
        }
    }

    RowLayout {
        id: workspaceRow
        anchors.centerIn: parent
        spacing: WhiteSurTheme.spacingSmall

        Repeater {
            model: 5

            Rectangle {
                id: workspaceButton

                property int workspaceId: index + 1
                property bool isActive: monitor?.activeWorkspace?.id === workspaceId
                property bool hasWindows: workspaceOccupied[index]

                Layout.preferredWidth: WhiteSurTheme.workspaceSize
                Layout.preferredHeight: WhiteSurTheme.workspaceSize
                radius: WhiteSurTheme.borderRadius

                // Background with different states
                color: {
                    if (isActive) return WhiteSurTheme.workspaceActive
                    if (hasWindows) return WhiteSurTheme.workspaceOccupied
                    return "transparent"
                }

                // Border with different states
                border.width: {
                    if (isActive) return WhiteSurTheme.workspaceBorderActive
                    if (hasWindows) return WhiteSurTheme.workspaceBorderOccupied
                    return 0
                }
                border.color: {
                    if (isActive) return WhiteSurTheme.workspaceActive
                    if (hasWindows) return Qt.rgba(WhiteSurTheme.workspaceActive.r, WhiteSurTheme.workspaceActive.g, WhiteSurTheme.workspaceActive.b, 0.4)
                    return "transparent"
                }

                Behavior on color {
                    animation: WhiteSurTheme.colorAnimation.createObject(this)
                }

                Behavior on border.width {
                    animation: WhiteSurTheme.numberAnimation.createObject(this)
                }

                Behavior on border.color {
                    animation: WhiteSurTheme.colorAnimation.createObject(this)
                }

                // Workspace number
                Text {
                    id: numberText
                    anchors.centerIn: parent
                    text: workspaceNames[index]
                    color: isActive ? WhiteSurTheme.textSelected :
                                      hasWindows ? WhiteSurTheme.workspaceActive : WhiteSurTheme.textSecondary
                    font.pixelSize: 10
                    font.weight: isActive ? Font.Bold : Font.Medium
                    font.family: "Inter"

                    Behavior on color {
                        animation: WhiteSurTheme.colorAnimation.createObject(this)
                    }

                    Behavior on font.weight {
                        animation: WhiteSurTheme.numberAnimation.createObject(this)
                    }
                }

                // Window indicator dot - properly sized and positioned
                Rectangle {
                    id: windowDot
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 2
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: WhiteSurTheme.workspaceDotSize
                    height: WhiteSurTheme.workspaceDotSize
                    radius: WhiteSurTheme.workspaceDotSize / 2
                    color: isActive ? WhiteSurTheme.textSelected : WhiteSurTheme.workspaceActive
                    visible: hasWindows
                    opacity: hasWindows ? 1 : 0

                    // Add a subtle glow to make it more visible
                    Rectangle {
                        anchors.centerIn: parent
                        width: parent.width + 1
                        height: parent.height + 1
                        radius: parent.radius + 0.5
                        color: Qt.rgba(parent.color.r, parent.color.g, parent.color.b, 0.3)
                        z: -1
                    }

                    Behavior on opacity {
                        animation: WhiteSurTheme.colorAnimation.createObject(this)
                    }

                    Behavior on color {
                        animation: WhiteSurTheme.colorAnimation.createObject(this)
                    }
                }

                // Active workspace indicator (subtle glow)
                Rectangle {
                    anchors.fill: parent
                    radius: parent.radius
                    color: "transparent"
                    border.width: isActive ? 1 : 0
                    border.color: Qt.rgba(WhiteSurTheme.workspaceActive.r, WhiteSurTheme.workspaceActive.g, WhiteSurTheme.workspaceActive.b, 0.3)
                    visible: isActive

                    Behavior on border.width {
                        animation: WhiteSurTheme.numberAnimation.createObject(this)
                    }
                }

                // Hover effect
                Rectangle {
                    anchors.fill: parent
                    radius: parent.radius
                    color: WhiteSurTheme.workspaceHover
                    opacity: mouseArea.containsMouse && !isActive ? 1 : 0

                    Behavior on opacity {
                        animation: WhiteSurTheme.colorAnimation.createObject(this)
                    }
                }

                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor

                    onClicked: {
                        Hyprland.dispatch(`workspace ${workspaceId}`)
                        root.workspaceClicked(workspaceId)
                    }

                    // Scale animation on click
                    onPressed: {
                        parent.scale = 0.95
                    }

                    onReleased: {
                        parent.scale = 1.0
                    }

                    onCanceled: {
                        parent.scale = 1.0
                    }
                }

                // Scale animation on click
                Behavior on scale {
                    animation: WhiteSurTheme.quickAnimation.createObject(this)
                }
            }
        }
    }

    // Optional: Add a subtle separator between workspaces and other elements
    Rectangle {
        anchors.right: workspaceRow.left
        anchors.rightMargin: WhiteSurTheme.spacing
        anchors.verticalCenter: parent.verticalCenter
        width: 1
        height: 16
        color: Qt.rgba(WhiteSurTheme.border.r, WhiteSurTheme.border.g, WhiteSurTheme.border.b, 0.3)
        visible: true
    }
}
