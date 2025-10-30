@echo off
setlocal enabledelayedexpansion

echo.
echo ================================================
echo    PhoneticAnalyzers - Local Development Setup
echo ================================================
echo.
echo This setup requires NO Azure CLI or cloud access!
echo Perfect while waiting for IT approvals.
echo.

echo Choose your local setup:
echo.
echo 1. Full local setup (PostgreSQL + Function Apps)
echo 2. Check prerequisites
echo 3. Start development (after setup)
echo 4. View setup guide
echo.

set /p choice="Enter your choice (1-4): "

if "%choice%"=="1" (
    echo.
    echo Setting up complete local development environment...
    echo.
    
    REM Check if .NET 8 is installed
    dotnet --version >nul 2>&1
    if %errorlevel% neq 0 (
        echo ERROR: .NET 8 SDK not found.
        echo Please install from: https://dotnet.microsoft.com/download/dotnet/8.0
        pause
        exit /b 1
    )
    
    echo ✅ .NET 8 SDK found
    
    REM Check for Docker
    docker --version >nul 2>&1
    if %errorlevel% equ 0 (
        echo ✅ Docker found - using containerized PostgreSQL
        echo Starting PostgreSQL container...
        docker run --name postgres-phonetic-local -e POSTGRES_PASSWORD=postgres -e POSTGRES_DB=phonetic_analyzers_dev -p 5432:5432 -d postgres:15
        timeout /t 10 >nul
    ) else (
        echo ⚠️  Docker not found
        echo Please install PostgreSQL manually from: https://www.postgresql.org/download/windows/
        echo Use these settings: Username=postgres, Password=postgres, Port=5432
        echo Create database: phonetic_analyzers_dev
        pause
    )
    
    echo.
    echo Building solution...
    dotnet restore
    dotnet build
    
    echo.
    echo Setting up database schema...
    cd src\PhoneticAnalyzers.Infrastructure
    dotnet tool install --global dotnet-ef --quiet
    dotnet ef database update
    cd ..\..
    
    echo.
    echo ✅ Setup complete!
    echo.
    echo Next steps:
    echo 1. Terminal 1: cd src\PhoneticAnalyzers.Functions.Ingestion ^&^& func start
    echo 2. Terminal 2: cd src\PhoneticAnalyzers.Functions.Search ^&^& func start --port 7072  
    echo 3. Test: curl http://localhost:7071/api/health
    echo.
    
) else if "%choice%"=="2" (
    echo.
    echo Checking prerequisites...
    echo.
    
    REM Check .NET
    dotnet --version >nul 2>&1
    if %errorlevel% equ 0 (
        echo ✅ .NET 8 SDK: Found
    ) else (
        echo ❌ .NET 8 SDK: Missing - Install from https://dotnet.microsoft.com/download/dotnet/8.0
    )
    
    REM Check Docker
    docker --version >nul 2>&1
    if %errorlevel% equ 0 (
        echo ✅ Docker: Found
    ) else (
        echo ⚠️  Docker: Not found - Install PostgreSQL manually or get Docker Desktop
    )
    
    REM Check Function Core Tools
    func --version >nul 2>&1
    if %errorlevel% equ 0 (
        echo ✅ Azure Functions Core Tools: Found  
    ) else (
        echo ❌ Azure Functions Core Tools: Missing - Run: npm install -g azure-functions-core-tools@4
    )
    
    REM Check PostgreSQL
    psql --version >nul 2>&1
    if %errorlevel% equ 0 (
        echo ✅ PostgreSQL Client: Found
    ) else (
        echo ⚠️  PostgreSQL Client: Not found (optional)
    )
    
) else if "%choice%"=="3" (
    echo.
    echo Starting development environment...
    echo.
    echo Open these in separate terminals:
    echo.
    echo Terminal 1 (Ingestion Function):
    echo cd src\PhoneticAnalyzers.Functions.Ingestion
    echo func start
    echo.
    echo Terminal 2 (Search Function):
    echo cd src\PhoneticAnalyzers.Functions.Search
    echo func start --port 7072
    echo.
    echo Then test with:
    echo curl http://localhost:7071/api/health
    echo.
    
) else if "%choice%"=="4" (
    echo.
    echo Opening local development guide...
    if exist "LOCAL_DEVELOPMENT_NO_CLOUD.md" (
        start "" "LOCAL_DEVELOPMENT_NO_CLOUD.md"
    ) else (
        echo LOCAL_DEVELOPMENT_NO_CLOUD.md not found.
        echo Please check the docs folder.
    )
    
) else (
    echo Invalid choice. Please run the script again.
)

echo.
echo ================================================
echo For detailed help, see LOCAL_DEVELOPMENT_NO_CLOUD.md
echo ================================================
pause