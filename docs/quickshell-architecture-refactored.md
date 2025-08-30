# Quickshell Architecture - Refactored & Clean

## Overview
This document describes the refactored and cleaned Quickshell configuration architecture, following consistent patterns and best practices. The system now implements a macOS-style Control Center with proper state management and Apple Human Interface Guidelines compliance.

## Architecture Overview

### Core Components
```
quickshell/
├── shell.qml                    # Main entry point and state management
├── modules/
│   ├── statusbar/              # Status bar components
│   │   ├── StatusBar.qml       # Main status bar container
│   │   ├── WhiteSurTheme.qml   # Centralized theme system
│   │   ├── WorkspaceIndicator.qml
│   │   ├── ClockWidget.qml
│   │   ├── BatteryWidget.qml
│   │   └── NetworkPopup.qml
│   └── sidebar/                # Control Center components
│       └── CentralSidebar.qml  # Main Control Center panel
```

## Component Architecture

### 1. Shell (shell.qml)
**Purpose**: Main entry point and state coordination
**Pattern**: Centralized state management with component coordination

```qml
ShellRoot {
    // Shared Control Center state
    property bool controlCenterOpen: false

    // Component coordination
    CentralSidebar { isOpen: controlCenterOpen }
    StatusBar { sidebarOpen: controlCenterOpen }

    // Global event handling
    // Keyboard shortcuts, click-outside-to-close
}
```

**Key Features**:
- **Single source of truth** for Control Center state
- **Event coordination** between components
- **Global keyboard shortcuts** (Cmd+Shift+S, Escape)
- **Click-outside-to-close** functionality

### 2. WhiteSurTheme (modules/statusbar/WhiteSurTheme.qml)
**Purpose**: Centralized theming system
**Pattern**: Singleton with Apple HIG compliance

