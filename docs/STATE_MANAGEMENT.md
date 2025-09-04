# DankMaterialShell State Management Documentation

## Overview

This document details the comprehensive state management architecture used in DankMaterialShell. The system employs multiple state management patterns including reactive property binding, singleton services, persistent configuration, and event-driven updates to create a cohesive and responsive desktop shell experience.

## State Management Layers

### 1. Service Layer (Global State)
**Location**: `Services/` directory  
**Pattern**: Singleton services with reactive properties  
**Scope**: System-wide state and hardware integration  

### 2. Configuration Layer (Persistent State)
**Location**: `Common/SettingsData.qml`  
**Pattern**: JSON-based persistence with reactive updates  
**Scope**: User preferences and customization  

### 3. Session Layer (Runtime State)
**Location**: `Common/SessionData.qml`  
**Pattern**: Runtime state with session persistence  
**Scope**: Current session data (wallpaper, theme mode, etc.)  

### 4. Component Layer (Local State)
**Location**: Individual components  
**Pattern**: Local properties with parent communication  
**Scope**: Component-specific state and UI state  

## Reactive Property Binding Architecture

### Core Principle
The system uses QML's reactive property binding to automatically update UI components when underlying state changes. This eliminates the need for manual UI updates and reduces bugs.

```qml
// Service exposes reactive property
// AudioService.qml
readonly property PwNode sink: Pipewire.defaultAudioSink
property real volume: sink && sink.audio ? sink.audio.volume : 0

// UI component binds directly to service property
// VolumeSlider.qml
DankSlider {
    value: Math.round(AudioService.volume * 100)
    onSliderValueChanged: (newValue) => {
        AudioService.setVolume(newValue)  // This updates the service property
    }
}
```

### Binding Chain Example
```
Hardware State → Service Property → UI Component → User Interaction
     ↑                                                      ↓
     ←←←←←←←← Service Function ←←←←←←←←←←←←←←←←←←←←←←←←←←←←←←←←
```

## Singleton Services Pattern

### Service Structure
All services follow a consistent singleton pattern for global state management:

```qml
pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

Singleton {
    id: root
    
    // State properties (reactive)
    property bool featureAvailable: false
    property var currentData: null
    property int currentValue: 0
    
    // State change signals
    signal dataChanged()
    signal valueChanged(int newValue)
    
    // State manipulation functions
    function updateValue(newValue) {
        if (currentValue !== newValue) {
            currentValue = newValue
            valueChanged(newValue)  // Emit signal
        }
    }
    
    // System integration
    Process {
        id: systemProcess
        onExited: (code) => {
            if (code === 0) {
                parseSystemOutput()
                dataChanged()  // Trigger UI updates
            }
        }
    }
    
    // IPC integration for external control
    IpcHandler {
        target: "servicename"
        function action(param: string): string {
            updateValue(parseInt(param))
            return "SUCCESS"
        }
    }
}
```

### Service State Patterns

#### 1. Hardware State Services
Services that manage hardware state (Audio, Network, Bluetooth):

```qml
// AudioService.qml
Singleton {
    // Hardware integration
    readonly property PwNode sink: Pipewire.defaultAudioSink
    readonly property PwNode source: Pipewire.defaultAudioSource
    
    // Derived reactive properties
    property bool audioAvailable: sink !== null
    property real volume: sink && sink.audio ? sink.audio.volume : 0
    property bool muted: sink && sink.audio ? sink.audio.muted : false
    
    // State change notifications
    signal volumeChanged()
    signal micMuteChanged()
    
    // State manipulation with automatic UI updates
    function setVolume(percentage) {
        if (sink && sink.audio) {
            sink.audio.volume = percentage / 100  // This triggers reactive updates
            volumeChanged()  // Additional signal for specific handlers
        }
    }
}
```

#### 2. Data Services
Services that manage data and provide computed properties:

```qml
// WeatherService.qml
Singleton {
    // Raw data
    property var weatherData: null
    property string location: ""
    
    // Computed properties (reactive)
    property string temperature: weatherData ? formatTemperature(weatherData.temp) : "--"
    property string condition: weatherData ? weatherData.condition : "Unknown"
    property string icon: weatherData ? getWeatherIcon(weatherData.code) : "cloud"
    
    // State update functions
    function updateWeatherData(data) {
        weatherData = data  // Triggers all dependent property updates
        dataUpdated()
    }
    
    function formatTemperature(temp) {
        return SettingsData.useFahrenheit ? 
               Math.round(temp * 9/5 + 32) + "°F" : 
               Math.round(temp) + "°C"
    }
}
```

