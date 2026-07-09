$ErrorActionPreference = "Stop"

# Paste your own keys between the quotes. Leave empty if you do not use a provider.
$OPENROUTER_API_KEY = ""
$OPENAI_API_KEY = ""
$GROQ_API_KEY = ""
$CEREBRAS_API_KEY = ""
$GEMINI_API_KEY = ""
$NVIDIA_API_KEY = ""
$GITHUB_TOKEN = ""
$BRAVE_API_KEY = ""
$TAVILY_API_KEY = ""

$env:Path = "$env:LOCALAPPDATA\hermes\bin;$env:USERPROFILE\.local\bin;$env:Path"

if (-not (Get-Command hermes -ErrorAction SilentlyContinue)) {
  Write-Host "Hermes is not installed or not in PATH. Run INSTALL_WINDOWS.ps1 first."
  exit 1
}

$EnvPath = (& hermes config env-path 2>$null).Trim()
if (-not $EnvPath) {
  $EnvPath = Join-Path $env:LOCALAPPDATA "hermes\.env"
}

$EnvDir = Split-Path -Parent $EnvPath
New-Item -ItemType Directory -Force -Path $EnvDir | Out-Null
if (-not (Test-Path $EnvPath)) { New-Item -ItemType File -Path $EnvPath | Out-Null }

function Upsert-EnvLine($Key, $Value) {
  if ([string]::IsNullOrWhiteSpace($Value)) { return }
  $lines = @()
  if (Test-Path $EnvPath) {
    $lines = Get-Content $EnvPath | Where-Object { $_ -notmatch "^$Key=" }
  }
  $lines += "$Key=`"$Value`""
  Set-Content -Path $EnvPath -Value $lines -Encoding UTF8
}

Upsert-EnvLine "OPENROUTER_API_KEY" $OPENROUTER_API_KEY
Upsert-EnvLine "OPENAI_API_KEY" $OPENAI_API_KEY
Upsert-EnvLine "GROQ_API_KEY" $GROQ_API_KEY
Upsert-EnvLine "CEREBRAS_API_KEY" $CEREBRAS_API_KEY
Upsert-EnvLine "GEMINI_API_KEY" $GEMINI_API_KEY
Upsert-EnvLine "NVIDIA_API_KEY" $NVIDIA_API_KEY
Upsert-EnvLine "GITHUB_TOKEN" $GITHUB_TOKEN
Upsert-EnvLine "BRAVE_API_KEY" $BRAVE_API_KEY
Upsert-EnvLine "TAVILY_API_KEY" $TAVILY_API_KEY

$AutoRoute = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) "AUTO_ROUTE_WINDOWS.ps1"
if (Test-Path $AutoRoute) {
  try { & $AutoRoute } catch {}
} elseif ($GROQ_API_KEY) {
  try { hermes config set model.provider custom:groq } catch {}
  try { hermes config set model.default qwen/qwen3-32b } catch {}
} elseif ($CEREBRAS_API_KEY) {
  try { hermes config set model.provider custom:cerebras } catch {}
  try { hermes config set model.default gpt-oss-120b } catch {}
} elseif ($GEMINI_API_KEY) {
  try { hermes config set model.provider gemini } catch {}
  try { hermes config set model.default gemini-2.0-flash } catch {}
} elseif ($NVIDIA_API_KEY) {
  try { hermes config set model.provider nvidia } catch {}
  try { hermes config set model.default nvidia/nemotron-3-super-120b-a12b } catch {}
} elseif ($OPENROUTER_API_KEY) {
  try { hermes config set model.provider openrouter } catch {}
  try { hermes config set model.default openrouter/free } catch {}
} elseif ($OPENAI_API_KEY) {
  try { hermes config set model.provider openai-api } catch {}
  try { hermes config set model.default gpt-5.6-terra } catch {}
  try { hermes config set agent.reasoning_effort medium } catch {}
} else {
  Write-Host "No cloud model key set. You can still use Ollama/local models if configured."
}

try { hermes config set display.skin eva-terminal } catch {}

Write-Host "Keys written to: $EnvPath"
Write-Host "Run: hermes"
