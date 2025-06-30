@echo off
echo ========================================
echo    InfoPulse News App Setup Script
echo ========================================
echo.

echo Step 1: Checking Flutter installation...
flutter doctor
if %errorlevel% neq 0 (
    echo ERROR: Flutter is not installed or not in PATH
    echo Please install Flutter first: https://flutter.dev/docs/get-started/install/windows
    pause
    exit /b 1
)

echo.
echo Step 2: Installing dependencies...
flutter pub get
if %errorlevel% neq 0 (
    echo ERROR: Failed to install dependencies
    pause
    exit /b 1
)

echo.
echo Step 3: Checking for connected devices...
flutter devices

echo.
echo Step 4: Running the app...
echo ✅ NewsAPI key is already configured!
echo ✅ Authentication system is ready!
echo Make sure you have started an Android emulator or connected a device
echo.
echo Available run options:
echo 1. Android Emulator/Device: flutter run
echo 2. Chrome Browser: flutter run -d chrome
echo.
echo New Features Added:
echo - User Registration and Login
echo - Profile Management
echo - Secure Password Storage
echo - Session Management
echo.
pause

flutter run
