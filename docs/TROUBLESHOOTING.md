# DankMaterialShell Troubleshooting Guide

## Common Issues and Solutions

### Panel/TopBar Not Clickable When Windows Are Open

**Symptoms**: 
- Can click on status bar/panel when workspace is empty
- Cannot click on status bar/panel when windows are present
- Panel appears but doesn't respond to mouse clicks

**Cause**: Missing Wayland layer shell properties in TopBar component

**Solution**: Ensure TopBar.qml has proper layer shell configuration:
```qml
PanelWindow {
    // ... other properties
    
    WlrLayershell.layer: WlrLayershell.Top
    WlrLayershell.exclusiveZone: !SettingsData.topBarVisible || autoHide ? -1 : root.effectiveBarHeight + SettingsData.topBarSpacing - 2 + SettingsData.topBarBottomGap
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
    
    // ... rest of component
}
```

**Why This Happens**: 
- Wayland layer shell protocol determines window stacking and input handling
- Without proper layer configuration, panels can be rendered behind windows
- `WlrLayershell.Top` ensures panel stays above regular windows
- `WlrKeyboardFocus.OnDemand` allows panel to receive input when clicked

**Additional Hyprland Configuration Issue**:
If the layer shell fix doesn't resolve the issue, check your Hyprland configuration for:

```bash
# In theme.conf or hyprland.conf
misc {
    layers_hog_keyboard_focus = false  # Should be false, not true
}
```

**Why**: `layers_hog_keyboard_focus = true` can cause layer shell windows to aggressively grab focus, interfering with proper input handling between the panel and regular windows.

### Random Focus Loss and Window Management Issues

**Symptoms**:
- Mouse cursor on window but window loses focus randomly
- Windows don't stay focused when hovering
- Focus jumps between windows unexpectedly

**Cause**: Aggressive mouse focus settings in Hyprland configuration

**Solution**: Adjust mouse focus behavior in `input.conf`:

```bash
# In input.conf
input {
    follow_mouse = 2          # Focus follows mouse but only for keyboard, not refocus
    mouse_refocus = false     # Don't automatically refocus windows under mouse
    float_switch_override_focus = 0
}
```

**Additional Fix in `theme.conf`**:
```bash
misc {
    mouse_move_focuses_monitor = false  # Prevent focus changes when moving between monitors
}
```

**Focus Behavior Options**:
- `follow_mouse = 0` - No focus follows mouse (click to focus)
- `follow_mouse = 1` - Focus follows mouse cursor (can cause issues)
- `follow_mouse = 2` - Focus follows mouse for keyboard only (recommended)
- `follow_mouse = 3` - Focus follows mouse, but mouse on border doesn't change focus

### UWSM Session Management Conflicts

**Symptoms**:
- Quickshell starts but crashes repeatedly
- Panel appears and disappears (openlayer/closelayer events in logs)
- IPC commands work intermittently

**Cause**: Conflicts between UWSM app management and quickshell autostart

**Solution**: Use direct quickshell launch instead of UWSM for the shell:

```bash
# In autostart.conf - use direct launch
exec-once = sleep 2 && quickshell -p /home/reaper/.config/quickshell

# Instead of:
# exec-once = uwsm app quickshell -p /home/reaper/.config/quickshell
```

**Why**: UWSM is excellent for regular applications but can interfere with desktop shells that need persistent layer shell windows.

### IPC Commands Not Working After Configuration Move

**Symptoms**:
- Keybindings don't trigger shell functions
- `qs -c dms ipc call ...` returns errors
- Features like volume/brightness controls don't work

**Cause**: Configuration moved from `/quickshell/dms/` to `/quickshell/` but commands still reference old path

**Solution**: Update all IPC commands from `qs -c dms` to `qs`:

```bash
# Old (broken)
qs -c dms ipc call spotlight toggle

# New (working)  
qs ipc call spotlight toggle
```

**Files to Check**:
- `~/.config/hypr/keybinds.conf`
- `~/.config/hypr/programs.conf`
- Any custom scripts or keybinding configs

### Wallpaper Cycling Not Working

**Symptoms**:
- Manual wallpaper switching works (`qs ipc call wallpaper next`)
- Automatic wallpaper cycling doesn't happen

**Cause**: Wallpaper cycling is disabled by default

**Solution**: Enable through Settings UI:
1. Open Settings (`Super + ,` or `qs ipc call settings toggle`)
2. Go to **Personalization** tab
3. Find **"Wallpaper Cycling"** section
4. Toggle **ON** the cycling switch
5. Configure mode:
   - **Interval**: Change wallpaper every X seconds
   - **Time**: Change wallpaper at specific time daily

