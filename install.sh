#!/usr/bin/env bash
# hermes-installer — install.sh
# https://github.com/EzAuto399/hermes-installer
# Author: Yo-Da Lai (https://yodalai.xyz)
# License: MIT
# Wraps the official Hermes Agent installer (https://github.com/NousResearch/hermes-agent, MIT).
# This is an independent third-party tool, not affiliated with Nous Research.

set -euo pipefail

MIN_PYTHON="3.11"

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; BOLD='\033[1m'; NC='\033[0m'

info()    { echo -e "${BLUE}ℹ${NC}  $*"; }
success() { echo -e "${GREEN}✓${NC}  $*"; }
warn()    { echo -e "${YELLOW}⚠${NC}  $*"; }
fail()    { echo -e "${RED}✗${NC}  $*"; exit 1; }
step()    { echo -e "\n${BOLD}── $* ──${NC}"; }
confirm() { read -p "$1 [y/N] " -n 1 -r; echo; [[ $REPLY =~ ^[Yy]$ ]]; }

cat <<EOF

  ╔════════════════════════════════════════════════╗
  ║   Hermes Agent ☤ — Install                     ║
  ║   EzAuto399/hermes-installer                     ║
  ║                                                ║
  ║   Yo-Da Lai (yodalai.xyz) — independent tool   ║
  ╚════════════════════════════════════════════════╝

  Wraps the official Hermes Agent installer with cross-platform
  prerequisite handling (Python, curl).

  Steps:
    1. Detect platform (macOS / Linux / WSL2 / Termux)
    2. Install Python ${MIN_PYTHON}+ and curl if missing
    3. Run the official Nous Research installer
    4. Verify and start the setup wizard

EOF

if ! confirm "Continue?"; then info "Aborted."; exit 0; fi
[[ "$EUID" -eq 0 ]] && fail "Don't run as root. Run as your normal user."

step "Detecting platform"
case "$(uname -s)" in
    Darwin*)
        OS="macos"; ARCH="$(uname -m)"; success "macOS ($ARCH)"
        ;;
    Linux*)
        if grep -qiE "(microsoft|wsl)" /proc/version 2>/dev/null; then
            OS="wsl"; success "WSL2"
        elif [ -d "/data/data/com.termux" ] 2>/dev/null; then
            OS="termux"; success "Termux (Android)"
            warn "Hermes installs the .[termux] extra on Android."
        else
            OS="linux"; success "Linux"
        fi
        if [ -f /etc/os-release ]; then
            . /etc/os-release
            DISTRO="${ID:-unknown}"; info "Distribution: $DISTRO"
        else DISTRO="unknown"; fi
        ;;
    *)
        cat <<EOF
${RED}✗${NC} Unsupported platform: $(uname -s)
Hermes does NOT support native Windows. Use install.ps1 for the WSL2 setup.
EOF
        exit 1
        ;;
esac

step "Checking curl"
install_curl() {
    case "$OS" in
        macos)
            command -v brew >/dev/null 2>&1 || install_homebrew
            brew install curl
            ;;
        linux|wsl)
            case "$DISTRO" in
                ubuntu|debian) sudo apt-get update -y && sudo apt-get install -y curl ;;
                fedora|rhel|centos) sudo dnf install -y curl ;;
                *) fail "Install curl manually for $DISTRO" ;;
            esac
            ;;
        termux) pkg install -y curl ;;
    esac
}

if command -v curl >/dev/null 2>&1; then
    success "curl ✓"
else
    if confirm "curl missing. Install now?"; then install_curl; success "curl installed"
    else fail "curl is required."; fi
fi

step "Checking Python ${MIN_PYTHON}+"
python_ok() {
    command -v python3 >/dev/null 2>&1 || return 1
    local v
    v=$(python3 -c 'import sys; print("{}.{}".format(*sys.version_info[:2]))' 2>/dev/null || echo "0.0")
    awk -v v1="$v" -v v2="$MIN_PYTHON" 'BEGIN { exit !(v1 >= v2) }'
}

install_homebrew() {
    if command -v brew >/dev/null 2>&1; then return; fi
    info "Installing Homebrew (will request sudo password)..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    if [[ "${ARCH:-}" == "arm64" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    else
        eval "$(/usr/local/bin/brew shellenv)"
    fi
}

install_python_macos() { install_homebrew; brew install python@3.12; }
install_python_debian() { sudo apt-get update -y && sudo apt-get install -y python3 python3-pip python3-venv; }
install_python_fedora() { sudo dnf install -y python3 python3-pip; }
install_python_termux() { pkg install -y python; }

if python_ok; then
    success "Python $(python3 --version | cut -d' ' -f2) ✓"
else
    if command -v python3 >/dev/null 2>&1; then
        warn "Python $(python3 --version | cut -d' ' -f2) is too old (need ${MIN_PYTHON}+)"
    else
        warn "Python 3 not installed"
    fi
    if confirm "Install Python ${MIN_PYTHON}+ now?"; then
        case "$OS" in
            macos) install_python_macos ;;
            linux|wsl)
                case "$DISTRO" in
                    ubuntu|debian) install_python_debian ;;
                    fedora|rhel|centos) install_python_fedora ;;
                    *) fail "Unsupported Linux distro: $DISTRO" ;;
                esac
                ;;
            termux) install_python_termux ;;
        esac
        python_ok || fail "Python install completed but version check still fails. Open new terminal."
        success "Python $(python3 --version | cut -d' ' -f2) installed"
    else
        fail "Cannot continue without Python."
    fi
fi

if command -v hermes >/dev/null 2>&1; then
    CURRENT=$(hermes --version 2>/dev/null || echo "unknown")
    warn "Hermes already installed (version $CURRENT)"
    if confirm "Update to latest?"; then
        hermes update
        success "Updated"
    else
        info "Keeping current version"
    fi
    exit 0
fi

step "Running official Hermes installer"
info "Source: github.com/NousResearch/hermes-agent/scripts/install.sh"
info "(Installs uv → creates venv → installs Hermes with all extras)"
echo

curl -fsSL https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.sh | bash

step "Verifying"
case "$SHELL" in
    */zsh)  RC="$HOME/.zshrc" ;;
    */bash) RC="$HOME/.bashrc" ;;
    *)      RC="$HOME/.profile" ;;
esac
source "$RC" 2>/dev/null || true

if command -v hermes >/dev/null 2>&1; then
    success "hermes command available: $(hermes --version 2>/dev/null || echo 'OK')"
    INSTALLED=true
else
    warn "hermes not on PATH in this session yet."
    info "Open a NEW terminal and run: hermes"
    INSTALLED=false
fi

cat <<EOF

  ╔════════════════════════════════════════════════╗
  ║   ✓ Hermes Agent installed                     ║
  ╚════════════════════════════════════════════════╝

  First steps (run in a fresh terminal):

    hermes setup        # Full setup wizard (recommended)
    hermes              # Start the interactive CLI
    hermes model        # Choose your LLM provider
    hermes tools        # Configure tools

  Messaging gateway:
    hermes gateway setup
    hermes gateway start

  Migrating from OpenClaw?
    hermes claw migrate              # interactive
    hermes claw migrate --dry-run    # preview only

  Diagnose issues:
    hermes doctor

  Official Hermes docs: https://hermes-agent.nousresearch.com/docs/

EOF

if [ "$INSTALLED" = true ] && confirm "Run 'hermes setup' now?"; then
    hermes setup
fi
