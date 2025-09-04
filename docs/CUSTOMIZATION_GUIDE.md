# DankMaterialShell Customization Guide

## Overview

This comprehensive guide provides detailed instructions for customizing and extending DankMaterialShell. Whether you're modifying existing components, creating new widgets, or integrating with external systems, this guide covers the patterns and best practices used throughout the codebase.

## Quick Start Customization

### 1. Theme Customization

**Changing Stock Themes**:
```bash
# Via IPC
qs -c dms ipc call theme toggle    # Toggle light/dark mode
qs -c dms ipc call theme light     # Set light mode
qs -c dms ipc call theme dark      # Set dark mode

# Via Settings UI
# Open Settings → Theme & Colors → Select theme
```

**Creating Custom Themes**:
```json
// ~/.config/custom-theme.json
{
  "name": "Custom Theme",
  "primary": "#FF6B35",
  "primaryText": "#FFFFFF",
  "secondary": "#FF9F1C",
  "surface": "#1A1A1A",
  "surfaceText": "#E0E0E0",
  "surfaceVariant": "#2D2D2D",
  "surfaceVariantText": "#B0B0B0",
  "background": "#121212",
  "backgroundText": "#E0E0E0",
  "outline": "#404040",
  "surfaceContainer": "#1E1E1E",
  "surfaceContainerHigh": "#282828"
}
```

**Applying Custom Themes**:
```qml
// In SettingsData
function loadCustomTheme() {
    Theme.loadCustomThemeFromFile("/path/to/custom-theme.json")
    Theme.switchTheme("custom")
}
```

### 2. Widget Customization

**Modifying Widget Order**:
```qml
// In SettingsData.qml - customize widget arrangement
property var topBarLeftWidgets: ["launcherButton", "workspaceSwitcher", "focusedWindow"]
property var topBarCenterWidgets: ["clock", "weather", "music"]
property var topBarRightWidgets: ["systemTray", "clipboard", "battery", "controlCenterButton"]
```

**Widget Visibility Control**:
```qml
// Toggle widget visibility
SettingsData.setShowWeather(false)    // Hide weather widget
SettingsData.setShowMusic(true)       // Show music widget
SettingsData.setShowBattery(false)    // Hide battery widget
```

### 3. Keybinding Customization

**Adding Custom Keybinds** (in Hyprland config):
```bash
# ~/.config/hypr/keybinds.conf
bind = SUPER, Space, exec, qs -c dms ipc call spotlight toggle
bind = SUPER, V, exec, qs -c dms ipc call clipboard toggle
bind = SUPER, M, exec, qs -c dms ipc call processlist toggle

# Custom application launches
bind = SUPER, T, exec, kitty
bind = SUPER, B, exec, firefox
bind = SUPER, E, exec, nautilus
```

## Advanced Customization

### Creating Custom Widgets

**1. Basic Widget Structure**:
```qml
// Widgets/CustomWidget.qml
import QtQuick
import qs.Common
import qs.Services
import qs.Widgets

Item {
    id: customWidget
    
    // Widget properties
    property string title: "Custom Widget"
    property bool enabled: true
    property color accentColor: Theme.primary
    
    // Widget size
    width: contentRow.implicitWidth + Theme.spacingL * 2
    height: Theme.barHeight
    
    // Widget signals
    signal clicked()
    signal dataChanged(var newData)
    
    // Main content
    Row {
        id: contentRow
        anchors.centerIn: parent
        spacing: Theme.spacingM
        
        DankIcon {
            name: "widgets"
            size: Theme.iconSize
            color: customWidget.enabled ? Theme.surfaceText : Theme.surfaceVariantText
            anchors.verticalCenter: parent.verticalCenter
        }
        
        StyledText {
            text: customWidget.title
            color: customWidget.enabled ? Theme.surfaceText : Theme.surfaceVariantText
            font.pixelSize: Theme.fontSizeMedium
            anchors.verticalCenter: parent.verticalCenter
        }
    }
    
    // Interaction handling
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        
        onClicked: {
            customWidget.clicked()
        }
    }
    
    // Background styling
    Rectangle {
        anchors.fill: parent
        color: parent.enabled ? Theme.widgetBackground() : Theme.surfaceVariant
        radius: Theme.cornerRadius
        opacity: parent.enabled ? 1 : 0.5
        
        Behavior on color {
            ColorAnimation {
                duration: Theme.shortDuration
                easing.type: Theme.standardEasing
            }
        }
    }
}
```

