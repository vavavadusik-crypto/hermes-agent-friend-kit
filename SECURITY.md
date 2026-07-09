# Security Policy

## Supported versions

Only the latest GitHub release is treated as supported for friends and testers.
Use:

```text
https://github.com/vavavadusik-crypto/hermes-agent-friend-kit/releases/latest
```

## Secrets policy

This repository must never contain:

- API keys or tokens;
- `.env` files;
- `auth.json`;
- private `~/.hermes` directories;
- chat logs or personal memories;
- screenshots that show secrets.

The repository contains only templates and local scripts that help users add
their own keys on their own machine.

## Reporting a security issue

Open a private channel with the maintainer before publishing details. If a key
was committed accidentally, revoke it in the provider dashboard immediately,
then rotate the key and remove it from git history before making another public
release.

## Local safety

Local Ollama fallback is disabled by default because weak laptops can overload
on local 7B/9B models. Enable it only when the machine can handle it:

```bash
HERMES_AGENT_ALLOW_LOCAL=1 hermes-agent-auto-route
```
