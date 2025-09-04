# DankMaterialShell Services Reference

## Overview

This document provides comprehensive documentation for all system services in DankMaterialShell. Services are singleton components that provide system integration, hardware abstraction, and state management for various desktop shell functions.

## Service Architecture

All services follow a consistent singleton pattern with these characteristics:

- **Singleton Pattern**: Global state management with single instances
- **Reactive Properties**: Automatic UI updates through property binding
- **System Integration**: Hardware and system API abstraction
- **IPC Support**: External control via quickshell IPC system
- **Error Handling**: Graceful degradation and capability detection

## Core Services

### AudioService.qml

**Purpose**: PipeWire audio system integration with volume and device management.

**Key Features**:
- PipeWire integration for modern audio handling
- Volume control with automatic mute handling
- Device name resolution and display formatting
- IPC commands for external control
- Reactive property updates

**Properties**:
```qml
readonly property PwNode sink: Pipewire.defaultAudioSink
readonly property PwNode source: Pipewire.defaultAudioSource

// Reactive audio state
property bool audioAvailable: sink !== null
property real volume: sink && sink.audio ? sink.audio.volume : 0
property bool muted: sink && sink.audio ? sink.audio.muted : false
```

**Key Functions**:
```qml
function setVolume(percentage) {
    if (sink && sink.audio) {
        const clampedVolume = Math.max(0, Math.min(100, percentage))
        sink.audio.volume = clampedVolume / 100
        volumeChanged()  // Signal for UI updates
    }
}

function toggleMute() {
    if (sink && sink.audio) {
        sink.audio.muted = !sink.audio.muted
        return sink.audio.muted ? "Audio muted" : "Audio unmuted"
    }
}
```

**IPC Commands**:
```bash
qs -c dms ipc call audio setvolume 50    # Set volume to 50%
qs -c dms ipc call audio increment 5     # Increase volume by 5%
qs -c dms ipc call audio mute            # Toggle mute
qs -c dms ipc call audio status          # Get audio status
```

### NetworkService.qml

**Purpose**: Comprehensive network management with WiFi and Ethernet support.

**Key Features**:
- NetworkManager integration via D-Bus monitoring
- WiFi scanning and connection management
- Ethernet detection and control
- Connection priority management
- Network information and diagnostics

**State Properties**:
```qml
property string networkStatus: "disconnected"  // "ethernet", "wifi", "disconnected"
property bool wifiConnected: false
property bool ethernetConnected: false
property string currentWifiSSID: ""
property int wifiSignalStrength: 0
property var wifiNetworks: []           // Available networks
property var savedConnections: []      // Saved WiFi networks
```

**Connection Management**:
```qml
function connectToWifi(ssid, password = "") {
    if (isConnecting) return
    
    isConnecting = true
    connectingSSID = ssid
    
    if (password) {
        wifiConnector.command = ["nmcli", "dev", "wifi", "connect", ssid, "password", password]
    } else {
        wifiConnector.command = ["nmcli", "dev", "wifi", "connect", ssid]
    }
    wifiConnector.running = true
}

function setNetworkPreference(preference) {
    userPreference = preference
    SettingsData.setNetworkPreference(preference)
    
    if (preference === "wifi") {
        setConnectionPriority("wifi")
    } else if (preference === "ethernet") {
        setConnectionPriority("ethernet")
    }
}
```

**D-Bus Monitoring**:
```qml
Process {
    id: nmStateMonitor
    command: ["gdbus", "monitor", "--system", "--dest", "org.freedesktop.NetworkManager"]
    
    stdout: SplitParser {
        onRead: line => {
            if (line.includes("StateChanged") || line.includes("ActiveConnection")) {
                refreshNetworkState()  // Reactive state updates
            }
        }
    }
}
```

### BluetoothService.qml

**Purpose**: Bluetooth device management with advanced codec support.

**Key Features**:
- Quickshell Bluetooth integration
- Device pairing and connection management
- Audio codec detection and switching (LDAC, aptX, AAC, SBC)
- Device type detection with appropriate icons
- Signal strength monitoring

**Device Management**:
```qml
readonly property BluetoothAdapter adapter: Bluetooth.defaultAdapter
readonly property bool available: adapter !== null
readonly property bool enabled: adapter?.enabled ?? false
readonly property var pairedDevices: {
    if (!adapter?.devices) return []
    return adapter.devices.values.filter(dev => dev?.paired || dev?.trusted)
}

function getDeviceIcon(device) {
    if (!device) return "bluetooth"
    
    var name = (device.name || device.deviceName || "").toLowerCase()
    var icon = (device.icon || "").toLowerCase()
    
    if (icon.includes("headset") || name.includes("headphone")) return "headset"
    if (icon.includes("mouse") || name.includes("mouse")) return "mouse"
    if (icon.includes("keyboard") || name.includes("keyboard")) return "keyboard"
    if (icon.includes("phone") || name.includes("phone")) return "smartphone"
    
    return "bluetooth"
}
```

