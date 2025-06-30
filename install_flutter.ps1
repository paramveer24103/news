# Flutter Installation Script for Windows
# Run this script as Administrator in PowerShell

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "    Flutter Installation Script" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if running as Administrator
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "❌ This script needs to be run as Administrator!" -ForegroundColor Red
    Write-Host "Right-click PowerShell and select 'Run as Administrator'" -ForegroundColor Yellow
    pause
    exit 1
}

# Step 1: Check if Flutter is already installed
Write-Host "Step 1: Checking if Flutter is already installed..." -ForegroundColor Yellow
try {
    $flutterVersion = flutter --version 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Flutter is already installed!" -ForegroundColor Green
        Write-Host $flutterVersion
        Write-Host ""
        Write-Host "Running flutter doctor..." -ForegroundColor Yellow
        flutter doctor
        pause
        exit 0
    }
} catch {
    Write-Host "Flutter not found, proceeding with installation..." -ForegroundColor Yellow
}

# Step 2: Create Flutter directory
Write-Host "Step 2: Creating Flutter directory..." -ForegroundColor Yellow
$flutterPath = "C:\flutter"
if (!(Test-Path $flutterPath)) {
    New-Item -ItemType Directory -Path $flutterPath -Force
    Write-Host "✅ Created directory: $flutterPath" -ForegroundColor Green
} else {
    Write-Host "✅ Directory already exists: $flutterPath" -ForegroundColor Green
}

# Step 3: Download Flutter SDK
Write-Host "Step 3: Downloading Flutter SDK..." -ForegroundColor Yellow
$flutterUrl = "https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.16.5-stable.zip"
$zipPath = "$env:TEMP\flutter_windows_stable.zip"

try {
    Write-Host "Downloading from: $flutterUrl" -ForegroundColor Cyan
    Write-Host "This may take a few minutes..." -ForegroundColor Yellow
    Invoke-WebRequest -Uri $flutterUrl -OutFile $zipPath -UseBasicParsing
    Write-Host "✅ Download completed!" -ForegroundColor Green
} catch {
    Write-Host "❌ Download failed: $_" -ForegroundColor Red
    pause
    exit 1
}

# Step 4: Extract Flutter SDK
Write-Host "Step 4: Extracting Flutter SDK..." -ForegroundColor Yellow
try {
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::ExtractToDirectory($zipPath, $flutterPath)
    Write-Host "✅ Extraction completed!" -ForegroundColor Green
} catch {
    Write-Host "❌ Extraction failed: $_" -ForegroundColor Red
    pause
    exit 1
}

# Step 5: Add Flutter to PATH
Write-Host "Step 5: Adding Flutter to PATH..." -ForegroundColor Yellow
$flutterBinPath = "$flutterPath\flutter\bin"
$currentPath = [Environment]::GetEnvironmentVariable("Path", "User")

if ($currentPath -notlike "*$flutterBinPath*") {
    $newPath = "$currentPath;$flutterBinPath"
    [Environment]::SetEnvironmentVariable("Path", $newPath, "User")
    Write-Host "✅ Added Flutter to PATH!" -ForegroundColor Green
} else {
    Write-Host "✅ Flutter already in PATH!" -ForegroundColor Green
}

# Step 6: Refresh environment variables
Write-Host "Step 6: Refreshing environment variables..." -ForegroundColor Yellow
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# Step 7: Verify Flutter installation
Write-Host "Step 7: Verifying Flutter installation..." -ForegroundColor Yellow
try {
    & "$flutterBinPath\flutter.bat" --version
    Write-Host "✅ Flutter installed successfully!" -ForegroundColor Green
} catch {
    Write-Host "❌ Flutter verification failed: $_" -ForegroundColor Red
}

# Step 8: Run Flutter Doctor
Write-Host "Step 8: Running Flutter Doctor..." -ForegroundColor Yellow
Write-Host "This will show what additional tools you need to install." -ForegroundColor Cyan
Write-Host ""
try {
    & "$flutterBinPath\flutter.bat" doctor
} catch {
    Write-Host "❌ Flutter doctor failed: $_" -ForegroundColor Red
}

# Step 9: Cleanup
Write-Host "Step 9: Cleaning up..." -ForegroundColor Yellow
Remove-Item $zipPath -Force -ErrorAction SilentlyContinue
Write-Host "✅ Cleanup completed!" -ForegroundColor Green

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "    Installation Summary" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "✅ Flutter SDK installed to: $flutterPath\flutter" -ForegroundColor Green
Write-Host "✅ Added to PATH: $flutterBinPath" -ForegroundColor Green
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host "1. Install Android Studio from: https://developer.android.com/studio" -ForegroundColor White
Write-Host "2. Install Flutter and Dart plugins in Android Studio" -ForegroundColor White
Write-Host "3. Run 'flutter doctor --android-licenses' to accept licenses" -ForegroundColor White
Write-Host "4. Create an Android Virtual Device (AVD)" -ForegroundColor White
Write-Host "5. Test with: flutter create test_app && cd test_app && flutter run" -ForegroundColor White
Write-Host ""
Write-Host "For your InfoPulse app, run:" -ForegroundColor Yellow
Write-Host "cd 'C:\Users\paramveer sinh zala\OneDrive\Desktop\news  appication4'" -ForegroundColor White
Write-Host "flutter pub get" -ForegroundColor White
Write-Host "flutter run" -ForegroundColor White
Write-Host ""
pause
