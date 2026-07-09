# Context for another AI assistant

You are helping my friend install and configure Hermes Agent from this repository.

Important facts:

- This repo is a safe installer/configuration kit, not a dump of someone else's private `~/.hermes`.
- It intentionally contains no personal API keys, tokens, chat logs, or private memory.
- The friend may use Windows or Linux.
- Use the official Hermes Agent installer first, then apply this repo's skin and optional key setup.
- Do not ask the user to paste secrets into public chats. Have them edit the local scripts or `.env` file.
- Prefer free or limited-free providers first. The launcher auto-route order is Groq, Cerebras, Gemini, NVIDIA NIM, OpenRouter, then Ollama cloud when quota is active.
- Local Ollama is disabled by default to protect weak laptops; enable it only with `HERMES_AGENT_ALLOW_LOCAL=1`.
- Public/no-key APIs are documented in `docs/PUBLIC_NO_KEY_APIS.md`; these are useful for research tools but do not replace an LLM provider.
- The skin file is `skins/eva-terminal.yaml`. It changes colors and labels but keeps the original Hermes banner art.
- On Linux, `linux-desktop/install_launcher_linux.sh` installs `Hermes Agent` and `Hermes Agent Settings` launchers.
- On Windows, `scripts/INSTALL_WINDOWS.ps1` creates `Hermes Agent.cmd` and `Hermes Agent Settings.cmd` on the Desktop.
- The normal launchers run an auto-route check before starting Hermes, verify real generation endpoints, skip exhausted providers, and stop safely when no remote provider works.

Recommended support flow:

1. Identify the OS.
2. Prefer the one-click setup file from the GitHub release, or run `install.sh` / `install.ps1`.
3. Help the user obtain their own provider key using `docs/FREE_KEYS_AND_APIS.md` or `docs/FRIEND_INSTALL_LETTER_RU.md`.
4. Use `Hermes Agent Settings` or the local `scripts/SET_KEYS_*` files to save keys.
5. Start Hermes from the Desktop launcher or with `hermes`.
6. If the model/provider fails, run `hermes-agent-auto-route --status`, `hermes fallback list`, `hermes doctor`, `hermes config show`, and `hermes model`.

Do not overwrite existing configs without making a backup. If editing config manually, preserve existing user settings and only set `display.skin: eva-terminal` plus the model provider/default chosen by the user.
