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

$PresetScript = Join-Path $PSScriptRoot "APPLY_HERMES_PRESET.py"
$Python = Get-Command python -ErrorAction SilentlyContinue
if ($Python) {
  try { & $Python.Source $PresetScript $ConfigPath } catch {}
} else {
  try { hermes config set display.skin eva-terminal } catch {}
}

$Desktop = [Environment]::GetFolderPath("Desktop")
if ($Desktop) {
  $HermesCmd = Join-Path $Desktop "Hermes Agent.cmd"
  $SettingsCmd = Join-Path $Desktop "Hermes Agent Settings.cmd"
  Set-Content -Path $HermesCmd -Encoding ASCII -Value "@echo off`r`nset PATH=%LOCALAPPDATA%\hermes\bin;%USERPROFILE%\.local\bin;%PATH%`r`nhermes`r`npause`r`n"
  Set-Content -Path $SettingsCmd -Encoding ASCII -Value "@echo off`r`npowershell -NoProfile -ExecutionPolicy Bypass -File `"$PSScriptRoot\CONFIGURE_KEYS_WINDOWS.ps1`"`r`npause`r`n"
}

Write-Host ""
Write-Host "Hermes installed/configured."
Write-Host "Next:"
Write-Host "1. Run: .\scripts\CONFIGURE_KEYS_WINDOWS.ps1"
Write-Host "2. Add your own API keys when asked."
Write-Host "3. Start: hermes"
