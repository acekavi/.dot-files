# Copilot Instructions: macOS WhiteSur Dotfiles

## Architecture Overview

This is a **modular Linux dotfiles repository** targeting the **macOS WhiteSur aesthetic** on Hyprland/Wayland. The configuration follows a strict separation of concerns:

- **`hypr/hyprland.conf`**: Main entry point that sources all modules via `source =` directives
- **`hypr/config/`**: Functional modules (monitors, input, keybindings, windowrules, autostart)
- **`hypr/themes/`**: Visual styling (currently `macos-whitesur.conf` with iOS-inspired gradients)
- **`hypr/scripts/`**: Utility scripts (wallpaper management, UWSM wrappers, rofi launchers)

## Key Design Patterns

### Modular Configuration Strategy
```bash
# To add new functionality, create a new .conf file in config/ and source it:
source = ~/.config/hypr/config/new-feature.conf
```

### Theme Switching System
Change themes by swapping the source line in `hyprland.conf`:
```bash
source = ~/.config/hypr/themes/macos-whitesur.conf  # Current theme
# source = ~/.config/hypr/themes/new-theme.conf     # New theme
```

### UWSM Wrapper Pattern
All application launches use UWSM wrappers for proper session management:
```bash
$uwsm_wrap = ~/.config/hypr/scripts/uwsm-wrapper.sh
bind = $mainMod, RETURN, exec, $uwsm_wrap alacritty
```

## macOS-Specific Conventions

### Keybinding Philosophy
- `SUPER` key maps to macOS `CMD` key
- `SUPER+Q` = Close window (CMD+W equivalent)
- `SUPER+SHIFT+Q` = Quit Hyprland (CMD+SHIFT+Q equivalent)
- `SUPER+SPACE` = App launcher (Spotlight equivalent)

### Color Palette Standards
- **Active borders**: `rgba(007AFFff) rgba(34C759ff) 45deg` (iOS blue-to-green gradient)
- **Inactive borders**: `rgba(E5E5E7aa)` (macOS window gray)
- **Rofi theme**: Authentic macOS dark colors (`rgba(28, 28, 30, 0.98)` background)

### Animation Curves
Custom bezier curves mimic macOS motion:
```bash
bezier = macOS, 0.32, 0.97, 0.53, 1.0
bezier = overshot, 0.7, 0.6, 0.1, 1.1
```

## Development Workflows

### Configuration Changes
1. Edit specific module in `hypr/config/` or `hypr/themes/`
2. Reload with `hyprctl reload` (no restart needed)
3. Test individual modules by commenting source lines

### Script Development
Scripts in `hypr/scripts/` follow these patterns:
- Bash with error handling and help flags
- Support for `--status` and `--help` arguments
- Sequential/predictable behavior over randomization
- State persistence for consistent user experience

### Theme Development
1. Copy `themes/macos-whitesur.conf` to new file
2. Modify colors, animations, blur settings
3. Update source line in main `hyprland.conf`
4. Use `hyprctl reload` to apply

## Tool Integration

### Rofi Configuration
- Main config in `rofi/config.rasi` with inline theming
- Multiple theme variants in `rofi/themes/`
- macOS-style keyboard navigation (Ctrl+A/E for line navigation)

### Wallpaper System
- `wallpaper-randomizer.sh` with live wallpaper switching via `hyprctl`
- Supports `--status` for debugging
- Auto-updates `hyprpaper.conf` configuration

### Font Conventions
- Primary: `JetBrainsMono Nerd Font` (terminal/code)
- UI: `Inter` family (rofi, general UI)
- DPI setting: `140` in `.Xresources`

## Quickshell Widget System

This dotfiles setup uses **Quickshell** for desktop widgets and the main status bar:

- **Status Bar**: macOS WhiteSur-themed top bar with workspace indicator, clock, and system controls
- **Widget Library**: Pre-built widgets available in `/illogical-impulse/.config/quickshell/ii/modules/`
- **Custom Components**: Purpose-built status bar in `quickshell/modules/statusbar/`
- **Reference Implementation**: Use existing widgets (bar, dock, mediaControls, etc.) as templates
- **QML Standards**: Follow Quickshell's QML patterns for consistent widget development
- **Module Structure**: Each widget type has its own module directory with reusable components

### Qt Layout Guidelines for Quickshell

**Follow Qt Layout Documentation**: https://doc.qt.io/qt-6/qml-qtquick-layouts-layout.html

**Essential Layout Patterns:**
- **Use Layout Properties**: Always use `Layout.fillWidth`, `Layout.fillHeight`, `Layout.alignment` instead of manual positioning
- **Avoid Direct Size Binding**: Never bind to `x`, `y`, `width`, or `height` properties in layouts - use `Layout.preferredWidth`, `Layout.preferredHeight`
- **Implicit Sizing**: Prefer `implicitWidth` and `implicitHeight` over explicit sizing
- **Layout Margins**: Use `Layout.margins`, `Layout.leftMargin`, `Layout.rightMargin` etc. for proper spacing
- **Stretch Factors**: Use `Layout.horizontalStretchFactor` and `Layout.verticalStretchFactor` for proportional sizing

