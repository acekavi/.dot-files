# DankMaterialShell Modals Reference

## Overview

This document provides comprehensive documentation for the modal system in DankMaterialShell. The modal system provides consistent overlay management with unified styling, animations, focus handling, and stacking management for full-screen and dialog components.

## Modal System Architecture

### Core Components

1. **DankModal**: Base modal component with consistent styling and behavior
2. **ModalManager**: Centralized modal state and stacking management
3. **Specialized Modals**: Task-specific implementations extending DankModal
4. **IPC Integration**: External control via quickshell IPC commands

### Modal Hierarchy

```
DankModal (Base)
├── SettingsModal (Complex tabbed interface)
├── SpotlightModal (Application launcher)
├── ClipboardHistoryModal (Clipboard management)
├── ProcessListModal (System monitoring)
├── NotificationModal (Notification center)
├── PowerMenuModal (Power management)
├── NotepadModal (Text editing)
├── FileBrowserModal (File selection)
├── NetworkInfoModal (Network details)
├── WifiPasswordModal (WiFi authentication)
└── ConfirmModal (User confirmations)
```

## Base Modal Component (DankModal.qml)

### Purpose
Provides a consistent foundation for all modal dialogs with standardized styling, animations, focus management, and interaction patterns.

### Key Features

**Layout & Positioning**:
- Flexible positioning (center, top-right, custom coordinates)
- Responsive sizing with screen-aware dimensions
- Configurable backgrounds with opacity control

**Animation System**:
- Multiple animation types (scale, slide, fade)
- Customizable duration and easing curves
- Smooth enter/exit transitions

**Focus Management**:
- Exclusive keyboard focus when active
- Escape key handling for dismissal
- Focus restoration on close

**Stacking Control**:
- Modal stacking management via ModalManager
- Optional stacking allowance for nested modals
- Automatic closure of conflicting modals

### Properties

```qml
// Layout properties
property real width: 400                    // Modal width
property real height: 300                   // Modal height
property string positioning: "center"       // "center", "top-right", "custom"
property point customPosition: Qt.point(0, 0) // Custom positioning

// Appearance properties
property bool showBackground: true          // Show backdrop
property real backgroundOpacity: 0.5        // Backdrop opacity
property color backgroundColor: Theme.surfaceContainer
property color borderColor: Theme.outlineMedium
property real borderWidth: 1
property real cornerRadius: Theme.cornerRadius
property bool enableShadow: false

// Behavior properties
property bool closeOnEscapeKey: true        // ESC key dismissal
property bool closeOnBackgroundClick: true  // Click-outside dismissal
property bool allowStacking: false          // Allow modal stacking
property bool shouldBeVisible: false        // Visibility state
property bool shouldHaveFocus: shouldBeVisible // Focus state

// Animation properties
property string animationType: "scale"      // "scale", "slide"
property int animationDuration: Theme.shorterDuration
property var animationEasing: Theme.emphasizedEasing
```

### Core Methods

```qml
function open() {
    ModalManager.openModal(root)        // Register with manager
    closeTimer.stop()                   // Cancel any pending close
    shouldBeVisible = true              // Set visibility
    visible = true                      // Show modal
    focusScope.forceActiveFocus()      // Capture focus
}

function close() {
    shouldBeVisible = false             // Begin close sequence
    closeTimer.restart()                // Start close timer
}

function toggle() {
    shouldBeVisible ? close() : open()  // Toggle state
}
```

### Animation Implementation

**Scale Animation**:
```qml
scale: {
    if (animationType === "scale")
        return shouldBeVisible ? 1 : 0.9
    return 1
}

Behavior on scale {
    enabled: animationType === "scale"
    NumberAnimation {
        duration: animationDuration
        easing.type: animationEasing
    }
}
```

**Slide Animation**:
```qml
transform: animationType === "slide" ? slideTransform : null

Translate {
    id: slideTransform
    x: shouldBeVisible ? 0 : 15
    y: shouldBeVisible ? 0 : -30
}
```

### Focus Management System

```qml
FocusScope {
    id: focusScope
    anchors.fill: parent
    visible: root.visible
    focus: root.visible
    
    Keys.onEscapePressed: event => {
        if (closeOnEscapeKey && shouldHaveFocus) {
            close()
            event.accepted = true
        }
    }
    
    onVisibleChanged: {
        if (visible && shouldHaveFocus) {
            Qt.callLater(() => focusScope.forceActiveFocus())
        }
    }
}
```

## Modal Manager (ModalManager.qml)

### Purpose
Centralized management of modal stacking, focus coordination, and conflict resolution.

### Key Features