**Audio Codec Management**:
```qml
function switchCodec(device, profileName, callback) {
    if (!device || !isAudioDevice(device)) {
        callback(false, "Invalid device")
        return
    }
    
    let cardName = getCardName(device)
    codecSwitchProcess.cardName = cardName
    codecSwitchProcess.profile = profileName
    codecSwitchProcess.callback = callback
    codecSwitchProcess.running = true
}

function getCodecInfo(codecName) {
    let codecMap = {
        "LDAC": {
            name: "LDAC",
            description: "Highest quality • Higher battery usage",
            qualityColor: "#4CAF50"
        },
        "APTX_HD": {
            name: "aptX HD", 
            description: "High quality • Balanced battery",
            qualityColor: "#FF9800"
        }
        // ... more codec definitions
    }
    return codecMap[codec] || { name: codecName, description: "Unknown codec" }
}
```

### NotificationService.qml

**Purpose**: Advanced notification system with grouping, queuing, and persistence.

**Key Features**:
- Notification server with desktop notification support
- Intelligent grouping by application
- Queue management with rate limiting
- Popup display with customizable timeouts
- Markdown and HTML content support

**Notification Management**:
```qml
readonly property list<NotifWrapper> notifications: []
readonly property list<NotifWrapper> popups: allWrappers.filter(n => n?.popup)
property int maxVisibleNotifications: 3
property int maxIngressPerSecond: 20

function _enqueuePopup(wrapper) {
    if (notificationQueue.length >= maxQueueSize) {
        // Remove non-critical notifications to make space
        const victim = notificationQueue.find(w => w.urgency !== NotificationUrgency.Critical)
        if (victim) {
            victim.popup = false
            notificationQueue.splice(notificationQueue.indexOf(victim), 1)
        }
    }
    notificationQueue.push(wrapper)
}
```

**Notification Grouping**:
```qml
function getGroupKey(wrapper) {
    if (wrapper.desktopEntry && wrapper.desktopEntry !== "") {
        return wrapper.desktopEntry.toLowerCase()
    }
    return wrapper.appName.toLowerCase()
}

function _calcGroupedNotifications() {
    const groups = {}
    
    for (const notif of notifications) {
        const groupKey = getGroupKey(notif)
        if (!groups[groupKey]) {
            groups[groupKey] = {
                key: groupKey,
                appName: notif.appName,
                notifications: [],
                latestNotification: null,
                count: 0
            }
        }
        
        groups[groupKey].notifications.unshift(notif)
        groups[groupKey].latestNotification = groups[groupKey].notifications[0]
        groups[groupKey].count = groups[groupKey].notifications.length
    }
    
    return Object.values(groups).sort((a, b) => {
        return b.latestNotification.time.getTime() - a.latestNotification.time.getTime()
    })
}
```

### WeatherService.qml

**Purpose**: Weather data fetching with intelligent retry and caching.

**Key Features**:
- wttr.in API integration
- Automatic location detection or manual coordinates
- Intelligent retry with exponential backoff
- Reference counting for performance optimization
- Comprehensive weather data (temperature, humidity, UV, etc.)

**Data Management**:
```qml
property var weather: ({
    "available": false,
    "loading": true,
    "temp": 0,
    "tempF": 0,
    "city": "",
    "wCode": "113",
    "humidity": 0,
    "wind": "",
    "sunrise": "06:00",
    "sunset": "18:00",
    "uv": 0,
    "pressure": 0
})

function addRef() {
    refCount++
    if (refCount === 1 && !weather.available && SettingsData.weatherEnabled) {
        fetchWeather()  // Start fetching when first consumer appears
    }
}

function removeRef() {
    refCount = Math.max(0, refCount - 1)
    // Stop fetching when no consumers remain
}
```

**Error Handling with Backoff**:
```qml
function handleWeatherFailure() {
    retryAttempts++
    if (retryAttempts < maxRetryAttempts) {
        console.log(`Weather fetch failed, retrying in ${retryDelay/1000}s`)
        retryTimer.start()
    } else {
        // Use exponential backoff: 1min, 2min, 4min, cap at 5min
        const backoffDelay = Math.min(60000 * Math.pow(2, persistentRetryCount), 300000)
        persistentRetryCount++
        persistentRetryTimer.interval = backoffDelay
        persistentRetryTimer.start()
    }
}
```

## System Integration Services

### DisplayService.qml

**Purpose**: Display and brightness management with night mode support.

**Key Features**:
- Brightness control via system commands
- Night mode (blue light filter) toggle
- Multi-monitor support
- Capability detection for hardware features

### BatteryService.qml

**Purpose**: Battery monitoring and power profile management.

**Key Features**:
- UPower integration for battery information
- Power profile switching (performance, balanced, power-saver)
- Charging state detection
- Battery level and time estimation

### CompositorService.qml

**Purpose**: Window manager integration (Niri, Hyprland).

**Key Features**:
- Compositor detection and adaptation
- Window management commands
- Workspace switching integration
- Multi-compositor support

## Data Services

### AppSearchService.qml

**Purpose**: Application discovery and search functionality.

**Key Features**:
- Desktop entry parsing and indexing
- Fuzzy search implementation
- Application categorization
- Icon resolution and caching

