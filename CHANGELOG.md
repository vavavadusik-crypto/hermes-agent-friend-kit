# Changelog

All notable public changes to Hermes Agent Friend Kit are summarized here.

## v1.1.4 - GitHub hygiene and docs alignment

- Added GitHub maintenance docs and status checklists.
- Added GitHub Actions validation, issue templates, and pull request template.
- Added release checksum workflow documentation.
- Clarified that local Ollama is disabled by default in auto-route.
- Clarified that auto-route verifies real generation endpoints and skips
  exhausted or unauthorized providers.
- Added a safety-first project status file and release process.

## v1.1.3 - Safe weak-laptop fallback

- Disabled local Ollama fallback by default.
- Added `HERMES_AGENT_ALLOW_LOCAL=1` as the explicit local fallback opt-in.
- Changed auto-route to check actual generation endpoints instead of only
  checking whether an API key exists.
- Added safe stop behavior when every remote/free provider is exhausted.

## v1.1.2 - Launch auto-route

- Added launch-time auto-route for Linux and Windows launchers.
- Added friend-facing install letter.
- Added setup assets for GitHub releases.

## v1.1.1 - GPT-5.6 optional route

- Added GPT-5.6 optional premium routing docs.
- Improved free/limited provider fallback guidance.

## v1.1.0 - One-click setup

- Added one-click setup files for Linux and Windows.
- Added API key setup helpers.

## v1.0.0 - Initial public kit

- Published the safe public installer/configuration kit.
- Excluded private keys, `.env`, `auth.json`, chat history, and personal memory.
