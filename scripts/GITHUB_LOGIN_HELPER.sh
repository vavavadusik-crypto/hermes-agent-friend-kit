#!/usr/bin/env bash
set -euo pipefail

if ! command -v gh >/dev/null 2>&1; then
  echo "GitHub CLI 'gh' is not installed."
  exit 1
fi

if gh auth status >/dev/null 2>&1; then
  echo "GitHub CLI is already authenticated."
  gh auth status
  exit 0
fi

echo "Starting GitHub CLI device login."
echo
echo "If browser login is confusing, use this exact manual page:"
echo "https://github.com/login/device"
echo
echo "The terminal will show a one-time code like ABCD-1234."
echo "Type that code into the GitHub page, then approve the login."
echo "No API token needs to be pasted into chat."
echo

BROWSER=false gh auth login --web -h github.com -p https -s repo,workflow,read:user

echo
gh auth status
