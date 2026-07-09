# Project Status

Updated: 2026-07-10

## Current release

- Latest release after this maintenance pass: `v1.1.4`
- Repo: https://github.com/vavavadusik-crypto/hermes-agent-friend-kit
- Latest release URL: https://github.com/vavavadusik-crypto/hermes-agent-friend-kit/releases/latest

## What this repo is

Hermes Agent Friend Kit is a safe installer/configuration kit for friends. It
installs the official Hermes Agent and applies public, non-secret helpers:

- desktop launchers;
- terminal skin;
- API-key setup scripts;
- provider auto-route;
- docs for free/limited providers;
- troubleshooting and support context.

## What this repo is not

This repo is not a private machine dump. It must not contain:

- personal `~/.hermes`;
- `.env`;
- API keys/tokens;
- memories;
- chat logs;
- private model configs.

## Current routing policy

Auto-route checks real generation endpoints and chooses the first working
remote/free route:

1. Groq
2. Cerebras
3. Gemini
4. NVIDIA NIM
5. OpenRouter
6. Ollama cloud, when account quota is active

Local Ollama is disabled by default and requires:

```bash
HERMES_AGENT_ALLOW_LOCAL=1
```

If no remote/free provider works, the launcher stops safely instead of loading
a heavy local model on weak laptops.

## Known limits

- Windows scripts are syntax-reviewed but still need smoke testing on a real
  Windows 10/11 machine.
- Free providers can rate-limit quickly. The launcher reports these states in
  `~/.cache/hermes-agent/auto-route.log` and `/tmp/hermes-agent-switcher-last.log`.
- OpenAI GPT-5.6 is optional premium routing, not default free routing.

## Next hardening steps

- Add docs link checks to CI.
- Smoke-test Windows setup.
- Add screenshots or a short install video.
- Add automated checksum verification instructions for release assets.
