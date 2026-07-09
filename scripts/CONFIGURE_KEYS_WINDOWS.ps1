$ErrorActionPreference = "Stop"

$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$env:Path = "$env:LOCALAPPDATA\hermes\bin;$env:USERPROFILE\.local\bin;$env:Path"

if (-not (Get-Command hermes -ErrorAction SilentlyContinue)) {
  Write-Host "Hermes is not installed or not in PATH. Run install.ps1 first."
  exit 1
}

$ConfigPath = (& hermes config path 2>$null).Trim()
if (-not $ConfigPath) {
  $ConfigPath = Join-Path $env:LOCALAPPDATA "hermes\config.yaml"
}
$EnvPath = (& hermes config env-path 2>$null).Trim()
if (-not $EnvPath) {
  $EnvPath = Join-Path $env:LOCALAPPDATA "hermes\.env"
}

New-Item -ItemType Directory -Force -Path (Split-Path -Parent $EnvPath) | Out-Null
if (-not (Test-Path $EnvPath)) { New-Item -ItemType File -Path $EnvPath | Out-Null }

$Python = Get-Command python -ErrorAction SilentlyContinue
if ($Python) {
  try { & $Python.Source (Join-Path $Root "scripts\APPLY_HERMES_PRESET.py") $ConfigPath } catch {}
}

function Read-SecretText($Label) {
  $secure = Read-Host "$Label (leave empty to skip)" -AsSecureString
  $bstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure)
  try { [Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr) } finally { [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr) }
}

function Upsert-EnvLine($Key, $Value) {
  if ([string]::IsNullOrWhiteSpace($Value)) { return }
  $escaped = $Value.Replace('\', '\\').Replace('"', '\"')
  $lines = @()
  if (Test-Path $EnvPath) {
    $lines = Get-Content $EnvPath | Where-Object { $_ -notmatch "^$Key=" }
  }
  $lines += "$Key=`"$escaped`""
  Set-Content -Path $EnvPath -Value $lines -Encoding UTF8
}

Write-Host ""
Write-Host "Choose the main provider to configure now:"
Write-Host "1) OpenRouter free/low-cost"
Write-Host "2) Groq"
Write-Host "3) Cerebras"
Write-Host "4) Gemini"
Write-Host "5) NVIDIA NIM"
Write-Host "6) Z.AI / GLM"
Write-Host "7) Kimi / Moonshot"
Write-Host "8) Ollama local/no key"
Write-Host "9) OpenAI GPT-5.6 Terra"
Write-Host "10) OpenAI GPT-5.6 Sol"
Write-Host "11) Skip provider setup"
$choice = Read-Host "Choice [1-11]"

switch ($choice) {
  "1" {
    $key = Read-SecretText "OPENROUTER_API_KEY"
    Upsert-EnvLine "OPENROUTER_API_KEY" $key
    try { hermes config set model.provider openrouter } catch {}
    try { hermes config set model.default openrouter/free } catch {}
  }
  "2" {
    $key = Read-SecretText "GROQ_API_KEY"
    Upsert-EnvLine "GROQ_API_KEY" $key
    try { hermes config set model.provider custom:groq } catch {}
    try { hermes config set model.default qwen/qwen3-32b } catch {}
  }
  "3" {
    $key = Read-SecretText "CEREBRAS_API_KEY"
    Upsert-EnvLine "CEREBRAS_API_KEY" $key
    try { hermes config set model.provider custom:cerebras } catch {}
    try { hermes config set model.default gpt-oss-120b } catch {}
  }
  "4" {
    $key = Read-SecretText "GEMINI_API_KEY"
    Upsert-EnvLine "GEMINI_API_KEY" $key
    Upsert-EnvLine "GOOGLE_API_KEY" $key
    try { hermes config set model.provider gemini } catch {}
    try { hermes config set model.default gemini-2.0-flash } catch {}
  }
  "5" {
    $key = Read-SecretText "NVIDIA_API_KEY"
    Upsert-EnvLine "NVIDIA_API_KEY" $key
    try { hermes config set model.provider nvidia } catch {}
    try { hermes config set model.default nvidia/nemotron-3-super-120b-a12b } catch {}
  }
  "6" {
    $key = Read-SecretText "GLM_API_KEY"
    Upsert-EnvLine "GLM_API_KEY" $key
    try { hermes config set model.provider zai } catch {}
    try { hermes config set model.default zai-org/GLM-5.1-FP8 } catch {}
  }
  "7" {
    $key = Read-SecretText "KIMI_API_KEY"
    Upsert-EnvLine "KIMI_API_KEY" $key
    try { hermes config set model.provider kimi-coding } catch {}
  }
  "8" {
    try { hermes config set model.provider ollama-launch } catch {}
    try { hermes config set model.default omnicoder-9b-65536ctx:latest } catch {}
  }
  "9" {
    $key = Read-SecretText "OPENAI_API_KEY"
    Upsert-EnvLine "OPENAI_API_KEY" $key
    try { hermes config set model.provider openai-api } catch {}
    try { hermes config set model.default gpt-5.6-terra } catch {}
    try { hermes config set agent.reasoning_effort medium } catch {}
  }
  "10" {
    $key = Read-SecretText "OPENAI_API_KEY"
    Upsert-EnvLine "OPENAI_API_KEY" $key
    try { hermes config set model.provider openai-api } catch {}
    try { hermes config set model.default gpt-5.6-sol } catch {}
    try { hermes config set agent.reasoning_effort medium } catch {}
  }
}

Upsert-EnvLine "GITHUB_TOKEN" (Read-SecretText "Optional GITHUB_TOKEN for repo/issues higher limits")
Upsert-EnvLine "TAVILY_API_KEY" (Read-SecretText "Optional TAVILY_API_KEY for web search")
Upsert-EnvLine "BRAVE_API_KEY" (Read-SecretText "Optional BRAVE_API_KEY for web search")

Write-Host ""
Write-Host "Settings saved."
Write-Host "Config: $ConfigPath"
Write-Host "Env: $EnvPath"
Write-Host "Run: hermes"