**Layout Structure Standards:**
```qml
RowLayout {
    anchors.fill: parent
    spacing: WhiteSurTheme.spacing

    Item {
        Layout.alignment: Qt.AlignLeft
        Layout.fillHeight: true
        Layout.preferredWidth: 200
        // Content
    }

    Item {
        Layout.fillWidth: true    // Expands to fill available space
        Layout.fillHeight: true
        // Center content
    }

    Item {
        Layout.alignment: Qt.AlignRight
        Layout.fillHeight: true
        Layout.preferredWidth: 150
        // Right content
    }
}
```

**Process Launching Standards:**
- **Primary Method**: `Quickshell.execDetached(["command", "arg1", "arg2"])` for external processes
- **Hyprland Integration**: `Hyprland.dispatch("exec command")` for window manager commands
- **Desktop Apps**: `DesktopEntries.byId("app-id")?.execute()` for desktop applications

**Required Imports:**
```qml
import QtQuick
import QtQuick.Layouts    // For Layout properties
import Quickshell         // For execDetached
import Quickshell.Wayland // For PanelWindow
import Quickshell.Widgets // For DesktopEntries (optional)
```

### Status Bar Architecture
```
quickshell/modules/statusbar/
├── WhiteSurTheme.qml       # Centralized color and styling constants
├── StatusBar.qml           # Main container with RowLayout using Qt Layout properties
├── WorkspaceIndicator.qml  # 5-workspace switcher with activity indicators
├── ClockWidget.qml         # Time and date display
├── ArchLogo.qml           # Rofi launcher button (uses Quickshell.execDetached)
├── SystemTrayPopup.qml    # Expandable system tray
└── BatteryWidget.qml      # Battery status with power mode selection
```

**Layout Implementation Example:**
```qml
RowLayout {
    anchors.fill: background
    spacing: WhiteSurTheme.spacing

    // Left section - fixed width, left-aligned
    Row {
        Layout.alignment: Qt.AlignLeft
        Layout.fillHeight: true
        spacing: WhiteSurTheme.spacing
        // Logo and workspace widgets
    }

    // Center section - expands to fill space
    Item {
        Layout.fillWidth: true
        Layout.fillHeight: true
        // Clock widget centered
    }

    // Right section - fixed width, right-aligned
    Row {
        Layout.alignment: Qt.AlignRight
        Layout.fillHeight: true
        spacing: WhiteSurTheme.spacing
        // System tray and indicators
    }
}
```

### Available Widget Modules (Reference)
```
ii/modules/
├── bar/              # Reference top/bottom bars
├── dock/             # Application dock
├── mediaControls/    # Media player controls
├── notificationPopup/ # Notification system
├── sidebarLeft/      # Left sidebar widgets
├── sidebarRight/     # Right sidebar widgets
└── overview/         # Workspace overview
```

## Configuration Management

### Git Tracking Rules
When making changes to any configuration files:
1. **Always update `.gitignore`** to track new config files
2. Use selective ignoring pattern: ignore everything (`*`), then explicitly track needed configs
3. Follow the existing `.gitignore` structure for consistency

### Documentation Standards
- **All documentation** goes in `.config/docs/` directory
- **Update `.gitignore`** to track documentation files when created
- Use markdown format for consistency
- Include practical examples and troubleshooting sections

### Wallpaper System
- **Sequential cycling**: Wallpapers cycle predictably in alphabetical order
- **Persistent state**: Position stored in `.config/hypr/.wallpaper-index` (ignored by git)
- **Control commands**: Use `wallpaper-control.sh` for all operations
- **No logging**: System operates without log files for simplicity

### Theme Consistency Standards
**Maintain visual coherence across all applications:**
- **Colors**: Use WhiteSur dark theme palette consistently
  - Background: `#1C1C1E` (dark) with 98% opacity
  - Accent: `#007AFF` (system blue)
  - Text Primary: `rgba(255, 255, 255, 0.95)`
  - Success: `#34C759`, Warning: `#FF9500`, Error: `#FF3B30`
- **Animations**: Apply macOS bezier curves (`0.32, 0.97, 0.53, 1.0`) with 300ms duration
- **Blur values**: Maintain consistent blur settings (size: 8, passes: 3)
- **Border radius**: Use 12px rounding for modern macOS appearance
- **Typography**: JetBrainsMono Nerd Font for icons, Inter for UI text

## Critical Dependencies

- **Hyprland**: Wayland compositor
- **Quickshell**: Widget system and UI components
- **UWSM**: Session management (optional but recommended)
- **WhiteSur GTK themes**: Visual consistency
- **Rofi**: Application launcher with theme integration
- **Alacritty**: Terminal with font configuration

When adding new applications, ensure they integrate with the UWSM wrapper pattern, follow the macOS-inspired keybinding conventions, and maintain the dark WhiteSur aesthetic.
