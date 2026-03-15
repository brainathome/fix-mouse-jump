#!/usr/bin/env bash
# =============================================================================
# install.sh — Install fix-mouse-jump
# =============================================================================

set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
readonly INSTALL_DIR="${HOME}/.local/bin"
readonly CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/fix-mouse-jump"
readonly AUTOSTART_DIR="${HOME}/.config/autostart"
readonly KSCREEN_PATCH_DIR="${HOME}/.local/share/kpackage/kcms/kcm_kscreen/contents/ui"
readonly SYSTEM_KSCREEN_DIR="/usr/share/kpackage/kcms/kcm_kscreen/contents/ui"

echo "Installing fix-mouse-jump..."
echo ""

# Install script
mkdir -p "$INSTALL_DIR"
cp "$SCRIPT_DIR/fix-mouse-jump" "$INSTALL_DIR/fix-mouse-jump"
chmod +x "$INSTALL_DIR/fix-mouse-jump"
echo "  [✓] Script installed to ${INSTALL_DIR}/fix-mouse-jump"

# Install config (only if not already present)
mkdir -p "$CONFIG_DIR"
if [[ ! -f "$CONFIG_DIR/config" ]]; then
    cp "$SCRIPT_DIR/config.example" "$CONFIG_DIR/config"
    echo "  [✓] Config installed to ${CONFIG_DIR}/config"
    echo "      → Edit this file to match your monitor setup!"
else
    echo "  [–] Config already exists at ${CONFIG_DIR}/config (not overwritten)"
fi

# Install autostart entry
mkdir -p "$AUTOSTART_DIR"
cat > "$AUTOSTART_DIR/fix-mouse-jump.desktop" << EOF
[Desktop Entry]
Type=Application
Name=Fix Mouse Jump
Comment=DPI-aware mouse transition fix for multi-monitor setups
Exec=${INSTALL_DIR}/fix-mouse-jump autostart
Terminal=false
X-KDE-autostart-phase=2
EOF
echo "  [✓] Autostart entry created"

# Install KDE kscreen UI patch (fixes gap warning + monitor positions)
if [[ -d "$SYSTEM_KSCREEN_DIR" ]]; then
    mkdir -p "$KSCREEN_PATCH_DIR"

    # Copy the 3 patched QML files from this project
    for qml_file in main.qml Output.qml Screen.qml; do
        if [[ -f "$SCRIPT_DIR/kscreen-patch/contents/ui/$qml_file" ]]; then
            cp "$SCRIPT_DIR/kscreen-patch/contents/ui/$qml_file" "$KSCREEN_PATCH_DIR/$qml_file"
        fi
    done

    # Copy remaining QML files from system (needed for complete KCM package)
    for qml_file in "$SYSTEM_KSCREEN_DIR"/*.qml; do
        local_name="$(basename "$qml_file")"
        if [[ ! -f "$KSCREEN_PATCH_DIR/$local_name" ]]; then
            cp "$qml_file" "$KSCREEN_PATCH_DIR/$local_name"
        fi
    done

    echo "  [✓] KDE display settings patch installed"
    echo "      → Gap warning suppressed, monitors shown bottom-aligned"
else
    echo "  [–] KDE kscreen KCM not found, skipping UI patch"
fi

echo ""
echo "Installation complete!"
echo ""
echo "Next steps:"
echo "  1. Edit your config:  nano ${CONFIG_DIR}/config"
echo "  2. Apply now:         fix-mouse-jump apply"
echo "  3. It will auto-apply on next login"
echo ""

# Check if ~/.local/bin is in PATH
if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
    echo "Note: ${INSTALL_DIR} is not in your PATH."
    echo "  Add this to your ~/.bashrc:"
    echo "    export PATH=\"\$HOME/.local/bin:\$PATH\""
    echo ""
fi
