#!/usr/bin/env bash
# hermes-installer — install.sh
# https://github.com/EzAuto399/hermes-installer
# Author: Yo-Da Lai (https://yodalai.xyz)
# License: MIT
# Wraps the official Hermes Agent installer (https://github.com/NousResearch/hermes-agent, MIT).
# This is an independent third-party tool, not affiliated with Nous Research.
#
# What this script does that the official installer doesn't:
#   - Installs curl and git if missing (the official installer requires both)
#   - Installs Homebrew on macOS (used by the official installer for ripgrep/ffmpeg)
#   - Installs build tools on Debian/Ubuntu (needed by Python packages)
#   - Platform detection with friendly guidance
#   - Then delegates to the official Nous Research installer for everything else

set -euo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; BOLD='\033[1m'; NC='\033[0m'

info()    { echo -e "${BLUE}→${NC}  $*"; }
success() { echo -e "${GREEN}✓${NC}  $*"; }
warn()    { echo -e "${YELLOW}⚠${NC}  $*"; }
fail()    { echo -e "${RED}✗${NC}  $*"; exit 1; }
step()    { echo -e "\n${BOLD}── $* ──${NC}"; }

confirm() {
    local answer
    read -p "$1 [y/N] " -r answer
    [[ "$answer" =~ ^[Yy]$ ]]
}

cat <<'EOF'

  ╔════════════════════════════════════════════════╗
  ║   Hermes Agent ☤ — Install                     ║
  ║   EzAuto399/hermes-installer                     ║
  ║                                                ║
  ║   Yo-Da Lai (yodalai.xyz) — independent tool   ║
  ╚════════════════════════════════════════════════╝

  This wraps the official Hermes Agent installer with
  prerequisite handling for a fresh device.

  What will happen:
    1. Detect your platform
    2. Install curl + git if missing (required by the installer)
    3. Install build tools on Linux (required by Python packages)
    4. Run the official Nous Research Hermes installer
    5. Verify everything works

  The official installer handles: uv, Python, Node.js,
  ripgrep, ffmpeg, and Hermes itself.

EOF

if ! confirm "Continue?"; then info "Aborted."; exit 0; fi
[[ "$EUID" -eq 0 ]] && fail "Don't run as root. Run as your normal user."

# ── Platform detection ──────────────────────────────────────────────

step "Detecting platform"

case "$(uname -s)" in
    Darwin*)
        OS="macos"; ARCH="$(uname -m)"
        success "macOS ($ARCH)"
        ;;
    Linux*)
        if grep -qiE "(microsoft|wsl)" /proc/version 2>/dev/null; then
            OS="wsl"; success "WSL2"
        elif [ -d "/data/data/com.termux" ] 2>/dev/null || [ -n "${TERMUX_VERSION:-}" ]; then
            OS="termux"; success "Termux (Android)"
        else
            OS="linux"; success "Linux"
        fi
        if [ -f /etc/os-release ]; then
            . /etc/os-release
            DISTRO="${ID:-unknown}"; info "Distribution: ${DISTRO}"
        else DISTRO="unknown"; fi
        ;;
    *)
        fail "Unsupported platform: $(uname -s). Use install.ps1 on Windows."
        ;;
esac

# ── curl ────────────────────────────────────────────────────────────

step "Checking curl"

if command -v curl >/dev/null 2>&1; then
    success "curl ✓"
else
    info "curl is not installed. The official Hermes installer needs it."
    case "$OS" in
        macos)
            if command -v brew >/dev/null 2>&1; then
                brew install curl && success "curl installed"
            else
                info "Installing Homebrew first..."
                /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || true
                if [[ "$ARCH" == "arm64" ]]; then
                    eval "$(/opt/homebrew/bin/brew shellenv)"
                else
                    eval "$(/usr/local/bin/brew shellenv)"
                fi
                brew install curl && success "curl installed"
            fi
            ;;
        linux|wsl)
            case "$DISTRO" in
                ubuntu|debian) sudo apt-get update -y && sudo apt-get install -y curl ;;
                fedora|rhel|centos) sudo dnf install -y curl ;;
                arch) sudo pacman -S --noconfirm curl ;;
                *) info "Install curl manually for your distro and re-run this script" ;;
            esac
            ;;
        termux) pkg install -y curl ;;
    esac
    command -v curl >/dev/null 2>&1 || fail "curl still not found after install attempt."
    success "curl installed"
