#!/usr/bin/env bash
set -euo pipefail

REPO_URL="${HERMES_KIT_REPO_URL:-https://github.com/vavavadusik-crypto/hermes-agent-friend-kit.git}"
BRANCH="${HERMES_KIT_BRANCH:-main}"
ARCHIVE_URL="${HERMES_KIT_ARCHIVE_URL:-https://github.com/vavavadusik-crypto/hermes-agent-friend-kit/archive/refs/heads/${BRANCH}.tar.gz}"
INSTALL_DIR="${HERMES_KIT_INSTALL_DIR:-$HOME/hermes-agent-friend-kit}"

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd || true)"
if [[ -n "$script_dir" && -x "$script_dir/scripts/INSTALL_LINUX.sh" ]]; then
  ROOT="$script_dir"
else
  ROOT="$INSTALL_DIR"
  if [[ -d "$ROOT/.git" ]] && command -v git >/dev/null 2>&1; then
    git -C "$ROOT" pull --ff-only || true
  fi
  if [[ ! -x "$ROOT/scripts/INSTALL_LINUX.sh" ]]; then
    tmp_root="$(mktemp -d)"
    trap 'rm -rf "$tmp_root"' EXIT
    if command -v git >/dev/null 2>&1; then
      git clone --depth 1 --branch "$BRANCH" "$REPO_URL" "$tmp_root/repo"
    else
      mkdir -p "$tmp_root/repo"
      curl -fsSL "$ARCHIVE_URL" | tar -xz --strip-components=1 -C "$tmp_root/repo"
    fi
    rm -rf "$ROOT"
    mkdir -p "$(dirname "$ROOT")"
    mv "$tmp_root/repo" "$ROOT"
  fi
fi

"$ROOT/scripts/INSTALL_LINUX.sh"

if [[ "$(uname -s)" == "Linux" && -n "${DISPLAY:-}${WAYLAND_DISPLAY:-}" && -x "$ROOT/linux-desktop/install_launcher_linux.sh" ]]; then
  "$ROOT/linux-desktop/install_launcher_linux.sh" || true
fi

if [[ "${HERMES_KIT_CONFIGURE_AFTER:-0}" == "1" && -x "$ROOT/scripts/CONFIGURE_KEYS_LINUX.sh" ]]; then
  "$ROOT/scripts/CONFIGURE_KEYS_LINUX.sh" || true
fi

echo
echo "Install complete."
echo "Kit files: $ROOT"
echo "Settings: $ROOT/scripts/CONFIGURE_KEYS_LINUX.sh"
