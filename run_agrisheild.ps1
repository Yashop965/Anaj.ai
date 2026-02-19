# AgriShield App - Complete Setup and Run Script (PowerShell)

Write-Host "`n============================================" -ForegroundColor Cyan
Write-Host "   AgriShield - Complete Setup and Run" -ForegroundColor Cyan
Write-Host "============================================`n" -ForegroundColor Cyan

# Set Flutter to PATH
$env:PATH = "C:\src\flutter\bin;$env:PATH"

# Step 1: Navigate to project
Write-Host "[Step 1] Navigating to project..." -ForegroundColor Green
$projectPath = "c:\Users\anuj kumar\OneDrive\Desktop\anaj ai\mobile_app"

if (Test-Path $projectPath) {
    Set-Location $projectPath
    Write-Host "Current directory: $(Get-Location)" -ForegroundColor Yellow
} else {
    Write-Host "ERROR: Project directory not found!" -ForegroundColor Red
    Write-Host "Path: $projectPath" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host ""

# Step 2: Get Flutter dependencies
Write-Host "[Step 2] Getting Flutter dependencies..." -ForegroundColor Green
Write-Host "This may take 2-5 minutes..." -ForegroundColor Yellow
Write-Host ""

try {
    & flutter pub get
    Write-Host "`n✓ Dependencies downloaded successfully!" -ForegroundColor Green
} catch {
    Write-Host "`n⚠ Warning: Some issues occurred, but continuing..." -ForegroundColor Yellow
}

Write-Host ""

# Step 3: Check for devices
Write-Host "[Step 3] Checking for available devices..." -ForegroundColor Green
Write-Host ""

$devices = & flutter devices 2>&1
Write-Host $devices

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "   Ready to Run!" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan

Write-Host "`nAvailable commands:
  flutter run              - Run on default device
  flutter run -v           - Verbose mode (debugging)
  flutter run -d <id>      - Run on specific device
  flutter build apk        - Build Android APK
  
Press Enter to start 'flutter run'...
" -ForegroundColor Green

Read-Host

# Step 4: Run the app
Write-Host "`n[Step 4] Starting AgriShield app...`n" -ForegroundColor Green

try {
    & flutter run
} catch {
    Write-Host "`nError running app: $_" -ForegroundColor Red
    Write-Host "Run 'flutter doctor' to check for issues" -ForegroundColor Yellow
}

Write-Host "`n✓ App session ended" -ForegroundColor Green
Read-Host "Press Enter to exit"