**2. Integrating Custom Widget**:
```qml
// In TopBar or other container
Loader {
    active: SettingsData.showCustomWidget
    visible: active
    
    sourceComponent: Component {
        CustomWidget {
            title: "My Widget"
            enabled: SomeService.isAvailable
            
            onClicked: {
                console.log("Custom widget clicked!")
                SomeService.performAction()
            }
        }
    }
}
```

**3. Adding Widget to Settings**:
```qml
// In SettingsData.qml
property bool showCustomWidget: true

function setShowCustomWidget(enabled) {
    showCustomWidget = enabled
    saveSettings()
}

// In settings UI
DankToggle {
    checked: SettingsData.showCustomWidget
    onToggled: SettingsData.setShowCustomWidget(checked)
}
```

### Creating Custom Services

**1. Service Structure**:
```qml
// Services/CustomService.qml
pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root
    
    // Service state
    property bool available: false
    property var currentData: null
    property bool isLoading: false
    
    // Service signals
    signal dataUpdated()
    signal errorOccurred(string error)
    
    // Service methods
    function initialize() {
        console.log("CustomService: Initializing...")
        checkAvailability()
    }
    
    function checkAvailability() {
        availabilityChecker.running = true
    }
    
    function fetchData() {
        if (!available) {
            errorOccurred("Service not available")
            return
        }
        
        isLoading = true
        dataFetcher.running = true
    }
    
    function processData(rawData) {
        try {
            currentData = JSON.parse(rawData)
            dataUpdated()
        } catch (e) {
            errorOccurred("Failed to process data: " + e.message)
        } finally {
            isLoading = false
        }
    }
    
    // System integration
    Process {
        id: availabilityChecker
        command: ["which", "required-command"]
        
        onExited: exitCode => {
            available = (exitCode === 0)
            if (available) {
                console.log("CustomService: Service available")
            } else {
                console.warn("CustomService: Required command not found")
            }
        }
    }
    
    Process {
        id: dataFetcher
        command: ["custom-command", "--json"]
        
        stdout: StdioCollector {
            onStreamFinished: {
                root.processData(text)
            }
        }
        
        onExited: exitCode => {
            if (exitCode !== 0) {
                root.errorOccurred("Command failed with exit code: " + exitCode)
                root.isLoading = false
            }
        }
    }
    
    // IPC integration
    IpcHandler {
        target: "customservice"
        
        function refresh(): string {
            root.fetchData()
            return "REFRESH_STARTED"
        }
        
        function status(): string {
            return JSON.stringify({
                available: root.available,
                loading: root.isLoading,
                hasData: root.currentData !== null
            })
        }
    }
    
    // Auto-initialization
    Component.onCompleted: {
        initialize()
    }
}
```

**2. Using Custom Service in Components**:
```qml
// In widget or component
import qs.Services

Item {
    // Bind to service state
    visible: CustomService.available
    enabled: !CustomService.isLoading
    
    // React to service signals
    Connections {
        target: CustomService
        
        function onDataUpdated() {
            updateDisplay()
        }
        
        function onErrorOccurred(error) {
            console.error("CustomService error:", error)
            showErrorMessage(error)
        }
    }
    
    // Use service data
    StyledText {
        text: CustomService.currentData ? CustomService.currentData.title : "No data"
        visible: CustomService.currentData !== null
    }
    
    // Trigger service actions
    DankActionButton {
        text: "Refresh"
        enabled: CustomService.available && !CustomService.isLoading
        onClicked: CustomService.fetchData()
    }
}
```

### Creating Custom Modals

