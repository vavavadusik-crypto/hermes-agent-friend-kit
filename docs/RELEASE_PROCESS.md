# Release Process

## 1. Validate

Run the checks from `docs/GITHUB_HYGIENE_CHECKLIST.md`.

## 2. Commit

Use a clear commit message:

```bash
git status --short --branch
git add <changed files>
git commit -m "Describe the release change"
git push origin HEAD:main
```

## 3. Build release assets

```bash
version="vX.Y.Z"
release_dir="$HOME/Рабочий стол/Hermes-Agent-Release-$version"
mkdir -p "$release_dir"
cp setup/Hermes-Agent-Setup-Linux.sh "$release_dir/Hermes-Agent-Setup-Linux.sh"
cp setup/Hermes-Agent-Setup-Windows.cmd "$release_dir/Hermes-Agent-Setup-Windows.cmd"
git archive --format=zip --output="$release_dir/hermes-agent-friend-kit-$version.zip" HEAD
(
  cd "$release_dir"
  sha256sum Hermes-Agent-Setup-Linux.sh Hermes-Agent-Setup-Windows.cmd hermes-agent-friend-kit-$version.zip > SHA256SUMS.txt
)
```

## 4. Publish release

```bash
gh release create "$version" \
  "$release_dir/Hermes-Agent-Setup-Linux.sh" \
  "$release_dir/Hermes-Agent-Setup-Windows.cmd" \
  "$release_dir/hermes-agent-friend-kit-$version.zip" \
  "$release_dir/SHA256SUMS.txt" \
  --target main \
  --title "Hermes Agent Friend Kit $version" \
  --notes "Release notes here."
```

## 5. Verify

```bash
gh release list --limit 5
gh release view "$version" --json tagName,name,url,assets,publishedAt,targetCommitish
```
