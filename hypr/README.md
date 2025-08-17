# Freedom Theme - Hyprland Configuration

A centralized, modular configuration for Hyprland with a beautiful "freedom" theme featuring a cohesive color scheme and organized structure.

## 🎨 Theme Features

- **Freedom Blue** (`#4A90E2`) - Primary accent color
- **Liberty Green** (`#50C878`) - Secondary accent color  
- **Purple Freedom** (`#8A2BE2`) - Tertiary accent color
- **Deep Black** (`#0A0A0A`) - Primary background
- **Smooth animations** with custom bezier curves
- **Modern blur effects** with optimized performance
- **Consistent visual hierarchy** across all elements

## 📁 Configuration Structure

```
hypr/
├── hyprland.conf          # Main configuration file
├── README.md              # This documentation
├── theme/                 # Theme-related configurations
│   ├── colors.conf        # Centralized color scheme
│   ├── decoration.conf    # Window decoration settings
│   └── animations.conf    # Animation configurations
├── system/                # System-level configurations
│   ├── monitors.conf      # Display settings
│   ├── input.conf         # Keyboard/mouse settings
│   └── environment.conf   # Environment variables
└── user/                  # User-specific configurations
    ├── programs.conf      # Application definitions
    ├── autostart.conf     # Startup applications
    ├── keybinds.conf      # Keyboard shortcuts
    └── windowrules.conf   # Window behavior rules
```

## 🚀 Quick Start

1. **Backup your current config:**
   ```bash
   cp ~/.config/hypr/hyprland.conf ~/.config/hypr/hyprland.conf.backup
   ```

2. **Replace with the new structure:**
   The new modular configuration is already in place.

3. **Setup ReGreet (Optional):**
   ```bash
   ~/.config/hypr/scripts/setup_regreet.sh
   ```

4. **Restart Hyprland:**
   Press `Super + M` or restart your session.

5. **UWSM Support:**
   UWSM is detected on your system. See documentation for switching to UWSM session management.

## 🎯 Customization

### Colors
Edit `theme/colors.conf` to modify the color scheme. All colors are defined as variables and used throughout the configuration.

### Keybinds
Modify `user/keybinds.conf` to customize keyboard shortcuts. The file is organized by category for easy navigation.

### Applications
Update `user/programs.conf` to change default applications for terminal, file manager, etc.

### Autostart
Configure startup applications in `user/autostart.conf`.

## 🔧 Advanced Configuration

### Adding New Colors
1. Define the color in `theme/colors.conf`
2. Use it in other configuration files with the `$` prefix

### Creating New Sections
1. Create a new `.conf` file in the appropriate directory
2. Add a `source` statement in `hyprland.conf`
3. Organize related settings in the new file

### Theme Variants
Create multiple color schemes by duplicating `theme/colors.conf` and modifying the variables.

## 📱 Supported Applications

The configuration includes optimized settings for:
- **Terminals:** Alacritty, Kitty, Foot
- **File Managers:** Dolphin, Nautilus, Thunar
- **Browsers:** Firefox, Brave, Chromium
- **Media Players:** Spotify, VLC, MPV
- **Development:** VS Code, JetBrains IDEs

## 🎨 Color Palette Reference

| Purpose | Color | Hex Code |
|---------|-------|----------|
| Primary Accent | Freedom Blue | `#4A90E2` |
| Secondary Accent | Liberty Green | `#50C878` |
| Tertiary Accent | Purple Freedom | `#8A2BE2` |
| Background | Deep Black | `#0A0A0A` |
| Surface | Surface Gray | `#2D2D2D` |
| Text | Light Text | `#E0E0E0` |
| Success | Success Green | `#50C878` |
| Warning | Warning Yellow | `#FFD700` |
| Error | Error Red | `#FF6B6B` |

## 🔄 Updating

To update the configuration:
1. Edit the appropriate `.conf` file
2. Save the changes
3. Restart Hyprland or reload the configuration

## 📚 Additional Resources

- [Hyprland Wiki](https://wiki.hypr.land/)
- [Hyprland Configuration](https://wiki.hypr.land/Configuring/)
- [Wayland Development](https://wayland.freedesktop.org/)

## 🤝 Contributing

Feel free to customize and improve this configuration. The modular structure makes it easy to:
- Add new features
- Modify existing settings
- Create theme variants
- Share configurations

## 🔄 Changelog

### Latest Updates
- ✅ **ReGreet Integration** - Complete greetd/ReGreet setup with Freedom Theme styling
- ✅ **Custom GTK4 CSS** - Beautiful login screen matching the theme colors
- ✅ **Configured monitor setup** - Optimized for 2240x1400@60.02Hz with 1.458 scale
- ✅ **Added multi-monitor support** - Ready-to-use configurations for external displays
- ✅ **Fixed all decoration errors** - Removed deprecated shadow properties (Hyprland 0.50+)
- ✅ **Fixed color format issues** - Converted from `rgba(0x...)` to `rgba(RRGGBBAA)` format
- ✅ **Fixed window rules** - Updated `alwaysontop` to `pin` for current Hyprland
- ✅ **Enhanced blur settings** - Added modern blur optimizations and properties
- ✅ **Fixed keybinds syntax** - Corrected `$mainMod = SUPER` variable syntax
- ✅ **Added UWSM support** - Configuration is now UWSM-ready with setup guide
- ✅ **Zero config errors** - All parsing errors resolved

### Compatibility
- ✅ **Hyprland Latest** - Compatible with current Hyprland variables
- ✅ **UWSM Ready** - Prepared for Universal Wayland Session Manager
- ✅ **Modular Structure** - Easy to maintain and customize

---

**Freedom Theme** - Empowering your desktop experience with style and organization.
