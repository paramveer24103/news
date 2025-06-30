@echo off
echo ========================================
echo    InfoPulse - Push to GitHub
echo ========================================
echo.

echo Step 1: Checking Git installation...
git --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Git is not installed or not in PATH
    echo Please install Git from: https://git-scm.com/download/win
    pause
    exit /b 1
)
echo ✅ Git is installed

echo.
echo Step 2: Checking current directory...
echo Current directory: %cd%
echo.

echo Step 3: Initializing Git repository (if needed)...
if not exist ".git" (
    git init
    echo ✅ Git repository initialized
) else (
    echo ✅ Git repository already exists
)

echo.
echo Step 4: Adding remote repository...
git remote remove origin >nul 2>&1
git remote add origin https://github.com/paramveer24103/news.git
echo ✅ Remote repository added: https://github.com/paramveer24103/news.git

echo.
echo Step 5: Creating .gitignore file...
if not exist ".gitignore" (
    echo Creating .gitignore for Flutter project...
    (
        echo # Miscellaneous
        echo *.class
        echo *.log
        echo *.pyc
        echo *.swp
        echo .DS_Store
        echo .atom/
        echo .buildlog/
        echo .history
        echo .svn/
        echo migrate_working_dir/
        echo.
        echo # IntelliJ related
        echo *.iml
        echo *.ipr
        echo *.iws
        echo .idea/
        echo.
        echo # The .vscode folder contains launch configuration and tasks you configure in
        echo # VS Code which you may wish to be included in version control, so this line
        echo # is commented out by default.
        echo #.vscode/
        echo.
        echo # Flutter/Dart/Pub related
        echo **/doc/api/
        echo **/ios/Flutter/.last_build_id
        echo .dart_tool/
        echo .flutter-plugins
        echo .flutter-plugins-dependencies
        echo .packages
        echo .pub-cache/
        echo .pub/
        echo /build/
        echo.
        echo # Symbolication related
        echo app.*.symbols
        echo.
        echo # Obfuscation related
        echo app.*.map.json
        echo.
        echo # Android Studio will place build artifacts here
        echo /android/app/debug
        echo /android/app/profile
        echo /android/app/release
        echo.
        echo # Windows
        echo windows/flutter/generated_plugin_registrant.cc
        echo windows/flutter/generated_plugin_registrant.h
        echo.
        echo # API Keys ^(keep private^)
        echo lib/utils/api_keys.dart
        echo.
        echo # IDE files
        echo .vscode/
        echo *.code-workspace
        echo.
        echo # OS generated files
        echo Thumbs.db
        echo ehthumbs.db
        echo Desktop.ini
    ) > .gitignore
    echo ✅ .gitignore created
) else (
    echo ✅ .gitignore already exists
)

