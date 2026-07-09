@echo off
setlocal
set HERMES_KIT_CONFIGURE_AFTER=1
powershell -NoProfile -ExecutionPolicy Bypass -Command "irm https://raw.githubusercontent.com/vavavadusik-crypto/hermes-agent-friend-kit/main/install.ps1 | iex"
echo.
echo Hermes Agent setup finished. You can close this window.
pause
