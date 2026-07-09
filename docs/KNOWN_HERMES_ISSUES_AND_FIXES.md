# Known Hermes Agent issues and fixes

This document is a practical checklist for new users before opening an issue.
It combines official Hermes Agent documentation, GitHub CLI documentation, and
public Hermes Agent issue patterns seen in the wild.

## Install and PATH

Problem:

- `hermes: command not found`
- Windows installer finished, but PowerShell does not see `hermes`

Fix:

- Close and reopen PowerShell or Windows Terminal.
- On Linux/macOS/WSL2, make sure these paths are available:

```bash
export PATH="$HOME/.local/bin:$HOME/.hermes/bin:$PATH"
command -v hermes
```

## GitHub login code does not appear

Problem:

- `gh auth login` shows a menu but no code.
- The browser opens, but the terminal does not finish login.

Fix:

```bash
./scripts/GITHUB_LOGIN_HELPER.sh
```

The helper uses:

```bash
BROWSER=false gh auth login --web -h github.com -p https -s repo,workflow,read:user
```

That skips the confusing menu and prints a one-time device code directly in the
terminal. Open `https://github.com/login/device`, type the code, and approve the
login.

If a token is required instead, do not paste it into chat or commit it:

```bash
read -s GH_TOKEN
echo "$GH_TOKEN" | gh auth login --with-token
unset GH_TOKEN
```

The GitHub CLI manual says token login needs at least `repo`, `read:org`, and
`gist` scopes. For this kit, `workflow` is also useful if the repository later
adds GitHub Actions.

## `hermes doctor` reports missing `GITHUB_TOKEN`

Problem:

- `gh auth status` is logged in.
- `hermes doctor` still warns that `GITHUB_TOKEN` is missing.

Fix:

- For publishing this kit, use `gh` auth instead of storing `GITHUB_TOKEN`.
- If a Hermes tool specifically needs `GITHUB_TOKEN`, set it through the key
  script, not by committing it:

```bash
./scripts/SET_KEYS_LINUX.sh
```

This warning can be a provider/tooling mismatch rather than a broken GitHub
login.

## Model context window below 64K

Problem:

- Hermes refuses a selected model.
- Error mentions context below 64000 tokens.

Fix:

- Choose a model/provider with at least 64K context.
- Avoid small local models for long agent sessions unless they are configured
  with enough context and the machine has enough RAM.
- If provider metadata is wrong, configure the model/provider explicitly.

Public issue examples:

- https://github.com/NousResearch/hermes-agent/issues/24140
- https://github.com/NousResearch/hermes-agent/issues/24000
- https://github.com/NousResearch/hermes-agent/issues/23949
- https://github.com/NousResearch/hermes-agent/issues/15882
- https://github.com/NousResearch/hermes-agent/issues/12976

## Provider key or routing problems

Problem:

- `No API key`
- empty OpenRouter key
- provider fallback not working
- a stale key is used after switching provider
- provider base URL is empty

Fix:

1. Edit the correct key script.
2. Run the key script again.
3. Restart the terminal session.
4. Check without printing secret values:

```bash
./scripts/CHECK_HERMES_ENV.sh
hermes config show
hermes model
```

Use one provider first, verify it, then add more providers. Debugging five
providers at once makes false failures harder to understand.

Official provider docs:

- https://hermes-agent.nousresearch.com/docs/integrations/providers
- https://hermes-agent.nousresearch.com/docs/user-guide/features/provider-routing

## GitHub Copilot provider confusion

Problem:

- `gh auth login` works.
- Copilot provider still fails with 403, empty base URL, or no model access.

Fix:

- A normal GitHub login is not the same thing as a GitHub Copilot subscription.
- For free or low-friction setup, start with OpenRouter free models, Groq,
  Cerebras, Gemini free tier, or local Ollama.

When Copilot fails after `gh auth login`, first verify the user actually has
Copilot access outside Hermes.

## Windows and shell-specific problems

Problem:

- Git Bash, PowerShell, and Windows Terminal show different PATH or config.
- `gh auth token` flashes or opens another console.
- `hermes doctor` fails because `gh` exists but is not executable.

Fix:

- Prefer Windows Terminal + PowerShell for native Windows install.
- Reopen the terminal after install.
- Verify exact commands:

```powershell
where.exe hermes
where.exe gh
gh auth status
hermes doctor
```

Official Windows note:

- https://hermes-agent.nousresearch.com/docs/user-guide/windows-native

## Linux terminal copy/paste and zoom

This kit's Linux xterm launcher includes:

- `Ctrl+Shift+C` copy
- `Ctrl+Shift+V` paste
- `Shift+Insert` paste
- `Ctrl + mouse wheel` zoom
- `Ctrl + +` / `Ctrl + -` zoom
- startup zoom selector

If the host distro handles shortcuts differently, run plain `hermes` in the
user's normal terminal.

## Safe diagnostic order

Run this order before reporting a bug:

```bash
./scripts/CHECK_HERMES_ENV.sh
gh auth status
hermes --version
hermes config show
hermes model
HERMES_KIT_RUN_DOCTOR=1 ./scripts/CHECK_HERMES_ENV.sh
```

Do not paste API keys, tokens, full `.env` files, or private chat logs into bug
reports.

## Public issue report template

Use this shape when asking another AI or a maintainer for help:

```text
Hermes Agent version:
OS and shell:
Install method:
Command that failed:
Exact error text:
Provider/model selected:
Does gh auth status work? yes/no
Does ./scripts/CHECK_HERMES_ENV.sh pass? yes/no
What changed before it broke:

Do not include API keys, tokens, .env files, or private chat logs.
```

## References

- Hermes Windows native guide: https://hermes-agent.nousresearch.com/docs/user-guide/windows-native
- Hermes quickstart: https://hermes-agent.nousresearch.com/docs/getting-started/quickstart
- Hermes provider documentation: https://hermes-agent.nousresearch.com/docs/integrations/providers
- Hermes updating and doctor documentation: https://hermes-agent.nousresearch.com/docs/getting-started/updating
- Hermes FAQ: https://hermes-agent.nousresearch.com/docs/reference/faq
- GitHub CLI auth manual: https://cli.github.com/manual/gh_auth_login
- GitHub device login: https://github.com/login/device
