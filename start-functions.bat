@echo off
echo.
echo 🚀 Starting PhoneticAnalyzers Function App
echo ========================================
echo.

REM Check if .NET 8 is installed
dotnet --version >nul 2>&1
if errorlevel 1 (
    echo ❌ .NET 8 SDK not found!
    echo 📥 Please install: winget install Microsoft.DotNet.SDK.8
    echo 🌐 Or download from: https://dotnet.microsoft.com/download/dotnet/8.0
    pause
    exit /b 1
)

REM Check if Azure Functions Core Tools is installed
func --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Azure Functions Core Tools not found!
    echo 📥 Installing now...
    npm install -g azure-functions-core-tools@4 --unsafe-perm true
    if errorlevel 1 (
        echo ❌ Installation failed. Please install manually:
        echo 🌐 https://docs.microsoft.com/en-us/azure/azure-functions/functions-run-local
        pause
        exit /b 1
    )
)

echo ✅ Prerequisites check passed!
echo.

REM Navigate to the function directory
cd /d "%~dp0src\PhoneticAnalyzers.Functions.Ingestion"

echo 📦 Building the project...
dotnet build
if errorlevel 1 (
    echo ❌ Build failed! 
    echo 🔧 Try: dotnet clean && dotnet restore && dotnet build
    pause
    exit /b 1
)

echo.
echo 🚀 Starting Azure Function...
echo 📡 API will be available at: http://localhost:7071
echo.
echo ⚡ Available endpoints:
echo    • GET  /api/health              - Health check
echo    • POST /api/ingest              - Add single person
echo    • POST /api/ingest/batch        - Add multiple persons
echo    • GET  /api/search?name=John    - Search by name
echo    • GET  /api/person/{id}         - Get person by ID
echo.
echo 🧪 To test the API, run: .\test-api.ps1
echo 🛑 Press Ctrl+C to stop the function
echo.

func start

pause