# DankMaterialShell Widgets Reference

## Overview

This document provides comprehensive documentation for all widget components in the DankMaterialShell system. Widgets are reusable UI components that follow Material Design 3 principles and provide consistent styling and behavior across the shell.

## Widget Categories

### Core UI Components
- **DankIcon**: Material Design icon system
- **StyledText**: Themed text component
- **StyledRect**: Themed rectangle/container
- **StateLayer**: Material Design 3 interaction states

### Input Controls
- **DankSlider**: Advanced slider with multi-input support
- **DankToggle**: Material Design toggle switch
- **DankTextField**: Styled text input with validation
- **DankDropdown**: Dropdown selection component

### Layout Components
- **DankGridView**: Adaptive grid layout
- **DankListView**: Scrollable list view
- **DankTabBar**: Unified tab navigation
- **DankFlickable**: Enhanced scrollable container

### Specialized Components
- **DankPopout**: Base overlay component
- **DankOSD**: On-screen display notifications
- **CachingImage**: Optimized image loading
- **SystemLogo**: Animated system branding

## Core Widget Documentation

### DankIcon

**Purpose**: Centralized icon component using Material Symbols font with variable axes support.

**Key Features**:
- Material Symbols Rounded font integration
- Variable font axes (FILL, GRAD, opsz, wght)
- Automatic theme integration
- Smooth fill animations
- Consistent sizing system

**Properties**:
```qml
property alias name: icon.text          // Icon name from Material Symbols
property alias size: icon.font.pixelSize // Icon size in pixels
property alias color: icon.color        // Icon color
property bool filled: false             // Fill state (0-1)
property int grade: Theme.isLightMode ? 0 : -25  // Optical adjustment
property int weight: filled ? 500 : 400 // Font weight
```

**Usage Examples**:
```qml
// Basic icon
DankIcon {
    name: "settings"
    size: Theme.iconSize
    color: Theme.surfaceText
}

// Filled icon with animation
DankIcon {
    name: "favorite"
    filled: isLiked
    color: isLiked ? Theme.error : Theme.surfaceText
}

// Custom sizing
DankIcon {
    name: "menu"
    size: Theme.iconSizeLarge
    weight: 600
}
```

**Animation Behavior**:
- Fill state animates smoothly using BezierSpline easing
- Weight changes animate with standard easing
- Duration controlled by `Appearance.anim.durations.quick`

### DankSlider

**Purpose**: Advanced slider component with sophisticated input handling and visual feedback.

**Key Features**:
- Multi-input support (mouse, touchpad, wheel)
- Smart input detection (differentiates mouse wheel vs touchpad)
- Visual feedback (tooltips, hover states)
- Customizable icons and units
- Accessibility support

**Properties**:
```qml
property int value: 50                   // Current value
property int minimum: 0                  // Minimum value
property int maximum: 100                // Maximum value
property string leftIcon: ""             // Left side icon
property string rightIcon: ""            // Right side icon
property bool enabled: true              // Enable/disable state
property string unit: "%"                // Value unit display
property bool showValue: true            // Show value tooltip
property bool wheelEnabled: true         // Enable wheel input
readonly property bool containsMouse     // Mouse hover state
```

**Signals**:
```qml
signal sliderValueChanged(int newValue)      // Value changed during interaction
signal sliderDragFinished(int finalValue)    // Drag operation completed
```

**Usage Examples**:
```qml
// Volume slider
DankSlider {
    value: Math.round(AudioService.sink.audio.volume * 100)
    leftIcon: "volume_down"
    rightIcon: "volume_up"
    unit: "%"
    onSliderValueChanged: (newValue) => {
        AudioService.setVolume(newValue)
    }
}

// Brightness slider
DankSlider {
    value: DisplayService.brightnessLevel
    minimum: 1
    maximum: 100
    leftIcon: "brightness_low"
    rightIcon: "brightness_high"
    enabled: DisplayService.brightnessAvailable
}

// Custom range slider
DankSlider {
    value: customValue
    minimum: -50
    maximum: 200
    unit: "°C"
    showValue: true
    wheelEnabled: false
}
```

**Input Handling**:
- **Mouse Wheel**: 5% steps for discrete scrolling
- **Touchpad**: 1% steps with accumulation for smooth scrolling
- **Click/Drag**: Direct position mapping
- **Keyboard**: Arrow key support (when focused)

