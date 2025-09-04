# DankMaterialShell Documentation

## Overview

This comprehensive documentation suite provides detailed information about the DankMaterialShell quickshell configuration, designed to help AI LLM models and developers understand the architecture, state management techniques, widget scripts, and customization patterns.

## Documentation Structure

### 📋 Core Documentation

- **[QUICKSHELL_ARCHITECTURE.md](QUICKSHELL_ARCHITECTURE.md)** - Complete architectural overview and design patterns
- **[STATE_MANAGEMENT.md](STATE_MANAGEMENT.md)** - Reactive property binding, singleton services, and state patterns
- **[CUSTOMIZATION_GUIDE.md](CUSTOMIZATION_GUIDE.md)** - Comprehensive guide for extending and customizing the shell

### 🧩 Component References

- **[WIDGETS_REFERENCE.md](WIDGETS_REFERENCE.md)** - All widget components and their usage patterns
- **[SERVICES_REFERENCE.md](SERVICES_REFERENCE.md)** - System services and their interactions
- **[MODALS_REFERENCE.md](MODALS_REFERENCE.md)** - Modal system and overlay components
- **[COMMON_UTILITIES.md](COMMON_UTILITIES.md)** - Shared utilities and helper components

## Quick Navigation

### For AI LLM Models

**Understanding the Codebase**:
1. Start with [QUICKSHELL_ARCHITECTURE.md](QUICKSHELL_ARCHITECTURE.md) for overall system design
2. Review [STATE_MANAGEMENT.md](STATE_MANAGEMENT.md) for data flow patterns
3. Reference component-specific docs for detailed implementation patterns

**Key Architectural Patterns**:
- **Singleton Services**: Global state management with reactive properties
- **Lazy Loading**: Performance optimization with on-demand component loading
- **Property Binding**: Automatic UI updates through reactive data flow
- **Multi-Monitor Support**: Variants pattern for screen-aware deployments

### For Developers

**Getting Started**:
1. Read [QUICKSHELL_ARCHITECTURE.md](QUICKSHELL_ARCHITECTURE.md) for system overview
2. Follow [CUSTOMIZATION_GUIDE.md](CUSTOMIZATION_GUIDE.md) for modification patterns
3. Use component references for specific implementation details

