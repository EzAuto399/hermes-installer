# hermes-installer — install.ps1
# https://github.com/EzAuto399/hermes-installer
# Author: Yo-Da Lai (https://yodalai.xyz)
# License: MIT
# Wraps the official Hermes Agent installer (https://github.com/NousResearch/hermes-agent, MIT).
# This is an independent third-party tool, not affiliated with Nous Research.
# Hermes does not support native Windows; this script sets up WSL2 and runs the Linux installer inside.

$ErrorActionPreference = "Stop"

function Write-Info    ($m) { Write-Host "ℹ  $m" -ForegroundColor Cyan }
function Write-Success ($m) { Write-Host "✓  $m" -ForegroundColor Green }
function Write-Warn    ($m) { Write-Host "⚠  $m" -ForegroundColor Yellow }
function Write-Fail    ($m) { Write-Host "✗  $m" -ForegroundColor Red; exit 1 }
function Write-Step    ($m) { Write-Host "`n── $m ──" -ForegroundColor White }
function Confirm-Yes ($prompt) {
    $r = Read-Host "$prompt [y/N]"
    return $r -match '^[Yy]'
}

Write-Host @"

  ╔════════════════════════════════════════════════╗
  ║   Hermes Agent ☤ — Install (Windows → WSL2)    ║
  ║   EzAuto399/hermes-installer                     ║
  ║                                                ║
  ║   Yo-Da Lai (yodalai.xyz) — independent tool   ║
  ╚════════════════════════════════════════════════╝

  ⚠ Hermes does NOT support native Windows.
  Windows users must run Hermes inside WSL2.

  This script will:
    1. Verify WSL2 is enabled
    2. Install WSL2 + Ubuntu if missing (requires Admin + reboot)
    3. Run install.sh inside WSL2

"@

if (-not (Confirm-Yes "Continue?")) { Write-Info "Aborted."; exit 0 }

$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host @"
✗ This script must run as Administrator (WSL install requires it).

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
    if (Confirm-Yes "Install WSL2 + Ubuntu now? (will require a reboot)") {
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
        if (Confirm-Yes "Reboot now?") {
            Restart-Computer -Confirm
        }
        exit 0
    }
    else {
        Write-Fail "Cannot install Hermes without WSL2 on Windows."
    }
}
else {
    Write-Success "WSL is installed"
}

Write-Step "Checking WSL distros"
$distros = (wsl -l -q 2>$null | Where-Object { $_.Trim() -ne '' })
if ($distros.Count -eq 0) {
    Write-Warn "No Linux distros installed under WSL."
    if (Confirm-Yes "Install Ubuntu now?") {
        wsl --install -d Ubuntu
        Write-Info "Ubuntu will open. Set username + password, then re-run this script."
        exit 0
    }
    else {
        Write-Fail "Cannot install Hermes without a WSL distro."
    }
}
Write-Success "WSL distros found:"
foreach ($d in $distros) { Write-Host "    - $($d.Trim())" }

Write-Step "Final step — install Hermes inside WSL"
$defaultDistro = (wsl -l -q | Select-Object -First 1).Trim()

Write-Host @"

  ╔════════════════════════════════════════════════╗
  ║   ✓ WSL is ready. Installing Hermes inside.    ║
  ╚════════════════════════════════════════════════╝

  Will execute inside WSL2 / $defaultDistro :
  curl -fsSL https://raw.githubusercontent.com/EzAuto399/hermes-installer/main/install.sh | bash

"@

if (Confirm-Yes "Run Hermes install inside WSL now?") {
    wsl -- bash -c "curl -fsSL https://raw.githubusercontent.com/EzAuto399/hermes-installer/main/install.sh | bash"
}
else {
    Write-Host @"

  Manual path:
    1. Open WSL terminal:    wsl
    2. Inside WSL, run:
         curl -fsSL https://raw.githubusercontent.com/EzAuto399/hermes-installer/main/install.sh | bash
    3. Once Hermes is installed:
         hermes setup

"@
}
