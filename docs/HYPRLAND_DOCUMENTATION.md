# Hyprland Configuration Documentation

## Overview

This documentation serves as a comprehensive reference for configuring Hyprland in this dotfiles repository. It covers all aspects of Hyprland configuration, theming integration with matugen, and best practices for maintaining a consistent desktop environment.

## Table of Contents

1. [Configuration Structure](#configuration-structure)
2. [Monitor Configuration](#monitor-configuration)
3. [Variables and Settings](#variables-and-settings)
4. [Keybindings](#keybindings)
5. [Window and Workspace Rules](#window-and-workspace-rules)
6. [Theming and Colors](#theming-and-colors)
7. [Matugen Integration](#matugen-integration)
8. [Performance Optimization](#performance-optimization)
9. [Troubleshooting](#troubleshooting)
10. [Reference Links](#reference-links)

## Configuration Structure

### Main Configuration File
- **Location**: `~/.config/hypr/hyprland.conf`
- **Format**: Hyprland configuration syntax
- **Sections**: Monitors, Programs, Autostart, Environment, Look & Feel, Input, Keybindings, Window Rules

### Configuration Splitting
You can split configuration into multiple files using the `source` directive:
```ini
source = ~/.config/hypr/colors.conf
source = ~/.config/hypr/keybinds.conf
source = ~/.config/hypr/rules.conf
```

## Monitor Configuration

### Basic Monitor Setup
```ini
monitor = name, resolution, position, scale
```

### Examples
```ini
# Single monitor
monitor = eDP-1, 2240x1400@60, auto, 1.46

# Dual monitor setup
monitor = DP-1, 1920x1080@144, 0x0, 1
monitor = DP-2, 1920x1080@60, 1920x0, 1

# Disable a monitor
monitor = HDMI-A-1, disable
```

### Advanced Monitor Options
```ini
# With transform (rotation)
monitor = eDP-1, 2880x1800@90, 0x0, 1, transform, 1

# With mirroring
monitor = DP-3, 1920x1080@60, 0x0, 1, mirror, DP-2

# With 10-bit support
monitor = eDP-1, 2880x1800@90, 0x0, 1, bitdepth, 10

# With HDR
monitor = eDP-1, 2880x1800@90, 0x0, 1, bitdepth, 10, cm, hdr

# With VRR (Variable Refresh Rate)
monitor = DP-1, 1920x1080@144, 0x0, 1, vrr, 1
```

### Monitor Commands
```bash
# List all monitors
hyprctl monitors all

# Get current monitor info
hyprctl monitors
```

## Variables and Settings

### General Settings
```ini
general {
    gaps_in = 5                    # Inner gaps between windows
    gaps_out = 20                  # Outer gaps around workspace edges
    border_size = 2                # Window border thickness
    col.active_border = rgba(33ccffee) rgba(00ff99ee) 45deg
    col.inactive_border = rgba(595959aa)
    resize_on_border = false       # Resize by dragging borders
    allow_tearing = false          # Screen tearing for gaming
    layout = dwindle              # Layout algorithm (dwindle/master)
}
```

### Decoration Settings
```ini
decoration {
    rounding = 10                  # Window corner rounding
    rounding_power = 2             # Rounding curve intensity
    
    active_opacity = 1.0           # Opacity for focused windows
    inactive_opacity = 1.0         # Opacity for unfocused windows
    
    shadow {
        enabled = true
        range = 4                  # Shadow blur radius
        render_power = 3           # Shadow intensity
        color = rgba(1a1a1aee)     # Shadow color
    }
    
    blur {
        enabled = true
        size = 3                   # Blur radius
        passes = 1                 # Blur passes (more = better quality, worse performance)
        vibrancy = 0.1696         # Blur vibrancy
        noise = 0.0117            # Blur noise
        contrast = 0.8916         # Blur contrast
        brightness = 0.8172       # Blur brightness
    }
}
```

### Animation Settings
```ini
animations {
    enabled = yes
    
    # Define bezier curves
    bezier = easeOutQuint, 0.23, 1, 0.32, 1
    bezier = easeInOutCubic, 0.65, 0.05, 0.36, 1
    bezier = linear, 0, 0, 1, 1
    
    # Apply animations
    animation = windows, 1, 4.79, easeOutQuint
    animation = windowsIn, 1, 4.1, easeOutQuint, popin 87%
    animation = windowsOut, 1, 1.49, linear, popin 87%
    animation = fade, 1, 3.03, quick
    animation = workspaces, 1, 1.94, almostLinear, fade
}
```

### Input Settings
```ini
input {
    kb_layout = us                 # Keyboard layout
    kb_variant =                   # Keyboard variant
    kb_model =                     # Keyboard model
    kb_options =                   # Keyboard options
    kb_rules =                     # Keyboard rules
    
    follow_mouse = 1               # Focus follows mouse (0/1/2/3)
    sensitivity = 0                # Mouse sensitivity (-1.0 to 1.0)
    
    touchpad {
        natural_scroll = false     # Natural scrolling
        disable_while_typing = true
        tap-to-click = true
        drag_lock = false
    }
}
```

### Gesture Settings
```ini
gestures {
    workspace_swipe = false        # Enable workspace swiping
    workspace_swipe_fingers = 3    # Fingers for workspace swipe
    workspace_swipe_distance = 300 # Swipe distance threshold
    workspace_swipe_invert = true  # Invert swipe direction
}
```

### Layout Settings

#### Dwindle Layout
```ini
dwindle {
    pseudotile = true              # Enable pseudotiling
    preserve_split = true          # Keep split ratios
    smart_split = false            # Smart splitting
    smart_resizing = true          # Smart resizing
    force_split = 0               # Force split direction (0/1/2)
    split_width_multiplier = 1.0   # Split width ratio
    no_gaps_when_only = false     # Disable gaps for single window
}
```

#### Master Layout
```ini
master {
    new_status = master           # New window status (master/slave)
    new_on_top = false           # New windows on top
    no_gaps_when_only = false    # Disable gaps for single window
    orientation = left           # Master area orientation
    inherit_fullscreen = true    # Inherit fullscreen from master
    always_center_master = false # Always center master window
    smart_resizing = true        # Smart resizing
    drop_at_cursor = true        # Drop windows at cursor
}
```

### Miscellaneous Settings
```ini
misc {
    force_default_wallpaper = -1   # Default wallpaper (-1/0/1/2)
    disable_hyprland_logo = false  # Disable Hyprland logo
    disable_splash_rendering = false # Disable splash screen
    mouse_move_enables_dpms = true  # Mouse movement enables DPMS
    key_press_enables_dpms = false  # Key press enables DPMS
    always_follow_on_dnd = true     # Follow drag and drop
    layers_hog_keyboard_focus = true # Layers hog keyboard focus
    animate_manual_resizes = false  # Animate manual resizes
    disable_autoreload = false      # Disable auto config reload
    enable_swallow = false          # Enable window swallowing
    swallow_regex = ^(kitty)$      # Swallow regex pattern
    focus_on_activate = false       # Focus on window activation
    no_direct_scanout = true        # Disable direct scanout
    hide_cursor_on_touch = true     # Hide cursor on touch
    mouse_move_focuses_monitor = true # Mouse movement focuses monitor
    render_ahead_of_time = false    # Render ahead of time
    render_ahead_safezone = 1       # Render ahead safezone
    cursor_zoom_factor = 1.0        # Cursor zoom factor
    cursor_zoom_rigid = false       # Rigid cursor zoom
    allow_session_lock_restore = false # Allow session lock restore
    background_color = 0x111111     # Background color
    close_special_on_empty = true   # Close special workspace when empty
    new_window_takes_focus = true   # New windows take focus
    resize_on_border = false        # Resize windows on border
    extend_border_grab_area = 15    # Extend border grab area
    hover_icon_on_border = true     # Show hover icon on border
}
```

## Keybindings

### Basic Syntax
```ini
bind = MODIFIERS, KEY, DISPATCHER, PARAMS
bindm = MODIFIERS, MOUSE_BUTTON, DISPATCHER, PARAMS
bindl = MODIFIERS, KEY, DISPATCHER, PARAMS  # Locked (works when locked)
binde = MODIFIERS, KEY, DISPATCHER, PARAMS  # Repeat when held
bindr = MODIFIERS, KEY, DISPATCHER, PARAMS  # Release bind
```

### Modifiers
- `SUPER` (Windows key)
- `ALT`
- `CTRL`
- `SHIFT`
- Combinations: `SUPER SHIFT`, `CTRL ALT`, etc.

### Common Dispatchers
```ini
# Window management
bind = SUPER, Q, exec, alacritty           # Execute program
bind = SUPER, C, killactive,               # Close active window
bind = SUPER, V, togglefloating,           # Toggle floating
bind = SUPER, F, fullscreen,               # Toggle fullscreen
bind = SUPER, P, pseudo,                   # Pseudotile (dwindle)
bind = SUPER, J, togglesplit,              # Toggle split (dwindle)

# Focus movement
bind = SUPER, left, movefocus, l           # Move focus left
bind = SUPER, right, movefocus, r          # Move focus right
bind = SUPER, up, movefocus, u             # Move focus up
bind = SUPER, down, movefocus, d           # Move focus down

# Window movement
bind = SUPER SHIFT, left, movewindow, l    # Move window left
bind = SUPER SHIFT, right, movewindow, r   # Move window right
bind = SUPER SHIFT, up, movewindow, u      # Move window up
bind = SUPER SHIFT, down, movewindow, d    # Move window down

# Workspace switching
bind = SUPER, 1, workspace, 1              # Switch to workspace 1
bind = SUPER, 2, workspace, 2              # Switch to workspace 2
# ... etc for 3-10

# Move to workspace
bind = SUPER SHIFT, 1, movetoworkspace, 1  # Move window to workspace 1
bind = SUPER SHIFT, 2, movetoworkspace, 2  # Move window to workspace 2
# ... etc for 3-10

# Special workspaces (scratchpad)
bind = SUPER, S, togglespecialworkspace, magic
bind = SUPER SHIFT, S, movetoworkspace, special:magic

# Mouse bindings
bindm = SUPER, mouse:272, movewindow       # Move window with mouse
bindm = SUPER, mouse:273, resizewindow     # Resize window with mouse

# Scroll through workspaces
bind = SUPER, mouse_down, workspace, e+1   # Next workspace
bind = SUPER, mouse_up, workspace, e-1     # Previous workspace
```

### Function Keys and Media Keys
```ini
# Volume controls
bindl = , XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+
bindl = , XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
bindl = , XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
bindl = , XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle

# Brightness controls
bindl = , XF86MonBrightnessUp, exec, brightnessctl set 10%+
bindl = , XF86MonBrightnessDown, exec, brightnessctl set 10%-

# Media controls
bindl = , XF86AudioPlay, exec, playerctl play-pause
bindl = , XF86AudioNext, exec, playerctl next
bindl = , XF86AudioPrev, exec, playerctl previous
```

## Window and Workspace Rules

### Window Rules
```ini
# Basic window rules
windowrule = float, ^(pavucontrol)$        # Float pavucontrol
windowrule = size 800 600, ^(pavucontrol)$ # Set size
windowrule = center, ^(pavucontrol)$       # Center window
windowrule = opacity 0.8, ^(kitty)$        # Set opacity

# Window rules v2 (more flexible)
windowrulev2 = float, class:^(pavucontrol)$
windowrulev2 = size 800 600, class:^(pavucontrol)$
windowrulev2 = center, class:^(pavucontrol)$
windowrulev2 = opacity 0.8, class:^(kitty)$

# Conditional rules
windowrulev2 = float, class:^(firefox)$, title:^(Picture-in-Picture)$
windowrulev2 = pin, class:^(firefox)$, title:^(Picture-in-Picture)$
windowrulev2 = size 25% 25%, class:^(firefox)$, title:^(Picture-in-Picture)$

# Workspace-specific rules
windowrulev2 = workspace 2, class:^(firefox)$
windowrulev2 = workspace 3, class:^(code)$
windowrulev2 = workspace 4, class:^(discord)$

# Gaming rules
windowrulev2 = immediate, class:^(steam_app_).*
windowrulev2 = fullscreen, class:^(steam_app_).*
```

### Available Window Rule Properties
- `float` - Make window floating
- `tile` - Force window to tile
- `fullscreen` - Make window fullscreen
- `maximize` - Maximize window
- `pin` - Pin window (always on top)
- `size W H` - Set window size
- `minsize W H` - Set minimum size
- `maxsize W H` - Set maximum size
- `center` - Center window
- `move X Y` - Move window to position
- `workspace N` - Send to workspace
- `opacity VALUE` - Set opacity (0.0-1.0)
- `animation STYLE` - Override animation
- `rounding N` - Override rounding
- `bordersize N` - Override border size
- `bordercolor COLOR` - Override border color
- `noblur` - Disable blur for window
- `noshadow` - Disable shadow for window
- `nofocus` - Don't focus window
- `noinitialfocus` - Don't focus on creation
- `suppressevent EVENT` - Suppress events

### Workspace Rules
```ini
# Basic workspace rules
workspace = 1, monitor:DP-1                # Bind workspace to monitor
workspace = 2, default:true               # Default workspace
workspace = 3, gapsin:0, gapsout:0        # No gaps workspace

# Smart gaps (no gaps when only one window)
workspace = w[tv1], gapsout:0, gapsin:0
workspace = f[1], gapsout:0, gapsin:0

# Persistent workspaces
workspace = 1, persistent:true
workspace = 2, persistent:true

# Special workspace rules
workspace = special:magic, on-created-empty:kitty
```

## Theming and Colors

### Color Format
Hyprland supports multiple color formats:
- `rgb(255, 255, 255)` - RGB values
- `rgba(255, 255, 255, 0.5)` - RGBA with alpha
- `0xffffff` - Hexadecimal
- `rgba(33ccffee)` - Hex with alpha

### Border Colors
```ini
general {
    # Single color
    col.active_border = rgba(33ccffee)
    col.inactive_border = rgba(595959aa)
    
    # Gradient (angle in degrees)
    col.active_border = rgba(33ccffee) rgba(00ff99ee) 45deg
    
    # Multiple colors
    col.active_border = rgba(ff0000ff) rgba(00ff00ff) rgba(0000ffff) 45deg
}
```

### Shadow Colors
```ini
decoration {
    shadow {
        color = rgba(1a1a1aee)     # Shadow color
        color_inactive = rgba(1a1a1a77) # Inactive shadow color
    }
}
```

## Matugen Integration

### Overview
This dotfiles setup uses matugen for dynamic color theming. Matugen generates color palettes from wallpapers or base colors and applies them across the desktop environment.

### Matugen Structure
```
~/.config/quickshell/dms/matugen/
├── configs/           # Configuration files for different applications
├── templates/         # Template files for color generation
└── dank16.py         # Custom 16-color palette generator
```

### Color Generation Workflow
1. **Base Color Selection**: Choose a primary color or extract from wallpaper
2. **Palette Generation**: Use `dank16.py` to generate 16-color palette
3. **Template Processing**: Apply colors to application templates
4. **Configuration Update**: Update application configs with new colors

### Using dank16.py
```bash
# Generate dark palette from hex color
python3 dank16.py "#3b82f6"

# Generate light palette
python3 dank16.py "#3b82f6" --light

# Honor specific primary color
python3 dank16.py "#3b82f6" --honor-primary "#ff6b6b"

# Custom background color
python3 dank16.py "#3b82f6" --background "#1a1a1a"

# Kitty format output
python3 dank16.py "#3b82f6" --kitty
```

### Matugen Configuration
The `base.toml` file defines template mappings:
```toml
[templates.gtk3]
input_path = './matugen/templates/gtk-colors.css'
output_path = '~/.config/gtk-3.0/dank-colors.css'

[templates.gtk4]
input_path = './matugen/templates/gtk-colors.css'
output_path = '~/.config/gtk-4.0/dank-colors.css'
```

### Integrating Colors with Hyprland
To use matugen colors in Hyprland:

1. **Generate Color File**: Create a Hyprland color template
2. **Source in Config**: Include the generated colors
3. **Apply to Variables**: Use colors in border, shadow, etc.

Example template (`hyprland-colors.conf.template`):
```ini
# Hyprland Colors - Generated by Matugen
$primary = {{colors.primary.default.hex}}
$surface = {{colors.surface.default.hex}}
$on_surface = {{colors.on_surface.default.hex}}
$outline = {{colors.outline.default.hex}}

general {
    col.active_border = rgba({{colors.primary.default.hex}}ee)
    col.inactive_border = rgba({{colors.outline.default.hex}}aa)
}

decoration {
    shadow {
        color = rgba({{colors.shadow.default.hex}}ee)
    }
}
```

## Performance Optimization

### GPU Acceleration
```ini
# Enable GPU acceleration
render {
    explicit_sync = 2              # Explicit sync mode
    explicit_sync_kms = 2          # KMS explicit sync
    direct_scanout = true          # Direct scanout
}

# NVIDIA-specific settings
env = LIBVA_DRIVER_NAME,nvidia
env = XDG_SESSION_TYPE,wayland
env = GBM_BACKEND,nvidia-drm
env = __GLX_VENDOR_LIBRARY_NAME,nvidia
env = WLR_NO_HARDWARE_CURSORS,1
```

### Animation Performance
```ini
animations {
    # Reduce animation complexity for better performance
    enabled = yes
    
    # Use simpler bezier curves
    bezier = simple, 0.25, 0.46, 0.45, 0.94
    
    # Reduce animation duration
    animation = windows, 1, 2, simple
    animation = fade, 1, 2, simple
    animation = workspaces, 1, 2, simple
}
```

### Blur Performance
```ini
decoration {
    blur {
        enabled = true
        size = 3                   # Lower size for better performance
        passes = 1                 # Single pass for speed
        new_optimizations = true   # Enable new optimizations
        xray = false              # Disable xray (expensive)
        ignore_opacity = false     # Don't ignore opacity
    }
}
```

### Memory Management
```ini
misc {
    vfr = true                    # Variable refresh rate
    vrr = 1                       # Variable refresh rate mode
    render_ahead_of_time = false  # Don't pre-render
    render_ahead_safezone = 1     # Minimal safezone
}
```

## Troubleshooting

### Common Issues

#### 1. Monitor Not Detected
```bash
# Check available monitors
hyprctl monitors all

# Force monitor detection
hyprctl reload
```

#### 2. Applications Not Starting
```bash
# Check if application exists
which application_name

# Check logs
journalctl -f --user-unit=hyprland

# Test application manually
application_name &
```

#### 3. Performance Issues
```bash
# Check GPU usage
nvidia-smi  # For NVIDIA
radeontop   # For AMD

# Monitor system resources
htop
```

#### 4. Keybindings Not Working
```bash
# Check current bindings
hyprctl binds

# Test binding manually
hyprctl dispatch exec kitty
```

#### 5. Window Rules Not Applied
```bash
# Get window class and title
hyprctl activewindow

# List all windows
hyprctl clients
```

### Debug Commands
```bash
# Reload configuration
hyprctl reload

# Get current config
hyprctl getoption general:gaps_in

# Set option temporarily
hyprctl keyword general:gaps_in 10

# Get system info
hyprctl systeminfo

# Monitor events
hyprctl --batch "dispatch exec kitty; dispatch workspace 2"
```

### Log Files
- **Hyprland Log**: `~/.local/share/hyprland/hyprland.log`
- **Crash Logs**: `~/.local/share/hyprland/crash_reports/`
- **System Logs**: `journalctl -u hyprland`

## Environment Variables

### Wayland Variables
```bash
# Core Wayland
export XDG_SESSION_TYPE=wayland
export XDG_CURRENT_DESKTOP=Hyprland
export XDG_SESSION_DESKTOP=Hyprland

# Qt Applications
export QT_QPA_PLATFORM=wayland
export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
export QT_AUTO_SCREEN_SCALE_FACTOR=1

# GTK Applications
export GDK_BACKEND=wayland
export GTK_USE_PORTAL=1

# Firefox
export MOZ_ENABLE_WAYLAND=1

# Java Applications
export _JAVA_AWT_WM_NONREPARENTING=1

# SDL Applications
export SDL_VIDEODRIVER=wayland

# Electron Applications
export ELECTRON_OZONE_PLATFORM_HINT=wayland
```

### NVIDIA Variables
```bash
export LIBVA_DRIVER_NAME=nvidia
export GBM_BACKEND=nvidia-drm
export __GLX_VENDOR_LIBRARY_NAME=nvidia
export WLR_NO_HARDWARE_CURSORS=1
export WLR_RENDERER_ALLOW_SOFTWARE=1
```

### Performance Variables
```bash
export WLR_DRM_NO_ATOMIC=1        # Disable atomic modesetting
export WLR_USE_LIBINPUT=1         # Use libinput
export XCURSOR_SIZE=24            # Cursor size
export XCURSOR_THEME=Adwaita      # Cursor theme
```

## Best Practices

### 1. Configuration Organization
- Split large configs into multiple files
- Use meaningful variable names
- Comment complex configurations
- Keep backups of working configurations

### 2. Performance Considerations
- Test animations on your hardware
- Adjust blur settings based on GPU capability
- Use appropriate monitor refresh rates
- Monitor system resources

### 3. Theming Consistency
- Use matugen for consistent color schemes
- Test themes in different lighting conditions
- Ensure sufficient contrast for accessibility
- Document color customizations

### 4. Maintenance
- Regularly update Hyprland and dependencies
- Test configurations after updates
- Keep documentation up to date
- Monitor for deprecated options

### 5. Debugging Workflow
1. Check logs for errors
2. Test minimal configuration
3. Add features incrementally
4. Use hyprctl for live testing
5. Document working solutions

## Reference Links

### Official Documentation
- [Hyprland Wiki](https://wiki.hypr.land/)
- [Configuration Overview](https://wiki.hypr.land/Configuring/)
- [Variables Reference](https://wiki.hypr.land/Configuring/Variables/)
- [Keybindings Guide](https://wiki.hypr.land/Configuring/Binds/)
- [Window Rules](https://wiki.hypr.land/Configuring/Window-Rules/)
- [Workspace Rules](https://wiki.hypr.land/Configuring/Workspace-Rules/)
- [Animations](https://wiki.hypr.land/Configuring/Animations/)
- [Monitor Configuration](https://wiki.hypr.land/Configuring/Monitors/)

### Community Resources
- [Hyprland GitHub](https://github.com/hyprwm/Hyprland)
- [Community Configurations](https://github.com/hyprwm/Hyprland/discussions/categories/configuration)
- [r/hyprland](https://reddit.com/r/hyprland)

### Related Tools
- [Matugen](https://github.com/InioX/matugen) - Material Design color generation
- [Waybar](https://github.com/Alexays/Waybar) - Status bar
- [Rofi](https://github.com/davatorium/rofi) - Application launcher
- [Dunst](https://github.com/dunst-project/dunst) - Notification daemon

---

*This documentation is maintained as part of the dotfiles repository. Update it when making significant configuration changes.*
