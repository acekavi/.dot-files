# DankMaterialShell Quickshell Architecture Documentation

## Overview

This document provides comprehensive documentation for the DankMaterialShell quickshell configuration, designed to help AI LLM models understand the architecture, state management techniques, widget scripts, and customization patterns.

## Project Structure

```
quickshell/
├── shell.qml              # Main entry point and orchestration
├── Common/                # Shared utilities and state management
│   ├── Theme.qml          # Material Design 3 theming system
│   ├── SettingsData.qml   # User preferences and configuration persistence
│   ├── SessionData.qml    # Runtime session state management
│   ├── Appearance.qml     # Visual appearance settings
│   ├── ModalManager.qml   # Modal overlay management
│   └── [8 more utilities]
├── Services/              # System integration singletons (22 services)
│   ├── AudioService.qml   # PipeWire audio control
│   ├── NetworkService.qml # Network connectivity management
│   ├── BluetoothService.qml # Bluetooth device management
│   ├── DisplayService.qml # Display and brightness control
│   ├── NotificationService.qml # System notification handling
│   └── [17 more services]
├── Modules/               # UI components organized by function
│   ├── TopBar/           # Panel components (26 files)
│   ├── ControlCenter/    # System controls (20 files)
│   ├── Notifications/    # Notification system (10 files)
│   ├── AppDrawer/        # Application launcher (3 files)
│   ├── Settings/         # Configuration interface (13 files)
│   ├── ProcessList/      # System monitoring (8 files)
│   ├── Dock/            # Application dock (4 files)
│   ├── Lock/            # Screen lock system (4 files)
│   └── [more modules]
├── Modals/               # Full-screen overlays (12 files)
│   ├── SettingsModal.qml
│   ├── ClipboardHistoryModal.qml
│   ├── ProcessListModal.qml
│   └── [9 more modals]
├── Widgets/              # Reusable UI controls (21 files)
│   ├── DankIcon.qml      # Centralized icon component
│   ├── DankSlider.qml    # Enhanced slider with animations
│   ├── DankToggle.qml    # Material Design toggle switch
│   ├── DankTabBar.qml    # Unified tab bar implementation
│   └── [17 more widgets]
└── assets/               # Static resources (icons, images)
```

## Core Architecture Principles

### 1. Singleton Services Pattern
All system services use the singleton pattern for global state management:

```qml
pragma Singleton
pragma ComponentBehavior: Bound

Singleton {
    id: root
    
    property bool featureAvailable: false
    property type currentValue: defaultValue
    
    function performAction(param) {
        // Implementation with system integration
    }
    
    // IPC handlers for external control
    IpcHandler {
        target: "servicename"
        function action(): string { /* ... */ }
    }
}
```

### 2. Reactive Property Binding
The system uses QML's reactive property binding for automatic UI updates:

```qml
// Service exposes reactive properties
property bool isConnected: networkManager.connected
property int signalStrength: networkManager.signalStrength

// UI components bind directly to service properties
DankIcon {
    name: NetworkService.isConnected ? "wifi" : "wifi_off"
    color: NetworkService.signalStrength > 50 ? Theme.success : Theme.warning
}
```

### 3. Lazy Loading with Performance Optimization
Heavy components use lazy loading to improve startup performance:

```qml
LazyLoader {
    id: heavyComponentLoader
    active: false
    
    HeavyComponent {
        id: heavyComponent
    }
}

// Activated only when needed
function showHeavyComponent() {
    heavyComponentLoader.active = true
    if (heavyComponentLoader.item) {
        heavyComponentLoader.item.show()
    }
}
```

### 4. Multi-Monitor Support with Variants
Uses Quickshell's Variants pattern for multi-monitor deployment:

```qml
Variants {
    model: SettingsData.getFilteredScreens("topBar")
    
    delegate: TopBar {
        modelData: item  // Each screen gets its own instance
    }
}
```

## State Management Architecture

### Theme System (Theme.qml)

The theme system provides centralized Material Design 3 theming with dynamic color extraction:

**Key Features:**
- **Dynamic Color Extraction**: Uses matugen to extract colors from wallpapers
- **Stock Theme Support**: Predefined color schemes (blue, purple, green, etc.)
- **Custom Theme Loading**: JSON-based custom themes
- **System Integration**: Automatic GTK/Qt application theming
- **Light/Dark Mode**: Reactive theme switching

