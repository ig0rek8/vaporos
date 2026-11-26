#!/usr/bin/env bash
# ==============================================================================
# VaporOS Live UI & Tools Updater
# Run inside a live or installed VaporOS session to apply the latest UI,
# GNOME-style App Grid, Pin/Unpin Dock, Laptop Battery & Close X buttons
# without rebuilding the ISO or rebooting!
# ==============================================================================
set -euo pipefail

echo "==> [1/4] Installing required UI packages (nwg-drawer, papirus-icon-theme)..."
sudo pacman -Sy --needed --noconfirm nwg-drawer papirus-icon-theme jq

echo "==> [2/4] Downloading latest VaporOS configs & scripts from GitHub..."
TMP_DIR="/tmp/vaporos-live-update"
rm -rf "$TMP_DIR"
git clone --depth 1 https://github.com/ig0rek8/vaporos.git "$TMP_DIR"

AIROOTFS="$TMP_DIR/archiso/airootfs"

echo "==> [3/4] Applying scripts, desktop entries, and user configs..."
sudo cp -a "$AIROOTFS/usr/local/bin/vaporos-"* /usr/local/bin/
sudo chmod 755 /usr/local/bin/vaporos-*
sudo cp -a "$AIROOTFS/usr/share/applications/vaporos-"*.desktop /usr/share/applications/

mkdir -p "$HOME/.config/vaporos" "$HOME/.config/waybar" "$HOME/.config/foot" \
         "$HOME/.config/gtk-3.0" "$HOME/.config/nwg-drawer" \
         "$HOME/.config/hypr" "$HOME/.config/sway"

cp -a "$AIROOTFS/etc/skel/.config/waybar/." "$HOME/.config/waybar/"
cp -a "$AIROOTFS/etc/skel/.config/foot/." "$HOME/.config/foot/"
cp -a "$AIROOTFS/etc/skel/.config/gtk-3.0/." "$HOME/.config/gtk-3.0/"
cp -a "$AIROOTFS/etc/skel/.config/nwg-drawer/." "$HOME/.config/nwg-drawer/"
cp -a "$AIROOTFS/etc/skel/.config/hypr/." "$HOME/.config/hypr/"
cp -a "$AIROOTFS/etc/skel/.config/sway/." "$HOME/.config/sway/"

if [[ ! -f "$HOME/.config/vaporos/pinned-apps" ]]; then
    cp -a "$AIROOTFS/etc/skel/.config/vaporos/pinned-apps" "$HOME/.config/vaporos/pinned-apps"
fi

rm -rf "$TMP_DIR"

echo "==> [4/4] Reloading Waybar, GNOME Dock, and compositor..."
pkill -x waybar 2>/dev/null || true
sleep 0.3

nohup waybar >/dev/null 2>&1 &
disown 2>/dev/null || true

if [[ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]]; then
    hyprctl reload >/dev/null 2>&1 || true
elif [[ -n "${SWAYSOCK:-}" ]]; then
    swaymsg reload >/dev/null 2>&1 || true
fi

echo ""
echo "✅ VaporOS UI updated! Close this terminal and open a new one to see the new CSD [X] titlebar."
echo "   - Top bar: [⊞ Apps], [🎮 Gaming Mode], [✕] close active window, smart laptop battery"
echo "   - Bottom dock: left-click to launch, right-click to unpin, [＋] to pin/unpin apps"
