# Illogical Impulse Quickshell Configuration Index

## 📁 Overall Architecture

### Main Entry Points
- **`shell.qml`** - Main shell configuration with module loading
- **`settings.qml`** - Settings application with navigation rail
- **`GlobalStates.qml`** - Global state management singleton

### Directory Structure
```
ii/
├── shell.qml                 # Main shell entry point
├── settings.qml              # Settings application
├── GlobalStates.qml          # Global state singleton
├── Translation.qml           # Internationalization
├── ReloadPopup.qml          # Reload notification
├── killDialog.qml           # Process termination dialog
├── screenshot.qml           # Screenshot functionality
├── welcome.qml              # Welcome screen
├── modules/                 # Widget modules
│   ├── common/             # Shared components
│   ├── bar/                # Status bar
│   ├── background/         # Background management
│   ├── dock/               # Application dock
│   ├── lock/               # Screen lock
│   ├── mediaControls/      # Media controls
│   ├── notificationPopup/  # Notifications
│   ├── onScreenDisplay/    # OSD elements
│   ├── overview/           # Workspace overview
│   ├── sidebarLeft/        # Left sidebar
│   ├── sidebarRight/       # Right sidebar
│   ├── verticalBar/        # Vertical status bar
│   └── wallpaperSelector/  # Wallpaper selection
├── services/               # Backend services
├── scripts/                # Shell scripts
├── assets/                 # Images and icons
└── defaults/               # Default configurations
```

## 🔧 Core Configuration Patterns

### 1. Module Loading System
```qml
// Enable/disable modules with boolean properties
property bool enableBar: true
property bool enableBackground: true
property bool enableDock: true

// Lazy loading with LazyLoader
LazyLoader {
    active: enableBar && Config.ready && !Config.options.bar.vertical;
    component: Bar {}
}
```

### 2. Global State Management
```qml
// GlobalStates.qml - Singleton pattern
pragma Singleton
pragma ComponentBehavior: Bound

Singleton {
    id: root
    property bool barOpen: true
    property bool sidebarLeftOpen: false
    property bool mediaControlsOpen: false

    // Global shortcuts
    GlobalShortcut {
        name: "workspaceNumber"
        description: "Hold to show workspace numbers"
        onPressed: { root.superDown = true }
        onReleased: { root.superDown = false }
    }

    // IPC handlers
    IpcHandler {
        target: "zoom"
        function zoomIn() { screenZoom = Math.min(screenZoom + 0.4, 3.0) }
        function zoomOut() { screenZoom = Math.max(screenZoom - 0.4, 1) }
    }
}
```

### 3. Configuration System
```qml
// Config.qml - JSON-based configuration
Singleton {
    property alias options: configOptionsJsonAdapter
    property bool ready: false

    function setNestedValue(nestedKey, value) {
        let keys = nestedKey.split(".");
        let obj = root.options;
        // Traverse and set nested properties
    }

    FileView {
        path: root.filePath
        watchChanges: true
        onFileChanged: reload()
    }
}
```

## 🎨 Appearance System

### 1. Material Design 3 Colors
```qml
// Appearance.qml - Comprehensive theming
m3colors: QtObject {
    property color m3primary: "#E5B6F2"
    property color m3onPrimary: "#452152"
    property color m3secondary: "#D5C0D7"
    property color m3background: "#161217"
    property color m3surface: "#161217"
    property color m3outline: "#988E97"
}

// Dynamic transparency based on wallpaper
property real autoBackgroundTransparency: {
    let x = wallpaperVibrancy
    let y = 0.5768 * (x * x) - 0.759 * (x) + 0.2896
    return Math.max(0, Math.min(0.22, y))
}
```

### 2. Animation System
```qml
animation: QtObject {
    property QtObject elementMove: QtObject {
        property int duration: 500
        property int type: Easing.BezierSpline
        property list<real> bezierCurve: [0.38, 1.21, 0.22, 1.00, 1, 1]
        property Component numberAnimation: Component {
            NumberAnimation {
                duration: root.animation.elementMove.duration
                easing.type: root.animation.elementMove.type
                easing.bezierCurve: root.animation.elementMove.bezierCurve
            }
        }
    }
}
```

