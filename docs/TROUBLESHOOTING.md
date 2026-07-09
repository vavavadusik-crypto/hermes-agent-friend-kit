# Troubleshooting / known issues

This file collects practical fixes from:

- official Hermes Agent docs;
- GitHub CLI docs/issues;
- known Hermes Agent GitHub issues;
- local project memory notes from the original setup.

## 1. `hermes: command not found`

Most common on Windows right after install.

Fix:

- close and reopen PowerShell/Windows Terminal;
- or run directly:

```powershell
& "$env:LOCALAPPDATA\hermes\bin\hermes.cmd"
```

On Linux/macOS/WSL2:

```bash
export PATH="$HOME/.local/bin:$HOME/.hermes/bin:$PATH"
command -v hermes
```

## 2. GitHub CLI login does not show a useful code

Use the helper:

```bash
./scripts/GITHUB_LOGIN_HELPER.sh
```

Manual fallback:

```bash
BROWSER=false gh auth login --web -h github.com -p https -s repo,workflow,read:user
```

Then open:

```text
https://github.com/login/device
```

and type the one-time code shown in the terminal.

Notes:

- If `gh auth login --web` opens the browser but never completes, restart the login and press Enter when `gh` asks to open the browser.
- If running inside `su`, SSH, container, or a different graphical user, browser opening can fail. Use `BROWSER=false` and open the URL manually.
- Check status:

```bash
gh auth status
gh auth token >/dev/null && echo "gh token OK"
```

## 3. `hermes doctor` says `GITHUB_TOKEN` is missing

If `gh auth status` is OK, this can be a cosmetic/incomplete doctor check. Some Hermes runtime paths can use `gh auth token` even when `GITHUB_TOKEN` env var is not set.

For this kit, GitHub publishing uses `gh`, not a stored `GITHUB_TOKEN`.

## 4. Model context window below 64K

Hermes Agent can reject models with small context windows:

```text
context window below minimum 64000 tokens
```

Fix:

- choose a model/provider with at least 64K context;
- or configure the correct context length if the provider reports it wrong;
- local Ollama 32K models may fail until configured with larger context and enough RAM.

## 5. Missing/empty provider key

Symptoms:

- "No API key"
- "empty OpenRouter API key"
- provider ignored/fallback not working
- "provider resolver returned an empty base URL"

Fix:

1. Edit the correct key script:
   - Linux/macOS/WSL2: `scripts/SET_KEYS_LINUX.sh`
   - Windows: `scripts/SET_KEYS_WINDOWS.ps1`
2. Run it again.
3. Verify:

```bash
hermes config show
hermes model
hermes doctor
```

## 6. GitHub Copilot provider appears available but fails

`gh auth login` is not the same as a GitHub Copilot subscription. A normal GitHub OAuth token can make Copilot look partially available, then requests fail with 403 or empty base URL.

Recommendation for free setup:

- prefer OpenRouter free router, Groq, Cerebras, Gemini, or Ollama;
- do not choose Copilot unless the user actually has Copilot access.

## 7. Copy/paste in the Linux xterm launcher

The included Linux launcher adds:

- `Ctrl+Shift+C` copy
- `Ctrl+Shift+V` paste
- `Shift+Insert` paste
- `Ctrl + mouse wheel` zoom
- `Ctrl + +` / `Ctrl + -` zoom

If the distro terminal handles shortcuts differently, use selection + middle mouse paste or run plain:

```bash
hermes
```

## 8. Run the kit diagnostic

```bash
./scripts/CHECK_HERMES_ENV.sh
```

This checks commands, config paths, GitHub auth, selected model/provider, key presence without printing key values, and basic launcher dependencies.

Full `hermes doctor` can take longer because it runs API connectivity checks. Use it explicitly:

```bash
HERMES_KIT_RUN_DOCTOR=1 ./scripts/CHECK_HERMES_ENV.sh
```

## References

- Hermes Windows native guide: https://hermes-agent.nousresearch.com/docs/user-guide/windows-native
- Hermes FAQ: https://hermes-agent.nousresearch.com/docs/reference/faq
- Hermes quickstart: https://hermes-agent.nousresearch.com/docs/getting-started/quickstart
- Hermes updating/doctor guidance: https://hermes-agent.nousresearch.com/docs/getting-started/updating
- GitHub CLI auth manual: https://cli.github.com/manual/gh_auth_login
- GitHub device login: https://github.com/login/device

For a longer checklist of real-world issue patterns, see
`docs/KNOWN_HERMES_ISSUES_AND_FIXES.md`.
