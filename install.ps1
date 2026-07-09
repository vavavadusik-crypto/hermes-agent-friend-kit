$ErrorActionPreference = "Stop"

$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
& (Join-Path $Root "scripts\INSTALL_WINDOWS.ps1")

Write-Host ""
Write-Host "Install complete. Next edit scripts\SET_KEYS_WINDOWS.ps1, paste your keys, and run it."

