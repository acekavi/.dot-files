# DankMaterialShell Common Utilities Reference

## Overview

This document provides comprehensive documentation for all common utilities and shared components in DankMaterialShell. These utilities provide foundational functionality including theming, session management, path handling, animations, and various helper functions used throughout the system.

## Core Utility Components

### Appearance.qml

**Purpose**: Centralized design system providing consistent spacing, typography, animations, and visual hierarchy.

**Key Features**:
- Material Design 3 compliant spacing and sizing
- Animation curves and durations for consistent motion
- Typography scale with semantic sizing
- Reusable design tokens for consistent UI

**Components**:

#### Spacing System
```qml
component Spacing: QtObject {
    readonly property int small: 4        // Tight spacing
    readonly property int normal: 8       // Standard spacing
    readonly property int large: 12       // Comfortable spacing
    readonly property int extraLarge: 16  // Generous spacing
    readonly property int huge: 24        // Maximum spacing
}
```

#### Typography Scale
```qml
component FontSize: QtObject {
    readonly property int small: 12       // Caption text, secondary info
    readonly property int normal: 14      // Body text, labels
    readonly property int large: 16       // Headings, important text
    readonly property int extraLarge: 20  // Section headers
    readonly property int huge: 24        // Main titles
}
```

#### Rounding System
```qml
component Rounding: QtObject {
    readonly property int small: 8        // Subtle rounded corners
    readonly property int normal: 12      // Standard corner radius
    readonly property int large: 16       // Prominent rounding
    readonly property int extraLarge: 24  // High emphasis rounding
    readonly property int full: 1000      // Fully rounded (circles)
}
```

#### Animation System
```qml
component AnimCurves: QtObject {
    // Standard Material Design 3 curves
    readonly property list<real> standard: [0.2, 0, 0, 1, 1, 1]
    readonly property list<real> standardAccel: [0.3, 0, 1, 1, 1, 1]
    readonly property list<real> standardDecel: [0, 0, 0, 1, 1, 1]
    
    // Emphasized curves for important transitions
    readonly property list<real> emphasized: [0.05, 0, 2/15, 0.06, 1/6, 0.4, 5/24, 0.82, 0.25, 1, 1, 1]
    readonly property list<real> emphasizedAccel: [0.3, 0, 0.8, 0.15, 1, 1]
    readonly property list<real> emphasizedDecel: [0.05, 0.7, 0.1, 1, 1, 1]
    
    // Expressive curves for spatial and effect animations
    readonly property list<real> expressiveFastSpatial: [0.42, 1.67, 0.21, 0.9, 1, 1]
    readonly property list<real> expressiveDefaultSpatial: [0.38, 1.21, 0.22, 1, 1, 1]
    readonly property list<real> expressiveEffects: [0.34, 0.8, 0.34, 1, 1, 1]
}

component AnimDurations: QtObject {
    readonly property int quick: 150              // Fast micro-interactions
    readonly property int normal: 300             // Standard transitions
    readonly property int slow: 500               // Deliberate transitions
    readonly property int extraSlow: 1000         // Major state changes
    readonly property int expressiveFastSpatial: 350    // Quick spatial movement
    readonly property int expressiveDefaultSpatial: 500 // Standard spatial movement
    readonly property int expressiveEffects: 200        // Visual effects
}
```

**Usage Examples**:
```qml
// Using spacing system
Column {
    spacing: Appearance.spacing.normal
    topPadding: Appearance.spacing.large
}

// Using typography scale
StyledText {
    font.pixelSize: Appearance.fontSize.large
    font.weight: Font.Medium
}

// Using animation system
Behavior on opacity {
    NumberAnimation {
        duration: Appearance.anim.durations.quick
        easing.type: Easing.BezierSpline
        easing.bezierCurve: Appearance.anim.curves.standard
    }
}
```

### SessionData.qml

**Purpose**: Runtime session state management with persistent storage for user preferences and temporary data.

**Key Features**:
- Session-specific settings (wallpaper, theme mode, etc.)
- JSON-based persistence with automatic loading/saving
- Night mode scheduling and configuration
- Wallpaper cycling and management
- GPU monitoring preferences
- IPC integration for external control

**State Properties**:
```qml
// Core session state
property bool isLightMode: false
property string wallpaperPath: ""
property bool doNotDisturb: false

// Night mode configuration
property bool nightModeEnabled: false
property int nightModeTemperature: 4500
property bool nightModeAutoEnabled: false
property string nightModeAutoMode: "time"  // "time" or "location"
property int nightModeStartHour: 18
property int nightModeStartMinute: 0
property int nightModeEndHour: 6
property int nightModeEndMinute: 0
property real latitude: 0.0
property real longitude: 0.0

// Application preferences
property var pinnedApps: []
property string notepadContent: ""

// Hardware preferences
property int selectedGpuIndex: 0
property bool nvidiaGpuTempEnabled: false
property var enabledGpuPciIds: []

// Wallpaper cycling
property bool wallpaperCyclingEnabled: false
property string wallpaperCyclingMode: "interval"  // "interval" or "time"
property int wallpaperCyclingInterval: 300        // seconds
property string wallpaperCyclingTime: "06:00"     // HH:mm format
```

