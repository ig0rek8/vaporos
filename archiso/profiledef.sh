#!/usr/bin/env bash
# shellcheck disable=SC2034

iso_name="vaporos"
iso_label="VAPOROS_$(date --date="@${SOURCE_DATE_EPOCH:-$(date +%s)}" +%Y%m)"
iso_publisher="VaporOS Project <https://github.com/vaporos>"
iso_application="VaporOS — Ultra-Light Arch Gaming OS"
iso_version="$(date --date="@${SOURCE_DATE_EPOCH:-$(date +%s)}" +%Y.%m.%d)"
install_dir="vapor"
buildmodes=('iso')
bootmodes=(
    'bios.syslinux'
    'uefi.systemd-boot'
)
arch="x86_64"
pacman_conf="pacman.conf"
airootfs_image_type="squashfs"
airootfs_image_tool_options=('-comp' 'zstd' '-Xcompression-level' '15' '-b' '1M')
bootstrap_tarball_compression=('zstd' '-c' '-T0' '--auto-threads=logical' '--long' '-15')

file_permissions=(
    ["/etc/shadow"]="0:0:400"
    ["/etc/gshadow"]="0:0:400"
    ["/etc/sudoers.d/10-gamer"]="0:0:440"
    ["/usr/local/bin/vaporos-session-dispatcher"]="0:0:755"
    ["/usr/local/bin/vaporos-gaming-session"]="0:0:755"
    ["/usr/local/bin/vaporos-desktop-session"]="0:0:755"
    ["/usr/local/bin/vaporos-switch-session"]="0:0:755"
    ["/usr/local/bin/vaporos-ctl"]="0:0:755"
    ["/usr/local/bin/vaporos-install"]="0:0:755"
    ["/usr/bin/steamos-session-select"]="0:0:755"
    ["/usr/local/bin/vaporos-firstboot"]="0:0:755"
)
