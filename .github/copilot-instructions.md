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

This dotfiles setup primarily uses **Quickshell** for desktop widgets and UI components:

- **Widget Library**: Pre-built widgets available in `/illogical-impulse/.config/quickshell/ii/modules/`
- **Reference Implementation**: Use existing widgets (bar, dock, mediaControls, etc.) as templates
- **QML Standards**: Follow Quickshell's QML patterns for consistent widget development
- **Module Structure**: Each widget type has its own module directory with reusable components

### Available Widget Modules
```
modules/
├── bar/              # Top/bottom bars
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
  - Background: `rgba(28, 28, 30, 0.98)` (dark)
  - Accent: `rgba(0, 122, 255, 1.0)` (system blue)
  - Text: `rgba(255, 255, 255, 0.95)` (primary)
- **Animations**: Apply macOS bezier curves (`0.32, 0.97, 0.53, 1.0`)
- **Blur values**: Maintain consistent blur settings (size: 8, passes: 3)
- **Border radius**: Use 12px rounding for modern macOS appearance

## Critical Dependencies

- **Hyprland**: Wayland compositor
- **Quickshell**: Widget system and UI components
- **UWSM**: Session management (optional but recommended)
- **WhiteSur GTK themes**: Visual consistency
- **Rofi**: Application launcher with theme integration
- **Alacritty**: Terminal with font configuration

When adding new applications, ensure they integrate with the UWSM wrapper pattern, follow the macOS-inspired keybinding conventions, and maintain the dark WhiteSur aesthetic.
