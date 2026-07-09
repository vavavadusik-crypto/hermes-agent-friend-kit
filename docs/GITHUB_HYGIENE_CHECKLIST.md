# GitHub Hygiene Checklist

Updated: 2026-07-10

## Done

- Public repo is intentionally small and does not include private `~/.hermes`.
- `.gitignore` blocks `.env`, token files, private keys, logs, virtualenvs, and caches.
- Latest release exists with Linux setup, Windows setup, and zip asset.
- `README.md` and `README_RU.md` explain one-click install.
- `SECURITY.md` documents secret handling.
- `CHANGELOG.md` documents release history.
- `docs/PROJECT_STATUS.md` documents current state and known limits.
- `docs/FRIEND_INSTALL_LETTER_RU.md` gives a friend-facing setup guide.
- `context/AI_CONTEXT_FOR_FRIEND.md` gives another AI assistant safe context.

## Do Not Do Without Explicit Approval

- Do not delete repositories.
- Do not delete old releases.
- Do not rewrite git history.
- Do not publish private `.env`, `auth.json`, `~/.hermes`, memories, or chat logs.
- Do not enable local Ollama fallback by default on weak laptops.

## Before Every Release

Run:

```bash
bash -n scripts/AUTO_ROUTE_LINUX.sh scripts/CONFIGURE_KEYS_LINUX.sh scripts/SET_KEYS_LINUX.sh linux-desktop/hermes-agent-window linux-desktop/hermes-agent-launcher linux-desktop/install_launcher_linux.sh install.sh setup/Hermes-Agent-Setup-Linux.sh scripts/INSTALL_LINUX.sh
python3 -m py_compile scripts/APPLY_HERMES_PRESET.py
git diff --check
rg -n "sk-[A-Za-z0-9_-]{8,}|ghp_[A-Za-z0-9_]{20,}|github_pat_[A-Za-z0-9_]{20,}|gho_[A-Za-z0-9_]{20,}|AIza[0-9A-Za-z_-]{20,}|gsk_[A-Za-z0-9]{20,}|csk-[A-Za-z0-9]{20,}" -S . || true
```

Then verify:

- latest README links point to `/releases/latest`;
- release notes say whether local fallback is enabled or disabled;
- setup files install from the intended branch/tag;
- Windows changes are smoke-tested when possible.

## Local Backup Before Risky Work

Before changing repo structure or GitHub metadata, create:

```bash
git bundle create hermes-agent-friend-kit-$(git rev-parse --short HEAD).bundle --all
git archive --format=zip --output hermes-agent-friend-kit-$(git rev-parse --short HEAD).zip HEAD
gh repo view --json nameWithOwner,description,visibility,defaultBranchRef,url > repo-view.json
gh release list --limit 100 > releases.txt
```
