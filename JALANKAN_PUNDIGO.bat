@echo off
title PundiGo Launcher
echo ========================================================
echo   MENYIAPKAN DEPENDENSI & MENJALANKAN PUNDIGO!
echo ========================================================
echo.
if exist build\flutter_assets (
  echo Membersihkan cache build lama agar tidak bentrok dengan OneDrive...
  attrib -R /S /D build\flutter_assets\* >nul 2>&1
  rmdir /S /Q build\flutter_assets >nul 2>&1
)
echo [1/2] Mengunduh dependensi (flutter pub get)...
call flutter pub get
echo.
echo [2/2] Membuka PundiGo di Google Chrome...
call flutter run -d chrome
pause
