# Quickshell Configuration for macOS WhiteSur Status Bar

This Quickshell configuration provides a macOS WhiteSur-themed status bar for Hyprland with the following features:

## Features

### Left Section
- **Arch Logo**: Clickable icon that launches Rofi application launcher
- **Workspace Indicator**: Shows 5 workspaces with:
  - Active workspace highlighted in blue
  - Workspaces with windows shown with blue outline
  - Empty workspaces shown as dots or numbers

### Center Section
- **Clock Widget**: Displays current time and date in macOS style

### Right Section
- **System Tray**: Expandable arrow showing system tray icons in a popup
- **WiFi Icon**: Placeholder for WiFi network selection popup
- **Bluetooth Icon**: Placeholder for Bluetooth device management popup
- **Battery Widget**: Shows battery percentage, charging status, and power mode selection

## Theme Consistency

All components follow the macOS WhiteSur design language:
- **Colors**: Dark background (#1C1C1E) with blue accent (#007AFF)
- **Typography**: JetBrainsMono Nerd Font for icons, system fonts for text
- **Animations**: Smooth 300ms transitions with cubic easing
- **Borders**: 12px radius for modern macOS appearance
- **Transparency**: 98% background opacity with blur effects

## Files Structure

```
quickshell/
├── shell.qml                           # Main shell entry point
└── modules/statusbar/
    ├── qmldir                          # Module definition
    ├── WhiteSurTheme.qml              # Color and styling constants
    ├── StatusBar.qml                  # Main status bar container
    ├── WorkspaceIndicator.qml         # Workspace switcher
    ├── ClockWidget.qml                # Time and date display
    ├── ArchLogo.qml                   # Arch Linux launcher button
    ├── SystemTrayPopup.qml            # System tray with popup
    └── BatteryWidget.qml              # Battery status and power modes
```

## Usage

1. Install Quickshell
2. Copy configuration to `~/.config/quickshell/`
3. Start Quickshell: `quickshell`
4. The status bar will appear on all monitors

## Customization

- **Colors**: Modify `WhiteSurTheme.qml` for color scheme changes
- **Layout**: Adjust spacing and sizing in individual components
- **Icons**: Replace Nerd Font icons in component text properties
- **Functionality**: Extend popup components with actual network/bluetooth management

## Dependencies

- Quickshell
- JetBrainsMono Nerd Font
- Hyprland (for workspace integration)
- System tray support
- UPower (for battery information)

## Integration with Hyprland

Add to your Hyprland autostart configuration:
```
exec-once = quickshell
```

The status bar automatically integrates with Hyprland workspaces and follows the same visual theme as your Hyprland configuration.