## Configuration State Management

### SettingsData Singleton
Manages persistent user preferences with automatic JSON serialization:

```qml
// Common/SettingsData.qml
Singleton {
    // Persistent properties with defaults
    property bool showWeather: true
    property string currentThemeName: "blue"
    property var topBarLeftWidgets: ["launcherButton", "workspaceSwitcher"]
    property real topBarTransparency: 0.75
    
    // Reactive list models for dynamic UI
    property alias topBarLeftWidgetsModel: leftWidgetsModel
    
    // Auto-save pattern
    function setShowWeather(enabled) {
        if (showWeather !== enabled) {
            showWeather = enabled
            saveSettings()  // Automatic persistence
        }
    }
    
    // JSON persistence
    function saveSettings() {
        settingsFile.setText(JSON.stringify({
            "showWeather": showWeather,
            "currentThemeName": currentThemeName,
            "topBarLeftWidgets": topBarLeftWidgets,
            "topBarTransparency": topBarTransparency
            // ... all settings
        }, null, 2))
    }
    
    // Reactive list model updates
    function updateListModel(listModel, order) {
        listModel.clear()
        for (var i = 0; i < order.length; i++) {
            listModel.append(createWidgetItem(order[i]))
        }
        widgetDataChanged()  // Notify UI components
    }
    
    // File-based persistence
    FileView {
        id: settingsFile
        path: StandardPaths.writableLocation(StandardPaths.ConfigLocation) + 
              "/DankMaterialShell/settings.json"
        
        onLoaded: parseSettings(text())  // Load on startup
        onLoadFailed: applyDefaults()    // Fallback to defaults
    }
}
```

### Configuration Migration
Automatic migration from legacy configuration formats:

```qml
function parseSettings(content) {
    try {
        var settings = JSON.parse(content)
        
        // Auto-migration from old theme system
        if (settings.themeIndex !== undefined) {
            const themeNames = ["blue", "purple", "green", ...]
            if (settings.themeIsDynamic) {
                currentThemeName = "dynamic"
            } else {
                currentThemeName = themeNames[settings.themeIndex] || "blue"
            }
            console.log("Auto-migrated theme from index", settings.themeIndex)
        }
        
        // Apply all settings with defaults
        showWeather = settings.showWeather !== undefined ? settings.showWeather : true
        // ... other properties
        
    } catch (e) {
        console.warn("Settings parse error:", e)
        applyDefaults()
    }
}
```

## Theme State Management

### Dynamic Theme System
The theme system manages complex state including dynamic color extraction:

```qml
// Common/Theme.qml
Singleton {
    // Theme state
    property string currentTheme: "blue"
    property bool isLightMode: false
    property var matugenColors: ({})
    property var customThemeData: null
    
    // Computed theme properties (reactive)
    readonly property var currentThemeData: {
        if (currentTheme === "custom") {
            return customThemeData || getStockTheme("blue")
        } else if (currentTheme === "dynamic") {
            return getDynamicTheme()  // From wallpaper colors
        } else {
            return getStockTheme(currentTheme)
        }
    }
    
    // Reactive color properties
    property color primary: currentThemeData.primary
    property color surface: currentThemeData.surface
    property color surfaceText: currentThemeData.surfaceText
    
    // State change functions
    function switchTheme(themeName, savePrefs = true) {
        if (currentTheme !== themeName) {
            currentTheme = themeName
            if (savePrefs) SettingsData.setTheme(currentTheme)
            generateSystemThemes()  // Update GTK/Qt themes
        }
    }
    
    // Dynamic color extraction
    function extractColors() {
        if (matugenAvailable) {
            matugenProcess.running = true
        }
    }
    
    Process {
        id: matugenProcess
        command: ["matugen", "image", wallpaperPath, "--json", "hex"]
        
        onExited: (code) => {
            if (code === 0) {
                try {
                    matugenColors = JSON.parse(stdout.text)
                    colorUpdateTrigger++  // Force reactive updates
                } catch (e) {
                    console.error("Color extraction failed:", e)
                }
            }
        }
    }
}
```

## Event-Driven State Updates

### Signal-Based Communication
Components communicate state changes through Qt's signal system:

