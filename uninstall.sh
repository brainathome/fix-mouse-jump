#!/usr/bin/env bash
# =============================================================================
# uninstall.sh — Uninstall fix-mouse-jump
# =============================================================================

set -euo pipefail

readonly INSTALL_DIR="${HOME}/.local/bin"
readonly CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/fix-mouse-jump"
readonly AUTOSTART_DIR="${HOME}/.config/autostart"
readonly LOG_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/fix-mouse-jump"
readonly KSCREEN_PATCH_DIR="${HOME}/.local/share/kpackage/kcms/kcm_kscreen"
readonly SYSTEMD_USER_DIR="${HOME}/.config/systemd/user"

echo "Uninstalling fix-mouse-jump..."
echo ""

# Revert layout before uninstalling
if [[ -x "$INSTALL_DIR/fix-mouse-jump" ]]; then
    "$INSTALL_DIR/fix-mouse-jump" revert 2>/dev/null || true
    echo "  [✓] Monitor layout reverted"
fi

# Remove script
rm -f "$INSTALL_DIR/fix-mouse-jump"
echo "  [✓] Script removed"

# Remove autostart entry
rm -f "$AUTOSTART_DIR/fix-mouse-jump.desktop"
echo "  [✓] Autostart entry removed"

# Stop watchdog if running
if [[ -f "$LOG_DIR/watchdog.pid" ]]; then
    old_pid=$(cat "$LOG_DIR/watchdog.pid" 2>/dev/null || echo "")
    if [[ -n "$old_pid" ]] && kill -0 "$old_pid" 2>/dev/null; then
        kill "$old_pid" 2>/dev/null || true
        echo "  [✓] Watchdog stopped (PID ${old_pid})"
    fi
    rm -f "$LOG_DIR/watchdog.pid"
fi

# Remove systemd file watcher
if command -v systemctl &>/dev/null; then
    systemctl --user disable --now fix-mouse-jump-watch.path 2>/dev/null || true
    rm -f "$SYSTEMD_USER_DIR/fix-mouse-jump-watch.path"
    rm -f "$SYSTEMD_USER_DIR/fix-mouse-jump-watch.service"
    systemctl --user daemon-reload 2>/dev/null || true
    echo "  [✓] systemd file watcher removed"
fi

# Remove log files
rm -rf "$LOG_DIR"
echo "  [✓] Log files removed"

# Remove KDE kscreen UI patch
if [[ -d "$KSCREEN_PATCH_DIR" ]]; then
    rm -rf "$KSCREEN_PATCH_DIR"
    echo "  [✓] KDE display settings patch removed"
fi

# Ask about config
if [[ -d "$CONFIG_DIR" ]]; then
    read -rp "  Remove config at ${CONFIG_DIR}? [y/N] " answer
    if [[ "$answer" =~ ^[Yy]$ ]]; then
        rm -rf "$CONFIG_DIR"
        echo "  [✓] Config removed"
    else
        echo "  [–] Config kept at ${CONFIG_DIR}"
    fi
fi

echo ""
echo "Uninstall complete."