**Key Methods**:
```qml
function setWallpaper(imagePath) {
    wallpaperPath = imagePath
    saveSettings()
    
    // Trigger dynamic theming if enabled
    if (SettingsData.wallpaperDynamicTheming) {
        Theme.extractColors()
    }
    
    // Generate system themes (GTK/Qt integration)
    Theme.generateSystemThemesFromCurrentTheme()
}

function addPinnedApp(appId) {
    if (!appId) return
    var currentPinned = [...pinnedApps]
    if (currentPinned.indexOf(appId) === -1) {
        currentPinned.push(appId)
        setPinnedApps(currentPinned)
    }
}

function isPinnedApp(appId) {
    return appId && pinnedApps.indexOf(appId) !== -1
}
```

**IPC Integration**:
```bash
# Wallpaper management via IPC
qs -c dms ipc call wallpaper set "/path/to/image.jpg"
qs -c dms ipc call wallpaper get
qs -c dms ipc call wallpaper next    # Cycle to next wallpaper
qs -c dms ipc call wallpaper prev    # Cycle to previous wallpaper
```

### Paths.qml

**Purpose**: Centralized path management and file system utilities with cross-platform compatibility.

**Key Features**:
- Standard directory path resolution
- Path manipulation utilities
- File system operations
- URL encoding/decoding handling
- Home directory expansion and shortening

**Standard Paths**:
```qml
readonly property url home: StandardPaths.standardLocations(StandardPaths.HomeLocation)[0]
readonly property url pictures: StandardPaths.standardLocations(StandardPaths.PicturesLocation)[0]

// Application-specific directories
readonly property url data: `${StandardPaths.standardLocations(StandardPaths.GenericDataLocation)[0]}/DankMaterialShell`
readonly property url state: `${StandardPaths.standardLocations(StandardPaths.GenericStateLocation)[0]}/DankMaterialShell`
readonly property url cache: `${StandardPaths.standardLocations(StandardPaths.GenericCacheLocation)[0]}/DankMaterialShell`
readonly property url config: `${StandardPaths.standardLocations(StandardPaths.GenericConfigLocation)[0]}/DankMaterialShell`

readonly property url imagecache: `${cache}/imagecache`
```

**Utility Functions**:
```qml
function stringify(path: url): string {
    return path.toString().replace(/%20/g, " ")  // Handle URL encoding
}

function expandTilde(path: string): string {
    return strip(path.replace("~", stringify(root.home)))  // Expand ~ to home directory
}

function shortenHome(path: string): string {
    return path.replace(strip(root.home), "~")  // Replace home directory with ~
}

function strip(path: url): string {
    return stringify(path).replace("file://", "")  // Remove file:// protocol
}

function mkdir(path: url): void {
    Quickshell.execDetached(["mkdir", "-p", strip(path)])  // Create directory recursively
}

function copy(from: url, to: url): void {
    Quickshell.execDetached(["cp", strip(from), strip(to)])  // Copy file
}

// Special case handling for applications with incorrect app IDs
function moddedAppId(appId: string): string {
    if (appId === "Spotify") return "spotify-launcher"
    return appId
}
```

**Usage Examples**:
```qml
// Path manipulation
var fullPath = Paths.expandTilde("~/Documents/file.txt")
var shortPath = Paths.shortenHome("/home/user/Documents/file.txt")  // Returns "~/Documents/file.txt"

// Directory operations
Paths.mkdir(Paths.cache)  // Create cache directory
Paths.copy(sourceFile, Paths.data + "/backup.txt")  // Copy file to data directory

// URL handling
var cleanPath = Paths.strip("file:///home/user/image.jpg")  // Returns "/home/user/image.jpg"
```

### ModalManager.qml

**Purpose**: Centralized modal state management preventing conflicts and managing focus.

**Key Features**:
- Modal stacking control
- Conflict resolution between competing modals
- Focus coordination
- Automatic cleanup

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
```

**Usage Pattern**:
```qml
// In modal components
Connections {
    target: ModalManager
    function onCloseAllModalsExcept(excludedModal) {
        if (excludedModal !== root && !allowStacking && shouldBeVisible) {
            close()
        }
    }
}

function open() {
    ModalManager.openModal(root)  // Register with manager
    // ... rest of open logic
}
```

## JavaScript Utilities

### fuzzysort.js

**Purpose**: High-performance fuzzy string searching for application launchers and search interfaces.

**Key Features**:
- Fast fuzzy string matching algorithm
- Configurable scoring and thresholds
- Support for multiple search keys
- Highlighting of matched characters
- Optimized for large datasets

**Core Functions**:
```javascript
// Single target search
var result = fuzzysort.single(search, target)

