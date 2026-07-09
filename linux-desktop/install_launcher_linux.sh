#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
mkdir -p "$HOME/.local/bin" "$HOME/.local/share/applications"

cp "$ROOT/linux-desktop/hermes-agent-window" "$HOME/.local/bin/hermes-agent-window"
cp "$ROOT/linux-desktop/hermes-agent-launcher" "$HOME/.local/bin/hermes-agent-launcher"
chmod +x "$HOME/.local/bin/hermes-agent-window" "$HOME/.local/bin/hermes-agent-launcher"

DESKTOP_FILE="$HOME/.local/share/applications/hermes-agent.desktop"
cat > "$DESKTOP_FILE" <<'EOF'
[Desktop Entry]
Type=Application
Name=Hermes Agent
Comment=Open Hermes Agent with zoom selector
Exec=/home/%u/.local/bin/hermes-agent-launcher
Icon=utilities-terminal
Terminal=false
Categories=Development;
StartupNotify=true
Keywords=Hermes;Agent;AI;CLI;
EOF

python3 - "$DESKTOP_FILE" <<'PY'
import os, sys
path = sys.argv[1]
home = os.path.expanduser("~")
text = open(path, encoding="utf-8").read().replace("/home/%u", home)
open(path, "w", encoding="utf-8").write(text)
PY

chmod +x "$DESKTOP_FILE"
if command -v update-desktop-database >/dev/null 2>&1; then
  update-desktop-database "$HOME/.local/share/applications" 2>/dev/null || true
fi

DESKTOP_DIR="$HOME/Desktop"
if [[ -d "$HOME/Рабочий стол" ]]; then
  DESKTOP_DIR="$HOME/Рабочий стол"
fi
if [[ -d "$DESKTOP_DIR" ]]; then
  cp "$DESKTOP_FILE" "$DESKTOP_DIR/Hermes Agent.desktop"
  chmod +x "$DESKTOP_DIR/Hermes Agent.desktop"
  gio set "$DESKTOP_DIR/Hermes Agent.desktop" metadata::trusted true 2>/dev/null || true
fi

echo "Linux desktop launcher installed."

