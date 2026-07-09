#!/usr/bin/env bash
set -euo pipefail

say() { printf '\n== %s ==\n' "$*"; }
ok() { printf 'OK: %s\n' "$*"; }
warn() { printf 'WARN: %s\n' "$*"; }

export PATH="$HOME/.local/bin:$HOME/.hermes/bin:$PATH"

say "Commands"
for cmd in hermes git gh curl; do
  if command -v "$cmd" >/dev/null 2>&1; then
    ok "$cmd -> $(command -v "$cmd")"
  else
    warn "$cmd not found"
  fi
done

say "Hermes"
if command -v hermes >/dev/null 2>&1; then
  hermes --version || true
  hermes config path || true
  hermes config env-path || true
else
  warn "Hermes is not installed or PATH is not refreshed."
fi

say "GitHub CLI"
if command -v gh >/dev/null 2>&1; then
  gh auth status || true
else
  warn "gh is missing. GitHub publishing will not work."
fi

say "Provider key presence"
ENV_PATH=""
if command -v hermes >/dev/null 2>&1; then
  ENV_PATH="$(hermes config env-path 2>/dev/null || true)"
fi
if [[ -z "$ENV_PATH" ]]; then
  ENV_PATH="$HOME/.hermes/.env"
fi
if [[ -f "$ENV_PATH" ]]; then
  ok "env file exists: $ENV_PATH"
  for key in OPENROUTER_API_KEY GROQ_API_KEY CEREBRAS_API_KEY GEMINI_API_KEY GITHUB_TOKEN BRAVE_API_KEY TAVILY_API_KEY; do
    if grep -q "^${key}=..*" "$ENV_PATH"; then
      ok "$key is set"
    else
      warn "$key is empty/missing"
    fi
  done
else
  warn "env file not found: $ENV_PATH"
fi

say "Linux desktop launcher dependencies"
if [[ "${OSTYPE:-}" == linux* ]]; then
  command -v xterm >/dev/null 2>&1 && ok "xterm installed" || warn "xterm missing"
  command -v zenity >/dev/null 2>&1 && ok "zenity installed" || warn "zenity missing; launcher will use fallback/no slider"
fi

say "Hermes doctor"
if command -v hermes >/dev/null 2>&1; then
  if [[ "${HERMES_KIT_RUN_DOCTOR:-0}" == "1" ]]; then
    timeout 120 hermes doctor || true
  else
    warn "Skipped by default because full doctor can take time on API connectivity checks."
    echo "Run full doctor with:"
    echo "  HERMES_KIT_RUN_DOCTOR=1 ./scripts/CHECK_HERMES_ENV.sh"
  fi
fi

say "Done"
