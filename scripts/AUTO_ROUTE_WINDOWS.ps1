$ErrorActionPreference = "Stop"

$Quiet = $args -contains "--quiet"
$StatusOnly = $args -contains "--status"
$AllowLocal = $env:HERMES_AGENT_ALLOW_LOCAL -eq "1"
$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$env:Path = "$env:LOCALAPPDATA\hermes\bin;$env:USERPROFILE\.local\bin;$env:Path"

if (-not (Get-Command hermes -ErrorAction SilentlyContinue)) {
  if (-not $Quiet) { Write-Host "Hermes is not installed or not in PATH." }
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

function Get-EnvValue($Key) {
  if (-not (Test-Path $EnvPath)) { return "" }
  $pattern = '^{0}=(.*)$' -f ([regex]::Escape($Key))
  $value = ""
  foreach ($line in Get-Content $EnvPath) {
    if ($line -match $pattern) {
      $raw = $Matches[1].Trim()
      if (($raw.StartsWith('"') -and $raw.EndsWith('"')) -or ($raw.StartsWith("'") -and $raw.EndsWith("'"))) {
        $raw = $raw.Substring(1, $raw.Length - 2)
      }
      $value = $raw.Trim()
    }
  }
  return $value
}

function Test-Http($Url, $Token = "", $Method = "GET", $Headers = @{}, $Body = $null) {
  $allHeaders = @{}
  foreach ($key in $Headers.Keys) { $allHeaders[$key] = $Headers[$key] }
  if ($Token) { $allHeaders["Authorization"] = "Bearer $Token" }
  try {
    if ($Body) {
      $json = $Body | ConvertTo-Json -Depth 10 -Compress
      $response = Invoke-WebRequest -Uri $Url -Method $Method -Headers $allHeaders -Body $json -ContentType "application/json" -TimeoutSec 5 -UseBasicParsing
    } else {
      $response = Invoke-WebRequest -Uri $Url -Method $Method -Headers $allHeaders -TimeoutSec 5 -UseBasicParsing
    }
    return @{ Ok = ($response.StatusCode -ge 200 -and $response.StatusCode -lt 300); Reason = "http $($response.StatusCode)" }
  } catch {
    $status = $null
    if ($_.Exception.Response) {
      try { $status = [int]$_.Exception.Response.StatusCode } catch {}
    }
    if ($status) { return @{ Ok = $false; Reason = "http $status" } }
    return @{ Ok = $false; Reason = $_.Exception.GetType().Name }
  }
}

function Test-Ollama($Model) {
  try {
    $response = Invoke-WebRequest -Uri "http://127.0.0.1:11434/api/tags" -TimeoutSec 5 -UseBasicParsing
    $payload = $response.Content | ConvertFrom-Json
    foreach ($item in $payload.models) {
      if ($item.name -eq $Model) { return @{ Ok = $true; Reason = "local model present" } }
    }
    return @{ Ok = $false; Reason = "local model missing" }
  } catch {
    return @{ Ok = $false; Reason = $_.Exception.GetType().Name }
  }
}

function Test-OllamaGenerate($Model) {
  try {
    $body = @{ model = $Model; prompt = "Reply OK only."; stream = $false; options = @{ num_predict = 1 } }
    return Test-Http "http://127.0.0.1:11434/api/generate" "" "POST" @{} $body
  } catch {
    return @{ Ok = $false; Reason = $_.Exception.GetType().Name }
  }
}

function Test-Gemini($Key) {
  if (-not $Key) { return @{ Ok = $false; Reason = "missing key" } }
  $body = @{
    contents = @(@{ parts = @(@{ text = "ping" }) })
    generationConfig = @{ maxOutputTokens = 1; temperature = 0 }
  }
  return Test-Http "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent" "" "POST" @{ "x-goog-api-key" = $Key } $body
}

function Set-Route($Provider, $Model, $BaseUrl = $null) {
  try { hermes config set model.provider $Provider | Out-Null } catch {}
  try { hermes config set model.default $Model | Out-Null } catch {}
  try { hermes config set model.max_tokens 4096 | Out-Null } catch {}
  if ($BaseUrl) {
    try { hermes config set model.base_url $BaseUrl | Out-Null } catch {}
  }
  if (-not $Quiet) { Write-Host "Auto route: $Provider / $Model" }
}

$routes = @(
  @{ Name = "groq"; Provider = "custom:groq"; Model = "qwen/qwen3-32b"; Key = "GROQ_API_KEY"; Test = { param($key) Test-Http "https://api.groq.com/openai/v1/chat/completions" $key "POST" @{} @{ model = "qwen/qwen3-32b"; messages = @(@{ role = "user"; content = "ping" }); max_tokens = 1; temperature = 0; stream = $false } } },
  @{ Name = "cerebras"; Provider = "custom:cerebras"; Model = "gpt-oss-120b"; Key = "CEREBRAS_API_KEY"; Test = { param($key) Test-Http "https://api.cerebras.ai/v1/chat/completions" $key "POST" @{} @{ model = "gpt-oss-120b"; messages = @(@{ role = "user"; content = "ping" }); max_tokens = 1; temperature = 0; stream = $false } } },
  @{ Name = "gemini"; Provider = "gemini"; Model = "gemini-2.0-flash"; Key = "GEMINI_API_KEY"; Test = { param($key) Test-Gemini $key } },
  @{ Name = "nvidia"; Provider = "nvidia"; Model = "nvidia/nemotron-3-super-120b-a12b"; Key = "NVIDIA_API_KEY"; BaseUrl = "https://integrate.api.nvidia.com/v1"; Test = { param($key) Test-Http "https://integrate.api.nvidia.com/v1/chat/completions" $key "POST" @{} @{ model = "nvidia/nemotron-3-super-120b-a12b"; messages = @(@{ role = "user"; content = "ping" }); max_tokens = 1; temperature = 0; stream = $false } } },
  @{ Name = "openrouter"; Provider = "openrouter"; Model = "openai/gpt-oss-20b:free"; Key = "OPENROUTER_API_KEY"; Test = { param($key) Test-Http "https://openrouter.ai/api/v1/chat/completions" $key "POST" @{ "HTTP-Referer" = "https://github.com/vavavadusik-crypto/hermes-agent-friend-kit"; "X-Title" = "Hermes Agent Friend Kit" } @{ model = "openai/gpt-oss-20b:free"; messages = @(@{ role = "user"; content = "ping" }); max_tokens = 1; temperature = 0; stream = $false } } }
)

$statuses = @()
$selected = $null
$openrouterRoute = $null
foreach ($route in $routes) {
  $key = Get-EnvValue $route.Key
  if (-not $key -and $route.Name -eq "gemini") { $key = Get-EnvValue "GOOGLE_API_KEY" }
  if (-not $key) {
    $statuses += "$($route.Name): skip (missing key)"
    continue
  }
  $result = & $route.Test $key
  $statuses += "$($route.Name): $(@('skip','ok')[[int]$result.Ok]) ($($result.Reason))"
  if ($result.Ok -and $route.Name -eq "openrouter") {
    $openrouterRoute = $route
  } elseif ($result.Ok -and -not $selected) {
    $selected = $route
  }
}

$ollama = Test-Ollama "omnicoder-9b-65536ctx:latest"
$glmCloud = Test-OllamaGenerate "glm-5.2:cloud"
$statuses += "ollama-glm-cloud: $(@('skip','ok')[[int]$glmCloud.Ok]) ($($glmCloud.Reason))"
if (-not $selected -and $glmCloud.Ok) {
  $selected = @{ Name = "ollama-glm-cloud"; Provider = "ollama-launch"; Model = "glm-5.2:cloud"; BaseUrl = "http://127.0.0.1:11434/v1" }
}
$kimiCloud = Test-OllamaGenerate "kimi-k2.7-code:cloud"
$statuses += "ollama-kimi-cloud: $(@('skip','ok')[[int]$kimiCloud.Ok]) ($($kimiCloud.Reason))"
if (-not $selected -and $kimiCloud.Ok) {
  $selected = @{ Name = "ollama-kimi-cloud"; Provider = "ollama-launch"; Model = "kimi-k2.7-code:cloud"; BaseUrl = "http://127.0.0.1:11434/v1" }
}

if ($AllowLocal) {
  $statuses += "ollama-local: $(@('skip','ok')[[int]$ollama.Ok]) ($($ollama.Reason))"
} else {
  $statuses += "ollama-local: skip (disabled)"
}

if (-not $selected -and $AllowLocal -and $ollama.Ok) {
  $selected = @{ Name = "ollama-local"; Provider = "ollama-launch"; Model = "omnicoder-9b-65536ctx:latest"; BaseUrl = "http://127.0.0.1:11434/v1" }
} elseif (-not $selected -and $openrouterRoute) {
  $selected = $openrouterRoute
}

if (-not $selected) {
  try { hermes config set model.provider openrouter | Out-Null } catch {}
  try { hermes config set model.default openrouter/free | Out-Null } catch {}
  try { hermes config set model.max_tokens 4096 | Out-Null } catch {}
  if ($StatusOnly) {
    Write-Host "Config: $ConfigPath"
    Write-Host "Env: $EnvPath"
    Write-Host "Active: unavailable"
    foreach ($line in $statuses) { Write-Host $line }
  } elseif (-not $Quiet) {
    Write-Host "No working remote provider right now. Local Ollama is disabled for weak laptops."
  }
  exit 2
}

Set-Route $selected.Provider $selected.Model $selected.BaseUrl

if ($StatusOnly) {
  Write-Host "Config: $ConfigPath"
  Write-Host "Env: $EnvPath"
  foreach ($line in $statuses) { Write-Host $line }
}
