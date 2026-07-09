#!/usr/bin/env bash
set -euo pipefail

export PATH="$HOME/.local/bin:$HOME/.hermes/bin:$PATH"

quiet=0
status_only=0
for arg in "$@"; do
  case "$arg" in
    --quiet) quiet=1 ;;
    --status) status_only=1 ;;
  esac
done

if ! command -v hermes >/dev/null 2>&1; then
  (( quiet )) || echo "Hermes is not installed or not in PATH."
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

mkdir -p "$(dirname "$CONFIG_PATH")" "$(dirname "$ENV_PATH")" "${XDG_CACHE_HOME:-$HOME/.cache}/hermes-agent"
touch "$ENV_PATH"
chmod 600 "$ENV_PATH"

python3 - "$CONFIG_PATH" "$ENV_PATH" "$quiet" "$status_only" "${XDG_CACHE_HOME:-$HOME/.cache}/hermes-agent/auto-route.log" <<'PY'
from __future__ import annotations

import json
import re
import sys
import urllib.error
import urllib.request
from datetime import datetime, timezone
from pathlib import Path

import yaml

config_path = Path(sys.argv[1]).expanduser()
env_path = Path(sys.argv[2]).expanduser()
quiet = sys.argv[3] == "1"
status_only = sys.argv[4] == "1"
log_path = Path(sys.argv[5]).expanduser()
timeout = float(__import__("os").environ.get("HERMES_AGENT_ROUTE_TIMEOUT", "5"))
allow_local = __import__("os").environ.get("HERMES_AGENT_ALLOW_LOCAL", "0") == "1"


def log(message: str) -> None:
    log_path.parent.mkdir(parents=True, exist_ok=True)
    stamp = datetime.now(timezone.utc).isoformat(timespec="seconds")
    with log_path.open("a", encoding="utf-8") as handle:
        handle.write(f"{stamp} {message}\n")


def load_cfg() -> dict:
    if not config_path.exists():
        return {}
    data = yaml.safe_load(config_path.read_text(encoding="utf-8")) or {}
    return data if isinstance(data, dict) else {}


def env_value(key: str) -> str:
    if not env_path.exists():
        return ""
    pat = re.compile(rf"^{re.escape(key)}=(.*)$")
    value = ""
    for line in env_path.read_text(encoding="utf-8", errors="replace").splitlines():
        match = pat.match(line.strip())
        if not match:
            continue
        raw = match.group(1).strip()
        if raw.startswith('"') and raw.endswith('"'):
            raw = raw[1:-1]
            raw = raw.replace(r"\"", '"').replace(r"\\", "\\")
        elif raw.startswith("'") and raw.endswith("'"):
            raw = raw[1:-1]
        value = raw.strip()
    return value


def ensure_provider(cfg: dict, name: str, api: str, default_model: str, key_env: str | None = None, label: str | None = None, models: list[str] | None = None) -> None:
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


def ensure_custom(cfg: dict, name: str, base_url: str, model: str, key_env: str) -> None:
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


def http_request(url: str, *, method: str = "GET", token: str = "", headers: dict[str, str] | None = None, payload: dict | None = None) -> tuple[bool, str]:
    final_headers = dict(headers or {})
    if token:
        final_headers.setdefault("Authorization", f"Bearer {token}")
    data = None
    if payload is not None:
        data = json.dumps(payload).encode("utf-8")
        final_headers.setdefault("Content-Type", "application/json")
    request = urllib.request.Request(url, data=data, headers=final_headers, method=method)
    try:
        with urllib.request.urlopen(request, timeout=timeout) as response:
            code = int(getattr(response, "status", 200))
            return 200 <= code < 300, f"http {code}"
    except urllib.error.HTTPError as exc:
        return False, f"http {exc.code}"
    except Exception as exc:
        return False, exc.__class__.__name__


def probe_openai_chat(url: str, key: str, model: str, headers: dict[str, str] | None = None) -> tuple[bool, str]:
    if not key:
        return False, "missing key"
    payload = {
        "model": model,
        "messages": [{"role": "user", "content": "ping"}],
        "max_tokens": 1,
        "temperature": 0,
        "stream": False,
    }
    return http_request(url, method="POST", token=key, headers=headers, payload=payload)


def probe_gemini(key: str) -> tuple[bool, str]:
    if not key:
        return False, "missing key"
    payload = {
        "contents": [{"parts": [{"text": "ping"}]}],
        "generationConfig": {"maxOutputTokens": 1, "temperature": 0},
    }
    return http_request(
        "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent",
        method="POST",
        headers={"x-goog-api-key": key},
        payload=payload,
    )


