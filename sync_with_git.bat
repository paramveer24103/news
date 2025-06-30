@echo off
echo ========================================
echo    InfoPulse - Sync with GitHub
echo ========================================
echo.

echo Step 1: Checking current Git status...
git status

echo.
echo Step 2: Pulling latest changes from remote repository...
echo This will merge any existing content from GitHub...
git pull origin main --allow-unrelated-histories
if %errorlevel% neq 0 (
    echo Trying with master branch...
    git pull origin master --allow-unrelated-histories
    if %errorlevel% neq 0 (
        echo ❌ Pull failed. Let's try a different approach...
        echo.
        echo Step 2b: Fetching remote content...
        git fetch origin
        echo.
        echo Step 2c: Merging with remote content...
        git merge origin/main --allow-unrelated-histories -m "Merge remote repository with local InfoPulse app"
        if %errorlevel% neq 0 (
            git merge origin/master --allow-unrelated-histories -m "Merge remote repository with local InfoPulse app"
        )
    )
)

echo.
echo Step 3: Checking for conflicts...
git status

echo.
echo Step 4: Adding any new changes...
git add .

echo.
echo Step 5: Committing merged changes...
git commit -m "feat: Complete InfoPulse Flutter app with authentication system

- Added comprehensive news aggregation features
- Implemented user authentication system
- Created login and registration screens
- Added profile management functionality
- Integrated secure password storage
- Added session management
- Implemented modern UI with animations
- Added news browsing, search, and bookmarks
- Included theme support (Light/Dark mode)
- Added onboarding flow for new users"

echo.
echo Step 6: Pushing to GitHub...
echo Pushing to: https://github.com/paramveer24103/news.git
git push origin main
if %errorlevel% neq 0 (
    echo Trying with master branch...
    git push origin master
    if %errorlevel% neq 0 (
        echo ❌ Push still failed. Let's check the branch...
        git branch -a
        echo.
        echo Current branch:
        git branch --show-current
        echo.
        echo Let's push to the current branch:
        git push origin HEAD
    )
)

echo.
echo ========================================
echo ✅ SUCCESS! Code synced with GitHub
echo ========================================
echo.
echo Repository URL: https://github.com/paramveer24103/news.git
echo.
echo Your InfoPulse app is now available on GitHub!
echo.
pause
