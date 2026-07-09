#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export PATH="$HOME/.local/bin:$HOME/.hermes/bin:$PATH"

if ! command -v hermes >/dev/null 2>&1; then
  echo "Hermes is not installed or not in PATH. Run install.sh first."
  exit 1
fi

CONFIG_PATH="$(hermes config path 2>/dev/null || true)"
if [[ -z "$CONFIG_PATH" ]]; then
  CONFIG_PATH="$HOME/.hermes/config.yaml"
fi
ENV_PATH="$(hermes config env-path 2>/dev/null || true)"
if [[ -z "$ENV_PATH" ]]; then
  ENV_PATH="$HOME/.hermes/.env"
fi

mkdir -p "$(dirname "$CONFIG_PATH")" "$(dirname "$ENV_PATH")"
touch "$ENV_PATH"
chmod 600 "$ENV_PATH"

if command -v python3 >/dev/null 2>&1; then
  python3 "$ROOT/scripts/APPLY_HERMES_PRESET.py" "$CONFIG_PATH" || true
elif command -v python >/dev/null 2>&1; then
  python "$ROOT/scripts/APPLY_HERMES_PRESET.py" "$CONFIG_PATH" || true
fi

escape_env_value() {
  printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g; s/\$/\\$/g; s/`/\\`/g'
}

upsert_env() {
  local key="$1"
  local value="$2"
  [[ -n "$value" ]] || return 0
  local tmp escaped
  tmp="$(mktemp)"
  escaped="$(escape_env_value "$value")"
  grep -v "^${key}=" "$ENV_PATH" > "$tmp" || true
  printf '%s="%s"\n' "$key" "$escaped" >> "$tmp"
  install -m 600 "$tmp" "$ENV_PATH"
  rm -f "$tmp"
}

prompt_secret() {
  local label="$1"
  local value=""
  if command -v zenity >/dev/null 2>&1 && [[ -n "${DISPLAY:-}${WAYLAND_DISPLAY:-}" ]]; then
    value="$(zenity --password --title="$label" --text="$label (leave empty to skip)" 2>/tmp/hermes-settings.log || true)"
  else
    printf '%s (leave empty to skip): ' "$label"
    read -r -s value || value=""
    printf '\n'
  fi
  printf '%s' "$value"
}

choose_provider() {
  if command -v zenity >/dev/null 2>&1 && [[ -n "${DISPLAY:-}${WAYLAND_DISPLAY:-}" ]]; then
    zenity --list \
      --title="Hermes Agent Settings" \
      --text="Choose the main provider to configure now" \
      --column="Provider" \
      "OpenRouter free/low-cost" \
      "Groq" \
      "Cerebras" \
      "Gemini" \
      "NVIDIA NIM" \
      "Z.AI / GLM" \
      "Kimi / Moonshot" \
      "Ollama local/no key" \
      "Skip provider setup" \
      2>/tmp/hermes-settings.log || true
  else
    cat <<'MENU'
Choose the main provider to configure now:
1) OpenRouter free/low-cost
2) Groq
3) Cerebras
4) Gemini
5) NVIDIA NIM
6) Z.AI / GLM
7) Kimi / Moonshot
8) Ollama local/no key
9) Skip provider setup
MENU
    printf 'Choice [1-9]: '
    local choice
    read -r choice || choice="9"
    case "$choice" in
      1) echo "OpenRouter free/low-cost" ;;
      2) echo "Groq" ;;
      3) echo "Cerebras" ;;
      4) echo "Gemini" ;;
      5) echo "NVIDIA NIM" ;;
      6) echo "Z.AI / GLM" ;;
      7) echo "Kimi / Moonshot" ;;
      8) echo "Ollama local/no key" ;;
      *) echo "Skip provider setup" ;;
    esac
  fi
}

provider="$(choose_provider)"
case "$provider" in
  "OpenRouter free/low-cost")
    key="$(prompt_secret "OPENROUTER_API_KEY")"
    upsert_env OPENROUTER_API_KEY "$key"
    hermes config set model.provider openrouter || true
    hermes config set model.default openrouter/free || true
    ;;
  "Groq")
    key="$(prompt_secret "GROQ_API_KEY")"
    upsert_env GROQ_API_KEY "$key"
    hermes config set model.provider custom:groq || true
    hermes config set model.default qwen/qwen3-32b || true
    ;;
  "Cerebras")
    key="$(prompt_secret "CEREBRAS_API_KEY")"
    upsert_env CEREBRAS_API_KEY "$key"
    hermes config set model.provider custom:cerebras || true
    hermes config set model.default gpt-oss-120b || true
    ;;
  "Gemini")
    key="$(prompt_secret "GEMINI_API_KEY")"
    upsert_env GEMINI_API_KEY "$key"
    upsert_env GOOGLE_API_KEY "$key"
    hermes config set model.provider gemini || true
    hermes config set model.default gemini-2.0-flash || true
    ;;
  "NVIDIA NIM")
    key="$(prompt_secret "NVIDIA_API_KEY")"
    upsert_env NVIDIA_API_KEY "$key"
    hermes config set model.provider nvidia || true
    hermes config set model.default nvidia/nemotron-3-super-120b-a12b || true
    ;;
  "Z.AI / GLM")
    key="$(prompt_secret "GLM_API_KEY")"
    upsert_env GLM_API_KEY "$key"
    hermes config set model.provider zai || true
    hermes config set model.default zai-org/GLM-5.1-FP8 || true
    ;;
  "Kimi / Moonshot")
    key="$(prompt_secret "KIMI_API_KEY")"
    upsert_env KIMI_API_KEY "$key"
    hermes config set model.provider kimi-coding || true
    ;;
  "Ollama local/no key")
    hermes config set model.provider ollama-launch || true
    hermes config set model.default glm-5.2:cloud || true
    ;;
esac

github_key="$(prompt_secret "Optional GITHUB_TOKEN for repo/issues higher limits")"
upsert_env GITHUB_TOKEN "$github_key"

search_key="$(prompt_secret "Optional TAVILY_API_KEY for web search")"
upsert_env TAVILY_API_KEY "$search_key"

brave_key="$(prompt_secret "Optional BRAVE_API_KEY for web search")"
upsert_env BRAVE_API_KEY "$brave_key"

echo
echo "Settings saved."
echo "Config: $CONFIG_PATH"
echo "Env: $ENV_PATH"
echo "Run: hermes"