### CalendarService.qml

**Purpose**: Calendar integration with CalDAV support.

**Key Features**:
- vdirsyncer integration for calendar sync
- Event parsing and display
- Multiple calendar source support
- Timezone handling

### UserInfoService.qml

**Purpose**: User information and profile management.

**Key Features**:
- User profile information
- Avatar/profile picture management
- System user data integration

## Utility Services

### PortalService.qml

**Purpose**: XDG Desktop Portal integration.

**Key Features**:
- Theme preference communication
- System integration via portals
- Cross-desktop compatibility

### ToastService.qml

**Purpose**: Toast notification system for system feedback.

**Key Features**:
- Non-intrusive status messages
- Different severity levels (info, warning, error)
- Automatic dismissal with customizable timing

### SessionService.qml

**Purpose**: Session management and system control.

**Key Features**:
- Logout, restart, shutdown operations
- Session state management
- System command execution

## Service Communication Patterns

### Cross-Service Dependencies

Services can communicate through the global scope:

```qml
// DisplayService.qml
function setNightMode(enabled) {
    nightModeEnabled = enabled
    
    // Notify theme system
    if (typeof Theme !== "undefined") {
        Theme.onDisplayModeChanged()
    }
    
    // Update settings
    if (typeof SettingsData !== "undefined") {
        SettingsData.setNightModeEnabled(enabled)
    }
}
```

### Event-Driven Updates

Services emit signals for state changes:

```qml
// AudioService.qml
signal volumeChanged()
signal micMuteChanged()

function setVolume(percentage) {
    sink.audio.volume = percentage / 100
    volumeChanged()  // Notify all connected components
}

// UI Component
Connections {
    target: AudioService
    function onVolumeChanged() {
        updateVolumeDisplay()
    }
}
```

### Reference Counting Pattern

Performance-sensitive services use reference counting:

```qml
// WeatherService.qml
function addRef() {
    refCount++
    if (refCount === 1) {
        startPeriodicUpdates()  // Only start when needed
    }
}

function removeRef() {
    refCount = Math.max(0, refCount - 1)
    if (refCount === 0) {
        stopPeriodicUpdates()  // Stop when no consumers
    }
}
```

## IPC Integration

Most services provide IPC handlers for external control:

```qml
IpcHandler {
    target: "audio"
    
    function setvolume(percentage: string): string {
        return root.setVolume(parseInt(percentage))
    }
    
    function increment(step: string): string {
        const newVolume = currentVolume + parseInt(step || "5")
        root.setVolume(newVolume)
        return `Volume increased to ${newVolume}%`
    }
    
    function status(): string {
        return `Volume: ${Math.round(volume * 100)}%${muted ? " (muted)" : ""}`
    }
}
```

## Error Handling Strategies

### Graceful Degradation

Services detect capabilities and adapt UI accordingly:

```qml
// BluetoothService.qml
readonly property bool available: adapter !== null

// UI Component
DankSlider {
    visible: BluetoothService.available
    enabled: BluetoothService.available
}
```

### Retry Logic

Network services implement intelligent retry mechanisms:

```qml
function handleFailure() {
    retryAttempts++
    if (retryAttempts < maxRetryAttempts) {
        // Immediate retry
        retryTimer.start()
    } else {
        // Exponential backoff for persistent failures
        const delay = Math.min(baseDelay * Math.pow(2, persistentRetryCount), maxDelay)
        persistentRetryTimer.interval = delay
        persistentRetryTimer.start()
    }
}
```

### Process Monitoring

System integration processes are monitored and restarted on failure:

```qml
Process {
    id: systemMonitor
    command: ["dbus-monitor", "system"]
    
    onExited: exitCode => {
        if (exitCode !== 0 && !restartTimer.running) {
            console.warn("System monitor failed, restarting in 5s")
            restartTimer.start()
        }
    }
}

Timer {
    id: restartTimer
    interval: 5000
    onTriggered: systemMonitor.running = true
}
```

## Performance Optimization

### Lazy Initialization

Services initialize expensive resources only when needed:

```qml
Component.onCompleted: {
    // Light initialization
    detectCapabilities()
}

function addRef() {
    refCount++
    if (refCount === 1) {
        // Heavy initialization only when first consumer appears
        initializeHeavyResources()
    }
}
```

### Debounced Updates

Rapid state changes are debounced to prevent excessive processing:

```qml
Timer {
    id: updateDebounceTimer
    interval: 100
    repeat: false
    onTriggered: performActualUpdate()
}

function requestUpdate() {
    updateDebounceTimer.restart()  // Debounce rapid requests
}
```

### Selective Property Updates

Only properties that actually changed trigger updates:

```qml
function updateState(newState) {
    var hasChanges = false
    
    if (currentState.property1 !== newState.property1) {
        currentState.property1 = newState.property1
        hasChanges = true
    }
    
    if (hasChanges) {
        stateChanged()  // Single signal for all changes
    }
}
```

This comprehensive service architecture provides robust system integration, automatic UI updates, and excellent performance characteristics for the DankMaterialShell desktop environment.