### DankToggle

**Purpose**: Material Design 3 toggle switch with smooth animations.

**Key Features**:
- Material Design 3 styling
- Smooth toggle animations
- Customizable colors and sizing
- Accessibility support
- Hover and focus states

**Properties**:
```qml
property bool checked: false             // Toggle state
property bool enabled: true              // Enable/disable
property color checkedColor: Theme.primary        // Active color
property color uncheckedColor: Theme.outline      // Inactive color
property color thumbColor: Theme.surface          // Thumb color
property real toggleWidth: 48            // Total width
property real toggleHeight: 24           // Total height
```

**Signals**:
```qml
signal toggled(bool checked)             // State changed
```

**Usage Examples**:
```qml
// Basic toggle
DankToggle {
    checked: SettingsData.showWeather
    onToggled: (isChecked) => {
        SettingsData.setShowWeather(isChecked)
    }
}

// Styled toggle
DankToggle {
    checked: nightModeEnabled
    checkedColor: Theme.warning
    uncheckedColor: Theme.surfaceVariant
    onToggled: (isChecked) => {
        DisplayService.setNightMode(isChecked)
    }
}
```

### DankTextField

**Purpose**: Styled text input field with validation and theming.

**Key Features**:
- Material Design 3 styling
- Input validation
- Placeholder text support
- Error state handling
- Focus state animations

**Properties**:
```qml
property alias text: textInput.text      // Input text
property string placeholderText: ""      // Placeholder text
property bool hasError: false            // Error state
property string errorText: ""            // Error message
property bool readOnly: false            // Read-only mode
property int maximumLength: 32767        // Character limit
```

**Usage Examples**:
```qml
// Basic text field
DankTextField {
    placeholderText: "Enter location..."
    text: WeatherService.location
    onTextChanged: {
        WeatherService.setLocation(text)
    }
}

// Validated text field
DankTextField {
    placeholderText: "Username"
    hasError: !isValidUsername(text)
    errorText: "Username must be at least 3 characters"
    maximumLength: 20
}
```

### DankDropdown

**Purpose**: Dropdown selection component with search and filtering.

**Key Features**:
- Searchable options
- Keyboard navigation
- Custom option rendering
- Dynamic option filtering
- Theme integration

**Properties**:
```qml
property var model: []                   // Options array
property int currentIndex: -1            // Selected index
property string currentText: ""          // Selected text
property string placeholderText: "Select..." // Placeholder
property bool searchEnabled: true        // Enable search
```

**Usage Examples**:
```qml
// Theme selector
DankDropdown {
    model: Theme.availableThemeNames
    currentText: Theme.currentThemeName
    onCurrentTextChanged: {
        Theme.switchTheme(currentText)
    }
}

// Icon theme selector
DankDropdown {
    model: SettingsData.availableIconThemes
    currentText: SettingsData.iconTheme
    searchEnabled: true
    onCurrentTextChanged: {
        SettingsData.setIconTheme(currentText)
    }
}
```

## Layout Components

### DankGridView

**Purpose**: Adaptive grid layout with automatic column calculation.

**Key Features**:
- Automatic column calculation based on item size
- Responsive layout
- Scroll support
- Custom item delegates
- Performance optimization

**Properties**:
```qml
property alias model: gridView.model     // Data model
property alias delegate: gridView.delegate // Item delegate
property int cellWidth: 120              // Preferred cell width
property int cellHeight: 120             // Preferred cell height
property int minimumColumns: 1           // Minimum columns
property int maximumColumns: 10          // Maximum columns
```

**Usage Examples**:
```qml
// App grid
DankGridView {
    model: AppSearchService.applications
    cellWidth: 100
    cellHeight: 120
    
    delegate: Item {
        width: cellWidth
        height: cellHeight
        
        DankIcon {
            name: model.icon
            size: 48
            anchors.centerIn: parent
        }
        
        Text {
            text: model.name
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }
}
```

### DankListView

**Purpose**: Scrollable list view with consistent styling.

**Key Features**:
- Smooth scrolling
- Custom item delegates
- Selection support
- Keyboard navigation
- Performance optimization

**Properties**:
```qml
property alias model: listView.model     // Data model
property alias delegate: listView.delegate // Item delegate
property int itemHeight: 48              // Default item height
property bool selectionEnabled: false    // Enable selection
property int currentIndex: -1            // Selected index
```

