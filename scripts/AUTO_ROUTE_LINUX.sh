#!/usr/bin/env bash
set -euo pipefail

export PATH="$HOME/.local/bin:$HOME/.hermes/bin:$PATH"

if ! command -v hermes >/dev/null 2>&1; then
  echo "Hermes is not installed or not in PATH."
  exit 0
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

python3 - "$CONFIG_PATH" "$ENV_PATH" <<'PY'
from __future__ import annotations

import re
import sys
from pathlib import Path

import yaml

config_path = Path(sys.argv[1]).expanduser()
env_path = Path(sys.argv[2]).expanduser()

cfg = yaml.safe_load(config_path.read_text(encoding="utf-8")) if config_path.exists() else {}
if not isinstance(cfg, dict):
    cfg = {}


def env_has(key: str) -> bool:
    if not env_path.exists():
        return False
    pattern = re.compile(rf"^{re.escape(key)}=(\"[^\"]+\"|'[^']+'|[^#\s]+)")
    return any(pattern.search(line) for line in env_path.read_text(encoding="utf-8", errors="replace").splitlines())


def ensure_provider(name: str, api: str, default_model: str, key_env: str | None = None, label: str | None = None, models: list[str] | None = None) -> None:
    providers = cfg.setdefault("providers", {})
    if not isinstance(providers, dict):
        providers = {}
        cfg["providers"] = providers
    entry = providers.get(name)
    if not isinstance(entry, dict):
        entry = {}
        providers[name] = entry
    entry["api"] = api
    entry["name"] = label or name
    entry["default_model"] = default_model
    if models:
        entry["models"] = models
    if key_env and not any(k in entry for k in ("api_key", "key_env")):
        entry["api_key"] = "${" + key_env + "}"


def ensure_custom(name: str, base_url: str, model: str, key_env: str) -> None:
    custom = cfg.get("custom_providers")
    if not isinstance(custom, list):
        custom = []
        cfg["custom_providers"] = custom
    entry = next((item for item in custom if isinstance(item, dict) and item.get("name") == name), None)
    if entry is None:
        entry = {"name": name}
        custom.append(entry)
    entry["base_url"] = base_url
    entry["model"] = model
    entry["max_output_tokens"] = 4096
    if not any(k in entry for k in ("api_key", "key_env")):
        entry["api_key"] = "${" + key_env + "}"


ensure_provider("openai-api", "https://api.openai.com/v1", "gpt-5.6-terra", "OPENAI_API_KEY", "OpenAI API")
ensure_provider("groq", "https://api.groq.com/openai/v1", "qwen/qwen3-32b", "GROQ_API_KEY", "groq")
ensure_provider("cerebras", "https://api.cerebras.ai/v1", "gpt-oss-120b", "CEREBRAS_API_KEY", "cerebras")
ensure_provider("gemini-openai", "https://generativelanguage.googleapis.com/v1beta/openai", "gemini-2.0-flash", "GEMINI_API_KEY", "gemini-openai")
ensure_provider(
    "ollama-launch",
    "http://127.0.0.1:11434/v1",
    "omnicoder-9b-65536ctx:latest",
    None,
    "Ollama",
    ["omnicoder-9b-65536ctx:latest", "carstenuhlig/omnicoder-9b:latest"],
)

ensure_custom("groq", "https://api.groq.com/openai/v1", "qwen/qwen3-32b", "GROQ_API_KEY")
ensure_custom("cerebras", "https://api.cerebras.ai/v1", "gpt-oss-120b", "CEREBRAS_API_KEY")
ensure_custom("gemini-openai", "https://generativelanguage.googleapis.com/v1beta/openai", "gemini-2.0-flash", "GEMINI_API_KEY")

cfg["fallback_providers"] = [
    {"provider": "custom:groq", "model": "qwen/qwen3-32b"},
    {"provider": "custom:cerebras", "model": "gpt-oss-120b"},
    {"provider": "gemini", "model": "gemini-2.0-flash"},
    {"provider": "nvidia", "model": "nvidia/nemotron-3-super-120b-a12b", "base_url": "https://integrate.api.nvidia.com/v1"},
    {"provider": "custom", "model": "omnicoder-9b-65536ctx:latest", "base_url": "http://127.0.0.1:11434/v1"},
]

if env_has("GROQ_API_KEY"):
    provider, model_name, base_url = "custom:groq", "qwen/qwen3-32b", None
elif env_has("CEREBRAS_API_KEY"):
    provider, model_name, base_url = "custom:cerebras", "gpt-oss-120b", None
elif env_has("GEMINI_API_KEY") or env_has("GOOGLE_API_KEY"):
    provider, model_name, base_url = "gemini", "gemini-2.0-flash", None
elif env_has("NVIDIA_API_KEY"):
    provider, model_name, base_url = "nvidia", "nvidia/nemotron-3-super-120b-a12b", None
elif env_has("OPENROUTER_API_KEY"):
    provider, model_name, base_url = "openrouter", "openrouter/free", None
else:
    provider, model_name, base_url = "custom", "omnicoder-9b-65536ctx:latest", "http://127.0.0.1:11434/v1"

model = cfg.setdefault("model", {})
if not isinstance(model, dict):
    model = {}
    cfg["model"] = model
model["provider"] = provider
model["default"] = model_name
model["max_tokens"] = 4096
if base_url:
    model["base_url"] = base_url
else:
    model.pop("base_url", None)

config_path.write_text(yaml.safe_dump(cfg, sort_keys=False, allow_unicode=True), encoding="utf-8")
print(f"Auto route: {provider} / {model_name}")
PY
