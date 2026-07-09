# Hermes Agent для друга

Это безопасный переносимый комплект для установки Hermes Agent на Linux или Windows.
Внутри нет личных ключей, токенов, истории чатов или приватных файлов.

## Что внутри

- `scripts/INSTALL_LINUX.sh` - установка Hermes Agent на Linux/macOS/WSL2.
- `scripts/INSTALL_WINDOWS.ps1` - установка Hermes Agent на Windows PowerShell.
- `scripts/SET_KEYS_LINUX.sh` - сюда вставляются ключи друга на Linux/macOS/WSL2.
- `scripts/SET_KEYS_WINDOWS.ps1` - сюда вставляются ключи друга на Windows.
- `skins/eva-terminal.yaml` - наш тёмный neon skin для Hermes, но с оригинальной картинкой Hermes.
- `linux-desktop/` - Linux launcher с выбором масштаба через окно-ползунок.
- `docs/FREE_KEYS_AND_APIS.md` - где брать бесплатные/limited API keys.
- `docs/PUBLIC_NO_KEY_APIS.md` - публичные API без регистрации и ключей.
- `context/AI_CONTEXT_FOR_FRIEND.md` - сообщение, которое друг может дать другой нейросети.

## Быстрый запуск на Linux

```bash
cd "для друга - Hermes Agent"
chmod +x scripts/*.sh linux-desktop/*.sh
./scripts/INSTALL_LINUX.sh
```

Потом открыть `scripts/SET_KEYS_LINUX.sh`, вставить свои ключи в верхние переменные и выполнить:

```bash
./scripts/SET_KEYS_LINUX.sh
hermes
```

## Быстрый запуск на Windows

Открыть PowerShell в этой папке:

```powershell
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
.\scripts\INSTALL_WINDOWS.ps1
```

Потом открыть `scripts\SET_KEYS_WINDOWS.ps1`, вставить свои ключи в верхние переменные и выполнить:

```powershell
.\scripts\SET_KEYS_WINDOWS.ps1
hermes
```

## Важное

Ключи нельзя отправлять в чат, GitHub, Discord, Telegram или скриншоты.
Каждый человек должен использовать свои ключи. Если ключ случайно утёк, его нужно сразу удалить/перевыпустить в кабинете провайдера.

## Если что-то сломалось

Диагностика:

```bash
./scripts/CHECK_HERMES_ENV.sh
```

Типовые ошибки и решения:

```text
docs/TROUBLESHOOTING.md
docs/KNOWN_HERMES_ISSUES_AND_FIXES.md
```

GitHub login/push:

```bash
./scripts/GITHUB_LOGIN_HELPER.sh
./scripts/PUSH_TO_GITHUB.sh
```