**Stacking Management**:
- Prevents modal conflicts through coordinated closure
- Optional stacking support for nested modals
- Automatic cleanup of competing modals

**Implementation**:
```qml
Singleton {
    signal closeAllModalsExcept(var excludedModal)
    
    function openModal(modal) {
        if (!modal.allowStacking) {
            closeAllModalsExcept(modal)  // Close competing modals
        }
    }
}

// Modal connection pattern
Connections {
    target: ModalManager
    function onCloseAllModalsExcept(excludedModal) {
        if (excludedModal !== root && !allowStacking && shouldBeVisible) {
            close()  // Close if not excluded and stacking disabled
        }
    }
}
```

## Specialized Modal Components

### SettingsModal

**Purpose**: Comprehensive system configuration interface with tabbed navigation.

**Key Features**:
- Multi-tab interface with lazy loading
- Profile image management with file browser integration
- Dynamic content loading based on selected tab
- IPC command support for external control

**Architecture**:
```qml
DankModal {
    width: 800
    height: 750
    
    content: Component {
        Item {
            // Sidebar navigation
            Rectangle {
                id: sidebarContainer
                property int currentIndex: 0
                
                // Profile section with image editing
                // Tab navigation with icons and labels
                Repeater {
                    model: [
                        {"text": "Personalization", "icon": "person"},
                        {"text": "Time & Date", "icon": "schedule"},
                        {"text": "Weather", "icon": "cloud"},
                        // ... more tabs
                    ]
                }
            }
            
            // Content area with lazy-loaded tabs
            Loader {
                active: sidebarContainer.currentIndex === 0
                sourceComponent: PersonalizationTab {}
            }
        }
    }
}
```

**Tab Loading Pattern**:
```qml
Loader {
    id: personalizationLoader
    anchors.fill: parent
    active: sidebarContainer.currentIndex === 0  // Only load when active
    visible: active
    asynchronous: true                           // Non-blocking load
    
    sourceComponent: Component {
        PersonalizationTab {
            parentModal: settingsModal              // Parent reference
        }
    }
}
```

### SpotlightModal

**Purpose**: Application launcher with search and categorization.

**Key Features**:
- Fuzzy search implementation
- Application categorization and filtering
- Keyboard navigation support
- Recent applications tracking

### ClipboardHistoryModal

**Purpose**: Clipboard management with history and search.

**Key Features**:
- Clipboard history with cliphist integration
- Search and filtering capabilities
- Item preview and selection
- Automatic cleanup of old entries

### ProcessListModal

**Purpose**: System process monitoring and management.

**Key Features**:
- Real-time process listing
- Process termination capabilities
- Resource usage monitoring
- Search and filtering by process name

### FileBrowserModal

**Purpose**: File selection with preview and filtering.

**Key Features**:
- Directory navigation with breadcrumbs
- File type filtering by extensions
- Image preview for supported formats
- Keyboard navigation support

**Usage Pattern**:
```qml
FileBrowserModal {
    id: wallpaperBrowser
    allowStacking: true
    browserTitle: "Select Wallpaper"
    browserIcon: "wallpaper"
    browserType: "wallpaper"
    fileExtensions: ["*.jpg", "*.jpeg", "*.png", "*.bmp", "*.gif", "*.webp"]
    
    onFileSelected: path => {
        SessionData.setWallpaper(path)
        close()
    }
}
```

## Modal Development Patterns

### Base Modal Extension

To create a new modal, extend DankModal:

```qml
// CustomModal.qml
import qs.Modals

DankModal {
    id: customModal
    
    // Configure base properties
    width: 600
    height: 400
    positioning: "center"
    closeOnEscapeKey: true
    
    // Custom properties
    property string customData: ""
    
    // Custom signals
    signal dataChanged(string newData)
    
    // Modal content
    content: Component {
        Item {
            anchors.fill: parent
            
            // Custom content implementation
            Column {
                anchors.centerIn: parent
                spacing: Theme.spacingL
                
                StyledText {
                    text: "Custom Modal Content"
                    font.pixelSize: Theme.fontSizeXLarge
                    color: Theme.surfaceText
                }
                
                DankActionButton {
                    text: "Close"
                    onClicked: customModal.close()
                }
            }
        }
    }
    
    // Custom methods
    function setData(data) {
        customData = data
        dataChanged(data)
    }
}
```

### IPC Integration Pattern

Add external control via IPC handlers:

