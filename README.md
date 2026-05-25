# hermes-installer

**One command to install [Hermes Agent](https://github.com/NousResearch/hermes-agent)** on a fresh device — the self-improving AI agent built by Nous Research.

This is an **independent third-party tool** by [Yo-Da Lai](https://yodalai.xyz). It wraps the official Hermes installer with prerequisite handling so a single command gets you from a fresh machine to a working Hermes install. It does not modify Hermes itself.

> Not affiliated with Nous Research. For official support, see the [Hermes docs](https://hermes-agent.nousresearch.com/docs/) and [Discord](https://discord.gg/NousResearch).

---

## What this script does

The official Hermes installer is excellent but assumes curl and git are already on your machine. This wrapper fills those gaps:

1. Detects your platform (macOS, Linux, WSL2, Termux)
2. Installs **curl** and **git** if missing (required by the official installer)
3. Installs **Homebrew** on macOS (used by the official installer for ripgrep/ffmpeg)
4. Installs **build tools** on Debian/Ubuntu (needed by Python packages)
5. Runs the official Hermes Agent installer, which handles: uv, Python, Node.js, ripgrep, ffmpeg, and Hermes itself
6. Verifies the install and offers to launch `hermes setup`

## Quick start

### macOS / Linux / WSL2

```bash
curl -fsSL https://raw.githubusercontent.com/EzAuto399/hermes-installer/main/install.sh | bash
```

Or clone and run locally:

```bash
git clone https://github.com/EzAuto399/hermes-installer.git
cd hermes-installer
chmod +x install.sh
./install.sh
```

### Windows

Hermes now supports two paths on Windows:

- **Native Windows** (early beta) — official Nous Research installer, runs Hermes directly on Windows with a bundled Git Bash
- **WSL2** (battle-tested) — runs Hermes inside a Linux VM, full feature support

Our PowerShell script offers both:

```powershell
irm https://raw.githubusercontent.com/EzAuto399/hermes-installer/main/install.ps1 | iex
```

It will ask which path you want, then handle the rest.

### Android (Termux)

```bash
pkg install curl
curl -fsSL https://raw.githubusercontent.com/EzAuto399/hermes-installer/main/install.sh | bash
```

## Platforms

| Platform | Script | Notes |
|---|---|---|
| macOS (Intel + Apple Silicon) | `install.sh` | Installs Homebrew, curl, git; official installer handles the rest |
| Linux (Ubuntu/Debian) | `install.sh` | Installs build tools, curl, git; official installer handles the rest |
| Linux (Fedora/RHEL/Arch) | `install.sh` | Best-effort curl/git install; official installer handles the rest |
| WSL2 | `install.sh` | Same as Linux above |
| Android (Termux) | `install.sh` | Installs curl, git via pkg; official installer uses `.[termux]` extra |
| Windows 10/11 | `install.ps1` | Offers native Windows (early beta) or WSL2 path |

## Inspect before running

```bash
curl -fsSL https://raw.githubusercontent.com/EzAuto399/hermes-installer/main/install.sh -o install.sh
less install.sh
chmod +x install.sh
./install.sh
```

## What you get

- `hermes` command available globally
- `uv`-managed Python virtual environment with Hermes installed
- 70+ built-in tools, 7 terminal backends (local, Docker, SSH, Daytona, Singularity, Modal, Vercel Sandbox)
- 20+ messaging platforms (Telegram, Discord, Slack, WhatsApp, Signal, and more)
- Cross-session persistent memory, autonomous skill creation, cron scheduling
- MCP integration, voice mode, browser tools

After install, see the official docs: https://hermes-agent.nousresearch.com/docs/

## Migrating from OpenClaw

```bash
hermes claw migrate --dry-run    # preview what would migrate
hermes claw migrate              # actually migrate
```

If you need to install OpenClaw first, see [openclaw-installer](https://github.com/EzAuto399/openclaw-installer).

## Troubleshooting

1. **Run `hermes doctor`** — built-in diagnostic
2. **Open a new terminal** — PATH changes need a fresh shell
3. **Check the [official Hermes issues](https://github.com/NousResearch/hermes-agent/issues)**
4. **Join the [Nous Research Discord](https://discord.gg/NousResearch)**
5. **For wrapper-specific issues**, open an issue in this repo

## Disclaimer

THIS SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND. You run this script at your own risk. It will:

- Install curl and git system-wide using your platform's package manager
- Install Homebrew on macOS if missing
- Use `sudo` for system package operations on Linux
- Run the official Nous Research installer, which installs `uv`, creates a virtual environment, and installs Hermes with all extras
- Hermes Agent itself prompts for and stores LLM API keys

By running this script, you acknowledge that:
- You are responsible for inspecting the script before running it
- This script is not affiliated with or endorsed by Nous Research, Hermes Agent, or any LLM provider
- The author is not responsible for any damage to your system, loss of data, or unintended consequences

## Attribution

This wrapper depends on:
- **Hermes Agent** by Nous Research — https://github.com/NousResearch/hermes-agent (MIT)
- **uv** by Astral — https://github.com/astral-sh/uv (MIT/Apache-2.0)

## License

MIT — see [LICENSE](LICENSE).

Copyright (c) 2026 Yo-Da Lai

---

Author: [Yo-Da Lai](https://yodalai.xyz) — Gold Coast, Australia.

If this saved you time, a star on the repo helps others find it.
