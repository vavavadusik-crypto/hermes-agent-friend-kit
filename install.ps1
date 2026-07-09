$ErrorActionPreference = "Stop"

$RepoUrl = if ($env:HERMES_KIT_REPO_URL) { $env:HERMES_KIT_REPO_URL } else { "https://github.com/vavavadusik-crypto/hermes-agent-friend-kit.git" }
$Branch = if ($env:HERMES_KIT_BRANCH) { $env:HERMES_KIT_BRANCH } else { "main" }
$ArchiveUrl = if ($env:HERMES_KIT_ARCHIVE_URL) { $env:HERMES_KIT_ARCHIVE_URL } else { "https://github.com/vavavadusik-crypto/hermes-agent-friend-kit/archive/refs/heads/$Branch.zip" }
$HomeDir = [Environment]::GetFolderPath("UserProfile")
$InstallDir = if ($env:HERMES_KIT_INSTALL_DIR) { $env:HERMES_KIT_INSTALL_DIR } else { Join-Path $HomeDir "hermes-agent-friend-kit" }

$ScriptDir = $null
if ($PSScriptRoot) {
  $ScriptDir = $PSScriptRoot
} elseif ($MyInvocation.MyCommand.Path) {
  $ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
}

if ($ScriptDir -and (Test-Path (Join-Path $ScriptDir "scripts\INSTALL_WINDOWS.ps1"))) {
  $Root = $ScriptDir
} else {
  $Root = $InstallDir
  if ((Test-Path (Join-Path $Root ".git")) -and (Get-Command git -ErrorAction SilentlyContinue)) {
    try { git -C $Root pull --ff-only } catch {}
  }
  if (-not (Test-Path (Join-Path $Root "scripts\INSTALL_WINDOWS.ps1"))) {
    $TempDir = Join-Path ([IO.Path]::GetTempPath()) ("hermes-agent-friend-kit-" + [guid]::NewGuid().ToString("N"))
    New-Item -ItemType Directory -Force -Path $TempDir | Out-Null
    if (Get-Command git -ErrorAction SilentlyContinue) {
      git clone --depth 1 --branch $Branch $RepoUrl (Join-Path $TempDir "repo")
      $DownloadedRoot = Join-Path $TempDir "repo"
    } else {
      $ZipPath = Join-Path $TempDir "repo.zip"
      Invoke-WebRequest -Uri $ArchiveUrl -OutFile $ZipPath
      Expand-Archive -Path $ZipPath -DestinationPath $TempDir -Force
      $DownloadedRoot = (Get-ChildItem -Path $TempDir -Directory | Where-Object { $_.Name -like "hermes-agent-friend-kit-*" } | Select-Object -First 1).FullName
    }
    if (-not $DownloadedRoot) { throw "Could not download Hermes Agent Friend Kit." }
    if (Test-Path $Root) { Remove-Item -Recurse -Force $Root }
    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $Root) | Out-Null
    Move-Item -Force $DownloadedRoot $Root
  }
}

& (Join-Path $Root "scripts\INSTALL_WINDOWS.ps1")

if ($env:HERMES_KIT_CONFIGURE_AFTER -eq "1") {
  try { & (Join-Path $Root "scripts\CONFIGURE_KEYS_WINDOWS.ps1") } catch {}
}

Write-Host ""
Write-Host "Install complete."
Write-Host "Kit files: $Root"
Write-Host "Settings: $Root\scripts\CONFIGURE_KEYS_WINDOWS.ps1"
