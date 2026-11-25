<#
.SYNOPSIS
    Builds the VaporOS Arch-based ISO on Windows using Docker Desktop.
#>
$ErrorActionPreference = "Stop"

$RepoRoot = (Resolve-Path "$PSScriptRoot\..").Path
$OutDir   = Join-Path $RepoRoot "out"

if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Error "Docker is not installed or not in PATH. Install Docker Desktop (with WSL2 backend) to build the ISO on Windows."
    exit 1
}

New-Item -ItemType Directory -Force -Path $OutDir | Out-Null

Write-Host "==> Building vaporos-builder Docker image..." -ForegroundColor Cyan
docker build -t vaporos-builder $RepoRoot

Write-Host "==> Running mkarchiso inside Arch Linux container..." -ForegroundColor Cyan
docker run --rm --privileged `
    -v "${RepoRoot}:/workspace" `
    vaporos-builder

Write-Host "`n==> Build finished! Check $OutDir for your VaporOS .iso image." -ForegroundColor Green
