$ErrorActionPreference = "Stop"

$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$env:Path = "$env:LOCALAPPDATA\hermes\bin;$env:USERPROFILE\.local\bin;$env:Path"

if (-not (Get-Command hermes -ErrorAction SilentlyContinue)) {
  Write-Host "Hermes is not installed or not in PATH."
  exit 0
}

$ConfigPath = (& hermes config path 2>$null).Trim()
if (-not $ConfigPath) {
  $ConfigPath = Join-Path $env:LOCALAPPDATA "hermes\config.yaml"
}

$EnvPath = (& hermes config env-path 2>$null).Trim()
if (-not $EnvPath) {
  $EnvPath = Join-Path $env:LOCALAPPDATA "hermes\.env"
}

New-Item -ItemType Directory -Force -Path (Split-Path -Parent $ConfigPath) | Out-Null
New-Item -ItemType Directory -Force -Path (Split-Path -Parent $EnvPath) | Out-Null
if (-not (Test-Path $EnvPath)) { New-Item -ItemType File -Path $EnvPath | Out-Null }

$Python = Get-Command python -ErrorAction SilentlyContinue
if ($Python) {
  try { & $Python.Source (Join-Path $Root "scripts\APPLY_HERMES_PRESET.py") $ConfigPath | Out-Null } catch {}
}

function Test-EnvKey($Key) {
  if (-not (Test-Path $EnvPath)) { return $false }
  $pattern = '^{0}=("[^"]+"|''[^'']+''|[^#\s]+)' -f ([regex]::Escape($Key))
  return [bool](Select-String -Path $EnvPath -Pattern $pattern -Quiet)
}

function Set-Route($Provider, $Model, $BaseUrl = $null) {
  try { hermes config set model.provider $Provider | Out-Null } catch {}
  try { hermes config set model.default $Model | Out-Null } catch {}
  try { hermes config set model.max_tokens 4096 | Out-Null } catch {}
  if ($BaseUrl) {
    try { hermes config set model.base_url $BaseUrl | Out-Null } catch {}
  }
  Write-Host "Auto route: $Provider / $Model"
}

if (Test-EnvKey "GROQ_API_KEY") {
  Set-Route "custom:groq" "qwen/qwen3-32b"
} elseif (Test-EnvKey "CEREBRAS_API_KEY") {
  Set-Route "custom:cerebras" "gpt-oss-120b"
} elseif ((Test-EnvKey "GEMINI_API_KEY") -or (Test-EnvKey "GOOGLE_API_KEY")) {
  Set-Route "gemini" "gemini-2.0-flash"
} elseif (Test-EnvKey "NVIDIA_API_KEY") {
  Set-Route "nvidia" "nvidia/nemotron-3-super-120b-a12b"
} elseif (Test-EnvKey "OPENROUTER_API_KEY") {
  Set-Route "openrouter" "openrouter/free"
} else {
  Set-Route "ollama-launch" "omnicoder-9b-65536ctx:latest" "http://127.0.0.1:11434/v1"
}