**1. Modal Component**:
```qml
// Modals/CustomModal.qml
import qs.Modals
import qs.Widgets
import qs.Common

DankModal {
    id: customModal
    
    // Modal configuration
    width: 500
    height: 400
    positioning: "center"
    closeOnEscapeKey: true
    closeOnBackgroundClick: true
    
    // Custom properties
    property string customData: ""
    property var onDataSubmitted: null
    
    // Custom signals
    signal dataSubmitted(string data)
    
    // Modal content
    content: Component {
        Item {
            anchors.fill: parent
            anchors.margins: Theme.spacingL
            
            Column {
                anchors.fill: parent
                spacing: Theme.spacingL
                
                // Header
                Row {
                    width: parent.width
                    
                    StyledText {
                        text: "Custom Modal"
                        font.pixelSize: Theme.fontSizeXLarge
                        font.weight: Font.Medium
                        color: Theme.surfaceText
                    }
                    
                    Item { Layout.fillWidth: true }
                    
                    DankActionButton {
                        iconName: "close"
                        onClicked: customModal.close()
                    }
                }
                
                // Content
                Rectangle {
                    width: parent.width
                    height: parent.height - headerRow.height - buttonRow.height - Theme.spacingL * 2
                    color: Theme.surfaceVariant
                    radius: Theme.cornerRadius
                    
                    DankTextField {
                        id: dataInput
                        anchors.centerIn: parent
                        width: parent.width - Theme.spacingL * 2
                        placeholderText: "Enter custom data..."
                        text: customModal.customData
                    }
                }
                
                // Actions
                Row {
                    id: buttonRow
                    anchors.right: parent.right
                    spacing: Theme.spacingM
                    
                    DankActionButton {
                        text: "Cancel"
                        onClicked: customModal.close()
                    }
                    
                    DankActionButton {
                        text: "Submit"
                        primary: true
                        enabled: dataInput.text.trim() !== ""
                        
                        onClicked: {
                            customModal.customData = dataInput.text
                            customModal.dataSubmitted(dataInput.text)
                            if (customModal.onDataSubmitted) {
                                customModal.onDataSubmitted(dataInput.text)
                            }
                            customModal.close()
                        }
                    }
                }
            }
        }
    }
    
    // IPC integration
    IpcHandler {
        target: "custommodal"
        
        function show(data: string): string {
            customModal.customData = data || ""
            customModal.open()
            return "CUSTOM_MODAL_OPENED"
        }
        
        function hide(): string {
            customModal.close()
            return "CUSTOM_MODAL_CLOSED"
        }
    }
}
```

**2. Integrating Custom Modal**:
```qml
// In shell.qml or component
CustomModal {
    id: customModal
    
    onDataSubmitted: data => {
        console.log("Data submitted:", data)
        // Process the submitted data
        processCustomData(data)
    }
}

// Usage in other components
DankActionButton {
    text: "Open Custom Modal"
    onClicked: customModal.open()
}
```

### System Integration

**1. Adding Custom System Commands**:
```qml
// Services/SystemCommandService.qml
Singleton {
    id: root
    
    function executeCustomCommand(command, args) {
        customCommandProcess.command = [command].concat(args || [])
        customCommandProcess.running = true
    }
    
    function openCustomApplication(appName) {
        executeCustomCommand("gtk-launch", [appName])
    }
    
    function customSystemAction() {
        executeCustomCommand("custom-script.sh", ["--action", "custom"])
    }
    
    Process {
        id: customCommandProcess
        
        onExited: exitCode => {
            if (exitCode === 0) {
                console.log("Custom command executed successfully")
            } else {
                console.error("Custom command failed with exit code:", exitCode)
            }
        }
    }
    
    IpcHandler {
        target: "systemcommand"
        
        function execute(command: string, args: string): string {
            const argArray = args ? args.split(" ") : []
            root.executeCustomCommand(command, argArray)
            return "COMMAND_EXECUTED"
        }
        
        function launch(app: string): string {
            root.openCustomApplication(app)
            return "APP_LAUNCHED"
        }
    }
}
```

**2. Custom Compositor Integration**:
```qml
// Services/CustomCompositorService.qml
Singleton {
    id: root
    
    property bool isCustomCompositor: false
    property var workspaces: []
    
    function detectCompositor() {
        compositorDetector.running = true
    }
    
    function switchWorkspace(index) {
        if (!isCustomCompositor) return
        
        workspaceSwitcher.command = ["custom-compositor-ctl", "workspace", index.toString()]
        workspaceSwitcher.running = true
    }
    
    Process {
        id: compositorDetector
        command: ["pgrep", "custom-compositor"]
        
        onExited: exitCode => {
            isCustomCompositor = (exitCode === 0)
            if (isCustomCompositor) {
                console.log("Custom compositor detected")
                loadWorkspaces()
            }
        }
    }
    
    Process {
        id: workspaceSwitcher
        
        onExited: exitCode => {
            if (exitCode === 0) {
                console.log("Workspace switched successfully")
            }
        }
    }
    
    Component.onCompleted: {
        detectCompositor()
    }
}
```

