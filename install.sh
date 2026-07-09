#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
"$ROOT/scripts/INSTALL_LINUX.sh"

if [[ -x "$ROOT/linux-desktop/install_launcher_linux.sh" ]]; then
  "$ROOT/linux-desktop/install_launcher_linux.sh" || true
fi

echo
echo "Install complete. Next edit scripts/SET_KEYS_LINUX.sh, paste your keys, and run it."

