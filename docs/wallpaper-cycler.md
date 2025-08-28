# Wallpaper Cycler Documentation

## Overview
The Hyprland Wallpaper Cycler provides predictable, sequential wallpaper switching for your desktop environment. Unlike random selection, this system ensures every wallpaper is displayed equally and in a consistent order.

## Features
- **Sequential cycling**: Wallpapers are displayed in alphabetical order
- **Predictable behavior**: No wallpaper is skipped or repeated until the full cycle completes
- **Persistent state**: Remembers position in the cycle across system restarts
- **Easy control**: Simple commands for manual cycling and status checking

## Files Structure
```
~/.config/hypr/
├── scripts/
│   ├── wallpaper-randomizer.sh    # Main cycler script (renamed for compatibility)
│   └── wallpaper-control.sh       # Control interface
├── hyprpaper.conf                 # Generated wallpaper configuration
└── .wallpaper-index               # Current position in cycle

~/.config/systemd/user/
├── wallpaper-randomizer.service   # Systemd service
└── wallpaper-randomizer.timer     # Systemd timer (5-minute intervals)

~/Pictures/Wallpapers/             # Wallpaper directory
```

## Usage

### Manual Control
```bash
# Change to next wallpaper
~/.config/hypr/scripts/wallpaper-control.sh next

# Show current status
~/.config/hypr/scripts/wallpaper-control.sh status

# Reset cycle to beginning
~/.config/hypr/scripts/wallpaper-control.sh reset

# Start automatic timer
~/.config/hypr/scripts/wallpaper-control.sh start

# Stop automatic timer
~/.config/hypr/scripts/wallpaper-control.sh stop
```

### Automatic Timer
The systemd timer automatically cycles wallpapers every 5 minutes:
```bash
# Enable timer to start on boot
systemctl --user enable wallpaper-randomizer.timer

# Start timer now
systemctl --user start wallpaper-randomizer.timer

# Check timer status
systemctl --user status wallpaper-randomizer.timer
```

## Technical Details

### Cycle Logic
1. Script scans `~/Pictures/Wallpapers/` for image files (jpg, jpeg, png, bmp, webp)
2. Files are sorted alphabetically for consistent ordering
3. Current position is stored in `~/.config/hypr/.wallpaper-index`
4. Each run advances to the next wallpaper in sequence
5. At the end of the list, cycle restarts from the beginning

### Supported Formats
- JPEG (.jpg, .jpeg)
- PNG (.png)
- BMP (.bmp)
- WebP (.webp)

### Performance
- Live wallpaper switching via `hyprctl` (no restart required)
- Fallback to config update + hyprpaper restart if live switching fails
- Minimal system impact with efficient file scanning

## Troubleshooting

### Common Issues
- **No wallpapers found**: Ensure `~/Pictures/Wallpapers/` exists and contains supported image files
- **Wallpaper not changing**: Check if hyprpaper is running with `pgrep hyprpaper`
- **Timer not working**: Verify timer status with `systemctl --user status wallpaper-randomizer.timer`

### Reset Cycle
If the cycle seems stuck or you want to start over:
```bash
~/.config/hypr/scripts/wallpaper-control.sh reset
```

This resets the index to 0, starting from the first wallpaper alphabetically.
