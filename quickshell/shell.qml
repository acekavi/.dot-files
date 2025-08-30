import QtQuick
import Quickshell
import "modules/statusbar"
import "modules/sidebar"

ShellRoot {
    // Shared Control Center state
    property bool controlCenterOpen: false

    // Control Center Panel
    CentralSidebar {
        id: controlCenter
        targetScreen: Quickshell.primaryScreen
        isOpen: controlCenterOpen
    }

    // Status Bar
    StatusBar {
        id: statusBar // Added id for statusBar
        targetScreen: Quickshell.primaryScreen
        sidebarOpen: controlCenterOpen

        onSidebarToggleRequested: {
            controlCenterOpen = !controlCenterOpen
        }
    }

    // Ensure screens are properly assigned after Quickshell is ready
    Component.onCompleted: {
        if (Quickshell.primaryScreen) {
            controlCenter.targetScreen = Quickshell.primaryScreen
            statusBar.targetScreen = Quickshell.primaryScreen
        } else if (Quickshell.screens.length > 0) {
            controlCenter.targetScreen = Quickshell.screens[0]
            statusBar.targetScreen = Quickshell.screens[0]
        }
    }

    // Global keyboard event handling for Control Center shortcuts
    Item {
        focus: true

        Keys.onPressed: (event) => {
                            // Handle Control Center shortcuts
                            if (event.key === Qt.Key_S && event.modifiers === Qt.ShiftModifier) {
                                controlCenterOpen = !controlCenterOpen
                            }
                            if (event.key === Qt.Key_Escape && controlCenterOpen) {
                                controlCenterOpen = false
                            }
                        }
    }

    // Handle clicking outside Control Center to close it
    MouseArea {
        anchors.fill: parent
        enabled: controlCenterOpen
        z: -1 // Behind other components

        onClicked: (mouse) => {
                       if (controlCenterOpen) {
                           // Check if click is outside Control Center area (right side)
                           if (mouse.x > (parent.width - 320)) { // controlCenterWidth
                               controlCenterOpen = false
                           }
                       }
                   }
    }
}