def probe_ollama(model: str) -> tuple[bool, str]:
    ok, reason = http_request("http://127.0.0.1:11434/api/tags")
    if not ok:
        return False, reason
    try:
        with urllib.request.urlopen("http://127.0.0.1:11434/api/tags", timeout=timeout) as response:
            payload = json.loads(response.read().decode("utf-8", errors="replace"))
        names = {item.get("name") for item in payload.get("models", []) if isinstance(item, dict)}
        if model in names:
            return True, "local model present"
        return False, "local model missing"
    except Exception as exc:
        return False, exc.__class__.__name__


def probe_ollama_generate(model: str) -> tuple[bool, str]:
    payload = {
        "model": model,
        "prompt": "Reply OK only.",
        "stream": False,
        "options": {"num_predict": 1},
    }
    ok, reason = http_request("http://127.0.0.1:11434/api/generate", method="POST", payload=payload)
    return ok, reason


ROUTES = {
    "groq": {
        "provider": "custom:groq",
        "model": "qwen/qwen3-32b",
        "env": "GROQ_API_KEY",
        "probe": lambda key: probe_openai_chat("https://api.groq.com/openai/v1/chat/completions", key, "qwen/qwen3-32b"),
    },
    "cerebras": {
        "provider": "custom:cerebras",
        "model": "gpt-oss-120b",
        "env": "CEREBRAS_API_KEY",
        "probe": lambda key: probe_openai_chat("https://api.cerebras.ai/v1/chat/completions", key, "gpt-oss-120b"),
    },
    "gemini": {
        "provider": "gemini",
        "model": "gemini-2.0-flash",
        "env": "GEMINI_API_KEY",
        "probe": probe_gemini,
    },
    "nvidia": {
        "provider": "nvidia",
        "model": "nvidia/nemotron-3-super-120b-a12b",
        "env": "NVIDIA_API_KEY",
        "base_url": "https://integrate.api.nvidia.com/v1",
        "probe": lambda key: probe_openai_chat("https://integrate.api.nvidia.com/v1/chat/completions", key, "nvidia/nemotron-3-super-120b-a12b"),
    },
    "openrouter": {
        "provider": "openrouter",
        "model": "openai/gpt-oss-20b:free",
        "env": "OPENROUTER_API_KEY",
        "probe": lambda key: probe_openai_chat(
            "https://openrouter.ai/api/v1/chat/completions",
            key,
            "openai/gpt-oss-20b:free",
            {"HTTP-Referer": "https://github.com/vavavadusik-crypto/hermes-agent-friend-kit", "X-Title": "Hermes Agent Friend Kit"},
        ),
    },
    "ollama-glm-cloud": {
        "provider": "ollama-launch",
        "model": "glm-5.2:cloud",
        "base_url": "http://127.0.0.1:11434/v1",
        "probe": lambda _key: probe_ollama_generate("glm-5.2:cloud"),
    },
    "ollama-kimi-cloud": {
        "provider": "ollama-launch",
        "model": "kimi-k2.7-code:cloud",
        "base_url": "http://127.0.0.1:11434/v1",
        "probe": lambda _key: probe_ollama_generate("kimi-k2.7-code:cloud"),
    },
    "ollama-local": {
        "provider": "custom",
        "model": "omnicoder-9b-65536ctx:latest",
        "base_url": "http://127.0.0.1:11434/v1",
        "probe": lambda _key: probe_ollama("omnicoder-9b-65536ctx:latest"),
    },
}

cfg = load_cfg()

ensure_provider(cfg, "openai-api", "https://api.openai.com/v1", "gpt-5.6-terra", "OPENAI_API_KEY", "OpenAI API")
ensure_provider(cfg, "groq", "https://api.groq.com/openai/v1", "qwen/qwen3-32b", "GROQ_API_KEY", "groq")
ensure_provider(cfg, "cerebras", "https://api.cerebras.ai/v1", "gpt-oss-120b", "CEREBRAS_API_KEY", "cerebras")
ensure_provider(cfg, "gemini-openai", "https://generativelanguage.googleapis.com/v1beta/openai", "gemini-2.0-flash", "GEMINI_API_KEY", "gemini-openai")
ensure_provider(
    cfg,
    "ollama-launch",
    "http://127.0.0.1:11434/v1",
    "omnicoder-9b-65536ctx:latest",
    None,
    "Ollama",
    ["omnicoder-9b-65536ctx:latest", "carstenuhlig/omnicoder-9b:latest"],
)
ensure_custom(cfg, "groq", "https://api.groq.com/openai/v1", "qwen/qwen3-32b", "GROQ_API_KEY")
ensure_custom(cfg, "cerebras", "https://api.cerebras.ai/v1", "gpt-oss-120b", "CEREBRAS_API_KEY")
ensure_custom(cfg, "gemini-openai", "https://generativelanguage.googleapis.com/v1beta/openai", "gemini-2.0-flash", "GEMINI_API_KEY")