### 3. Typography System
```qml
font: QtObject {
    property QtObject family: QtObject {
        property string main: "Rubik"
        property string title: "Gabarito"
        property string iconMaterial: "Material Symbols Rounded"
        property string monospace: "JetBrains Mono NF"
    }
    property QtObject pixelSize: QtObject {
        property int smallest: 10
        property int normal: 16
        property int title: 22
    }
}
```

## 🧩 Widget System

### 1. Base Widget Components
```qml
// RippleButton.qml - Material Design button
Button {
    property bool toggled
    property string buttonText
    property real buttonRadius: 4
    property int rippleDuration: 1200

    // Custom mouse handling
    MouseArea {
        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
        onPressed: (event) => {
            if(event.button === Qt.RightButton) {
                if (root.altAction) root.altAction();
                return;
            }
            // Handle other buttons...
        }
    }

    // Ripple effect implementation
    background: Rectangle {
        // Ripple animation logic
    }
}
```

### 2. Layout Components
```qml
// BarGroup.qml - Container for bar widgets
Item {
    property bool vertical: false
    property real padding: 5

    Rectangle {
        id: background
        color: Config.options?.bar.borderless ? "transparent" : Appearance.colors.colLayer1
        radius: Appearance.rounding.small
    }

    GridLayout {
        id: gridLayout
        columns: root.vertical ? 1 : -1
        // Layout configuration
    }
}
```

### 3. Interactive Components
```qml
// FocusedScrollMouseArea.qml - Scroll handling
MouseArea {
    signal scrollUp(delta: int)
    signal scrollDown(delta: int)
    signal movedAway()

    onWheel: event => {
        if (event.angleDelta.y < 0)
            root.scrollDown(event.angleDelta.y);
        else if (event.angleDelta.y > 0)
            root.scrollUp(event.angleDelta.y);
    }
}
```

## 📱 Status Bar Implementation

### 1. Bar Structure
```qml
// Bar.qml - Main bar container
Scope {
    Variants {
        model: Quickshell.screens
        LazyLoader {
            active: GlobalStates.barOpen && !GlobalStates.screenLocked
            component: PanelWindow {
                // Bar window implementation
                exclusionMode: ExclusionMode.Ignore
                exclusiveZone: Appearance.sizes.baseBarHeight
                WlrLayershell.namespace: "quickshell:bar"
            }
        }
    }
}
```

### 2. Bar Content Layout
```qml
// BarContent.qml - Three-section layout
Item {
    // Left section - Brightness control + left sidebar
    FocusedScrollMouseArea {
        onScrollDown: root.brightnessMonitor.setBrightness(root.brightnessMonitor.brightness - 0.05)
        onScrollUp: root.brightnessMonitor.setBrightness(root.brightnessMonitor.brightness + 0.05)
    }

    // Middle section - Workspaces + media
    RowLayout {
        BarGroup { Resources {} }
        BarGroup { Workspaces {} }
        BarGroup { ClockWidget {} }
    }

    // Right section - Volume control + right sidebar
    FocusedScrollMouseArea {
        onScrollDown: Audio.sink.audio.volume -= step
        onScrollUp: Audio.sink.audio.volume += step
    }
}
```

### 3. Workspace Management
```qml
// Workspaces.qml - Dynamic workspace display
Item {
    property int workspaceGroup: Math.floor((monitor?.activeWorkspace?.id - 1) / Config.options.bar.workspaces.shown)
    property list<bool> workspaceOccupied: []

    // Workspace background indicators
    Repeater {
        model: Config.options.bar.workspaces.shown
        Rectangle {
            // Dynamic radius based on adjacent workspaces
            property var radiusLeft: previousOccupied ? 0 : (width / 2)
            property var radiusRight: rightOccupied ? 0 : (width / 2)
        }
    }

    // Active workspace indicator
    Rectangle {
        color: Appearance.colors.colPrimary
        radius: Appearance.rounding.full
        // Dynamic positioning and sizing
    }
}
```

