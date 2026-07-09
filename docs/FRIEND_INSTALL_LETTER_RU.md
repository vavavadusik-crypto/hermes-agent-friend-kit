# Письмо для друга: как поставить наш Hermes Agent

Это безопасный публичный комплект для установки Hermes Agent. Он ставит
официальный Hermes Agent, добавляет наш стиль, настройки провайдеров,
auto-route и ярлыки. Внутри нет чужих API-ключей, приватных чатов, памяти,
`auth.json`, `.env` или личного `~/.hermes`.

## Самый простой сценарий

1. Открой GitHub Releases этого репозитория.
2. Скачай один setup-файл под свою систему:
   - Linux: `Hermes-Agent-Setup-Linux.sh`
   - Windows: `Hermes-Agent-Setup-Windows.cmd`
3. Запусти setup-файл.
4. Открой `Hermes Agent Settings` на рабочем столе.
5. Добавь свои API-ключи.
6. Запусти `Hermes Agent`.

## One-command install

Linux:

```bash
HERMES_KIT_CONFIGURE_AFTER=1 bash <(curl -fsSL https://raw.githubusercontent.com/vavavadusik-crypto/hermes-agent-friend-kit/main/install.sh)
```

Windows PowerShell:

```powershell
$env:HERMES_KIT_CONFIGURE_AFTER="1"; irm https://raw.githubusercontent.com/vavavadusik-crypto/hermes-agent-friend-kit/main/install.ps1 | iex
```

## Какие ключи нужны

Для обычного старта хватит одного ключа. Если добавишь несколько, launcher сам
выберет лучший доступный маршрут в таком порядке:

| Приоритет | Provider | Куда вставлять | Модель/маршрут |
| --- | --- | --- | --- |
| 1 | Groq | `GROQ_API_KEY` | `custom:groq` / `qwen/qwen3-32b` |
| 2 | Cerebras | `CEREBRAS_API_KEY` | `custom:cerebras` / `gpt-oss-120b` |
| 3 | Gemini | `GEMINI_API_KEY` | `gemini` / `gemini-2.0-flash` |
| 4 | NVIDIA NIM | `NVIDIA_API_KEY` | `nvidia` / `nvidia/nemotron-3-super-120b-a12b` |
| 5 | OpenRouter | `OPENROUTER_API_KEY` | `openrouter` / `openrouter/free` |
| 6 | Ollama local | ключ не нужен | `omnicoder-9b-65536ctx:latest` |
| optional | OpenAI | `OPENAI_API_KEY` | `gpt-5.6-terra` или `gpt-5.6-sol` |

OpenAI GPT-5.6 здесь добавлен как платный premium route, а не как бесплатный
дефолт. Для экономии используй его только для сложного ревью, архитектуры,
безопасности и финальной проверки.

## Где брать ключи

- OpenRouter: https://openrouter.ai/keys
- Groq: https://console.groq.com/keys
- Cerebras: https://cloud.cerebras.ai/
- Gemini / Google AI Studio: https://aistudio.google.com/app/apikey
- NVIDIA NIM: https://build.nvidia.com/settings/api-keys
- OpenAI: https://platform.openai.com/api-keys
- GitHub token, если нужен repo/issues workflow: https://github.com/settings/personal-access-tokens

Подробный список с пояснениями: `docs/FREE_KEYS_AND_APIS.md`.

## Что такое auto-route

Перед каждым запуском desktop launcher смотрит локальный `.env` Hermes Agent и
обновляет `config.yaml`. Он не показывает ключи и не отправляет их в GitHub.
Если ключ Groq есть, выбирается Groq. Если Groq нет, пробуется Cerebras, потом
Gemini, NVIDIA, OpenRouter. Если cloud-ключей нет, остается локальный Ollama.

Это сделано, чтобы Hermes не падал на одном provider и не тратил платные модели
без явного выбора пользователя.

## Безопасность

- Не отправляй API-ключи в чат.
- Не публикуй `.env`, `auth.json`, `~/.hermes`, скриншоты с ключами.
- Если ключ утек, сразу удали его в кабинете провайдера и создай новый.
- Каждый человек использует свои ключи и свои аккаунты.

## Если что-то не работает

Linux:

```bash
cd ~/hermes-agent-friend-kit
./scripts/CHECK_HERMES_ENV.sh
hermes fallback list
hermes doctor
```

Windows:

```powershell
cd $env:USERPROFILE\hermes-agent-friend-kit
.\scripts\CONFIGURE_KEYS_WINDOWS.ps1
hermes fallback list
hermes doctor
```

Еще подсказки: `docs/TROUBLESHOOTING.md` и
`context/AI_CONTEXT_FOR_FRIEND.md`.
