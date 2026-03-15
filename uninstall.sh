#!/usr/bin/env bash
# =============================================================================
# uninstall.sh — Uninstall fix-mouse-jump
# =============================================================================

set -euo pipefail

readonly INSTALL_DIR="${HOME}/.local/bin"
readonly CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/fix-mouse-jump"
readonly AUTOSTART_DIR="${HOME}/.config/autostart"
readonly LOG_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/fix-mouse-jump"

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

# Remove log files
rm -rf "$LOG_DIR"
echo "  [✓] Log files removed"

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
