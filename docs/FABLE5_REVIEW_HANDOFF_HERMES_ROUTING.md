# Fable 5 review handoff: Hermes routing and GPT-5.6

Status: prepared by Codex on 2026-07-09.

## Goal

Review the Hermes Agent Friend Kit routing changes with maximum rigor, but do
not edit files unless the user explicitly asks for an implementation pass.

## Scope

Repository:

```text
/home/architect/Рабочий стол/для друга - Hermes Agent
```

Changed areas:

- `scripts/AUTO_ROUTE_LINUX.sh`
- `scripts/AUTO_ROUTE_WINDOWS.ps1`
- `scripts/APPLY_HERMES_PRESET.py`
- `scripts/CONFIGURE_KEYS_LINUX.sh`
- `scripts/CONFIGURE_KEYS_WINDOWS.ps1`
- `scripts/SET_KEYS_LINUX.sh`
- `scripts/SET_KEYS_WINDOWS.ps1`
- `docs/HERMES_CONFIG_TEMPLATE.yaml`
- `docs/FREE_KEYS_AND_APIS.md`
- `docs/GPT_5_6_AND_FALLBACK_ROUTING.md`
- `README.md`
- `README_RU.md`

## Required checks

1. Confirm free/limited providers stay first.
2. Confirm auto-route verifies real generation endpoints, not only key presence.
3. Confirm local Ollama is disabled by default and only enabled with
   `HERMES_AGENT_ALLOW_LOCAL=1`.
4. Confirm Ollama cloud is skipped when session usage limit is exhausted.
5. Confirm GPT-5.6 is optional premium only.
6. Confirm `gpt-5.6-terra` is the recommended first paid test and
   `gpt-5.6-sol` is reserved for hardest review/final polish.
7. Confirm no secrets, real API keys, tokens, `.env`, `auth.json`, or private
   `~/.hermes` data are committed.
8. Confirm Linux and Windows settings scripts stay usable.

## OpenAI official docs used

- https://developers.openai.com/api/docs/guides/latest-model.md
- https://developers.openai.com/api/docs/guides/upgrading-to-gpt-5p6-sol.md
- https://developers.openai.com/api/docs/guides/prompt-guidance-gpt-5p6.md

## Reviewer output

Return:

1. Findings ordered by severity.
2. Any required fixes.
3. A final recommendation: ship / do not ship / ship after listed fixes.

Avoid broad project exploration and network-heavy commands.
