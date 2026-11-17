@echo off
setlocal
title PundiGo! - Android Emulator Launcher

echo ========================================================
echo   PUNDIGO! - MENJALANKAN DI ANDROID EMULATOR (FRESH)
echo ========================================================
echo.

set "ADB=%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe"
set "EMU=%LOCALAPPDATA%\Android\Sdk\emulator\emulator.exe"

if exist build\flutter_assets (
  echo [1/5] Membersihkan cache build lama...
  attrib -R /S /D build\flutter_assets\* >nul 2>&1
  rmdir /S /Q build\flutter_assets >nul 2>&1
)

echo [2/5] Mengecek apakah Android Emulator sudah menyala...
set "DEVICE_FOUND="
if exist "%ADB%" (
  for /f "skip=1 tokens=1,2" %%a in ('"%ADB%" devices') do (
    if "%%b"=="device" set "DEVICE_FOUND=%%a"
  )
)

if not defined DEVICE_FOUND (
  if exist "%EMU%" (
    for /f "delims=" %%v in ('"%EMU%" -list-avds') do (
      if not defined FIRST_AVD set "FIRST_AVD=%%v"
    )
  )
  if defined FIRST_AVD (
    echo       Menyalakan Android Emulator: %FIRST_AVD% ...
    start "" "%EMU%" -avd "%FIRST_AVD%"
    echo       Menunggu Emulator selesai booting (sekitar 20-40 detik)...
    "%ADB%" wait-for-device
    :wait_boot
    for /f "delims=" %%s in ('"%ADB%" shell getprop sys.boot_completed 2^>nul') do set "BOOTED=%%s"
    if not "%BOOTED%"=="1" (
      timeout /t 2 /nobreak >nul
      goto wait_boot
    )
    for /f "skip=1 tokens=1,2" %%a in ('"%ADB%" devices') do (
      if "%%b"=="device" set "DEVICE_FOUND=%%a"
    )
  ) else (
    echo [PERINGATAN] Belum ada Emulator Android yang terpasang.
    echo Silakan buat emulator dulu di Android Studio Device Manager.
    pause
    exit /b 1
  )
)

echo       Emulator aktif: %DEVICE_FOUND%
echo.
echo [3/5] Menghapus aplikasi PundiGo versi lama di Emulator (jika ada)...
if exist "%ADB%" (
  "%ADB%" -s %DEVICE_FOUND% uninstall com.example.pundigo >nul 2>&1
)

echo [4/5] Memastikan dependensi Flutter (flutter pub get)...
call flutter pub get

echo.
echo [5/5] Memasang ^& menjalankan PundiGo versi TERBARU di Emulator...
call flutter run -d %DEVICE_FOUND%
pause
