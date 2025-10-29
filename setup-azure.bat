@echo off
setlocal enabledelayedexpansion

echo.
echo ================================================
echo    PhoneticAnalyzers - Azure Cloud Setup
echo ================================================
echo.
echo This setup is designed for fintech companies where
echo Docker is not allowed. Everything runs in Azure!
echo.

REM Check if PowerShell is available
where powershell >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: PowerShell not found. Please install PowerShell.
    pause
    exit /b 1
)

REM Check if Azure CLI is installed
where az >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Azure CLI not found. 
    echo Please install Azure CLI from: https://aka.ms/installazurecliwindows
    echo Or run: winget install Microsoft.AzureCLI
    pause
    exit /b 1
)

echo Choose your deployment option:
echo.
echo 1. Development (Simple) - NO VNet, IP firewall only
echo 2. Development (Secure) - WITH VNet and private endpoints  
echo 3. Production environment - Full security with VNet
echo 4. Deploy application code only - EXISTING infrastructure
echo 5. Check Azure login status
echo 6. Manual setup guide
echo.

set /p choice="Enter your choice (1-6): "

if "%choice%"=="1" (
    echo.
    echo Setting up SIMPLE development environment (no VNet)...
    echo This is perfect for getting started quickly!
    echo - PostgreSQL with IP firewall
    echo - Public Function App endpoints  
    echo - Cost: ~$20-40/month
    echo.
    powershell -ExecutionPolicy Bypass -File "deploy-dev-simple.ps1" -Environment dev
    
) else if "%choice%"=="2" (
    echo.
    echo Setting up SECURE development environment (with VNet)...
    echo This includes enterprise security features:
    echo - Private PostgreSQL endpoints
    echo - VNet integration
    echo - Cost: ~$60-80/month
    echo.
    powershell -ExecutionPolicy Bypass -File "deploy-dev-simple.ps1" -Environment dev -EnableVNet
    
) else if "%choice%"=="3" (
    echo.
    echo Setting up PRODUCTION environment (full security)...
    echo This includes all enterprise features:
    echo - High availability PostgreSQL
    echo - Private endpoints and VNet
    echo - Complete monitoring and security
    echo - Cost: ~$100-200/month
    echo.
    powershell -ExecutionPolicy Bypass -File "deploy-dev-simple.ps1" -Environment prod -EnableVNet
    
) else if "%choice%"=="4" (
    echo.
    set /p env="Enter environment name (dev/prod): "
    
    echo Deploying application code only...
    powershell -ExecutionPolicy Bypass -File "deploy-azure.ps1" -Environment !env! -SkipInfrastructure
    
) else if "%choice%"=="5" (
    echo Checking Azure login status...
    az account show
    if %errorlevel% neq 0 (
        echo You are not logged in. Please run: az login
    )
    
) else if "%choice%"=="6" (
    echo Opening Azure setup guide...
    if exist "AZURE_DEPLOYMENT_SETUP.md" (
        start "" "AZURE_DEPLOYMENT_SETUP.md"
    ) else (
        echo AZURE_DEPLOYMENT_SETUP.md not found.
    )
    
) else (
    echo Invalid choice. Please run the script again.
)

echo.
echo ================================================
echo Need help? Check AZURE_DEPLOYMENT_SETUP.md
echo ================================================
pause