```qml
// Service emits signals on state changes
// NetworkService.qml
Singleton {
    signal connectionChanged(bool connected)
    signal strengthChanged(int strength)
    
    function updateConnection(connected) {
        if (isConnected !== connected) {
            isConnected = connected
            connectionChanged(connected)  // Notify interested components
        }
    }
}

// Components connect to signals
// NetworkIndicator.qml
Item {
    Component.onCompleted: {
        NetworkService.connectionChanged.connect(updateIndicator)
        NetworkService.strengthChanged.connect(updateStrength)
    }
    
    function updateIndicator(connected) {
        // Update UI based on connection state
        icon.name = connected ? "wifi" : "wifi_off"
        icon.color = connected ? Theme.success : Theme.error
    }
}
```

### Cross-Service Communication
Services can communicate with each other through the global scope:

```qml
// DisplayService.qml
function setNightMode(enabled) {
    nightModeEnabled = enabled
    
    // Notify theme system
    if (typeof Theme !== "undefined") {
        Theme.onDisplayModeChanged()
    }
    
    // Notify settings
    if (typeof SettingsData !== "undefined") {
        SettingsData.setNightModeEnabled(enabled)
    }
}
```

## State Synchronization Patterns

### Multi-Monitor State
State synchronization across multiple monitor instances:

```qml
// Each monitor gets its own TopBar instance
Variants {
    model: SettingsData.getFilteredScreens("topBar")
    
    delegate: TopBar {
        modelData: item
        
        // Shared state from services
        weatherVisible: SettingsData.showWeather
        weatherData: WeatherService.currentCondition
        
        // Per-monitor state
        property var localWorkspaces: getWorkspacesForScreen(modelData.name)
    }
}
```

### Widget State Management
Dynamic widget ordering and visibility:

```qml
// SettingsData manages widget configuration
property var topBarLeftWidgets: ["launcherButton", "workspaceSwitcher"]

// TopBar reflects current configuration
Row {
    Repeater {
        model: SettingsData.topBarLeftWidgetsModel
        
        delegate: Loader {
            source: getWidgetComponent(model.widgetId)
            active: model.enabled
            
            // Pass shared state to widget
            property var sharedData: getSharedDataForWidget(model.widgetId)
        }
    }
}

// Widget configuration updates
function moveWidget(fromIndex, toIndex) {
    var widgets = [...topBarLeftWidgets]
    widgets.splice(toIndex, 0, widgets.splice(fromIndex, 1)[0])
    setTopBarLeftWidgets(widgets)  // Triggers UI update
}
```

## Performance Optimization in State Management

### Lazy State Loading
Heavy state computations are performed lazily:

```qml
// Expensive computation only when needed
property var expensiveData: null
readonly property var processedData: {
    if (expensiveData === null) {
        expensiveData = performExpensiveCalculation()
    }
    return expensiveData
}

function invalidateCache() {
    expensiveData = null  // Triggers recalculation on next access
}
```

### Debounced Updates
Rapid state changes are debounced to prevent excessive updates:

```qml
Timer {
    id: updateTimer
    interval: 100
    repeat: false
    onTriggered: performActualUpdate()
}

function requestUpdate() {
    updateTimer.restart()  // Debounce rapid requests
}
```

### Selective Property Updates
Only update properties that have actually changed:

```qml
function updateNetworkState(newState) {
    var changed = false
    
    if (connectionState !== newState.connected) {
        connectionState = newState.connected
        changed = true
    }
    
    if (signalStrength !== newState.strength) {
        signalStrength = newState.strength
        changed = true
    }
    
    if (changed) {
        networkStateChanged()  // Single signal for all changes
    }
}
```

## State Debugging and Monitoring

### Debug Properties
Services expose debug information for troubleshooting:

```qml
// Debug properties (only in debug builds)
readonly property var debugInfo: ({
    "serviceState": currentState,
    "lastUpdate": lastUpdateTime,
    "errorCount": errorCount,
    "isConnected": connectionState
})

function getDebugInfo(): string {
    return JSON.stringify(debugInfo, null, 2)
}
```

### State Change Logging
Important state changes are logged for debugging:

```qml
function setState(newState) {
    console.log("State change:", currentState, "→", newState)
    const oldState = currentState
    currentState = newState
    stateChanged(oldState, newState)
}
```

This comprehensive state management system provides a robust foundation for the DankMaterialShell desktop environment, ensuring consistent behavior, automatic UI updates, and maintainable code architecture.