fi

# ── git ──────────────────────────────────────────────────────────────

step "Checking git"

if command -v git >/dev/null 2>&1; then
    success "git $(git --version | awk '{print $3}') ✓"
else
    info "git is not installed. The official Hermes installer needs it to clone the repo."
    case "$OS" in
        macos)
            command -v brew >/dev/null 2>&1 || {
                info "Installing Homebrew..."
                /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
                if [[ "$ARCH" == "arm64" ]]; then
                    eval "$(/opt/homebrew/bin/brew shellenv)"
                else
                    eval "$(/usr/local/bin/brew shellenv)"
                fi
            }
            brew install git && success "git installed"
            ;;
        linux|wsl)
            case "$DISTRO" in
                ubuntu|debian) sudo apt-get update -y && sudo apt-get install -y git ;;
                fedora|rhel|centos) sudo dnf install -y git ;;
                arch) sudo pacman -S --noconfirm git ;;
                *) info "Install git manually: your-package-manager install git" ;;
            esac
            ;;
        termux) pkg install -y git ;;
    esac
    command -v git >/dev/null 2>&1 || fail "git still not found after install attempt."
    success "git installed"
fi

# ── macOS Homebrew (official installer uses it for ripgrep/ffmpeg) ──

if [ "$OS" = "macos" ] && ! command -v brew >/dev/null 2>&1; then
    step "Installing Homebrew"
    info "The official Hermes installer uses Homebrew (brew) to install ripgrep and ffmpeg."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    if [[ "$ARCH" == "arm64" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    else
        eval "$(/usr/local/bin/brew shellenv)"
    fi
    success "Homebrew installed"
fi

# ── Build tools for Debian/Ubuntu ───────────────────────────────────

if { [ "$OS" = "linux" ] || [ "$OS" = "wsl" ]; } && { [ "$DISTRO" = "ubuntu" ] || [ "$DISTRO" = "debian" ]; }; then
    step "Checking build tools"
    NEED_BUILD=false
    for pkg in gcc python3-dev libffi-dev; do
        if ! dpkg -s "$pkg" &>/dev/null; then
            NEED_BUILD=true
            break
        fi
    done
    if [ "$NEED_BUILD" = true ]; then
        info "Some Python packages need build tools (build-essential, python3-dev, libffi-dev)."
        info "Hermes Agent itself does not require or retain root access."
        if confirm "Install build tools now? (requires sudo)"; then
            sudo apt-get update -y
            sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq build-essential python3-dev libffi-dev
            success "Build tools installed"
        else
            warn "Skipping build tools. The official installer may prompt again."
        fi
    else
        success "Build tools ✓"
    fi
fi

# ── Already installed? ──────────────────────────────────────────────

if command -v hermes >/dev/null 2>&1; then
    CURRENT=$(hermes --version 2>/dev/null || echo "unknown")
    warn "Hermes already installed (version ${CURRENT})"
    if confirm "Update to latest?"; then
        info "Running: hermes update"
        hermes update
        success "Updated"
    fi
    exit 0
fi

# ── Run official installer ──────────────────────────────────────────

step "Running the official Hermes Agent installer"
info "Source: github.com/NousResearch/hermes-agent/scripts/install.sh"
info "This installs uv, Python, Node.js, ripgrep, ffmpeg, and Hermes itself."
info "(first run on a fresh venv can take 1–5 minutes)"
echo

curl -fsSL https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.sh | bash

# ── Verify ───────────────────────────────────────────────────────────

step "Verifying installation"

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

cat <<'EOF'

  ╔════════════════════════════════════════════════╗
  ║   ✓ Hermes Agent installed                     ║
  ╚════════════════════════════════════════════════╝

  First steps (run in a fresh terminal):

    hermes setup        # Full setup wizard (recommended)
    hermes              # Start the interactive CLI
    hermes setup --portal  # Skip API keys — use Nous Portal
    hermes model        # Choose your LLM provider
    hermes tools        # Configure tools

  Messaging gateway:
    hermes gateway setup
    hermes gateway start

  Migrating from OpenClaw?
    hermes claw migrate --dry-run    # preview only
    hermes claw migrate              # migrate

  Diagnose issues:
    hermes doctor

  Official docs: https://hermes-agent.nousresearch.com/docs/

EOF

if [ "$INSTALLED" = true ] && confirm "Run 'hermes setup' now?"; then
    hermes setup
fi