## 🎯 Key Design Patterns

### 1. Component Composition
- **LazyLoader**: Conditional component loading
- **Revealer**: Animated show/hide with smooth transitions
- **BarGroup**: Consistent container styling
- **FocusedScrollMouseArea**: Scroll event handling

### 2. State Management
- **GlobalStates**: Centralized state singleton
- **Config**: JSON-based configuration with file watching
- **Appearance**: Comprehensive theming system

### 3. Animation Patterns
- **Behavior**: Property change animations
- **SequentialAnimation**: Multi-step animations
- **ParallelAnimation**: Simultaneous animations
- **Custom easing curves**: Material Design 3 curves

### 4. Layout Patterns
- **RowLayout/ColumnLayout**: Flexible layouts
- **GridLayout**: Grid-based arrangements
- **Anchors**: Precise positioning
- **States**: Dynamic layout changes

## 🔌 Service Integration

### 1. System Services
```qml
import Quickshell.Services.UPower
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Bluetooth

// Service usage examples
property var brightnessMonitor: Brightness.getMonitorForScreen(screen)
property var audioSink: Audio.sink.audio
property var networkStatus: Network.materialSymbol
```

### 2. IPC Communication
```qml
IpcHandler {
    target: "bar"
    function toggle(): void { GlobalStates.barOpen = !GlobalStates.barOpen }
    function close(): void { GlobalStates.barOpen = false }
    function open(): void { GlobalStates.barOpen = true }
}
```

## 📝 Configuration Options

### 1. Bar Configuration
```json
{
  "bar": {
    "bottom": false,
    "showBackground": true,
    "cornerStyle": 1,
    "borderless": false,
    "autoHide": {
      "enable": true,
      "showWhenPressingSuper": {
        "enable": true,
        "delay": 100
      }
    },
    "workspaces": {
      "shown": 5,
      "alwaysShowNumbers": false,
      "showAppIcons": true,
      "monochromeIcons": false
    }
  }
}
```

### 2. Appearance Configuration
```json
{
  "appearance": {
    "transparency": {
      "enable": true,
      "automatic": true,
      "backgroundTransparency": 0.11,
      "contentTransparency": 0.57
    },
    "palette": {
      "type": "auto"
    }
  }
}
```

## 🚀 Best Practices

### 1. Performance
- Use `LazyLoader` for conditional components
- Implement proper cleanup in `Component.onDestruction`
- Use `Repeater` efficiently with proper models
- Avoid unnecessary property bindings

### 2. Maintainability
- Centralize common styles in `Appearance.qml`
- Use consistent naming conventions
- Implement proper error handling
- Document complex logic with comments

### 3. User Experience
- Smooth animations for state changes
- Consistent visual feedback
- Responsive layouts for different screen sizes
- Accessible color contrasts

## 🔍 Common Widgets Reference

### 1. Text Components
- **StyledText**: Base text with theming
- **MaterialSymbol**: Material Design icons
- **StyledLabel**: Label with consistent styling

### 2. Interactive Elements
- **RippleButton**: Material Design button
- **StyledSwitch**: Toggle switch
- **StyledSlider**: Range slider
- **StyledSpinBox**: Number input

### 3. Layout Components
- **BarGroup**: Bar widget container
- **Revealer**: Animated show/hide
- **RoundCorner**: Rounded corner shapes
- **FloatingActionButton**: FAB component

### 4. Utility Components
- **ColorUtils**: Color manipulation functions
- **FileUtils**: File system operations
- **StringUtils**: String manipulation
- **ObjectUtils**: Object utilities

This index provides a comprehensive reference for understanding and implementing quickshell widgets using the illogical impulse configuration patterns and architecture.
