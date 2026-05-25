# hermes-installer — install.ps1
# https://github.com/EzAuto399/hermes-installer
# Author: Yo-Da Lai (https://yodalai.xyz)
# License: MIT
# This is an independent third-party tool, not affiliated with Nous Research.
#
# Hermes Agent now has official native Windows support (early beta).
# This script offers two paths:
#   1. Run the official native Windows installer (recommended for trying it out)
#   2. Set up WSL2 and install there (more battle-tested, same as Linux)

$ErrorActionPreference = "Stop"

function Write-Info    ($m) { Write-Host "→  $m" -ForegroundColor Cyan }
function Write-Success ($m) { Write-Host "✓  $m" -ForegroundColor Green }
function Write-Warn    ($m) { Write-Host "⚠  $m" -ForegroundColor Yellow }
function Write-Fail    ($m) { Write-Host "✗  $m" -ForegroundColor Red; exit 1 }
function Write-Step    ($m) { Write-Host "`n── $m ──" -ForegroundColor White }
function Write-Header  ($m) { Write-Host $m -ForegroundColor Magenta }

Write-Header @"

  ╔════════════════════════════════════════════════╗
  ║   Hermes Agent ☤ — Install (Windows)            ║
  ║   EzAuto399/hermes-installer                     ║
  ║                                                ║
  ║   Yo-Da Lai (yodalai.xyz) — independent tool   ║
  ╚════════════════════════════════════════════════╝

  Hermes Agent now supports native Windows (early beta) AND
  WSL2 (Linux on Windows — the most battle-tested path).

  Choose your install path:

    [1] Native Windows (early beta)
        Official Nous Research PowerShell installer.
        Installs Hermes directly on Windows with a bundled Git Bash.
        Good for trying it out. Some rough edges expected.

    [2] WSL2 — Linux on Windows (recommended for daily use)
        Most battle-tested path. Runs Hermes inside a Linux VM.
        Full feature support. Requires a one-time WSL2 setup.

"@

$choice = Read-Host "Which path? [1 or 2]"
if ($choice -eq "1") {

    Write-Step "Running official native Windows installer"
    Write-Info "Source: github.com/NousResearch/hermes-agent/scripts/install.ps1"
    Write-Info "This installs Hermes directly on Windows with a bundled Git Bash."
    Write-Warn "Native Windows support is early beta — expect rough edges."
    Write-Warn "File issues at: github.com/NousResearch/hermes-agent/issues"
    Write-Host ""
    irm https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.ps1 | iex
    exit 0

} elseif ($choice -ne "2") {
    Write-Fail "Invalid choice. Pick 1 or 2."
}

# ── WSL2 path ───────────────────────────────────────────────────────

Write-Step "Windows → WSL2 install path"
Write-Info "This will set up WSL2 (if needed), then install Hermes inside it."

$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host @"
✗ This path needs Administrator privileges (WSL install requires it).
Right-click PowerShell → "Run as Administrator" → re-run this script.
"@ -ForegroundColor Red
    exit 1
}
Write-Success "Running as Administrator"

Write-Step "Checking Windows version"
$os = Get-CimInstance -ClassName Win32_OperatingSystem
$build = [int]$os.BuildNumber
if ($build -lt 19041) {
    Write-Fail "Windows build $build is too old. WSL2 requires build 19041+ (Windows 10 May 2020 update) or Windows 11."
}
Write-Success "Windows $($os.Caption), build $build ✓"

Write-Step "Checking WSL"
$wslInstalled = $false
try {
    $null = wsl --status 2>$null
    if ($LASTEXITCODE -eq 0) { $wslInstalled = $true }
} catch {}

if (-not $wslInstalled) {
    Write-Warn "WSL is not installed."
    $answer = Read-Host "Install WSL2 + Ubuntu now? (will require a reboot) [y/N]"
    if ($answer -match '^[Yy]') {
        Write-Info "Running: wsl --install"
        wsl --install
        Write-Host @"

  ╔════════════════════════════════════════════════╗
  ║   ⚠ REBOOT REQUIRED                            ║
  ║                                                ║
  ║   After reboot:                                ║
  ║   1. Ubuntu opens automatically                ║
  ║   2. Set Linux username + password             ║
  ║   3. In the Ubuntu terminal, run:              ║
  ║                                                ║
  ║      curl -fsSL https://raw.githubusercontent.com/EzAuto399/hermes-installer/main/install.sh | bash
  ║                                                ║
  ║   That installs Hermes inside WSL2.            ║
  ╚════════════════════════════════════════════════╝

"@ -ForegroundColor Yellow
        $reboot = Read-Host "Reboot now? [y/N]"
        if ($reboot -match '^[Yy]') { Restart-Computer -Confirm }
        exit 0
    }
    else { Write-Fail "Cannot install Hermes without WSL2 on Windows." }
}
else { Write-Success "WSL is installed" }

Write-Step "Checking WSL distros"
$distros = (wsl -l -q 2>$null | Where-Object { $_.Trim() -ne '' })
if ($distros.Count -eq 0) {
    Write-Warn "No Linux distros installed under WSL."
    $answer = Read-Host "Install Ubuntu now? [y/N]"
    if ($answer -match '^[Yy]') {
        wsl --install -d Ubuntu
        Write-Info "Ubuntu will open. Set username + password, then re-run this script."
        exit 0
    }
    else { Write-Fail "Cannot install Hermes without a WSL distro." }
}
Write-Success "WSL distros found:"
foreach ($d in $distros) { Write-Host "    - $($d.Trim())" }

Write-Step "Installing Hermes inside WSL"
$defaultDistro = (wsl -l -q | Select-Object -First 1).Trim()

Write-Host @"

  ╔════════════════════════════════════════════════╗
  ║   ✓ WSL is ready. Installing Hermes inside.    ║
  ╚════════════════════════════════════════════════╝

  Will execute inside WSL / $defaultDistro :
  curl -fsSL https://raw.githubusercontent.com/EzAuto399/hermes-installer/main/install.sh | bash

"@

$answer = Read-Host "Run Hermes install inside WSL now? [y/N]"
if ($answer -match '^[Yy]') {
    wsl -- bash -c "curl -fsSL https://raw.githubusercontent.com/EzAuto399/hermes-installer/main/install.sh | bash"
}
else {
    Write-Host @"

  Manual path:
    1. Open WSL:  wsl
    2. Inside WSL, run:
         curl -fsSL https://raw.githubusercontent.com/EzAuto399/hermes-installer/main/install.sh | bash
    3. Once done:  hermes setup

"@
}
