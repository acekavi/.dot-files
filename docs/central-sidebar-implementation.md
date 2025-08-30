# Control Center Implementation

## Overview
The Control Center is a floating control panel positioned on the right side of the screen, designed to provide quick access to system controls and network management. It follows macOS design principles and integrates seamlessly with the status bar.

## Architecture

### Core Components
- **`CentralSidebar.qml`**: Main Control Center component with floating panel design
- **`SidebarManager.qml`**: Singleton managing Control Center state and behavior
- **`shell.qml`**: Integration point with global event handling

### Design Principles
- **Floating Panel**: Right-side positioned, compact design
- **macOS Aesthetic**: Clean, minimal interface with proper spacing
- **Toggle Behavior**: Only visible when activated via status bar button
- **Auto-close**: Closes when clicking outside or pressing Escape

## Component Details

### CentralSidebar.qml
The main Control Center component that renders as a floating panel:

```qml
PanelWindow {
    id: sidebar
    anchors {
        right: true
        top: true
    }

    // Slide animation from right
    x: isOpen ? 0 : sidebarWidth
}
```

**Key Features:**
- **Right-side positioning**: Anchored to right edge of screen
- **Compact dimensions**: 320x480 pixels for focused functionality
- **Slide animation**: Smooth slide-in from right edge
- **Floating design**: Rounded corners with subtle borders

**Content Sections:**
1. **Header**: Control Center title with close button
2. **WiFi Section**: Toggle switch and networks list placeholder
3. **Bluetooth Section**: Toggle switch and devices list placeholder
4. **Quick Actions**: Icon-only buttons for common tasks

### SidebarManager.qml
Singleton managing Control Center state and behavior:

```qml
QtObject {
    property bool isOpen: false
    property bool isAnimating: false

    function toggleSidebar() { /* ... */ }
    function openSidebar() { /* ... */ }
    function closeSidebar() { /* ... */ }
}
```

**Key Functions:**
- **`toggleSidebar()`**: Switches between open/closed states
- **`openSidebar()`**: Opens Control Center with animation
- **`closeSidebar()`**: Closes Control Center with animation
- **`handleKeyPress()`**: Global keyboard shortcuts (Cmd+Shift+S, Escape)

### Integration Points

#### Status Bar Integration
The status bar contains a Control Center toggle button (☰) that calls `SidebarManager.toggleSidebar()`:

```qml
// Control Center Toggle Button
Rectangle {
    onClicked: {
        SidebarManager.toggleSidebar()
    }
}
```

#### Global Event Handling
The shell handles global events for Control Center control:

```qml
// Keyboard shortcuts
Keys.onPressed: (event) => {
    SidebarManager.handleKeyPress(event.key, event.modifiers)
}

// Click outside to close
MouseArea {
    onClicked: (mouse) => {
        if (mouse.x > (parent.width - WhiteSurTheme.sidebarWidth)) {
            SidebarManager.closeSidebar()
        }
    }
}
```

## Design Compliance

### macOS Human Interface Guidelines
- **8pt Grid System**: Consistent spacing using WhiteSurTheme constants
- **Typography**: Inter font family with proper weights and sizes
- **Colors**: WhiteSur theme palette with proper contrast
- **Animations**: Smooth 300ms transitions with easing curves
- **Layout**: Clean, organized sections with proper visual hierarchy

### Visual Design
- **Background**: Semi-transparent with subtle borders
- **Icons**: JetBrainsMono Nerd Font for system icons
- **Buttons**: Hover states with color and scale animations
- **Separators**: Clean lines between sections
- **Spacing**: Consistent margins and padding throughout

## Usage Patterns

### Opening the Control Center
1. **Status Bar Button**: Click the ☰ button in the status bar
2. **Keyboard Shortcut**: Press Cmd+Shift+S
3. **Programmatic**: Call `SidebarManager.openSidebar()`

### Closing the Control Center
1. **Close Button**: Click the ✕ button in the header
2. **Keyboard Shortcut**: Press Escape
3. **Click Outside**: Click anywhere outside the Control Center area
4. **Programmatic**: Call `SidebarManager.closeSidebar()`

### Current Functionality
- **WiFi Management**: Toggle switch (placeholder for network list)
- **Bluetooth Management**: Toggle switch (placeholder for device list)
- **Quick Actions**: Settings, Terminal, Files (icon-only with tooltips)

## Future Enhancements

### WiFi Integration
- **Network Scanning**: Real-time WiFi network discovery
- **Connection Management**: Connect/disconnect from networks
- **Signal Strength**: Visual indicators for network quality
- **Security Status**: WPA/WPA2/WPA3 indicators

### Bluetooth Integration
- **Device Discovery**: Scan for nearby Bluetooth devices
- **Pairing Management**: Connect to and manage paired devices
- **Device Types**: Different icons for headphones, speakers, etc.
- **Battery Status**: Show device battery levels

### Additional Features
- **Volume Control**: System volume slider
- **Brightness Control**: Screen brightness adjustment
- **Power Management**: Battery status and power modes
- **System Info**: CPU, memory, storage usage

## Performance Considerations

### Animation Optimization
- **Hardware Acceleration**: Uses Qt's optimized animation system
- **Duration**: 300ms animations for smooth feel
- **Easing**: Custom bezier curves for macOS-like motion

### Memory Management
- **Lazy Loading**: Components only created when needed
- **Efficient Rendering**: Minimal redraws during animations
- **Resource Cleanup**: Proper disposal of animation objects

## Troubleshooting

### Common Issues
1. **Control Center not appearing**: Check status bar button and SidebarManager state
2. **Animation glitches**: Verify animation duration matches timeout values
3. **Positioning issues**: Ensure proper anchor and dimension properties
4. **Click outside not working**: Check MouseArea z-index and enabled state

### Debug Information
- **Console Logs**: Check for component lifecycle messages
- **State Inspection**: Monitor `SidebarManager.isOpen` property
- **Animation Status**: Check `SidebarManager.isAnimating` property

## Accessibility

### Keyboard Navigation
- **Tab Order**: Logical tab sequence through interactive elements
- **Shortcuts**: Global keyboard shortcuts for main functions
- **Focus Management**: Proper focus indicators and states

### Visual Accessibility
- **High Contrast**: Proper color contrast ratios
- **Icon Labels**: Clear text labels for all interactive elements
- **Size Guidelines**: Adequate touch target sizes (40x40px minimum)

---

*This Control Center implementation provides a clean, focused interface for system control while maintaining the macOS aesthetic and following established design patterns.*
