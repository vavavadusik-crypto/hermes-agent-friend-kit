# Context for another AI assistant

You are helping my friend install and configure Hermes Agent from this repository.

Important facts:

- This repo is a safe installer/configuration kit, not a dump of someone else's private `~/.hermes`.
- It intentionally contains no personal API keys, tokens, chat logs, or private memory.
- The friend may use Windows or Linux.
- Use the official Hermes Agent installer first, then apply this repo's skin and optional key setup.
- Do not ask the user to paste secrets into public chats. Have them edit the local scripts or `.env` file.
- Prefer free or limited-free providers first: OpenRouter free router, Groq, Cerebras, Gemini, or local Ollama.
- Public/no-key APIs are documented in `docs/PUBLIC_NO_KEY_APIS.md`; these are useful for research tools but do not replace an LLM provider.
- The skin file is `skins/eva-terminal.yaml`. It changes colors and labels but keeps the original Hermes banner art.
- On Linux, `linux-desktop/install_launcher_linux.sh` installs a desktop launcher with a zoom slider.

Recommended support flow:

1. Identify the OS.
2. Run `scripts/INSTALL_LINUX.sh` or `scripts/INSTALL_WINDOWS.ps1`.
3. Help the user obtain their own provider key using `docs/FREE_KEYS_AND_APIS.md`.
4. Have them edit `scripts/SET_KEYS_LINUX.sh` or `scripts/SET_KEYS_WINDOWS.ps1`.
5. Run the key setup script.
6. Start Hermes with `hermes`.
7. If the model/provider fails, run `hermes doctor`, `hermes config show`, and `hermes model`.

Do not overwrite existing configs without making a backup. If editing config manually, preserve existing user settings and only set `display.skin: eva-terminal` plus the model provider/default chosen by the user.

