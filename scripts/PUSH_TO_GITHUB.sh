#!/usr/bin/env bash
set -euo pipefail

REPO_NAME="${1:-hermes-agent-friend-kit}"
VISIBILITY="${2:---public}"

if ! command -v gh >/dev/null 2>&1; then
  echo "GitHub CLI 'gh' is not installed."
  exit 1
fi

if ! gh auth status >/dev/null 2>&1; then
  echo "GitHub CLI is not authenticated."
  echo "Run:"
  echo "  gh auth login -h github.com -p https -s repo,workflow,read:user"
  exit 1
fi

OWNER="$(gh api user --jq .login)"
REMOTE_URL="https://github.com/$OWNER/$REPO_NAME.git"

if git remote get-url origin >/dev/null 2>&1; then
  echo "origin already exists: $(git remote get-url origin)"
elif gh repo view "$OWNER/$REPO_NAME" >/dev/null 2>&1; then
  echo "Repository already exists: https://github.com/$OWNER/$REPO_NAME"
  git remote add origin "$REMOTE_URL"
else
  gh repo create "$REPO_NAME" "$VISIBILITY" --source=. --remote=origin --push
fi

if grep -q "YOUR_GITHUB_USERNAME" README.md docs/PUBLISH_TO_GITHUB.md 2>/dev/null; then
  sed -i "s/YOUR_GITHUB_USERNAME/$OWNER/g" README.md docs/PUBLISH_TO_GITHUB.md
  git add README.md docs/PUBLISH_TO_GITHUB.md
  git commit -m "Document published install URLs" || true
fi

git push -u origin main

echo "Repository ready:"
echo "https://github.com/$OWNER/$REPO_NAME"
echo
echo "Linux one-command install:"
echo "bash <(curl -fsSL https://raw.githubusercontent.com/$OWNER/$REPO_NAME/main/install.sh)"
echo
echo "Windows one-command install:"
echo "irm https://raw.githubusercontent.com/$OWNER/$REPO_NAME/main/install.ps1 | iex"