**State Management Pattern:**
```qml
// Reactive color properties
property color primary: currentThemeData.primary
property color surface: currentThemeData.surface

// Dynamic color extraction from wallpaper
function extractColors() {
    if (matugenAvailable) {
        matugenProcess.running = true
    }
}

// Reactive theme switching
function switchTheme(themeName, savePrefs = true) {
    currentTheme = themeName
    if (savePrefs) SettingsData.setTheme(currentTheme)
    generateSystemThemesFromCurrentTheme()
}
```

### Settings Persistence (SettingsData.qml)

Manages user preferences with automatic persistence and migration:

**Key Features:**
- **JSON Persistence**: Settings stored in `~/.config/DankMaterialShell/settings.json`
- **Auto-migration**: Handles legacy configuration formats
- **Reactive Updates**: Changes trigger immediate UI updates
- **Widget Configuration**: Dynamic widget ordering and visibility
- **Screen Preferences**: Per-monitor component configuration

**State Management Pattern:**
```qml
// Persistent properties with defaults
property bool showWeather: true
property var topBarLeftWidgets: ["launcherButton", "workspaceSwitcher"]

// Automatic persistence
function setShowWeather(enabled) {
    showWeather = enabled
    saveSettings()  // Triggers JSON serialization
}

// Reactive list models for dynamic widget ordering
function updateListModel(listModel, order) {
    listModel.clear()
    for (var i = 0; i < order.length; i++) {
        listModel.append(createWidgetItem(order[i]))
    }
    widgetDataChanged()  // Signal for UI updates
}
```

## Widget System Architecture

### Base Widget Pattern (DankIcon.qml)

All widgets follow a consistent pattern with Material Design integration:

```qml
import QtQuick
import qs.Common

StyledText {
    id: icon
    
    // Configurable properties
    property alias name: icon.text
    property alias size: icon.font.pixelSize
    property bool filled: false
    
    // Material Design integration
    font.family: "Material Symbols Rounded"
    color: Theme.surfaceText
    
    // Variable font axes for Material Symbols
    font.variableAxes: ({
        "FILL": fill.toFixed(1),
        "GRAD": Theme.isLightMode ? 0 : -25,
        "opsz": 24,
        "wght": filled ? 500 : 400
    })
    
    // Smooth animations
    Behavior on fill {
        NumberAnimation {
            duration: Appearance.anim.durations.quick
            easing.type: Easing.BezierSpline
        }
    }
}
```

### Advanced Widget Pattern (DankSlider.qml)

Complex widgets implement sophisticated interaction patterns:

**Key Features:**
- **Multi-input Support**: Mouse, touchpad, and wheel input
- **Smart Detection**: Differentiates between mouse wheel and touchpad
- **Visual Feedback**: Tooltips, hover states, and animations
- **Accessibility**: Proper cursor shapes and keyboard navigation

**Interaction Handling:**
```qml
MouseArea {
    onWheel: (wheelEvent) => {
        const deltaY = wheelEvent.angleDelta.y
        const isMouseWheel = Math.abs(deltaY) >= 120 && (Math.abs(deltaY) % 120) === 0
        
        if (isMouseWheel) {
            // Mouse wheel: 5% steps
            let step = Math.max(1, (slider.maximum - slider.minimum) / 20)
            // Apply step...
        } else {
            // Touchpad: accumulate then apply 1% steps
            scrollAccumulator += deltaY
            if (Math.abs(scrollAccumulator) >= touchpadThreshold) {
                // Apply accumulated change...
            }
        }
    }
}
```

## Service Integration Patterns

### System Service Pattern (AudioService.qml)

Services provide abstracted system integration with automatic capability detection:

**Key Features:**
- **Hardware Abstraction**: Unified API for different audio systems
- **Capability Detection**: Automatic feature availability detection
- **IPC Integration**: External control via quickshell IPC
- **Reactive Properties**: Automatic UI updates on state changes

