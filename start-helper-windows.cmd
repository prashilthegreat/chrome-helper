@echo off
title Chrome Helper
cd /d "%~dp0"
where node >nul 2>nul
if errorlevel 1 (
  echo Node.js is required. Install it from https://nodejs.org/ and run this file again.
  pause
  exit /b 1
)
echo Starting Chrome Helper. Keep this window open while using the PWA.
node helper.mjs
pause
