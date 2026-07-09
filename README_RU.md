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

## Установка как обычной программы

Для друзей нормальный сценарий такой:

1. Открыть GitHub Releases.
2. Скачать один setup-файл под свою ОС.
3. Запустить его.
4. Добавить свои API-ключи в Hermes Agent Settings.

Setup-файлы:

- Linux: `Hermes-Agent-Setup-Linux.sh`
- Windows: `Hermes-Agent-Setup-Windows.cmd`

Setup ставит официальный Hermes Agent, применяет наш публичный preset и создаёт
ярлыки/настройки. Внутри нет моих приватных ключей, `.env`, `auth.json`,
истории чатов, памяти или личного `~/.hermes/config.yaml`.

## Установка из терминала

Linux:

```bash
HERMES_KIT_CONFIGURE_AFTER=1 bash <(curl -fsSL https://raw.githubusercontent.com/vavavadusik-crypto/hermes-agent-friend-kit/main/install.sh)
```

Windows PowerShell:

```powershell
$env:HERMES_KIT_CONFIGURE_AFTER="1"; irm https://raw.githubusercontent.com/vavavadusik-crypto/hermes-agent-friend-kit/main/install.ps1 | iex
```

После такой установки весь комплект будет сохранён:

- Linux/macOS/WSL2: `~/hermes-agent-friend-kit`
- Windows: `%USERPROFILE%\hermes-agent-friend-kit`

## Быстрый запуск на Linux desktop

```bash
git clone https://github.com/vavavadusik-crypto/hermes-agent-friend-kit.git
cd hermes-agent-friend-kit
chmod +x scripts/*.sh linux-desktop/*.sh
./install.sh
```

На Linux с графическим окружением ставится ярлык:

- `Hermes Agent` - запуск Hermes в обычном системном терминале.
- `Hermes Agent Settings` - настройка API-ключей и модели.

Горячие клавиши остаются стандартными для терминала:

- `Ctrl+Shift+C` копирует.
- `Ctrl+Shift+V` вставляет.
- `Ctrl+C` прерывает зависшую команду.

Потом открыть `Hermes Agent Settings` или выполнить:

```bash
./scripts/CONFIGURE_KEYS_LINUX.sh
hermes
```

## macOS / WSL2

Установщик можно использовать тот же, но запускать лучше в обычном терминале:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/vavavadusik-crypto/hermes-agent-friend-kit/main/install.sh)
cd ~/hermes-agent-friend-kit
./scripts/CONFIGURE_KEYS_LINUX.sh
hermes
```

Linux `.desktop` ярлык ставится только если найдено графическое Linux-окружение.

## Быстрый запуск на Windows

Открыть PowerShell в этой папке:

```powershell
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
.\scripts\INSTALL_WINDOWS.ps1
```

Потом открыть `Hermes Agent Settings.cmd` на рабочем столе или выполнить:

```powershell
.\scripts\CONFIGURE_KEYS_WINDOWS.ps1
hermes
```

## Важное

Ключи нельзя отправлять в чат, GitHub, Discord, Telegram или скриншоты.
Каждый человек должен использовать свои ключи. Если ключ случайно утёк, его нужно сразу удалить/перевыпустить в кабинете провайдера.
Личные модели, приватный `~/.hermes/config.yaml`, `.env`, `auth.json`, память и историю чатов нельзя публиковать в GitHub.

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
