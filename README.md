# Hermes Agent Friend Kit

Safe installer/configuration kit for [Hermes Agent](https://github.com/NousResearch/hermes-agent).

This repository does **not** contain personal API keys, tokens, private memory, chat logs, or a copied `~/.hermes` directory. It installs official Hermes Agent, applies a small terminal skin, and gives the user scripts/templates for adding their own free-tier API keys.

## Download and install like a normal app

Recommended for friends:

1. Open the GitHub Releases page: https://github.com/vavavadusik-crypto/hermes-agent-friend-kit/releases/latest
2. Download one setup file for your OS.
3. Run it.
4. Add your own API keys in Hermes Agent Settings.

Setup files:

- Linux: `Hermes-Agent-Setup-Linux.sh`
- Windows: `Hermes-Agent-Setup-Windows.cmd`

The setup file installs official Hermes Agent, applies this public preset, and
creates launchers/settings helpers. It does **not** contain the maintainer's
private keys, personal memory, `.env`, `auth.json`, chat history, or private
model config.

What gets installed:

- official Hermes Agent from NousResearch;
- this public friend kit in `~/hermes-agent-friend-kit` or
  `%USERPROFILE%\hermes-agent-friend-kit`;
- the `eva-terminal` skin;
- API-key/settings helpers;
- auto-route before launch for free/limited providers;
- desktop launchers when the OS supports them.

## Terminal install

Linux:

```bash
HERMES_KIT_CONFIGURE_AFTER=1 bash <(curl -fsSL https://raw.githubusercontent.com/vavavadusik-crypto/hermes-agent-friend-kit/main/install.sh)
```

Windows PowerShell:

```powershell
$env:HERMES_KIT_CONFIGURE_AFTER="1"; irm https://raw.githubusercontent.com/vavavadusik-crypto/hermes-agent-friend-kit/main/install.ps1 | iex
```

The one-command installer downloads the full kit to:

- Linux/macOS/WSL2: `~/hermes-agent-friend-kit`
- Windows: `%USERPROFILE%\hermes-agent-friend-kit`

## Linux desktop

```bash
git clone https://github.com/vavavadusik-crypto/hermes-agent-friend-kit.git
cd hermes-agent-friend-kit
chmod +x install.sh scripts/*.sh linux-desktop/*.sh
./install.sh
```

On a graphical Linux desktop, this also installs a `Hermes Agent` launcher.
It also installs `Hermes Agent Settings` for API keys and model provider setup.
Each desktop launch runs a small auto-route check first: it keeps free or
limited providers first, refreshes the fallback chain, and avoids Ollama cloud
models unless the user selects them manually.
Local Ollama models are not selected automatically on weak laptops. To allow
local fallback explicitly, start the launcher with `HERMES_AGENT_ALLOW_LOCAL=1`.
It opens Hermes in the normal system terminal when possible, so terminal
shortcuts stay standard:

- `Ctrl+Shift+C` copies;
- `Ctrl+Shift+V` pastes;
- `Ctrl+C` interrupts a running command.

After install, open `Hermes Agent Settings`, or run:

```bash
./scripts/CONFIGURE_KEYS_LINUX.sh
hermes
```

## macOS / WSL2

Use the same Linux installer, but run Hermes in your normal terminal:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/vavavadusik-crypto/hermes-agent-friend-kit/main/install.sh)
cd ~/hermes-agent-friend-kit
./scripts/CONFIGURE_KEYS_LINUX.sh
hermes
```

The Linux `.desktop` launcher is only installed when a graphical Linux session is detected.

## Windows PowerShell

```powershell
git clone https://github.com/vavavadusik-crypto/hermes-agent-friend-kit.git
cd hermes-agent-friend-kit
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
.\install.ps1
```

After install, open `Hermes Agent Settings.cmd` from the Desktop, or run:

```powershell
.\scripts\CONFIGURE_KEYS_WINDOWS.ps1
hermes
```

The Windows desktop `Hermes Agent.cmd` launcher also runs auto-route before
starting Hermes: it selects the first configured free/limited provider and
falls back to local Ollama when no API keys are present.

## Free keys

See `docs/FREE_KEYS_AND_APIS.md`. A short friend-facing setup letter is in
`docs/FRIEND_INSTALL_LETTER_RU.md`.

## GPT-5.6

GPT-5.6 is included as an optional premium route, not the default free route.
Use `gpt-5.6-terra` for first paid checks and `gpt-5.6-sol` only for hard
review or final polish. See `docs/GPT_5_6_AND_FALLBACK_ROUTING.md`.

## Troubleshooting

Run:

```bash
./scripts/CHECK_HERMES_ENV.sh
```

Known fixes are documented in `docs/TROUBLESHOOTING.md`.
The longer real-world checklist is `docs/KNOWN_HERMES_ISSUES_AND_FIXES.md`.

For GitHub login/publishing:

```bash
./scripts/GITHUB_LOGIN_HELPER.sh
./scripts/PUSH_TO_GITHUB.sh
```

## Public no-key APIs

See `docs/PUBLIC_NO_KEY_APIS.md` and `public-no-key-connectors.json`.

## Security

This repo is a public installer/preset, not a dump of a private `~/.hermes`
profile. Do not commit `.env`, API keys, tokens, private memories, logs, copied
Hermes home directories, or another user's personal model configuration.