cloud_available: list[str] = []
openrouter_ok = False
statuses: list[tuple[str, bool, str]] = []
for name in ["groq", "cerebras", "gemini", "nvidia", "openrouter"]:
    spec = ROUTES[name]
    key = env_value(str(spec["env"]))
    ok, reason = spec["probe"](key)  # type: ignore[index]
    statuses.append((name, ok, reason))
    if ok and name != "openrouter":
        cloud_available.append(name)
    if ok and name == "openrouter":
        openrouter_ok = True
    elif name == "openrouter":
        openrouter_ok = False

for name in ["ollama-glm-cloud", "ollama-kimi-cloud"]:
    ok, reason = ROUTES[name]["probe"]("")  # type: ignore[index]
    statuses.append((name, ok, reason))
    if ok:
        cloud_available.append(name)

available: list[str] = list(cloud_available)
if not available and openrouter_ok:
    available.append("openrouter")
if allow_local:
    ollama_ok, ollama_reason = ROUTES["ollama-local"]["probe"]("")  # type: ignore[index]
    statuses.append(("ollama-local", ollama_ok, ollama_reason))
    if ollama_ok:
        available.append("ollama-local")
else:
    statuses.append(("ollama-local", False, "disabled"))

if not available:
    fallback_provider = "openrouter" if env_value("OPENROUTER_API_KEY") else "ollama-launch"
    fallback_model = "openrouter/free" if fallback_provider == "openrouter" else "glm-5.2:cloud"
    model = cfg.setdefault("model", {})
    if not isinstance(model, dict):
        model = {}
        cfg["model"] = model
    model["provider"] = fallback_provider
    model["default"] = fallback_model
    model["max_tokens"] = 4096
    model.pop("api_key", None)
    model.pop("base_url", None)
    cfg["fallback_providers"] = []
    config_path.write_text(yaml.safe_dump(cfg, sort_keys=False, allow_unicode=True), encoding="utf-8")
    log("selected=none statuses=" + ", ".join(f"{name}:{'ok' if ok else reason}" for name, ok, reason in statuses))
    if status_only:
        print(f"Config: {config_path}")
        print(f"Env: {env_path}")
        print("Active: unavailable")
        for name, ok, reason in statuses:
            print(f"{name}: {'ok' if ok else 'skip'} ({reason})")
    elif not quiet:
        print("No working remote provider right now. Local Ollama is disabled for weak laptops.")
    sys.exit(2)

selected = available[0]
selected_spec = ROUTES[selected]

fallbacks = []
seen = set()
for name in available:
    spec = ROUTES[name]
    marker = (spec["provider"], spec["model"])
    if marker in seen:
        continue
    seen.add(marker)
    item = {"provider": spec["provider"], "model": spec["model"]}
    if spec.get("base_url"):
        item["base_url"] = spec["base_url"]
    fallbacks.append(item)
cfg["fallback_providers"] = fallbacks

model = cfg.setdefault("model", {})
if not isinstance(model, dict):
    model = {}
    cfg["model"] = model
model["provider"] = selected_spec["provider"]
model["default"] = selected_spec["model"]
model["max_tokens"] = 4096
model.pop("api_key", None)
if selected_spec.get("base_url"):
    model["base_url"] = selected_spec["base_url"]
else:
    model.pop("base_url", None)

config_path.write_text(yaml.safe_dump(cfg, sort_keys=False, allow_unicode=True), encoding="utf-8")

log(
    "selected="
    + selected
    + " statuses="
    + ", ".join(f"{name}:{'ok' if ok else reason}" for name, ok, reason in statuses)
)

if status_only:
    print(f"Config: {config_path}")
    print(f"Env: {env_path}")
    print(f"Active: {model.get('provider')} / {model.get('default')}")
    for name, ok, reason in statuses:
        print(f"{name}: {'ok' if ok else 'skip'} ({reason})")
    print("Fallback:")
    for i, item in enumerate(fallbacks, 1):
        extra = f" [{item.get('base_url')}]" if item.get("base_url") else ""
        print(f"  {i}. {item.get('provider')} / {item.get('model')}{extra}")
elif not quiet:
    print(f"Auto route: {model.get('provider')} / {model.get('default')}")
PY
