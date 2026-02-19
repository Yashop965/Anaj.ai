@echo off
REM Flutter Automated Setup Script for Windows
REM This script downloads and installs Flutter SDK

setlocal enabledelayedexpansion

echo.
echo ============================================
echo   AgriShield - Flutter Setup Script
echo ============================================
echo.

REM Create src directory if it doesn't exist
if not exist "C:\src" (
    echo Creating C:\src directory...
    mkdir C:\src
)

REM Download Flutter SDK
echo.
echo [Step 1] Downloading Flutter SDK...
echo Please wait, this may take 2-5 minutes...
echo.

cd /d C:\src

REM Using Git to clone Flutter (faster and includes git history)
git clone https://github.com/flutter/flutter.git -b stable --depth 1

if errorlevel 1 (
    echo.
    echo ERROR: Git clone failed. Make sure Git is installed.
    echo Download Git from: https://git-scm.com/download/win
    echo.
    pause
    exit /b 1
)

echo.
echo [Step 2] Flutter downloaded successfully!
echo.
echo [Step 3] Adding Flutter to system PATH...

REM Get current PATH
for /f "tokens=2*" %%A in ('reg query "HKCU\Environment" /v PATH 2^>nul') do set "CURRENT_PATH=%%B"

REM Add Flutter to PATH if not already there
echo !CURRENT_PATH! | find /i "C:\src\flutter\bin" >nul
if errorlevel 1 (
    setx PATH "C:\src\flutter\bin;!CURRENT_PATH!"
    echo PATH updated successfully!
) else (
    echo Flutter already in PATH!
)

echo.
echo [Step 4] Running Flutter Doctor...
echo Please wait while Flutter checks your system...
echo.

REM Close and reopen to get updated PATH
call C:\src\flutter\bin\flutter doctor

echo.
echo ============================================
echo   Setup Complete!
echo ============================================
echo.
echo Next steps:
echo 1. Close and reopen PowerShell/Terminal
echo 2. Run: flutter doctor
echo 3. Navigate to your project: cd mobile_app
echo 4. Run: flutter pub get
echo 5. Run: flutter run
echo.
echo For more info visit: https://flutter.dev
echo.
pause
