# macOS Theme Guide for Quickshell

This guide explains how to use and customize the macOS theme for your Quickshell configuration.

## Overview

The macOS theme transforms your Quickshell desktop environment to mimic the look and feel of macOS, including:
- Apple design system colors (both light and dark modes)
- macOS-style translucent panels and dock
- Adjusted animations and hover effects
- macOS UI conventions and layouts

## Quick Start

### Switching to macOS Theme
```bash
~/.config/quickshell/scripts/switch-theme.sh macos
```

### Switching back to Material Theme
```bash
~/.config/quickshell/scripts/switch-theme.sh material
```

## What Changes with macOS Theme

### 1. **Color Palette**
- Primary blue: `#007AFF` (light) / `#0A84FF` (dark)
- Surface colors match macOS system grays
- Accent colors follow Apple's system colors
- Translucent backgrounds for panels

### 2. **Top Bar**
- Height: 30px (vs 48px in Material)
- No rounded corners or margins
- Translucent background (72% opacity)
- Subtle white border (10% opacity)
- No shadow effects

### 3. **Dock**
- Larger icons: 48px (vs 40px)
- More rounded corners: 16px radius
- Translucent background (60% opacity)
- Bottom margin: 4px
- macOS-style hover animations

### 4. **UI Elements**
- Smaller corner radius: 6px for buttons
- Adjusted hover states (10% vs 8% opacity)
- Press states (15% vs 12% opacity)
- macOS font sizing (11/13/15/17px)

### 5. **Hyprland Configuration**
- Window corner radius: 10px
- Enhanced blur effects (size 20, 2 passes)
- Softer shadows with vertical offset
- macOS-style animations (popin effect)
- Natural scrolling enabled
- Three-finger workspace swipe gestures

## Customization

### Modifying Colors

Edit `~/.config/quickshell/Common/ThemeMac.qml`:

```qml
readonly property var macOSColors: {
    if (isLightMode) {
        return {
            primary: "#007AFF",      // Change primary color
            surface: "#F5F5F7",      // Change background color
            // ... other colors
        }
    } else {
        return {
            primary: "#0A84FF",      // Dark mode primary
            surface: "#1C1C1E",      // Dark mode background
            // ... other colors
        }
    }
}
```

### Adjusting Panel Transparency

In `ThemeMac.qml`:
```qml
property real panelTransparency: 0.72    // Top bar opacity
property real widgetTransparency: 0.75   // Widget opacity
property real popupTransparency: 0.88    // Popup opacity
```

### Changing Dock Appearance

Edit `~/.config/quickshell/Modules/Dock/Dock.qml`:
```qml
// Adjust dock transparency
color: Theme.isMacTheme ? Qt.rgba(Theme.surface.r,
                                  Theme.surface.g,
                                  Theme.surface.b, 0.6)  // Change 0.6 for opacity
```

## File Structure

```
~/.config/quickshell/
├── Common/
│   ├── Theme.qml          # Active theme (copy of selected theme)
│   ├── ThemeMac.qml       # macOS theme definition
│   └── ThemeMaterial.qml  # Material theme definition
├── scripts/
│   ├── switch-theme.sh    # Master theme switcher
│   ├── apply-macos-theme.sh
│   └── apply-material-theme.sh
└── Modules/
    ├── TopBar/TopBar.qml  # Modified for macOS styling
    └── Dock/Dock.qml      # Modified for macOS styling
```

## Dynamic Theming

The macOS theme supports dynamic color extraction from wallpapers:
1. Set theme to "dynamic" in Quickshell settings
2. Colors will be extracted using matugen
3. macOS color values are used as fallbacks

## Troubleshooting

### Theme not applying correctly
1. Ensure all files were created correctly
2. Check quickshell logs: `journalctl --user -xe | grep quickshell`
3. Manually restart: `pkill quickshell && quickshell -p ~/.config/quickshell`

### Missing fonts
Install SF Pro fonts or the theme will fall back to Inter/Helvetica Neue.

### Performance issues
If blur is too heavy, reduce in `theme-macos.conf`:
```bash
blur {
    size = 10  # Reduce from 20
    passes = 1  # Reduce from 2
}
```

## Integration with System

### GTK Applications
The theme automatically applies to GTK apps if matugen is available.

### Qt Applications
Qt apps will follow the theme if qt5ct/qt6ct is configured.

### Icon Theme
For best results, install Big Sur or WhiteSur icon themes:
```bash
yay -S whitesur-icon-theme
```

## Known Limitations

1. Some Material Design specific features may look different
2. Window decorations are controlled by Hyprland, not Quickshell
3. True macOS window controls require additional configuration

## Tips

1. **Enable Dock**: Go to Quickshell settings and enable the dock
2. **Adjust gaps**: Modify `gaps_in` and `gaps_out` in `theme-macos.conf`
3. **Disable animations**: Set `animations { enabled = no }` in Hyprland config
4. **Custom keybindings**: Add macOS-style shortcuts in `~/.config/hypr/keybinds.conf`
