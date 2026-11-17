@echo off
title PundiGo Launcher
echo ========================================================
echo   MENYIAPKAN DEPENDENSI & MENJALANKAN PUNDIGO!
echo ========================================================
echo.
echo [1/2] Mengunduh dependensi (flutter pub get)...
call flutter pub get
echo.
echo [2/2] Membuka PundiGo di Google Chrome...
call flutter run -d chrome
pause
