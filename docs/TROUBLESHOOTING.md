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
