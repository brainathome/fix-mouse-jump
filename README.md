# fix-mouse-jump

**DPI-aware mouse transition fix for multi-monitor setups on Linux/X11.**

Eliminates the "mouse jump" when moving the cursor between monitors with different resolutions or DPI values. This is the Linux equivalent of [LittleBigMouse](https://github.com/mgth/LittleBigMouse) for Windows.

## The Problem

When using monitors with different resolutions (e.g., a 4K/UWQHD center monitor with 1080p side monitors), moving the mouse across screen boundaries causes a jarring position jump. The mouse enters the adjacent screen at the wrong vertical position because X11 maps pixels 1:1 regardless of physical monitor size.

```
Without fix-mouse-jump:          With fix-mouse-jump:

 ┌──────┐┌──────────────┐         ┌──────┐┌──────────────┐
 │      ││              │         │      ││              │
 │ 1080p ││    UWQHD    │         │ 1080p ││    UWQHD    │
 │      ││              │         │      ││              │
 │  ──→ ││ ↑ JUMP!      │         │  ──→ ││→  smooth!    │
 └──────┘│              │         └──────┘│              │
         └──────────────┘                  └──────────────┘
```

## How It Works

The tool uses `xrandr --scale` to virtually increase the resolution of lower-DPI monitors, so their pixel density matches the higher-DPI center monitor. This makes mouse transitions physically accurate.

The scale factor is calculated from the physical pixel densities:

```
center_ppmm = center_height_px / center_height_mm
side_ppmm   = side_height_px   / side_height_mm
SCALE       = center_ppmm / side_ppmm
```

## Requirements

- Linux with X11 (not Wayland)
- KDE Plasma (optional, for plasmashell restart)
- `xrandr`
- `bash` ≥ 4.0
- `awk`

## Installation

```bash
git clone https://github.com/brainAThome/fix-mouse-jump.git
cd fix-mouse-jump
chmod +x install.sh
./install.sh
```

Then edit the config to match your monitor setup:

```bash
nano ~/.config/fix-mouse-jump/config
```

## Configuration

Find your monitor names and physical sizes:

```bash
xrandr --query | grep " connected"
```

Example output:
```
DP-0 connected 1920x1080+0+520 597mm x 336mm
DP-4 connected primary 3840x1600+1920+0 880mm x 370mm
DP-2 connected 1920x1080+5760+520 597mm x 336mm
```

Edit `~/.config/fix-mouse-jump/config`:

```bash
# Monitor output names
LEFT_MONITOR="DP-0"
CENTER_MONITOR="DP-4"
RIGHT_MONITOR="DP-2"

# Native resolutions
LEFT_RES="1920x1080"
CENTER_RES="3840x1600"
RIGHT_RES="1920x1080"

# Scale factor (see calculation above)
SCALE="1.35"
```

## Usage

```bash
# Apply the fix
fix-mouse-jump apply

# Revert to original layout
fix-mouse-jump revert

# Show current monitor status
fix-mouse-jump status

# Show help
fix-mouse-jump help
```

The fix is automatically applied at login via an autostart entry.

## Uninstall

```bash
./uninstall.sh
```

## Known Limitations

- **X11 only** — On Wayland, per-monitor scaling is handled natively by the compositor (no fix needed).
- **KDE kscreen2 conflict** — KDE's display settings may show a "gap" warning because it doesn't understand xrandr scaling. This is cosmetic only and can be ignored. Don't click "Apply" in KDE display settings, as it will override the fix.
- **Text size** — Side monitors will show slightly smaller text due to the virtual resolution increase.

## Tested Setup

| Monitor | Model | Resolution | Size |
|---------|-------|-----------|------|
| Left | Dell S2721HGF (27") | 1920×1080 | 597mm × 336mm |
| Center | Dell AW3821DW (38") | 3840×1600 | 880mm × 370mm |
| Right | Dell S2721HGFA (27") | 1920×1080 | 597mm × 336mm |

## Alternatives

- **[LittleBigMouse](https://github.com/mgth/LittleBigMouse)** — Windows equivalent (inspiration for this project)
- **Wayland** — Native per-monitor scaling (but may have compatibility issues with some apps)

## License

[GPL-3.0](LICENSE)
