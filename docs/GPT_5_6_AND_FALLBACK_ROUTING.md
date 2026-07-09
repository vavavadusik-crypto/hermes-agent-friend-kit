# GPT-5.6 and Hermes fallback routing

Updated: 2026-07-09

## Default policy

This kit keeps free or limited-free providers first. The automatic desktop
route uses this order:

1. Groq via `custom:groq`.
2. Cerebras via `custom:cerebras`.
3. Gemini.
4. NVIDIA NIM.
5. OpenRouter free/low-cost, if the user has a key.
6. Local Ollama `omnicoder-9b-65536ctx:latest`.

OpenRouter is still documented as the easiest manual starting point because one
key can route to many models, but the automatic launcher prefers the fast
free/limited inference providers first.

Do not put Ollama cloud models such as `glm-5.2:cloud` in the automatic
fallback chain unless the user explicitly wants to spend Ollama cloud quota.

## GPT-5.6 role

OpenAI GPT-5.6 is a premium path, not the default free path.

- `gpt-5.6-sol` / `gpt-5.6`: frontier quality.
- `gpt-5.6-terra`: balanced quality and cost.
- `gpt-5.6-luna`: efficient high-volume work.

Use `gpt-5.6-terra` for first paid smoke tests and `gpt-5.6-sol` only for
hard review, architecture, security, or final polishing tasks.

Hermes direct OpenAI provider:

```bash
hermes config set model.provider openai-api
hermes config set model.default gpt-5.6-terra
hermes config set agent.reasoning_effort medium
```

Secrets go in the local Hermes env file:

```bash
OPENAI_API_KEY="..."
```

Never commit the env file.

## Current OpenAI migration notes

Official OpenAI guidance says `gpt-5.6` is an alias for `gpt-5.6-sol`.
For model-family migrations, do not blindly replace every model with Sol:
map low-cost and high-volume roles to Terra or Luna.

When GPT-5.6 is used through Chat Completions with function tools, effective
reasoning must be `none`. Reasoning plus tools should use the Responses API.
Because Hermes is an agent with tool-calling, treat GPT-5.6 in this kit as an
explicit premium route until the active Hermes transport is verified.

Official docs:

- https://developers.openai.com/api/docs/guides/latest-model.md
- https://developers.openai.com/api/docs/guides/upgrading-to-gpt-5p6-sol.md
- https://developers.openai.com/api/docs/guides/prompt-guidance-gpt-5p6.md
