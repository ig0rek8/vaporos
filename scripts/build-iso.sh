#!/usr/bin/env bash
# ==============================================================================
# VaporOS ISO Builder (runs on Arch Linux or inside the VaporOS Docker image)
# ==============================================================================
set -euo pipefail

REPO_DIR="${REPO_DIR:-/workspace}"
OUT_DIR="${OUT_DIR:-$REPO_DIR/out}"
WORK_DIR="/tmp/vaporos-work"
PROFILE_DIR="/tmp/vaporos-profile"

if [[ $EUID -ne 0 ]]; then
    echo "ERROR: mkarchiso must be run as root (or via Docker)." >&2
    exit 1
fi

echo "==> Preparing clean archiso profile in $PROFILE_DIR..."
rm -rf "$WORK_DIR" "$PROFILE_DIR"
mkdir -p "$OUT_DIR"
cp -a "$REPO_DIR/archiso" "$PROFILE_DIR"

echo "==> Normalizing LF line endings (safe for Windows hosts)..."
find "$PROFILE_DIR" -type f \( -name "*.sh" -o -name "*.conf" -o -name "*.service" -o -name "*.toml" -o -name "*.cfg" -o -name "*.desktop" -o -path "*/bin/*" \) \
    -exec sed -i 's/\r$//' {} +

echo "==> Enabling core systemd services via symlinks..."
SYSTEMD_DIR="$PROFILE_DIR/airootfs/etc/systemd/system"
WANTS_DIR="$SYSTEMD_DIR/multi-user.target.wants"
mkdir -p "$WANTS_DIR"

ln -sf /usr/lib/systemd/system/NetworkManager.service "$WANTS_DIR/NetworkManager.service"
ln -sf /usr/lib/systemd/system/bluetooth.service "$WANTS_DIR/bluetooth.service"
ln -sf /usr/lib/systemd/system/greetd.service "$WANTS_DIR/greetd.service"
ln -sf /usr/lib/systemd/system/systemd-oomd.service "$WANTS_DIR/systemd-oomd.service"
ln -sf /etc/systemd/system/vaporos-firstboot.service "$WANTS_DIR/vaporos-firstboot.service"
ln -sf /usr/lib/systemd/system/multi-user.target "$SYSTEMD_DIR/default.target"
# Prevent getty@tty1 from fighting greetd on VT1 & mask unused accounts-daemon
ln -sf /dev/null "$SYSTEMD_DIR/getty@tty1.service"
ln -sf /dev/null "$SYSTEMD_DIR/accounts-daemon.service"
# Pre-set timezone so systemd-firstboot does not block boot with Initial Setup prompt
ln -sf /usr/share/zoneinfo/UTC "$PROFILE_DIR/airootfs/etc/localtime"

# Ensure executable bits on all custom VaporOS scripts
chmod 755 \
    "$PROFILE_DIR"/airootfs/usr/local/bin/vaporos-* \
    "$PROFILE_DIR/airootfs/usr/bin/steamos-session-select"

echo "==> Building VaporOS ISO with mkarchiso..."
mkarchiso -v -w "$WORK_DIR" -o "$OUT_DIR" "$PROFILE_DIR"

echo "==> Done! ISO written to: $OUT_DIR"
ls -lh "$OUT_DIR"/vaporos-*.iso
