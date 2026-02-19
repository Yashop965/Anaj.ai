@echo off
REM AgriShield - Complete Fix and Dependencies Installation
REM This script fixes all errors and installs all required dependencies

setlocal enabledelayedexpansion

REM Colors for output
color 0B

echo.
echo ============================================
echo   AgriShield - Complete Fix & Setup
echo ============================================
echo.

REM Set Flutter path
set FLUTTER_PATH=C:\src\flutter\bin
set FLUTTER_CMD=%FLUTTER_PATH%\flutter.bat

REM Verify Flutter exists
if not exist "%FLUTTER_CMD%" (
    echo ERROR: Flutter not found at %FLUTTER_CMD%
    echo Please ensure Flutter is installed at C:\src\flutter
    pause
    exit /b 1
)

echo [Step 1] Adding Flutter to PATH...
set PATH=%FLUTTER_PATH%;%PATH%

REM Navigate to project
echo [Step 2] Navigating to project directory...
cd /d "c:\Users\anuj kumar\OneDrive\Desktop\anaj ai\mobile_app"
if errorlevel 1 (
    echo ERROR: Could not navigate to project
    pause
    exit /b 1
)
echo Current location: %cd%
echo.

REM Clean Flutter
echo [Step 3] Cleaning Flutter cache and build files...
call %FLUTTER_CMD% clean
if errorlevel 1 (
    echo WARNING: Flutter clean had issues, continuing...
)
echo.

REM Remove pub cache for dependencies
echo [Step 4] Clearing dependency locks...
if exist pubspec.lock (
    del pubspec.lock
    echo Removed pubspec.lock
)
echo.

REM Get fresh dependencies
echo [Step 5] Installing all dependencies...
echo This may take 5-10 minutes, please wait...
echo.
call %FLUTTER_CMD% pub get
if errorlevel 1 (
    echo ERROR: Failed to get dependencies
    echo Trying again with verbose mode...
    call %FLUTTER_CMD% pub get -v
    if errorlevel 1 (
        echo FATAL: Could not install dependencies
        pause
        exit /b 1
    )
)
echo [OK] Dependencies installed successfully!
echo.

REM Upgrade dependencies to latest compatible versions
echo [Step 6] Checking for dependency upgrades...
call %FLUTTER_CMD% pub upgrade --dry-run

REM Run Flutter doctor for diagnosis
echo.
echo [Step 7] Running Flutter Doctor for system check...
echo.
call %FLUTTER_CMD% doctor -v
echo.

REM Check devices
echo [Step 8] Checking available devices...
echo.
call %FLUTTER_CMD% devices
echo.

REM Create build files
echo [Step 9] Generating build files...
call %FLUTTER_CMD% pub run build_runner build --delete-conflicting-outputs 2>nul
echo.

REM Summary
echo.
echo ============================================
echo   ✓ Setup Complete!
echo ============================================
echo.
echo Next steps:
echo 1. Connect an Android device or start an emulator
echo 2. Run: flutter run
echo    OR
echo 3. Run: flutter run -v (for debugging)
echo.
pause
