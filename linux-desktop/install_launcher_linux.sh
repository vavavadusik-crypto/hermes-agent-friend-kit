#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
mkdir -p "$HOME/.local/bin" "$HOME/.local/share/applications"

cp "$ROOT/linux-desktop/hermes-agent-window" "$HOME/.local/bin/hermes-agent-window"
cp "$ROOT/linux-desktop/hermes-agent-launcher" "$HOME/.local/bin/hermes-agent-launcher"
cp "$ROOT/scripts/AUTO_ROUTE_LINUX.sh" "$HOME/.local/bin/hermes-agent-auto-route"
chmod +x "$HOME/.local/bin/hermes-agent-window" "$HOME/.local/bin/hermes-agent-launcher" "$HOME/.local/bin/hermes-agent-auto-route"

cat > "$HOME/.local/bin/hermes-agent-settings" <<EOF
#!/usr/bin/env bash
set -euo pipefail
ROOT="$ROOT"
if command -v ptyxis >/dev/null 2>&1; then
  exec ptyxis --new-window -T "Hermes Agent Settings" -- "\$ROOT/scripts/CONFIGURE_KEYS_LINUX.sh"
elif command -v gnome-terminal >/dev/null 2>&1; then
  exec gnome-terminal --title="Hermes Agent Settings" -- "\$ROOT/scripts/CONFIGURE_KEYS_LINUX.sh"
elif command -v xterm >/dev/null 2>&1; then
  exec xterm -T "Hermes Agent Settings" -e "\$ROOT/scripts/CONFIGURE_KEYS_LINUX.sh"
else
  exec "\$ROOT/scripts/CONFIGURE_KEYS_LINUX.sh"
fi
EOF
chmod +x "$HOME/.local/bin/hermes-agent-settings"

DESKTOP_FILE="$HOME/.local/share/applications/hermes-agent.desktop"
cat > "$DESKTOP_FILE" <<'EOF'
[Desktop Entry]
Type=Application
Name=Hermes Agent
Comment=Open Hermes Agent terminal interface
Exec=__HOME__/.local/bin/hermes-agent-launcher
Icon=utilities-terminal
Terminal=false
Categories=Development;
StartupNotify=true
Keywords=Hermes;Hermest;Agent;AI;CLI;
EOF

SETTINGS_DESKTOP_FILE="$HOME/.local/share/applications/hermes-agent-settings.desktop"
cat > "$SETTINGS_DESKTOP_FILE" <<'EOF'
[Desktop Entry]
Type=Application
Name=Hermes Agent Settings
Comment=Configure Hermes Agent API keys, model provider, and fallback route
Exec=__HOME__/.local/bin/hermes-agent-settings
Icon=preferences-system
Terminal=false
Categories=Settings;
StartupNotify=true
Keywords=Hermes;Agent;Settings;API;Keys;Model;
EOF

for file in "$DESKTOP_FILE" "$SETTINGS_DESKTOP_FILE"; do
  escaped_home="${HOME//\\/\\\\}"
  escaped_home="${escaped_home//&/\\&}"
  sed -i "s#__HOME__#$escaped_home#g" "$file"
done

chmod +x "$DESKTOP_FILE" "$SETTINGS_DESKTOP_FILE"
if command -v update-desktop-database >/dev/null 2>&1; then
  update-desktop-database "$HOME/.local/share/applications" 2>/dev/null || true
fi

DESKTOP_DIR="$HOME/Desktop"
if [[ -d "$HOME/Рабочий стол" ]]; then
  DESKTOP_DIR="$HOME/Рабочий стол"
fi
if [[ -d "$DESKTOP_DIR" ]]; then
  cp "$DESKTOP_FILE" "$DESKTOP_DIR/Hermes Agent.desktop"
  cp "$SETTINGS_DESKTOP_FILE" "$DESKTOP_DIR/Hermes Agent Settings.desktop"
  chmod +x "$DESKTOP_DIR/Hermes Agent.desktop"
  chmod +x "$DESKTOP_DIR/Hermes Agent Settings.desktop"
  gio set "$DESKTOP_DIR/Hermes Agent.desktop" metadata::trusted true 2>/dev/null || true
  gio set "$DESKTOP_DIR/Hermes Agent Settings.desktop" metadata::trusted true 2>/dev/null || true
fi

echo "Linux desktop launcher installed."
