# Flutter Automated Setup Script for Windows (PowerShell)
# This script downloads and installs Flutter SDK

Write-Host "`n============================================" -ForegroundColor Cyan
Write-Host "   AgriShield - Flutter Setup" -ForegroundColor Cyan
Write-Host "============================================`n" -ForegroundColor Cyan

# Check if running as Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
if (-not $isAdmin) {
    Write-Host "WARNING: This script should be run as Administrator for best results." -ForegroundColor Yellow
    Write-Host "Some operations may not work without admin privileges." -ForegroundColor Yellow
    Write-Host ""
}

# Step 1: Create src directory
Write-Host "[Step 1] Setting up directories..." -ForegroundColor Green
if (-not (Test-Path "C:\src")) {
    Write-Host "Creating C:\src..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Path "C:\src" -Force | Out-Null
} else {
    Write-Host "C:\src already exists" -ForegroundColor Gray
}

# Step 2: Check Git installation
Write-Host "`n[Step 2] Checking Git installation..." -ForegroundColor Green
$gitPath = (Get-Command git -ErrorAction SilentlyContinue).Source
if ($null -eq $gitPath) {
    Write-Host "ERROR: Git is not installed!" -ForegroundColor Red
    Write-Host "Please download and install Git from: https://git-scm.com/download/win" -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
} else {
    Write-Host "Git found at: $gitPath" -ForegroundColor Green
}

# Step 3: Download Flutter
Write-Host "`n[Step 3] Downloading Flutter SDK..." -ForegroundColor Green
Write-Host "This may take 2-5 minutes. Please wait..." -ForegroundColor Yellow

Push-Location "C:\src"
try {
    # Check if Flutter already exists
    if (Test-Path "C:\src\flutter" -PathType Container) {
        Write-Host "Flutter already exists at C:\src\flutter" -ForegroundColor Yellow
        $choice = Read-Host "Do you want to update it? (y/n)"
        if ($choice -eq 'y') {
            Write-Host "Updating Flutter..." -ForegroundColor Yellow
            Set-Location "C:\src\flutter"
            git pull origin stable | Out-Null
            Write-Host "Flutter updated!" -ForegroundColor Green
        }
    } else {
        Write-Host "Cloning Flutter repository..." -ForegroundColor Yellow
        git clone https://github.com/flutter/flutter.git -b stable --depth 1
        if ($LASTEXITCODE -ne 0) {
            Write-Host "ERROR: Failed to download Flutter" -ForegroundColor Red
            Read-Host "Press Enter to exit"
            exit 1
        }
        Write-Host "Flutter downloaded successfully!" -ForegroundColor Green
    }
} finally {
    Pop-Location
}

# Step 4: Add Flutter to PATH
Write-Host "`n[Step 4] Adding Flutter to system PATH..." -ForegroundColor Green

$flutterBin = "C:\src\flutter\bin"
$currentPath = [Environment]::GetEnvironmentVariable("PATH", "User")

if (!($currentPath -like "*flutter*")) {
    Write-Host "Updating PATH variable..." -ForegroundColor Yellow
    [Environment]::SetEnvironmentVariable("PATH", "$flutterBin;$currentPath", "User")
    
    # Also add to current session
    $env:PATH = "$flutterBin;$env:PATH"
    
    Write-Host "PATH updated successfully!" -ForegroundColor Green
} else {
    Write-Host "Flutter already in PATH" -ForegroundColor Green
}

# Step 5: Run Flutter Doctor
Write-Host "`n[Step 5] Running Flutter Doctor..." -ForegroundColor Green
Write-Host "Checking your system configuration..." -ForegroundColor Yellow
Write-Host "`n"

& "$flutterBin\flutter" doctor

# Step 6: Summary
Write-Host "`n============================================" -ForegroundColor Cyan
Write-Host "   Setup Complete!" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan

Write-Host "`nNext Steps:
1. Close and reopen PowerShell
2. Navigate to project: cd 'C:\Users\anuj kumar\OneDrive\Desktop\anaj ai\mobile_app'
3. Get dependencies: flutter pub get
4. Run app: flutter run

Quick Commands:
- View Flutter info: flutter --version
- Check setup: flutter doctor
- Run your app: flutter run
- Build APK: flutter build apk
- Build iOS: flutter build ios

Documentation: https://flutter.dev/docs
Github: https://github.com/flutter/flutter
`n" -ForegroundColor Green

Write-Host "Your AgriShield app is ready to run!" -ForegroundColor Cyan
Read-Host "`nPress Enter to finish"
