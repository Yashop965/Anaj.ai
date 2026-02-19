@echo off
REM AgriShield App - Complete Setup and Run Script

setlocal enabledelayedexpansion

REM Set Flutter path
set FLUTTER_PATH=C:\src\flutter\bin
set PATH=%FLUTTER_PATH%;%PATH%

echo.
echo ============================================
echo   AgriShield - Complete Setup and Run
echo ============================================
echo.

REM Step 1: Navigate to project
echo [Step 1] Navigating to project...
cd /d "c:\Users\anuj kumar\OneDrive\Desktop\anaj ai\mobile_app"
if errorlevel 1 (
    echo ERROR: Could not navigate to project directory
    pause
    exit /b 1
)
echo Current directory: %cd%
echo.

REM Step 2: Get Flutter dependencies
echo [Step 2] Getting Flutter dependencies...
echo This may take 2-5 minutes...
echo.
call flutter pub get

if errorlevel 1 (
    echo.
    echo WARNING: Some dependencies may have failed
    echo But we'll try to continue...
    echo.
)

echo.
echo [Step 3] Flutter dependencies ready!
echo.

REM Step 3: List available devices
echo [Step 4] Checking for available devices...
echo.
call flutter devices

echo.
echo ============================================
echo   Setup Complete!
echo ============================================
echo.
echo To run your app, use one of these commands:
echo.
echo   flutter run                    (Run on default device)
echo   flutter run -d emulator-5554   (Run on specific device)
echo   flutter run -v                 (Verbose mode for debugging)
echo.
echo Press Enter to run 'flutter run'...
pause

REM Step 4: Run the app
echo.
echo [Step 5] Starting AgriShield app...
echo.
call flutter run

echo.
echo App run completed!
pause
