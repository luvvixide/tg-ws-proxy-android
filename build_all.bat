@echo off
setlocal
cd /d "%~dp0"

echo ==========================================================
echo   TG WS Proxy Android - full build (native .so + APK)
echo ==========================================================
echo.

where cargo >nul 2>nul
if errorlevel 1 (
    echo [ERROR] cargo not found. Install Rust: https://rustup.rs
    goto :fail
)
where java >nul 2>nul
if errorlevel 1 (
    echo [ERROR] Java 17+ not found. Install JDK 17 or Android Studio.
    goto :fail
)

rem --- Android SDK location for Gradle (local.properties) ---
if defined ANDROID_HOME goto :sdk_ok
if defined ANDROID_SDK_ROOT goto :sdk_ok
if exist "local.properties" goto :sdk_ok
if not exist "%LOCALAPPDATA%\Android\Sdk" (
    echo [ERROR] Android SDK not found. Install Android Studio ^(SDK + NDK^)
    echo         or set ANDROID_HOME.
    goto :fail
)
set "SDK_ESC=%LOCALAPPDATA:\=\\%\\Android\\Sdk"
> "local.properties" echo sdk.dir=%SDK_ESC%
echo Created local.properties with sdk.dir=%SDK_ESC%
:sdk_ok

echo.
echo [1/2] Building native Rust libraries...
call build_so.bat
if errorlevel 1 (
    echo.
    echo [ERROR] Native build failed. See errors above.
    echo         Typical causes: no NDK ^(Android Studio ^> SDK Manager ^> SDK Tools ^> NDK^)
    echo         or Rust compile errors.
    goto :fail
)

echo.
echo [2/2] Building APKs with Gradle...
call build_apk.bat
if errorlevel 1 goto :fail

echo.
echo ==========================================================
echo   DONE. APKs are in: %~dp0app\release\
echo   Install the *-universal.apk on the phone.
echo ==========================================================
if exist "app\release" start "" "app\release"
endlocal
exit /b 0

:fail
echo.
echo BUILD FAILED.
pause
endlocal
exit /b 1