// Multiple targets search
var results = fuzzysort.go(search, targets, {
    threshold: 0.6,        // Minimum score threshold
    limit: 10,            // Maximum results
    key: 'name',          // Property to search
    keys: ['name', 'description']  // Multiple properties
})

// Prepared search for performance
var prepared = fuzzysort.prepare(target)
var preparedSearch = fuzzysort.getPreparedSearch(search)
var result = fuzzysort.algorithm(preparedSearch, prepared)
```

**Usage in Application Search**:
```qml
// AppSearchService.qml
function searchApplications(query) {
    if (!query.trim()) return allApplications
    
    const results = fuzzysort.go(query, allApplications, {
        threshold: 0.6,
        limit: 50,
        keys: ['name', 'description', 'keywords']
    })
    
    return results.map(result => ({
        ...result.obj,
        score: result.score,
        highlighted: fuzzysort.highlight(result, '<mark>', '</mark>')
    }))
}
```

### markdown2html.js

**Purpose**: Markdown to HTML conversion for rich text display in notifications and content areas.

**Key Features**:
- Lightweight markdown parsing
- HTML output for QML rich text
- Support for common markdown syntax
- Safe HTML generation

**Usage**:
```qml
// NotificationService.qml
readonly property string htmlBody: {
    if (body && (body.includes('<') && body.includes('>'))) {
        return body  // Already HTML
    }
    return Markdown2Html.markdownToHtml(body)  // Convert markdown
}
```

## Utility Components

### Ref.qml

**Purpose**: Reference counting utility for managing resource lifecycles.

**Key Features**:
- Automatic reference counting
- Resource lifecycle management
- Memory leak prevention
- Service activation control

### CacheUtils.qml

**Purpose**: Caching utilities for improved performance and reduced resource usage.

**Key Features**:
- Image caching strategies
- Cache invalidation
- Storage management
- Performance optimization

### AppUsageHistoryData.qml

**Purpose**: Application usage tracking for intelligent application suggestions.

**Key Features**:
- Usage frequency tracking
- Recent application history
- Launch count statistics
- Intelligent sorting

### StockThemes.js

**Purpose**: Predefined color themes and theme management utilities.

**Key Features**:
- Material Design 3 color schemes
- Theme data structures
- Color palette generation
- Theme validation

**Theme Structure**:
```javascript
const themes = {
    blue: {
        name: "Blue",
        primary: "#1976D2",
        primaryText: "#FFFFFF",
        secondary: "#42A5F5",
        surface: "#121212",
        surfaceText: "#FFFFFF",
        // ... more colors
    },
    // ... more themes
}

function getThemeByName(name, isLight) {
    const theme = themes[name] || themes.blue
    return isLight ? generateLightVariant(theme) : theme
}

function getAllThemeNames() {
    return Object.keys(themes)
}
```

## Integration Patterns

### Service Integration

Common utilities integrate seamlessly with services:

```qml
// WeatherService.qml using Paths
readonly property string cacheFile: Paths.strip(Paths.cache) + "/weather.json"

// AudioService.qml using Appearance
Behavior on volume {
    NumberAnimation {
        duration: Appearance.anim.durations.quick
        easing.type: Easing.BezierSpline
        easing.bezierCurve: Appearance.anim.curves.standard
    }
}
```

### Component Integration

Widgets and modules leverage common utilities:

```qml
// DankSlider.qml using Appearance
Rectangle {
    radius: Appearance.rounding.normal
    color: Theme.surfaceContainer
    
    Behavior on opacity {
        NumberAnimation {
            duration: Appearance.anim.durations.quick
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Appearance.anim.curves.standard
        }
    }
}

// Settings using SessionData
DankToggle {
    checked: SessionData.doNotDisturb
    onToggled: SessionData.setDoNotDisturb(checked)
}
```

### Theme Integration

All components use consistent theming through utilities:

```qml
// Using Appearance with Theme
StyledText {
    font.pixelSize: Appearance.fontSize.large
    color: Theme.surfaceText
    
    Behavior on color {
        ColorAnimation {
            duration: Appearance.anim.durations.normal
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Appearance.anim.curves.standard
        }
    }
}
```

## Performance Considerations

### Lazy Loading

Utilities support lazy initialization:

```qml
// SessionData.qml
Component.onCompleted: {
    loadSettings()  // Load only when component is created
}
```

### Caching Strategies

Efficient caching throughout the system:

```qml
// Paths.qml - cached path calculations
readonly property url imagecache: `${cache}/imagecache`

// fuzzysort.js - prepared searches for performance
var prepared = fuzzysort.prepare(target)  // Prepare once, use many times
```

### Resource Management

Proper cleanup and resource management:

```qml
// SessionData.qml
function saveSettings() {
    settingsFile.setText(JSON.stringify(settings, null, 2))  // Efficient JSON serialization
}

// Paths.qml
function mkdir(path: url): void {
    Quickshell.execDetached(["mkdir", "-p", strip(path)])  // Non-blocking file operations
}
```

This comprehensive utility system provides the foundation for consistent, performant, and maintainable code throughout the DankMaterialShell desktop environment.