```qml
DankModal {
    id: customModal
    
    IpcHandler {
        target: "custommodal"
        
        function open(): string {
            customModal.open()
            return "CUSTOM_OPEN_SUCCESS"
        }
        
        function close(): string {
            customModal.close()
            return "CUSTOM_CLOSE_SUCCESS"
        }
        
        function toggle(): string {
            customModal.toggle()
            return customModal.shouldBeVisible ? 
                   "CUSTOM_OPENED" : "CUSTOM_CLOSED"
        }
        
        function setdata(data: string): string {
            customModal.setData(data)
            return "DATA_SET_SUCCESS"
        }
    }
}
```

### Stacking Modal Pattern

For modals that can appear over other modals:

```qml
DankModal {
    id: nestedModal
    allowStacking: true  // Allow over other modals
    
    onDialogClosed: {
        // Restore parent modal focus
        if (parentModal) {
            parentModal.shouldHaveFocus = Qt.binding(() => {
                return parentModal.shouldBeVisible
            })
        }
    }
}
```

## Animation Customization

### Custom Animation Types

Extend the animation system with custom effects:

```qml
DankModal {
    animationType: "custom"
    
    // Custom animation properties
    property real customRotation: shouldBeVisible ? 0 : 180
    property real customOpacity: shouldBeVisible ? 1 : 0
    
    // Apply custom transforms
    transform: [
        Rotation {
            angle: customRotation
            origin.x: width / 2
            origin.y: height / 2
        }
    ]
    
    // Custom animation behaviors
    Behavior on customRotation {
        NumberAnimation {
            duration: animationDuration * 1.5
            easing.type: Easing.OutBack
        }
    }
    
    Behavior on customOpacity {
        NumberAnimation {
            duration: animationDuration
            easing.type: animationEasing
        }
    }
}
```

### Entrance/Exit Effects

Create sophisticated entrance and exit effects:

```qml
DankModal {
    property bool isEntering: false
    property bool isExiting: false
    
    onOpened: {
        isEntering = true
        entranceTimer.start()
    }
    
    function close() {
        isExiting = true
        shouldBeVisible = false
        exitTimer.start()
    }
    
    Timer {
        id: entranceTimer
        interval: animationDuration
        onTriggered: isEntering = false
    }
    
    Timer {
        id: exitTimer
        interval: animationDuration
        onTriggered: {
            isExiting = false
            visible = false
        }
    }
    
    // Apply entrance/exit effects
    opacity: {
        if (isEntering) return Math.min(1, entranceProgress)
        if (isExiting) return Math.max(0, 1 - exitProgress)
        return shouldBeVisible ? 1 : 0
    }
}
```

## Accessibility Features

### Keyboard Navigation

Implement comprehensive keyboard support:

```qml
DankModal {
    content: Component {
        Item {
            focus: true
            
            Keys.onTabPressed: {
                // Navigate to next focusable element
                nextTabStop.forceActiveFocus()
            }
            
            Keys.onBacktabPressed: {
                // Navigate to previous focusable element
                previousTabStop.forceActiveFocus()
            }
            
            Keys.onReturnPressed: {
                // Activate default action
                defaultButton.clicked()
            }
        }
    }
}
```

### Screen Reader Support

Add accessibility properties for screen readers:

```qml
DankModal {
    Accessible.role: Accessible.Dialog
    Accessible.name: "Settings Dialog"
    Accessible.description: "System configuration interface"
    
    content: Component {
        Item {
            Accessible.role: Accessible.Pane
            Accessible.name: "Settings Content"
            
            // Focusable elements with accessibility
            DankActionButton {
                Accessible.role: Accessible.Button
                Accessible.name: "Close Settings"
                Accessible.description: "Close the settings dialog"
                Accessible.onPressAction: clicked()
            }
        }
    }
}
```

## Performance Optimization

### Lazy Content Loading

Load expensive content only when needed:

```qml
DankModal {
    content: Component {
        Loader {
            anchors.fill: parent
            active: parent.parent.shouldBeVisible  // Only load when modal visible
            asynchronous: true                     // Non-blocking load
            
            sourceComponent: Component {
                ExpensiveContent {
                    // Heavy content loaded asynchronously
                }
            }
        }
    }
}
```

### Resource Management

Properly manage resources in modals:

```qml
DankModal {
    onOpened: {
        // Initialize resources when opened
        initializeResources()
    }
    
    onDialogClosed: {
        // Clean up resources when closed
        cleanupResources()
        
        // Reset state for next opening
        resetModalState()
    }
    
    function initializeResources() {
        // Start timers, load data, etc.
    }
    
    function cleanupResources() {
        // Stop timers, clear caches, etc.
    }
}
```

This comprehensive modal system provides a robust foundation for creating consistent, accessible, and performant dialog interfaces in the DankMaterialShell desktop environment.
