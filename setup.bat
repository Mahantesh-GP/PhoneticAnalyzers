@echo off
setlocal enabledelayedexpansion

echo.
echo ==========================================
echo    PhoneticAnalyzers Quick Setup
echo ==========================================
echo.

REM Check if PowerShell is available
where powershell >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: PowerShell not found. Please install PowerShell.
    pause
    exit /b 1
)

echo Choose setup option:
echo 1. Full setup (Prerequisites + Services + Tests)
echo 2. Prerequisites check only
echo 3. Start services only
echo 4. Run tests only
echo 5. Manual setup (see DEVELOPMENT_SETUP.md)
echo.

set /p choice="Enter your choice (1-5): "

if "%choice%"=="1" (
    echo Running full setup...
    powershell -ExecutionPolicy Bypass -File "setup-dev.ps1" -StartServices -RunTests
) else if "%choice%"=="2" (
    echo Checking prerequisites...
    powershell -ExecutionPolicy Bypass -File "setup-dev.ps1"
) else if "%choice%"=="3" (
    echo Starting services...
    powershell -ExecutionPolicy Bypass -File "setup-dev.ps1" -SkipPrerequisiteCheck -StartServices
) else if "%choice%"=="4" (
    echo Running tests...
    powershell -ExecutionPolicy Bypass -File "setup-dev.ps1" -SkipPrerequisiteCheck -RunTests
) else if "%choice%"=="5" (
    echo Opening setup guide...
    if exist "DEVELOPMENT_SETUP.md" (
        start "" "DEVELOPMENT_SETUP.md"
    ) else (
        echo DEVELOPMENT_SETUP.md not found. Please read the README.md file.
    )
) else (
    echo Invalid choice. Please run the script again.
)

echo.
pause