**Implementation Pattern:**
```qml
pragma Singleton
import Quickshell.Services.Pipewire

Singleton {
    id: root
    
    // Hardware integration
    readonly property PwNode sink: Pipewire.defaultAudioSink
    readonly property PwNode source: Pipewire.defaultAudioSource
    
    // Reactive state
    signal volumeChanged
    signal micMuteChanged
    
    // Abstracted control functions
    function setVolume(percentage) {
        if (root.sink && root.sink.audio) {
            const clampedVolume = Math.max(0, Math.min(100, percentage))
            root.sink.audio.volume = clampedVolume / 100
            root.volumeChanged()  // Notify UI components
            return "Volume set to " + clampedVolume + "%"
        }
        return "No audio sink available"
    }
    
    // IPC integration for external control
    IpcHandler {
        target: "audio"
        
        function increment(step: string): string {
            // Implementation...
            root.volumeChanged()
            return result
        }
    }
}
```

## Modal System Architecture

The modal system provides consistent overlay management with unified styling:

**Key Components:**
- **ModalManager**: Centralized modal state management
- **DankModal**: Base modal component with consistent styling
- **Specialized Modals**: Task-specific implementations (Settings, Clipboard, etc.)

**Modal Pattern:**
```qml
DankModal {
    id: modal
    
    property bool isVisible: false
    
    function show() {
        isVisible = true
        open()
    }
    
    function hide() {
        isVisible = false
        close()
    }
    
    function toggle() {
        isVisible ? hide() : show()
    }
    
    // Consistent styling from Theme
    background: Rectangle {
        color: Theme.popupBackground()
        radius: Theme.cornerRadius
        border.color: Theme.outline
    }
}
```

## Performance Optimization Strategies

### 1. Lazy Loading
Heavy components are loaded only when needed:

```qml
LazyLoader {
    id: expensiveComponentLoader
    active: false  // Not loaded initially
    
    ExpensiveComponent {
        // Only instantiated when active = true
    }
}
```

### 2. Property Binding Optimization
Direct binding to underlying APIs avoids unnecessary wrapper functions:

```qml
// Good: Direct binding
enabled: BluetoothService.adapter.powered

// Avoid: Unnecessary wrapper
enabled: BluetoothService.isPowered()  // Creates function call overhead
```

### 3. Smart Feature Detection
UI components adapt based on system capabilities:

```qml
DankSlider {
    visible: DisplayService.brightnessAvailable
    enabled: DisplayService.brightnessAvailable
    value: DisplayService.brightnessLevel
}
```

## Customization Patterns

### Widget Ordering System
Dynamic widget reordering with persistent configuration:

```qml
// Settings store widget order
property var topBarLeftWidgets: ["launcherButton", "workspaceSwitcher", "focusedWindow"]

// UI reflects current order
Repeater {
    model: SettingsData.topBarLeftWidgetsModel
    
    delegate: Loader {
        source: getWidgetSource(model.widgetId)
        active: model.enabled
    }
}

// Runtime reordering
function setTopBarLeftWidgets(newOrder) {
    topBarLeftWidgets = newOrder
    updateListModel(leftWidgetsModel, newOrder)
    saveSettings()  // Persist changes
}
```

### Theme Customization
Multiple theming approaches with consistent API:

```qml
// Stock themes
Theme.switchTheme("blue")

// Dynamic wallpaper-based theming
Theme.switchTheme(Theme.dynamic)

// Custom JSON themes
Theme.loadCustomTheme(customThemeData)
```

## IPC Command System

External control via quickshell's IPC system:

```bash
# Audio control
qs ipc call audio setvolume 50
qs ipc call audio mute

# Theme control
qs ipc call theme toggle
qs ipc call theme dark

# Modal control
qs ipc call spotlight toggle
qs ipc call settings toggle
```

## Multi-Monitor Support

Sophisticated multi-monitor handling with per-screen configuration:

```qml
// Screen filtering based on user preferences
function getFilteredScreens(componentId) {
    var prefs = screenPreferences[componentId] || ["all"]
    if (prefs.includes("all")) {
        return Quickshell.screens
    }
    return Quickshell.screens.filter(screen => prefs.includes(screen.name))
}

// Per-monitor component deployment
Variants {
    model: SettingsData.getFilteredScreens("topBar")
    
    delegate: TopBar {
        modelData: item  // Each screen gets customized instance
    }
}
```

This architecture provides a robust, performant, and highly customizable desktop shell system with comprehensive state management and clean separation of concerns.
