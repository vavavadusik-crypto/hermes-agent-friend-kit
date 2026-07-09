#!/usr/bin/env bash
set -euo pipefail

# Paste your own keys between the quotes. Leave empty if you do not use a provider.
OPENROUTER_API_KEY=""
GROQ_API_KEY=""
CEREBRAS_API_KEY=""
GEMINI_API_KEY=""
GITHUB_TOKEN=""
BRAVE_API_KEY=""
TAVILY_API_KEY=""

export PATH="$HOME/.local/bin:$HOME/.hermes/bin:$PATH"

if ! command -v hermes >/dev/null 2>&1; then
  echo "Hermes is not installed or not in PATH. Run INSTALL_LINUX.sh first."
  exit 1
fi

ENV_PATH="$(hermes config env-path 2>/dev/null || true)"
if [[ -z "$ENV_PATH" ]]; then
  ENV_PATH="$HOME/.hermes/.env"
fi
mkdir -p "$(dirname "$ENV_PATH")"
touch "$ENV_PATH"
chmod 600 "$ENV_PATH"

upsert_env() {
  local key="$1"
  local value="$2"
  [[ -n "$value" ]] || return 0
  local tmp
  tmp="$(mktemp)"
  grep -v "^${key}=" "$ENV_PATH" > "$tmp" || true
  printf '%s="%s"\n' "$key" "$value" >> "$tmp"
  mv "$tmp" "$ENV_PATH"
}

upsert_env OPENROUTER_API_KEY "$OPENROUTER_API_KEY"
upsert_env GROQ_API_KEY "$GROQ_API_KEY"
upsert_env CEREBRAS_API_KEY "$CEREBRAS_API_KEY"
upsert_env GEMINI_API_KEY "$GEMINI_API_KEY"
upsert_env GITHUB_TOKEN "$GITHUB_TOKEN"
upsert_env BRAVE_API_KEY "$BRAVE_API_KEY"
upsert_env TAVILY_API_KEY "$TAVILY_API_KEY"

if [[ -n "$OPENROUTER_API_KEY" ]]; then
  hermes config set model.provider openrouter || true
  hermes config set model.default openrouter/free || true
elif [[ -n "$GROQ_API_KEY" ]]; then
  hermes config set model.provider groq || true
  hermes config set model.default qwen/qwen3-32b || true
elif [[ -n "$CEREBRAS_API_KEY" ]]; then
  hermes config set model.provider cerebras || true
  hermes config set model.default gpt-oss-120b || true
elif [[ -n "$GEMINI_API_KEY" ]]; then
  hermes config set model.provider gemini || true
  hermes config set model.default gemini-2.0-flash || true
else
  echo "No cloud model key set. You can still use Ollama/local models if configured."
fi

hermes config set display.skin eva-terminal || true

echo "Keys written to: $ENV_PATH"
echo "Run: hermes"

