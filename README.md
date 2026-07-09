# Hermes Agent Friend Kit

Safe installer/configuration kit for [Hermes Agent](https://github.com/NousResearch/hermes-agent).

This repository does **not** contain personal API keys, tokens, private memory, chat logs, or a copied `~/.hermes` directory. It installs official Hermes Agent, applies a small terminal skin, and gives the user scripts/templates for adding their own free-tier API keys.

## Linux / macOS / WSL2

```bash
git clone https://github.com/vavavadusik-crypto/hermes-agent-friend-kit.git
cd hermes-agent-friend-kit
chmod +x install.sh scripts/*.sh linux-desktop/*.sh
./install.sh
```

After install, edit `scripts/SET_KEYS_LINUX.sh`, paste your own keys, then run:

```bash
./scripts/SET_KEYS_LINUX.sh
hermes
```

## Windows PowerShell

```powershell
git clone https://github.com/vavavadusik-crypto/hermes-agent-friend-kit.git
cd hermes-agent-friend-kit
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
.\install.ps1
```

After install, edit `scripts\SET_KEYS_WINDOWS.ps1`, paste your own keys, then run:

```powershell
.\scripts\SET_KEYS_WINDOWS.ps1
hermes
```

## One-command install after publishing

Replace `vavavadusik-crypto` with the real repo owner after publishing:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/vavavadusik-crypto/hermes-agent-friend-kit/main/install.sh)
```

Windows:

```powershell
irm https://raw.githubusercontent.com/vavavadusik-crypto/hermes-agent-friend-kit/main/install.ps1 | iex
```

## Free keys

See `docs/FREE_KEYS_AND_APIS.md`.

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

Do not commit `.env`, API keys, tokens, private memories, logs, or copied Hermes home directories.