## Configuration Patterns

### Environment-Specific Configuration

**1. Development vs Production**:
```qml
// Common/Environment.qml
pragma Singleton

Singleton {
    readonly property bool isDevelopment: Qt.application.arguments.includes("--dev")
    readonly property bool isDebug: Qt.application.arguments.includes("--debug")
    
    readonly property string configSuffix: isDevelopment ? "-dev" : ""
    readonly property int logLevel: isDebug ? 0 : 2  // 0=verbose, 2=warnings+errors
}

// Usage in components
Process {
    command: ["custom-command"]
    running: !Environment.isDevelopment  // Don't run in development
}

Timer {
    interval: Environment.isDevelopment ? 1000 : 10000  // Faster updates in dev
    repeat: true
}
```

**2. Feature Flags**:
```qml
// Common/FeatureFlags.qml
pragma Singleton

Singleton {
    // Experimental features
    readonly property bool enableExperimentalWidgets: false
    readonly property bool enableAdvancedAnimations: true
    readonly property bool enableBetaServices: false
    
    // Performance flags
    readonly property bool enableHighPerformanceMode: false
    readonly property bool enableReducedAnimations: false
    
    // Debug flags
    readonly property bool enableDebugOverlay: false
    readonly property bool enablePerformanceMonitoring: false
}

// Usage in components
DankWidget {
    visible: FeatureFlags.enableExperimentalWidgets
    enabled: FeatureFlags.enableExperimentalWidgets
}

NumberAnimation {
    duration: FeatureFlags.enableReducedAnimations ? 0 : Theme.shortDuration
}
```

### Multi-Monitor Configuration

**1. Per-Monitor Settings**:
```qml
// In SettingsData.qml
property var screenPreferences: ({})

function setScreenPreferences(prefs) {
    screenPreferences = prefs
    saveSettings()
}

function getScreenPreference(screenName, component, defaultValue) {
    const screenPrefs = screenPreferences[screenName] || {}
    const componentPrefs = screenPrefs[component] || {}
    return componentPrefs.hasOwnProperty('value') ? componentPrefs.value : defaultValue
}

// Usage
function getFilteredScreens(componentId) {
    var prefs = screenPreferences && screenPreferences[componentId] || ["all"]
    if (prefs.includes("all")) {
        return Quickshell.screens
    }
    return Quickshell.screens.filter(screen => prefs.includes(screen.name))
}
```

**2. Monitor-Specific Components**:
```qml
// Variants pattern for multi-monitor
Variants {
    model: SettingsData.getFilteredScreens("customComponent")
    
    delegate: CustomComponent {
        property var screen: modelData
        
        // Monitor-specific configuration
        width: screen.width
        height: getComponentHeight(screen.name)
        visible: getScreenPreference(screen.name, "customComponent", true)
        
        // Monitor-specific positioning
        anchors.top: screen.name === "DP-1" ? parent.top : undefined
        anchors.bottom: screen.name !== "DP-1" ? parent.bottom : undefined
    }
}
```

## Performance Optimization

### Lazy Loading Patterns

**1. Component Lazy Loading**:
```qml
// Lazy loading expensive components
Loader {
    id: expensiveComponentLoader
    active: false
    asynchronous: true
    
    sourceComponent: Component {
        ExpensiveComponent {
            // Heavy component loaded only when needed
        }
    }
    
    function activate() {
        if (!active) {
            active = true
        }
    }
    
    function deactivate() {
        if (active) {
            active = false
        }
    }
}

// Trigger loading based on visibility or interaction
onVisibleChanged: {
    if (visible) {
        expensiveComponentLoader.activate()
    } else {
        Qt.callLater(() => expensiveComponentLoader.deactivate())
    }
}
```

**2. Data Lazy Loading**:
```qml
// Service with lazy data loading
Singleton {
    property var cachedData: null
    property bool dataLoaded: false
    
    function loadData() {
        if (dataLoaded) return cachedData
        
        // Load data only when first requested
        dataLoader.running = true
        return null
    }
    
    Process {
        id: dataLoader
        command: ["expensive-data-command"]
        
        onExited: exitCode => {
            if (exitCode === 0) {
                cachedData = parseData(stdout.text)
                dataLoaded = true
                dataAvailable()
            }
        }
    }
}
```