## Specialized Components

### DankPopout

**Purpose**: Base component for overlay popouts and tooltips.

**Key Features**:
- Automatic positioning
- Backdrop handling
- Animation support
- Focus management
- Theme integration

**Properties**:
```qml
property Item attachedTo: null           // Anchor item
property int preferredPosition: Qt.AlignBottom // Position preference
property bool modal: false               // Modal behavior
property real margins: Theme.spacingM    // Positioning margins
```

### CachingImage

**Purpose**: Optimized image component with caching and loading states.

**Key Features**:
- Automatic caching
- Loading state handling
- Error state handling
- Async loading
- Memory optimization

**Properties**:
```qml
property string source: ""               // Image source URL/path
property bool cache: true                // Enable caching
property bool asynchronous: true         // Async loading
property int sourceSize.width: 0         // Preferred width
property int sourceSize.height: 0        // Preferred height
```

**Usage Examples**:
```qml
// Profile picture
CachingImage {
    source: UserInfoService.profilePicture
    width: 48
    height: 48
    sourceSize.width: 96
    sourceSize.height: 96
    
    Rectangle {
        anchors.fill: parent
        radius: width / 2
        color: "transparent"
        border.color: Theme.outline
        border.width: 1
    }
}

// Weather icon
CachingImage {
    source: WeatherService.currentCondition.icon
    width: Theme.iconSizeLarge
    height: Theme.iconSizeLarge
    cache: true
    asynchronous: true
}
```

## Widget Development Guidelines

### 1. Consistent Theming
All widgets should use Theme properties for colors and styling:

```qml
// Good
color: Theme.surfaceText
backgroundColor: Theme.surface
borderColor: Theme.outline

// Avoid
color: "#ffffff"
backgroundColor: "#1a1c1e"
```

### 2. Responsive Design
Widgets should adapt to different screen sizes and DPI:

```qml
// Use relative sizing
width: Theme.iconSize * 2
height: Theme.barHeight
padding: Theme.spacingM

// Avoid fixed pixel values
width: 48  // Too rigid
```

### 3. Accessibility
Include proper accessibility features:

```qml
// Cursor shapes
MouseArea {
    cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
}

// Keyboard navigation
Keys.onReturnPressed: toggle()
Keys.onSpacePressed: toggle()

// Screen reader support
Accessible.role: Accessible.Button
Accessible.name: "Volume control"
Accessible.description: "Adjust system volume"
```

### 4. Performance Optimization
Optimize for smooth animations and low resource usage:

```qml
// Use Behavior animations for smooth transitions
Behavior on opacity {
    NumberAnimation {
        duration: Theme.shortDuration
        easing.type: Theme.standardEasing
    }
}

// Avoid expensive operations in property bindings
property bool expensiveCalculation: {
    // Cache results when possible
    return calculateOnce()
}
```

### 5. Signal Handling
Use descriptive signal names and provide useful parameters:

```qml
// Good
signal valueChanged(int newValue, int oldValue)
signal selectionChanged(string selectedItem)

// Avoid generic signals
signal changed()
signal clicked()
```

## Custom Widget Development

To create a new widget:

1. **Create Widget File**: Place in `Widgets/` directory
2. **Follow Naming Convention**: Use `Dank` prefix
3. **Implement Base Pattern**: Extend appropriate base component
4. **Add Theme Integration**: Use Theme properties
5. **Include Documentation**: Add usage examples and property descriptions

**Example Custom Widget**:
```qml
// Widgets/DankCustomWidget.qml
import QtQuick
import qs.Common

Item {
    id: customWidget
    
    // Public properties
    property string title: ""
    property bool active: false
    
    // Signals
    signal activated()
    
    // Implementation
    Rectangle {
        anchors.fill: parent
        color: customWidget.active ? Theme.primaryBackground : Theme.surface
        radius: Theme.cornerRadius
        
        StyledText {
            text: customWidget.title
            color: Theme.surfaceText
            anchors.centerIn: parent
        }
        
        MouseArea {
            anchors.fill: parent
            onClicked: {
                customWidget.active = !customWidget.active
                customWidget.activated()
            }
        }
    }
}
```

This widget system provides a comprehensive foundation for building consistent, accessible, and performant UI components within the DankMaterialShell ecosystem.