echo.
echo Step 6: Creating README.md...
if not exist "README.md" (
    (
        echo # InfoPulse - Flutter News App
        echo.
        echo A comprehensive cross-platform news application built with Flutter, featuring user authentication, news aggregation, and modern UI design.
        echo.
        echo ## 🚀 Features
        echo.
        echo ### 📰 News Features
        echo - **Global News Coverage** - Latest news from trusted sources
        echo - **Category Browsing** - Business, Technology, Sports, Health, Entertainment
        echo - **Search Functionality** - Find specific news articles
        echo - **Bookmarks** - Save articles for later reading
        echo - **Dark/Light Theme** - Customizable app appearance
        echo.
        echo ### 🔐 Authentication System
        echo - **User Registration** - Create account with email validation
        echo - **Secure Login** - Encrypted password storage
        echo - **Profile Management** - Edit user information
        echo - **Password Change** - Update credentials securely
        echo - **Session Management** - Persistent login state
        echo - **Logout** - Secure session termination
        echo.
        echo ### 🎨 UI/UX Features
        echo - **Onboarding Flow** - Welcome screens for new users
        echo - **Splash Screen** - Branded app launch
        echo - **Smooth Animations** - Enhanced user experience
        echo - **Material Design** - Modern Android design principles
        echo - **Responsive Layout** - Works on all screen sizes
        echo.
        echo ## 🛠️ Tech Stack
        echo.
        echo - **Framework**: Flutter ^3.16.0
        echo - **Language**: Dart
        echo - **State Management**: Provider
        echo - **HTTP Client**: http package
        echo - **Local Storage**: SharedPreferences
        echo - **Security**: crypto package for password hashing
        echo - **News API**: NewsAPI.org integration
        echo.
        echo ## 📦 Dependencies
        echo.
        echo ```yaml
        echo dependencies:
        echo   flutter:
        echo     sdk: flutter
        echo   provider: ^6.1.1
        echo   http: ^1.1.2
        echo   shared_preferences: ^2.2.2
        echo   crypto: ^3.0.3
        echo   uuid: ^4.2.1
        echo ```
        echo.
        echo ## 🚀 Getting Started
        echo.
        echo ### Prerequisites
        echo - Flutter SDK ^3.16.0
        echo - Dart SDK
        echo - Android Studio / VS Code
        echo - Android Emulator or Physical Device
        echo.
        echo ### Installation
        echo.
        echo 1. **Clone the repository**
        echo    ```bash
        echo    git clone https://github.com/paramveer24103/news.git
        echo    cd news
        echo    ```
        echo.
        echo 2. **Install dependencies**
        echo    ```bash
        echo    flutter pub get
        echo    ```
        echo.
        echo 3. **Configure NewsAPI Key**
        echo    - Get your free API key from [NewsAPI.org](https://newsapi.org/register^)
        echo    - Update `lib/utils/constants.dart` with your API key
        echo.
        echo 4. **Run the app**
        echo    ```bash
        echo    flutter run
        echo    ```
        echo.
        echo ## 📱 App Structure
        echo.
        echo ```
        echo lib/
        echo ├── models/           # Data models
        echo ├── providers/        # State management
        echo ├── screens/          # UI screens
        echo │   ├── auth/         # Authentication screens
        echo │   └── ...
        echo ├── services/         # API and business logic
        echo ├── utils/            # Constants and themes
        echo └── widgets/          # Reusable UI components
        echo ```
        echo.
        echo ## 🔐 Authentication Flow
        echo.
        echo 1. **First Launch**: Onboarding screens
        echo 2. **Registration**: Create account with validation
        echo 3. **Login**: Secure authentication
        echo 4. **Main App**: Access all features
        echo 5. **Profile**: Manage account settings
        echo.
        echo ## 🎯 Key Features Demo
        echo.
        echo - **Secure Registration**: Email validation, password strength
        echo - **Persistent Login**: Stay logged in between sessions
        echo - **Profile Management**: Edit details, change password
        echo - **News Browsing**: Categories, search, bookmarks
        echo - **Theme Toggle**: Light/Dark mode support
        echo.
        echo ## 🤝 Contributing
        echo.
        echo 1. Fork the repository
        echo 2. Create your feature branch (`git checkout -b feature/AmazingFeature`^)
        echo 3. Commit your changes (`git commit -m 'Add some AmazingFeature'`^)
        echo 4. Push to the branch (`git push origin feature/AmazingFeature`^)
        echo 5. Open a Pull Request
        echo.
        echo ## 📄 License
        echo.
        echo This project is licensed under the MIT License - see the LICENSE file for details.
        echo.
        echo ## 🙏 Acknowledgments
        echo.
        echo - [NewsAPI.org](https://newsapi.org/^) for providing news data
        echo - [Flutter](https://flutter.dev/^) for the amazing framework
        echo - [Material Design](https://material.io/^) for design guidelines
        echo.
        echo ## 📞 Contact
        echo.
        echo **Developer**: Paramveer Singh Zala
        echo **GitHub**: [@paramveer24103](https://github.com/paramveer24103^)
        echo **Repository**: [InfoPulse News App](https://github.com/paramveer24103/news^)
        echo.
        echo ---
        echo.
        echo **Built with ❤️ using Flutter**
    ) > README.md
    echo ✅ README.md created
) else (
    echo ✅ README.md already exists
)

echo.
echo Step 7: Adding all files to Git...
git add .
echo ✅ All files added to staging area

echo.
echo Step 8: Checking Git status...
git status

echo.
echo Step 9: Committing changes...
set /p commit_message="Enter commit message (or press Enter for default): "
if "%commit_message%"=="" (
    set commit_message=feat: Add comprehensive authentication system to InfoPulse news app
)
git commit -m "%commit_message%"
echo ✅ Changes committed with message: "%commit_message%"

echo.
echo Step 10: Pushing to GitHub...
echo Pushing to: https://github.com/paramveer24103/news.git
echo.
echo Note: You may be prompted for your GitHub credentials
echo If you have 2FA enabled, use a Personal Access Token instead of password
echo.
git push -u origin main
if %errorlevel% neq 0 (
    echo.
    echo ❌ Push failed. Trying with 'master' branch...
    git branch -M main
    git push -u origin main
    if %errorlevel% neq 0 (
        echo ❌ Push failed. Please check your credentials and try again.
        echo.
        echo Troubleshooting tips:
        echo 1. Make sure you have push access to the repository
        echo 2. If you have 2FA, use a Personal Access Token
        echo 3. Check your internet connection
        echo 4. Verify the repository URL is correct
        pause
        exit /b 1
    )
)

echo.
echo ========================================
echo ✅ SUCCESS! Code pushed to GitHub
echo ========================================
echo.
echo Repository URL: https://github.com/paramveer24103/news.git
echo.
echo Your InfoPulse app with authentication system is now available on GitHub!
echo.
echo What was pushed:
echo ✅ Complete Flutter news app
echo ✅ User authentication system
echo ✅ Login and registration screens
echo ✅ Profile management
echo ✅ Secure password storage
echo ✅ Session management
echo ✅ Modern UI with animations
echo ✅ News browsing and bookmarks
echo ✅ Theme support (Light/Dark)
echo.
echo Next steps:
echo 1. Visit your repository: https://github.com/paramveer24103/news.git
echo 2. Add repository description and topics on GitHub
echo 3. Consider adding screenshots to README
echo 4. Set up GitHub Actions for CI/CD (optional)
echo.
pause
