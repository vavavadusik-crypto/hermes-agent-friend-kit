# Publish to GitHub

Recommended repo name:

```text
hermes-agent-friend-kit
```

Authenticate GitHub CLI:

```bash
./scripts/GITHUB_LOGIN_HELPER.sh
```

Manual equivalent:

```bash
BROWSER=false gh auth login --web -h github.com -p https -s repo,workflow,read:user
```

Or with a token without printing it:

```bash
read -s GH_TOKEN
echo "$GH_TOKEN" | gh auth login --with-token
unset GH_TOKEN
```

Create and push:

```bash
./scripts/PUSH_TO_GITHUB.sh
```

The script creates or connects the repository, replaces `vavavadusik-crypto`
with the real owner, and prints one-command install links.

Manual owner replacement if needed:

```bash
OWNER="$(gh api user --jq .login)"
sed -i "s/vavavadusik-crypto/$OWNER/g" README.md docs/PUBLISH_TO_GITHUB.md
git add README.md docs/PUBLISH_TO_GITHUB.md
git commit -m "Document published install URLs"
git push
```
