$ErrorActionPreference = "Stop"

Write-Host "== Hermes Agent Windows installer =="

if (-not (Get-Command hermes -ErrorAction SilentlyContinue)) {
  Write-Host "Installing Hermes Agent from the official Windows installer..."
  iex (irm https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.ps1)
}

$env:Path = "$env:LOCALAPPDATA\hermes\bin;$env:USERPROFILE\.local\bin;$env:Path"

if (-not (Get-Command hermes -ErrorAction SilentlyContinue)) {
  Write-Host "Hermes command not found after install. Open a new PowerShell window and run this script again."
  exit 1
}

$ConfigPath = (& hermes config path 2>$null).Trim()
if ($ConfigPath) {
  $HermesHome = Split-Path -Parent $ConfigPath
} else {
  $HermesHome = Join-Path $env:LOCALAPPDATA "hermes"
}

$SkinDir = Join-Path $HermesHome "skins"
New-Item -ItemType Directory -Force -Path $SkinDir | Out-Null
Copy-Item -Force (Join-Path $PSScriptRoot "..\skins\eva-terminal.yaml") (Join-Path $SkinDir "eva-terminal.yaml")

try { hermes config set display.skin eva-terminal } catch {}
try { hermes config set toolsets '["hermes-cli","web"]' } catch {}

Write-Host ""
Write-Host "Hermes installed/configured."
Write-Host "Next:"
Write-Host "1. Edit scripts\SET_KEYS_WINDOWS.ps1 and paste your own keys."
Write-Host "2. Run: .\scripts\SET_KEYS_WINDOWS.ps1"
Write-Host "3. Start: hermes"

