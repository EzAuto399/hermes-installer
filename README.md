# hermes-installer

Cross-platform install scripts for **[Hermes Agent](https://github.com/NousResearch/hermes-agent)** — the self-improving AI agent built by Nous Research.

This is an **independent third-party tool** built and maintained by [Yo-Da Lai](https://yodalai.xyz). It wraps the official Hermes installer with prerequisite handling (Python installation), platform detection, and a Windows-to-WSL2 setup path. It does not modify Hermes itself; it calls the official `scripts/install.sh` from the [Hermes Agent repo](https://github.com/NousResearch/hermes-agent/blob/main/scripts/install.sh) under the hood.

> ⚠️ **Not affiliated with Nous Research or the Hermes Agent project.** For official support, see the [Hermes documentation](https://hermes-agent.nousresearch.com/docs/) and the [Nous Research Discord](https://discord.gg/NousResearch).

---

## What this script does

1. Detects your platform (macOS, Linux, WSL2, Termux on Android, or native Windows)
2. Installs Python 3.11+ and curl if missing
3. Runs the official Hermes Agent installer (`scripts/install.sh`), which itself installs `uv`, creates a venv, and pulls Hermes with all extras
4. Verifies the install and offers to launch `hermes setup`

## Quick start

### macOS / Linux / WSL2

```bash
curl -fsSL https://raw.githubusercontent.com/yodalai/hermes-installer/main/install.sh | bash
```

Or clone and run locally:

```bash
git clone https://github.com/yodalai/hermes-installer.git
cd hermes-installer
chmod +x install.sh
./install.sh
```

### Windows

Hermes does **not** support native Windows. Windows users must run it inside WSL2 (Linux on Windows).

Run the PowerShell script as Administrator:

```powershell
irm https://raw.githubusercontent.com/yodalai/hermes-installer/main/install.ps1 | iex
```

It will:
1. Verify your Windows build supports WSL2
2. Install WSL2 + Ubuntu if missing
3. After reboot, run the Linux install script inside WSL2

### Android (Termux)

```bash
pkg install curl
curl -fsSL https://raw.githubusercontent.com/yodalai/hermes-installer/main/install.sh | bash
```

Termux installs the `.[termux]` extra (curated for Android compatibility — full extras include voice deps that don't run on Android).

## Platforms supported

| Platform | Script | Notes |
|---|---|---|
| macOS (Intel + Apple Silicon) | `install.sh` | Installs Homebrew + Python via brew |
| Linux (Ubuntu/Debian) | `install.sh` | apt + NodeSource for Python |
| Linux (Fedora/RHEL/CentOS) | `install.sh` | dnf for Python |
| WSL2 (Linux on Windows) | `install.sh` | Same as Linux flow |
| Android (Termux) | `install.sh` | pkg manager, `.[termux]` extra |
| Windows 10/11 native | `install.ps1` | Sets up WSL2, then runs install.sh inside |

## Inspect the script before running

`curl | bash` should always be inspected. To review before executing:

```bash
curl -fsSL https://raw.githubusercontent.com/yodalai/hermes-installer/main/install.sh -o install.sh
less install.sh        # read it
chmod +x install.sh
./install.sh
```

## What you get after installing

- `hermes` command available globally
- `uv`-managed Python virtualenv with Hermes installed
- Cross-session persistent memory + skills system
- 40+ built-in tools, six terminal backends (local, Docker, SSH, Daytona, Singularity, Modal)
- Multi-platform messaging gateway (Telegram, Discord, Slack, WhatsApp, Signal, Email, CLI)

After install, follow the official Hermes docs:
- https://hermes-agent.nousresearch.com/docs/

## Migrating from OpenClaw

Hermes ships with a built-in `hermes claw migrate` command that imports SOUL.md, MEMORY.md, skills, command allowlists, and API keys from an existing OpenClaw install. After running this installer:

```bash
hermes claw migrate --dry-run    # preview what would migrate
hermes claw migrate              # actually migrate
```

If you need to install OpenClaw first, see [openclaw-installer](https://github.com/yodalai/openclaw-installer).

## Troubleshooting

If the install fails:

1. **Run `hermes doctor`** — built-in diagnostic
2. **Open a new terminal** — PATH changes from Python install may need a fresh shell
3. **Check the [official Hermes Agent issues](https://github.com/NousResearch/hermes-agent/issues)** — your problem may already be reported there
4. **Join the [Nous Research Discord](https://discord.gg/NousResearch)** — Hermes-specific help
5. **For issues with this wrapper script specifically**, open an issue here

## Disclaimer

THIS SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

You run this script at your own risk. It will:
- Install Python 3.11+ system-wide using your platform's package manager
- Install Homebrew on macOS if missing
- Run `sudo` for system package operations on Linux
- Run the official Nous Research installer, which installs `uv` and creates a virtualenv
- Hermes Agent itself prompts for and stores LLM API keys

By running this script, you acknowledge that:
- You are responsible for inspecting the script before running it
- This script is not affiliated with, endorsed by, or supported by Nous Research, the Hermes Agent project, or its maintainers
- This script is not affiliated with Anthropic, OpenAI, or any LLM provider
- The author is not responsible for any damage to your system, loss of data, or unintended consequences

If you encounter issues with Hermes Agent itself (post-install), report them at the [official Hermes repo](https://github.com/NousResearch/hermes-agent/issues), not here.

If you encounter issues with this wrapper script, open an issue in this repo.

## Attribution

This wrapper depends on and calls into:

- **Hermes Agent** by Nous Research — https://github.com/NousResearch/hermes-agent (MIT)
- **uv** by Astral — https://github.com/astral-sh/uv (MIT/Apache-2.0)

All credit for the underlying functionality goes to those projects' maintainers.

## License

MIT — see [LICENSE](LICENSE).

Copyright (c) 2026 Yo-Da Lai

---

Author: [Yo-Da Lai](https://yodalai.xyz) — independent automation engineer, Gold Coast, Australia.

If this saved you time, a star on the repo helps others find it.
