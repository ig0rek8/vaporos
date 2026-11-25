<#
.SYNOPSIS
    Boots the latest built VaporOS ISO in QEMU for quick testing on Windows.
#>
$ErrorActionPreference = "Stop"

$RepoRoot = (Resolve-Path "$PSScriptRoot\..").Path
$Iso = Get-ChildItem -Path (Join-Path $RepoRoot "out") -Filter "vaporos-*.iso" -ErrorAction SilentlyContinue |
    Sort-Object LastWriteTime -Descending |
    Select-Object -First 1

if (-not $Iso) {
    Write-Error "No VaporOS ISO found in out\. Run .\scripts\build-iso.ps1 first."
    exit 1
}

if (-not (Get-Command qemu-system-x86_64 -ErrorAction SilentlyContinue)) {
    Write-Error "qemu-system-x86_64 not found in PATH. Install QEMU for Windows or boot $($Iso.FullName) in VirtualBox / VMware / Ventoy."
    exit 1
}

Write-Host "==> Launching $($Iso.Name) in QEMU (4 GB RAM, 4 vCPUs)..." -ForegroundColor Cyan
qemu-system-x86_64 `
    -m 4096 `
    -smp 4 `
    -cdrom $Iso.FullName `
    -boot d `
    -vga virtio `
    -display sdl,gl=on `
    -net nic -net user
