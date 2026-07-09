# Где взять бесплатные или free-tier ключи

Проверено по официальным страницам 2026-07-09. Free-tier и лимиты могут меняться, поэтому перед активным использованием проверь текущие условия в кабинете провайдера.

## Рекомендуемый порядок

1. **OpenRouter** - самый удобный старт: один ключ и много моделей, включая free router.
2. **Groq** - быстрый free-tier/limited inference.
3. **Cerebras** - быстрый inference, есть Free tier.
4. **Gemini API / Google AI Studio** - хороший бесплатный/limited ключ для Gemini.
5. **Ollama** - без cloud key, локально на компьютере, но зависит от железа.
6. **OpenAI GPT-5.6** - premium-провайдер, не бесплатный; использовать для точечных сложных задач.

## OpenRouter

- Ключи: https://openrouter.ai/keys
- Документация: https://openrouter.ai/docs/quickstart
- Free router: https://openrouter.ai/openrouter/free
- Рекомендуемый model id для старта: `openrouter/free`

После вставки `OPENROUTER_API_KEY` скрипт пробует поставить:

```bash
hermes config set model.provider openrouter
hermes config set model.default openrouter/free
```

## Groq

- Console: https://console.groq.com/
- API keys: https://console.groq.com/keys
- Rate limits: https://console.groq.com/docs/rate-limits

Ключ вставляется как `GROQ_API_KEY`.

## Cerebras

- Docs: https://inference-docs.cerebras.ai/
- Quickstart: https://inference-docs.cerebras.ai/quickstart
- Pricing / Free tier: https://www.cerebras.ai/pricing
- Cloud console: https://cloud.cerebras.ai/

Ключ вставляется как `CEREBRAS_API_KEY`.

## Gemini / Google AI Studio

- API key docs: https://ai.google.dev/gemini-api/docs/api-key
- API keys page: https://aistudio.google.com/app/apikey
- Gemini API docs: https://ai.google.dev/gemini-api/docs

Важно: ограничь ключ только Gemini API, если Google предлагает restriction. Ключ вставляется как `GEMINI_API_KEY`.

## GitHub token

GitHub token не обязателен для обычного общения с Hermes, но полезен для работы с repo, issues, PR и публичным поиском с более высоким лимитом.

- Fine-grained tokens: https://github.com/settings/personal-access-tokens
- Classic tokens: https://github.com/settings/tokens

Ключ вставляется как `GITHUB_TOKEN`.

## Ollama без ключей

- Linux installer: https://ollama.com/download
- Windows installer: https://ollama.com/download/windows
- Linux docs: https://docs.ollama.com/linux
- Windows docs: https://docs.ollama.com/windows

Ollama не требует cloud API key. Минус: модель работает на твоём компьютере, поэтому скорость и память зависят от железа.

Пример:

```bash
ollama pull qwen2.5-coder:7b
ollama serve
```

Потом в Hermes можно выбрать Ollama/local provider через:

```bash
hermes model
```

В этом kit пункт `Ollama local/no key` выбирает локальную модель
`omnicoder-9b-65536ctx:latest`, если она есть в Ollama. Не путай это с
`glm-5.2:cloud`: cloud-модели Ollama могут иметь лимиты подписки.

## OpenAI GPT-5.6

- Latest model guide: https://developers.openai.com/api/docs/guides/latest-model.md
- Migration guide: https://developers.openai.com/api/docs/guides/upgrading-to-gpt-5p6-sol.md
- Prompting guide: https://developers.openai.com/api/docs/guides/prompt-guidance-gpt-5p6.md
- API keys: https://platform.openai.com/api-keys

Ключ вставляется как `OPENAI_API_KEY`.

Роли моделей:

- `gpt-5.6-sol` / alias `gpt-5.6` - максимум качества, самый дорогой путь.
- `gpt-5.6-terra` - баланс качества и цены, рекомендуемый старт для ручной проверки.
- `gpt-5.6-luna` - более дешёвый high-volume путь.

Для экономии не ставь GPT-5.6 дефолтом, пока бесплатные/limited провайдеры
закрывают задачу. В настройках Hermes выбирай GPT-5.6 только для сложной
проверки, ревью, архитектуры и финальной полировки.

## Безопасность ключей

- Не отправляй ключи в чат.
- Не коммить `.env`.
- Не делай скриншоты с ключами.
- Если ключ утёк, удали его в кабинете провайдера и создай новый.
- Для Google/Gemini включай ограничения ключа.