### Missing Icons or Fonts

**Symptoms**:
- Icons appear as squares or missing characters
- Error messages about Material Symbols font

**Solution**: Install required fonts:
```bash
# Arch Linux
sudo pacman -S ttf-material-symbols-rounded

# Or download from Google Fonts
# https://fonts.google.com/icons
```

### Theme/Color Issues

**Symptoms**:
- Colors don't match between applications
- Dynamic theming not working
- GTK/Qt apps don't follow theme

**Cause**: Missing matugen or incorrect theme configuration

**Solution**:
1. **Install matugen**:
   ```bash
   # Check if installed
   which matugen
   
   # Install if missing (Arch)
   yay -S matugen
   ```

2. **Enable system theming**:
   - Open Settings → Theme & Colors
   - Enable "GTK Apps" toggle
   - Enable "Qt Apps" toggle

3. **Configure Qt environment**:
   ```bash
   # Add to your shell profile or Hyprland config
   export QT_QPA_PLATFORMTHEME=qt6ct
   export QT_QPA_PLATFORMTHEME_QT5=qt5ct
   ```

### Multi-Monitor Issues

**Symptoms**:
- Panel appears on wrong monitor
- Duplicate panels or missing panels
- Inconsistent behavior across monitors

**Solution**: Check monitor configuration in Settings:
1. Open Settings → Displays
2. Configure which components appear on which screens
3. Verify monitor names match your Hyprland config

**Debug Monitor Names**:
```bash
# Check Hyprland monitor names
hyprctl monitors

# Check quickshell screen detection
qs ipc call --list-screens  # If this command exists
```

### Performance Issues

**Symptoms**:
- Slow animations or UI lag
- High CPU/memory usage
- Shell feels unresponsive

**Solutions**:

1. **Disable expensive features**:
   - Reduce animation complexity in Settings
   - Disable blur effects if enabled
   - Reduce transparency levels

2. **Check for process issues**:
   ```bash
   # Monitor quickshell resource usage
   top -p $(pgrep quickshell)
   
   # Check for error loops
   journalctl --user -f | grep quickshell
   ```

3. **Restart services**:
   ```bash
   # Restart quickshell
   pkill quickshell
   quickshell -p /home/reaper/.config/quickshell
   ```

### Service Integration Issues

**Symptoms**:
- Audio controls don't work
- Network/Bluetooth toggles don't function
- System information not updating

**Cause**: Missing system dependencies or permissions

**Solutions**:

1. **Audio (PipeWire)**:
   ```bash
   # Check PipeWire status
   systemctl --user status pipewire
   systemctl --user status pipewire-pulse
   ```

2. **Network (NetworkManager)**:
   ```bash
   # Check NetworkManager status
   systemctl status NetworkManager
   
   # Check user permissions
   groups $USER | grep -E "(wheel|network)"
   ```

3. **Bluetooth (BlueZ)**:
   ```bash
   # Check Bluetooth service
   systemctl status bluetooth
   
   # Test bluetoothctl
   bluetoothctl show
   ```

### Configuration File Issues

**Symptoms**:
- Settings don't persist
- Configuration resets on restart
- Error messages about JSON parsing

**Solution**: Check configuration file permissions and syntax:

```bash
# Check settings files
ls -la ~/.config/DankMaterialShell/
cat ~/.config/DankMaterialShell/settings.json | jq .  # Validate JSON

# Reset to defaults if corrupted
rm ~/.config/DankMaterialShell/settings.json
# Quickshell will recreate with defaults
```

### Debug Mode

**Enable Debug Output**:
```bash
# Run quickshell with debug output
QT_LOGGING_RULES="*=true" quickshell -p /home/reaper/.config/quickshell

# Or check logs
tail -f ~/.local/share/quickshell/log.qslog
```

## Prevention Tips

### Regular Maintenance
1. **Keep fonts updated**: Ensure Material Symbols font is current
2. **Monitor system services**: Check that PipeWire, NetworkManager, BlueZ are running
3. **Backup configurations**: Keep backups of working configurations
4. **Test after updates**: Verify functionality after system updates

### Development Best Practices
1. **Test on multiple monitors**: Verify behavior with different monitor configurations
2. **Check layer shell properties**: Ensure all panel components have proper WlrLayershell configuration
3. **Validate IPC commands**: Test IPC functionality after path changes
4. **Monitor resource usage**: Watch for memory leaks or CPU spikes

This troubleshooting guide should help resolve common issues and prevent future problems with the DankMaterialShell configuration.