**Common Tasks**:
- **Creating Widgets**: See [WIDGETS_REFERENCE.md](WIDGETS_REFERENCE.md#widget-development-guidelines)
- **Adding Services**: See [SERVICES_REFERENCE.md](SERVICES_REFERENCE.md#adding-new-services)
- **Custom Modals**: See [MODALS_REFERENCE.md](MODALS_REFERENCE.md#modal-development-patterns)
- **Theme Customization**: See [CUSTOMIZATION_GUIDE.md](CUSTOMIZATION_GUIDE.md#theme-customization)

## System Architecture Summary

```
DankMaterialShell/
├── shell.qml                 # Main orchestration (250 lines)
├── Common/                   # Shared utilities (12 files)
│   ├── Theme.qml            # Material Design 3 theming
│   ├── SettingsData.qml     # User preferences
│   ├── SessionData.qml      # Runtime session state
│   └── Appearance.qml       # Design system tokens
├── Services/                 # System integration (22 services)
│   ├── AudioService.qml     # PipeWire audio control
│   ├── NetworkService.qml   # NetworkManager integration
│   ├── BluetoothService.qml # Bluetooth management
│   └── NotificationService.qml # Notification system
├── Modules/                  # UI components (93 files)
│   ├── TopBar/             # Panel components
│   ├── ControlCenter/      # System controls
│   ├── Notifications/      # Notification system
│   └── Settings/           # Configuration interface
├── Widgets/                  # Reusable controls (21 files)
│   ├── DankIcon.qml        # Material Design icons
│   ├── DankSlider.qml      # Enhanced sliders
│   └── DankToggle.qml      # Toggle switches
└── Modals/                   # Full-screen overlays (12 files)
    ├── SettingsModal.qml   # Configuration interface
    ├── SpotlightModal.qml  # Application launcher
    └── ClipboardHistoryModal.qml # Clipboard management
```

## Key Features Documented

### 🎨 Theming System
- **Dynamic Color Extraction**: Wallpaper-based theming with matugen
- **Stock Themes**: Predefined Material Design 3 color schemes  
- **Custom Themes**: JSON-based theme loading and validation
- **System Integration**: Automatic GTK/Qt application theming

### ⚡ Performance Optimizations
- **Lazy Loading**: Components loaded on-demand for faster startup
- **Reference Counting**: Services activated only when needed
- **Property Binding**: Efficient reactive updates without manual UI refresh
- **Debounced Updates**: Intelligent batching of rapid state changes

### 🔧 System Integration
- **Multi-Compositor Support**: Niri and Hyprland compatibility
- **Hardware Abstraction**: Unified APIs for audio, network, bluetooth
- **IPC Commands**: External control via quickshell IPC system
- **Process Management**: Robust system command execution with error handling

### 🎯 Developer Experience
- **Consistent Patterns**: Unified approaches across all components
- **Type Safety**: TypeScript-style type hints and validation
- **Error Handling**: Graceful degradation and capability detection
- **Documentation**: Comprehensive inline and external documentation

## Development Workflow

### 1. Understanding Components
```bash
# Read architectural overview
cat docs/QUICKSHELL_ARCHITECTURE.md

# Understand state management
cat docs/STATE_MANAGEMENT.md

# Review specific component types
cat docs/WIDGETS_REFERENCE.md
cat docs/SERVICES_REFERENCE.md
```

### 2. Making Modifications
```bash
# Test changes
qs -p /path/to/quickshell/config

# Format code
qmlformat -i **/*.qml

# Lint code
qmllint **/*.qml
```

### 3. Creating Extensions
```bash
# Create new widget
touch Widgets/CustomWidget.qml

# Create new service  
touch Services/CustomService.qml

# Create new modal
touch Modals/CustomModal.qml
```

## IPC Command Reference

### Audio Control
```bash
qs ipc call audio setvolume 50
qs ipc call audio increment 5
qs ipc call audio mute
```

### Theme Control
```bash
qs ipc call theme toggle
qs ipc call theme light
qs ipc call theme dark
```

### Modal Control
```bash
qs ipc call spotlight toggle
qs ipc call settings toggle
qs ipc call clipboard toggle
```

### System Control
```bash
qs ipc call wallpaper set "/path/to/image.jpg"
qs ipc call powermenu toggle
qs ipc call lock lock
```

## Configuration Patterns

### Widget Configuration
```qml
// Enable/disable widgets
SettingsData.setShowWeather(true)
SettingsData.setShowMusic(false)

// Reorder widgets
SettingsData.setTopBarLeftWidgets(["launcherButton", "workspaceSwitcher"])
```

### Theme Configuration
```qml
// Switch themes
Theme.switchTheme("blue")
Theme.switchTheme("dynamic")  // Wallpaper-based
Theme.loadCustomThemeFromFile("/path/to/theme.json")
```

### Service Configuration
```qml
// Configure services
NetworkService.setNetworkPreference("wifi")
DisplayService.setBrightness(75)
AudioService.setVolume(50)
```

## Troubleshooting

### Common Issues

1. **Missing Icons**: Install Material Symbols font
2. **No Dynamic Theming**: Install matugen package
3. **Qt Apps Not Themed**: Configure qt5ct/qt6ct with QT_QPA_PLATFORMTHEME
4. **Performance Issues**: Enable lazy loading and check for memory leaks

### Debug Tools

```bash
# Check quickshell logs
qs -p . 2>&1 | grep -E "(ERROR|WARN)"

# Monitor system integration
journalctl -f | grep -E "(NetworkManager|PipeWire|BlueZ)"

# Test IPC commands
qs ipc call --help
```

### Performance Monitoring

```qml
// Enable debug overlays
FeatureFlags.enableDebugOverlay: true
FeatureFlags.enablePerformanceMonitoring: true

// Monitor component lifecycle
Component.onCompleted: console.log("Component created:", objectName)
Component.onDestruction: console.log("Component destroyed:", objectName)
```

## Contributing Guidelines

### Code Style
- Use 4-space indentation
- Follow QML property order: id, properties, signals, functions, children
- Use descriptive variable names and avoid abbreviations
- Add type hints to function parameters
- Include JSDoc-style comments for complex functions

### Architecture Principles
- **Single Responsibility**: Each component has one clear purpose
- **Loose Coupling**: Minimize dependencies between components
- **High Cohesion**: Related functionality grouped together
- **Consistent Patterns**: Follow established architectural patterns
- **Performance First**: Consider performance impact of all changes

### Testing
- Test on multiple screen configurations
- Verify theme switching works correctly
- Test IPC commands functionality
- Check memory usage with long-running sessions
- Validate accessibility features

## Resources

### External Documentation
- [Quickshell Documentation](https://quickshell.org/docs/)
- [Qt QML Documentation](https://doc.qt.io/qt-6/qmlapplications.html)
- [Material Design 3](https://m3.material.io/)
- [Matugen Documentation](https://github.com/InioX/matugen)

### Community
- [Niri Community Discord](https://discord.gg/vT8Sfjy7sx)
- [DankMaterialShell Repository](https://github.com/AvengeMedia/DankMaterialShell)
- [Quickshell Community](https://quickshell.org/community/)

---

This documentation provides a comprehensive foundation for understanding, customizing, and extending the DankMaterialShell desktop environment. Each document builds upon the others to create a complete picture of the system's architecture and capabilities.