**Color System**:
- **Primary Backgrounds**: System background colors (#0F0F14, #1C1C21, #29292E)
- **Semantic Colors**: System blue (#007AFF), green (#34C759), orange (#FF9500), red (#FF3B30)
- **Interactive States**: Hover, pressed, selected states
- **Control Center Specific**: Dedicated colors for panels, cards, toggles

**Layout System**:
- **8pt Grid System**: Consistent spacing (8, 16, 24, 32px)
- **Component Dimensions**: Standardized sizes for buttons, panels, icons
- **Animation Components**: Reusable animation definitions

### 3. Control Center (modules/sidebar/CentralSidebar.qml)
**Purpose**: Floating control panel for system management
**Pattern**: PanelWindow with visibility-based state management

**Key Features**:
- **Floating Panel**: Right-side positioned, doesn't occupy permanent screen space
- **Visibility Control**: Uses `visible: isOpen` for show/hide
- **Apple HIG Design**: Proper colors, spacing, and interactive states
- **Content Sections**: WiFi, Bluetooth, Quick Actions

**State Management**:
```qml
PanelWindow {
    visible: isOpen  // Key: PanelWindow visibility controls show/hide
    exclusiveZone: 0 // Don't block other windows
}
```

### 4. Status Bar (modules/statusbar/StatusBar.qml)
**Purpose**: Top status bar with system information and controls
**Pattern**: PanelWindow with integrated widgets

**Components**:
- **Sidebar Toggle**: ☰ button for Control Center
- **Workspace Indicator**: 5-workspace switcher
- **Clock Widget**: Time and date display
- **System Widgets**: WiFi, Bluetooth, Volume, Battery
- **Network Popup**: WiFi network management

## State Management Architecture

### Control Center State Flow
```
Status Bar ☰ Button → shell.qml controlCenterOpen → CentralSidebar visible
     ↑                                                      ↓
     ←─────────────── State Synchronization ←───────────────
```

### State Properties
- **`controlCenterOpen`**: Boolean state in shell.qml
- **`isOpen`**: Bound to Control Center component
- **`sidebarOpen`**: Bound to Status Bar component

### Event Handling
1. **Toggle Request**: Status bar emits `sidebarToggleRequested`
2. **State Update**: Shell updates `controlCenterOpen`
3. **Component Sync**: All components automatically update via property binding
4. **Visibility Change**: PanelWindow shows/hides based on state

## Design Principles

### Apple Human Interface Guidelines Compliance
- **Color System**: Official macOS dark mode colors
- **Typography**: Inter font family with proper weights
- **Spacing**: 8pt grid system for consistency
- **Interactive States**: Hover, pressed, selected feedback
- **Materials**: Proper opacity and transparency levels

### Component Design Patterns
- **Single Responsibility**: Each component has one clear purpose
- **Property Binding**: State flows through property bindings
- **Event Delegation**: Events bubble up to shell for coordination
- **Reusable Components**: Animation and styling components

### Performance Considerations
- **Lazy Loading**: Components only created when needed
- **Efficient Binding**: Minimal property updates
- **Animation Optimization**: Hardware-accelerated animations
- **Memory Management**: Proper cleanup of event handlers

## Usage Patterns

### Opening Control Center
1. **Status Bar Button**: Click ☰ button
2. **Keyboard Shortcut**: Cmd+Shift+S
3. **Programmatic**: Set `controlCenterOpen = true`

### Closing Control Center
1. **Toggle Button**: Click ☰ button again
2. **Close Button**: Click ✕ in Control Center header
3. **Keyboard Shortcut**: Press Escape
4. **Click Outside**: Click anywhere outside Control Center
5. **Programmatic**: Set `controlCenterOpen = false`

### Control Center Features
- **WiFi Management**: Toggle switch (placeholder for network list)
- **Bluetooth Management**: Toggle switch (placeholder for device list)
- **Quick Actions**: Settings, Terminal, Files (icon-only with tooltips)

## Code Quality Standards

### QML Best Practices
- **Property Binding**: Use property bindings over imperative updates
- **Component Reuse**: Extract common patterns into reusable components
- **State Management**: Centralize state in parent components
- **Event Handling**: Use signals and slots for component communication

### Architecture Principles
- **Separation of Concerns**: Each component has a single responsibility
- **Dependency Injection**: Components receive dependencies via properties
- **Event-Driven**: State changes flow through events and property bindings
- **Testable**: Components can be tested in isolation

### Documentation Standards
- **Inline Comments**: Explain complex logic and design decisions
- **Property Documentation**: Document all public properties
- **Usage Examples**: Provide practical examples for common use cases
- **Architecture Diagrams**: Visual representation of component relationships

## Future Enhancements

### Planned Features
1. **Real WiFi Integration**: Network scanning and connection management
2. **Bluetooth Device Management**: Device discovery and pairing
3. **Volume Control**: System volume slider with media controls
4. **Brightness Control**: Screen brightness adjustment
5. **Power Management**: Battery status and power modes

### Architecture Improvements
1. **Plugin System**: Extensible Control Center functionality
2. **State Persistence**: Remember user preferences
3. **Multi-Screen Support**: Support for multiple displays
4. **Gesture Support**: Touch and trackpad gestures
5. **Accessibility**: Screen reader and keyboard navigation support

## Troubleshooting

### Common Issues
1. **Control Center not appearing**: Check `controlCenterOpen` state and component binding
2. **State not syncing**: Verify property bindings and signal connections
3. **Performance issues**: Check for unnecessary property updates or animations
4. **Visual glitches**: Verify theme properties and animation settings

### Debug Information
- **Console Logs**: Monitor state changes and event handling
- **Property Inspection**: Check component property values
- **Event Tracing**: Follow event flow through the system
- **Performance Profiling**: Monitor animation and rendering performance

## Conclusion

The refactored Quickshell architecture provides a clean, maintainable, and extensible foundation for the macOS-style Control Center. By following consistent patterns and Apple HIG compliance, the system delivers a professional user experience while maintaining code quality and performance.

The architecture emphasizes:
- **Simplicity**: Clear component responsibilities and state flow
- **Consistency**: Unified theming and interaction patterns
- **Extensibility**: Easy to add new features and components
- **Maintainability**: Clean code structure and documentation

This foundation enables future enhancements while maintaining the current high-quality user experience.
