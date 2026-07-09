#!/usr/bin/env bash
set -euo pipefail

export HERMES_KIT_CONFIGURE_AFTER="${HERMES_KIT_CONFIGURE_AFTER:-1}"
bash <(curl -fsSL https://raw.githubusercontent.com/vavavadusik-crypto/hermes-agent-friend-kit/main/install.sh)
