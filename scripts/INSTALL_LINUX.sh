#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "== Hermes Agent Linux/macOS/WSL2 installer =="

if ! command -v hermes >/dev/null 2>&1; then
  echo "Installing Hermes Agent from the official installer..."
  curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash
fi

export PATH="$HOME/.local/bin:$HOME/.hermes/bin:$PATH"

if ! command -v hermes >/dev/null 2>&1; then
  echo "Hermes command not found after install. Open a new terminal and run this script again."
  exit 1
fi

HERMES_CONFIG_PATH="$(hermes config path 2>/dev/null || true)"
if [[ -n "$HERMES_CONFIG_PATH" ]]; then
  HERMES_HOME="$(dirname "$HERMES_CONFIG_PATH")"
else
  HERMES_HOME="${HERMES_HOME:-$HOME/.hermes}"
fi

mkdir -p "$HERMES_HOME/skins"
cp "$ROOT/skins/eva-terminal.yaml" "$HERMES_HOME/skins/eva-terminal.yaml"

if command -v python3 >/dev/null 2>&1; then
  python3 "$ROOT/scripts/APPLY_HERMES_PRESET.py" "$HERMES_CONFIG_PATH" || true
elif command -v python >/dev/null 2>&1; then
  python "$ROOT/scripts/APPLY_HERMES_PRESET.py" "$HERMES_CONFIG_PATH" || true
else
  hermes config set display.skin eva-terminal || true
fi

echo
echo "Hermes installed/configured."
echo "Next:"
echo "1. Run: ./scripts/CONFIGURE_KEYS_LINUX.sh"
echo "2. Add your own API keys when asked."
echo "3. Start: hermes"
echo
