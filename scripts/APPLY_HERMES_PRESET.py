#!/usr/bin/env python3
"""Apply the public Hermest/Hermes preset without storing secrets."""

from __future__ import annotations

import sys
from pathlib import Path

try:
    import yaml
except Exception as exc:  # pragma: no cover - user environment guard
    print(f"PyYAML is required to apply the preset: {exc}", file=sys.stderr)
    sys.exit(2)


CUSTOM_PROVIDERS = [
    {
        "name": "groq",
        "base_url": "https://api.groq.com/openai/v1",
        "api_key": "${GROQ_API_KEY}",
        "model": "qwen/qwen3-32b",
        "max_output_tokens": 4096,
    },
    {
        "name": "cerebras",
        "base_url": "https://api.cerebras.ai/v1",
        "api_key": "${CEREBRAS_API_KEY}",
        "model": "gpt-oss-120b",
        "max_output_tokens": 4096,
    },
    {
        "name": "gemini-openai",
        "base_url": "https://generativelanguage.googleapis.com/v1beta/openai",
        "api_key": "${GEMINI_API_KEY}",
        "model": "gemini-2.0-flash",
        "max_output_tokens": 4096,
    },
    {
        "name": "cohere",
        "base_url": "https://api.cohere.ai/v2",
        "api_key": "${COHERE_API_KEY}",
        "model": "command-r-plus-08-2024",
        "max_output_tokens": 4096,
    },
]

PROVIDERS = {
    "openai-api": {
        "api": "https://api.openai.com/v1",
        "api_key": "${OPENAI_API_KEY}",
        "default_model": "gpt-5.6-terra",
        "name": "OpenAI API",
    },
    "groq": {
        "api": "https://api.groq.com/openai/v1",
        "api_key": "${GROQ_API_KEY}",
        "default_model": "qwen/qwen3-32b",
        "name": "groq",
    },
    "cerebras": {
        "api": "https://api.cerebras.ai/v1",
        "api_key": "${CEREBRAS_API_KEY}",
        "default_model": "gpt-oss-120b",
        "name": "cerebras",
    },
    "gemini-openai": {
        "api": "https://generativelanguage.googleapis.com/v1beta/openai",
        "api_key": "${GEMINI_API_KEY}",
        "default_model": "gemini-2.0-flash",
        "name": "gemini-openai",
    },
    "cohere": {
        "api": "https://api.cohere.ai/v2",
        "api_key": "${COHERE_API_KEY}",
        "default_model": "command-r-plus-08-2024",
        "name": "cohere",
    },
    "ollama-launch": {
        "api": "http://127.0.0.1:11434/v1",
        "default_model": "omnicoder-9b-65536ctx:latest",
        "models": [
            "omnicoder-9b-65536ctx:latest",
            "carstenuhlig/omnicoder-9b:latest",
        ],
        "name": "Ollama",
    },
}

FALLBACK_PROVIDERS = [
    {
        "provider": "custom:groq",
        "model": "qwen/qwen3-32b",
    },
    {
        "provider": "custom:cerebras",
        "model": "gpt-oss-120b",
    },
    {
        "provider": "gemini",
        "model": "gemini-2.0-flash",
    },
    {
        "provider": "nvidia",
        "model": "nvidia/nemotron-3-super-120b-a12b",
        "base_url": "https://integrate.api.nvidia.com/v1",
    },
    {
        "provider": "ollama-launch",
        "model": "omnicoder-9b-65536ctx:latest",
        "base_url": "http://127.0.0.1:11434/v1",
    },
]


def load_yaml(path: Path) -> dict:
    if not path.exists():
        return {}
    data = yaml.safe_load(path.read_text(encoding="utf-8")) or {}
    return data if isinstance(data, dict) else {}


def merge_named_list(existing: object, additions: list[dict], key: str = "name") -> list[dict]:
    result: list[dict] = []
    seen: set[str] = set()
    if isinstance(existing, list):
        for item in existing:
            if isinstance(item, dict):
                name = str(item.get(key, "")).strip()
                if name:
                    seen.add(name)
                result.append(item)
    for item in additions:
        name = str(item.get(key, "")).strip()
        if name and name in seen:
            continue
        result.append(dict(item))
    return result


def merge_fallbacks(existing: object) -> list[dict]:
    result: list[dict] = []
    seen: set[tuple[str, str]] = set()
    if isinstance(existing, list):
        for item in existing:
            if isinstance(item, dict):
                marker = (str(item.get("provider", "")), str(item.get("model", "")))
                seen.add(marker)
                result.append(item)
    for item in FALLBACK_PROVIDERS:
        marker = (str(item.get("provider", "")), str(item.get("model", "")))
        if marker not in seen:
            result.append(dict(item))
    return result


def main() -> int:
    if len(sys.argv) != 2:
        print("Usage: APPLY_HERMES_PRESET.py /path/to/config.yaml", file=sys.stderr)
        return 2

    path = Path(sys.argv[1]).expanduser()
    path.parent.mkdir(parents=True, exist_ok=True)
    cfg = load_yaml(path)

    display = cfg.setdefault("display", {})
    if isinstance(display, dict):
        display["skin"] = "eva-terminal"

    providers = cfg.setdefault("providers", {})
    if isinstance(providers, dict):
        for name, value in PROVIDERS.items():
            providers.setdefault(name, value)

    cfg["custom_providers"] = merge_named_list(cfg.get("custom_providers"), CUSTOM_PROVIDERS)
    cfg["fallback_providers"] = merge_fallbacks(cfg.get("fallback_providers"))

    model = cfg.setdefault("model", {})
    if isinstance(model, dict) and not model.get("provider"):
        model["provider"] = "openrouter"
        model["default"] = "openrouter/free"
        model["max_tokens"] = 4096

    path.write_text(yaml.safe_dump(cfg, sort_keys=False, allow_unicode=True), encoding="utf-8")
    print(f"Applied public Hermes preset: {path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