### Memory Management

**1. Object Pooling**:
```qml
// Object pool for frequently created/destroyed items
QtObject {
    id: objectPool
    
    property var pool: []
    property int maxPoolSize: 10
    
    function acquire() {
        if (pool.length > 0) {
            return pool.pop()
        }
        return createNew()
    }
    
    function release(obj) {
        if (pool.length < maxPoolSize) {
            obj.reset()  // Reset object state
            pool.push(obj)
        } else {
            obj.destroy()
        }
    }
    
    function createNew() {
        return pooledObjectComponent.createObject(parent)
    }
    
    Component {
        id: pooledObjectComponent
        PooledObject {
            function reset() {
                // Reset all properties to defaults
            }
        }
    }
}
```

**2. Resource Cleanup**:
```qml
// Proper resource management
Component {
    onDestruction: {
        // Clean up resources
        if (timer.running) timer.stop()
        if (process.running) process.kill()
        
        // Clear references
        cachedData = null
        connections.target = null
    }
}

// Connection cleanup
Connections {
    id: serviceConnections
    target: SomeService
    
    Component.onDestruction: {
        target = null  // Prevent dangling references
    }
}
```

## Testing and Debugging

### Debug Utilities

**1. Debug Overlay**:
```qml
// Debug/DebugOverlay.qml
import QtQuick
import qs.Common

Rectangle {
    anchors.fill: parent
    color: "transparent"
    visible: FeatureFlags.enableDebugOverlay
    
    Column {
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: Theme.spacingM
        
        Rectangle {
            width: debugText.implicitWidth + Theme.spacingM * 2
            height: debugText.implicitHeight + Theme.spacingS * 2
            color: Qt.rgba(0, 0, 0, 0.8)
            radius: Theme.cornerRadius
            
            StyledText {
                id: debugText
                anchors.centerIn: parent
                color: "white"
                font.pixelSize: Theme.fontSizeSmall
                text: `FPS: ${fpsCounter.fps}
Memory: ${memoryMonitor.usage}MB
Services: ${Object.keys(services).length}`
            }
        }
    }
    
    Timer {
        id: fpsCounter
        property int fps: 60
        interval: 1000
        repeat: true
        running: parent.visible
        
        onTriggered: {
            // Calculate FPS
        }
    }
}
```

**2. Performance Monitoring**:
```qml
// Debug/PerformanceMonitor.qml
QtObject {
    id: performanceMonitor
    
    property var timings: ({})
    
    function startTiming(name) {
        timings[name] = Date.now()
    }
    
    function endTiming(name) {
        if (timings[name]) {
            const duration = Date.now() - timings[name]
            console.log(`Performance: ${name} took ${duration}ms`)
            delete timings[name]
        }
    }
    
    function measureFunction(name, func) {
        startTiming(name)
        const result = func()
        endTiming(name)
        return result
    }
}

// Usage
PerformanceMonitor.startTiming("componentCreation")
// ... expensive operation
PerformanceMonitor.endTiming("componentCreation")
```

## Best Practices

### Code Organization

1. **Follow the established directory structure**
2. **Use consistent naming conventions** (PascalCase for components, camelCase for properties)
3. **Group related functionality** in appropriate directories
4. **Document complex components** with inline comments
5. **Use TypeScript-style type hints** in function signatures

### State Management

1. **Use reactive property binding** instead of imperative updates
2. **Minimize cross-component dependencies** 
3. **Centralize shared state** in services or common components
4. **Implement proper cleanup** in Component.onDestruction
5. **Use signals for loose coupling** between components

### Performance

1. **Lazy load expensive components** using Loader
2. **Use object pooling** for frequently created items
3. **Implement proper caching** strategies
4. **Minimize property binding complexity**
5. **Profile performance** regularly during development

### Accessibility

1. **Add Accessible properties** to interactive elements
2. **Implement keyboard navigation** for all interactive components
3. **Provide proper focus management**
4. **Use semantic colors** from the theme system
5. **Test with screen readers** when possible

This customization guide provides the foundation for extending and modifying DankMaterialShell to meet your specific needs while maintaining code quality and performance standards.
