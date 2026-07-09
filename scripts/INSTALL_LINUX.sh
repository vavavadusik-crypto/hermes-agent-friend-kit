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

hermes config set display.skin eva-terminal || true
hermes config set toolsets '["hermes-cli","web"]' || true

echo
echo "Hermes installed/configured."
echo "Next:"
echo "1. Edit scripts/SET_KEYS_LINUX.sh and paste your own keys."
echo "2. Run: ./scripts/SET_KEYS_LINUX.sh"
echo "3. Start: hermes"
echo

