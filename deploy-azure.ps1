#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Azure-only deployment script for PhoneticAnalyzers (No Docker required)

.DESCRIPTION
    This script deploys PhoneticAnalyzers to Azure without requiring Docker or local databases.
    Perfect for fintech companies with strict security policies.

.PARAMETER Environment
    The environment to deploy to (dev, test, prod)

.PARAMETER Location
    Azure region for deployment (default: East US 2)

.PARAMETER SkipInfrastructure
    Skip infrastructure deployment and only deploy application code

.PARAMETER ResourceGroupName
    Custom resource group name (optional)

.EXAMPLE
    .\deploy-azure.ps1 -Environment dev -Location "East US 2"
    
.EXAMPLE
    .\deploy-azure.ps1 -Environment prod -SkipInfrastructure
#>

param(
    [Parameter(Mandatory = $true)]
    [ValidateSet("dev", "test", "prod")]
    [string]$Environment,
    
    [string]$Location = "East US 2",
    
    [switch]$SkipInfrastructure,
    
    [string]$ResourceGroupName = ""
)

# Colors for output
$Red = @{ ForegroundColor = "Red" }
$Green = @{ ForegroundColor = "Green" }
$Yellow = @{ ForegroundColor = "Yellow" }
$Blue = @{ ForegroundColor = "Blue" }
$Cyan = @{ ForegroundColor = "Cyan" }

Write-Host "🚀 PhoneticAnalyzers Azure Deployment" @Blue
Write-Host "====================================" @Blue
Write-Host "Environment: $Environment" @Cyan
Write-Host "Location: $Location" @Cyan
Write-Host ""

# Generate unique names based on environment
$timestamp = Get-Date -Format "yyyyMMdd"
$random = Get-Random -Minimum 1000 -Maximum 9999

if ([string]::IsNullOrEmpty($ResourceGroupName)) {
    $ResourceGroupName = "rg-phoneticanalyzers-$Environment-$timestamp"
}

$dbServerName = "psql-phoneticanalyzers-$Environment-$random"
$functionAppIngestion = "func-phoneticanalyzers-ingestion-$Environment-$random"
$functionAppSearch = "func-phoneticanalyzers-search-$Environment-$random"
$storageAccountName = "stphoneticanalyzers$Environment$random"
$keyVaultName = "kv-phoneticanalyzers-$Environment-$random"
$appInsightsName = "ai-phoneticanalyzers-$Environment-$random"

# Database configuration based on environment
$dbConfig = @{
    dev = @{
        sku = "Standard_B1ms"
        tier = "Burstable"
        storage = 32
        backup_retention = 7
        ha_enabled = $false
    }
    test = @{
        sku = "Standard_B2s" 
        tier = "Burstable"
        storage = 64
        backup_retention = 14
        ha_enabled = $false
    }
    prod = @{
        sku = "Standard_D2s_v3"
        tier = "GeneralPurpose"
        storage = 128
        backup_retention = 30
        ha_enabled = $true
    }
}

function Test-AzureCLI {
    try {
        $account = az account show --output json 2>$null | ConvertFrom-Json
        if ($account) {
            Write-Host "✅ Logged into Azure as: $($account.user.name)" @Green
            Write-Host "   Subscription: $($account.name)" @Blue
            return $true
        }
    }
    catch {
        Write-Host "❌ Not logged into Azure CLI" @Red
        Write-Host "Please run: az login" @Yellow
        return $false
    }
    return $false
}

function Deploy-Infrastructure {
    Write-Host "🏗️ Deploying Azure Infrastructure..." @Yellow
    Write-Host ""

    # Create Resource Group
    Write-Host "Creating resource group: $ResourceGroupName" @Blue
    az group create --name $ResourceGroupName --location $Location --output table
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Failed to create resource group" @Red
        exit 1
    }

    # Create PostgreSQL Flexible Server
    Write-Host ""
    Write-Host "Creating PostgreSQL Flexible Server: $dbServerName" @Blue
    
    $dbPassword = Read-Host "Enter PostgreSQL admin password (min 8 characters)" -AsSecureString
    $dbPasswordPlain = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($dbPassword))
    
    $dbArgs = @(
        "postgres", "flexible-server", "create"
        "--resource-group", $ResourceGroupName
        "--name", $dbServerName
        "--location", $Location
        "--admin-user", "pgadmin"
        "--admin-password", $dbPasswordPlain
        "--sku-name", $dbConfig[$Environment].sku
        "--tier", $dbConfig[$Environment].tier
        "--storage-size", $dbConfig[$Environment].storage
        "--backup-retention", $dbConfig[$Environment].backup_retention
        "--version", "15"
        "--public-access", "0.0.0.0"
        "--output", "table"
    )
    
    if ($dbConfig[$Environment].ha_enabled) {
        $dbArgs += "--high-availability", "Enabled"
    }
    
    & az @dbArgs
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Failed to create PostgreSQL server" @Red
        exit 1
    }

    # Create database
    Write-Host ""
    Write-Host "Creating database: phonetic_analyzers" @Blue
    az postgres flexible-server db create `
        --resource-group $ResourceGroupName `
        --server-name $dbServerName `
        --database-name "phonetic_analyzers" `
        --output table

    # Create Storage Account
    Write-Host ""
    Write-Host "Creating storage account: $storageAccountName" @Blue
    az storage account create `
        --name $storageAccountName `
        --resource-group $ResourceGroupName `
        --location $Location `
        --sku "Standard_LRS" `
        --output table

    # Create Key Vault
    Write-Host ""
    Write-Host "Creating Key Vault: $keyVaultName" @Blue
    az keyvault create `
        --name $keyVaultName `
        --resource-group $ResourceGroupName `
        --location $Location `
        --output table

    # Store database password in Key Vault
    Write-Host "Storing database password in Key Vault..." @Blue
    az keyvault secret set `
        --vault-name $keyVaultName `
        --name "postgresql-password" `
        --value $dbPasswordPlain `
        --output table

    # Create Application Insights
    Write-Host ""
    Write-Host "Creating Application Insights: $appInsightsName" @Blue
    az monitor app-insights component create `
        --app $appInsightsName `
        --location $Location `
        --resource-group $ResourceGroupName `
        --output table

    # Create Function Apps
    Write-Host ""
    Write-Host "Creating Function App (Ingestion): $functionAppIngestion" @Blue
    az functionapp create `
        --resource-group $ResourceGroupName `
        --name $functionAppIngestion `
        --storage-account $storageAccountName `
        --functions-version 4 `
        --runtime "dotnet-isolated" `
        --runtime-version "8.0" `
        --consumption-plan-location $Location `
        --output table

    Write-Host ""
    Write-Host "Creating Function App (Search): $functionAppSearch" @Blue
    az functionapp create `
        --resource-group $ResourceGroupName `
        --name $functionAppSearch `
        --storage-account $storageAccountName `
        --functions-version 4 `
        --runtime "dotnet-isolated" `
        --runtime-version "8.0" `
        --consumption-plan-location $Location `
        --output table

    # Get connection strings
    Write-Host ""
    Write-Host "Configuring connection strings..." @Blue
    
    $dbConnectionString = "Host=$dbServerName.postgres.database.azure.com;Database=phonetic_analyzers;Username=pgladmin;Password=$dbPasswordPlain;SSL Mode=Require;"
    
    $aiConnectionString = az monitor app-insights component show `
        --app $appInsightsName `
        --resource-group $ResourceGroupName `
        --query "connectionString" -o tsv

    # Configure Function App settings
    Write-Host "Configuring Ingestion Function App..." @Blue
    az functionapp config appsettings set `
        --resource-group $ResourceGroupName `
        --name $functionAppIngestion `
        --settings `
            "ConnectionStrings__DefaultConnection=$dbConnectionString" `
            "APPLICATIONINSIGHTS_CONNECTION_STRING=$aiConnectionString" `
            "ASPNETCORE_ENVIRONMENT=$Environment" `
        --output table

    Write-Host "Configuring Search Function App..." @Blue
    az functionapp config appsettings set `
        --resource-group $ResourceGroupName `
        --name $functionAppSearch `
        --settings `
            "ConnectionStrings__DefaultConnection=$dbConnectionString" `
            "APPLICATIONINSIGHTS_CONNECTION_STRING=$aiConnectionString" `
            "ASPNETCORE_ENVIRONMENT=$Environment" `
        --output table

    # Enable managed identity
    Write-Host ""
    Write-Host "Enabling managed identities..." @Blue
    az functionapp identity assign --resource-group $ResourceGroupName --name $functionAppIngestion --output table
    az functionapp identity assign --resource-group $ResourceGroupName --name $functionAppSearch --output table

    Write-Host ""
    Write-Host "✅ Infrastructure deployment completed!" @Green
    Write-Host ""
    Write-Host "📋 Deployment Summary:" @Yellow
    Write-Host "Resource Group: $ResourceGroupName" @Cyan
    Write-Host "PostgreSQL Server: $dbServerName.postgres.database.azure.com" @Cyan
    Write-Host "Ingestion Function: https://$functionAppIngestion.azurewebsites.net" @Cyan
    Write-Host "Search Function: https://$functionAppSearch.azurewebsites.net" @Cyan
    Write-Host ""

    # Store deployment info for later use
    $deploymentInfo = @{
        resourceGroup = $ResourceGroupName
        dbServer = $dbServerName
        dbPassword = $dbPasswordPlain
        functionAppIngestion = $functionAppIngestion
        functionAppSearch = $functionAppSearch
        keyVault = $keyVaultName
        appInsights = $appInsightsName
    }
    
    $deploymentInfo | ConvertTo-Json | Out-File "deployment-info-$Environment.json"
    Write-Host "💾 Deployment info saved to: deployment-info-$Environment.json" @Blue
}

function Deploy-Application {
    Write-Host "📦 Deploying Application Code..." @Yellow
    Write-Host ""

    # Load deployment info if skipping infrastructure
    if ($SkipInfrastructure) {
        if (Test-Path "deployment-info-$Environment.json") {
            $deploymentInfo = Get-Content "deployment-info-$Environment.json" | ConvertFrom-Json
            $functionAppIngestion = $deploymentInfo.functionAppIngestion
            $functionAppSearch = $deploymentInfo.functionAppSearch
            $ResourceGroupName = $deploymentInfo.resourceGroup
        }
        else {
            Write-Host "❌ No deployment info found. Run without -SkipInfrastructure first." @Red
            exit 1
        }
    }

    # Build solution
    Write-Host "Building solution..." @Blue
    dotnet build --configuration Release
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Build failed" @Red
        exit 1
    }

    # Deploy Ingestion Function
    Write-Host ""
    Write-Host "Deploying Ingestion Function App..." @Blue
    Push-Location "src\PhoneticAnalyzers.Functions.Ingestion"
    
    func azure functionapp publish $functionAppIngestion --force
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Failed to deploy Ingestion Function" @Red
        Pop-Location
        exit 1
    }
    
    Pop-Location

    # Deploy Search Function (if exists)
    if (Test-Path "src\PhoneticAnalyzers.Functions.Search") {
        Write-Host ""
        Write-Host "Deploying Search Function App..." @Blue
        Push-Location "src\PhoneticAnalyzers.Functions.Search"
        
        func azure functionapp publish $functionAppSearch --force
        
        if ($LASTEXITCODE -ne 0) {
            Write-Host "❌ Failed to deploy Search Function" @Red
            Pop-Location
            exit 1
        }
        
        Pop-Location
    }

    Write-Host ""
    Write-Host "✅ Application deployment completed!" @Green
}

function Setup-Database {
    Write-Host "🗄️ Setting up Database Schema..." @Yellow
    Write-Host ""

    # Load deployment info
    if (Test-Path "deployment-info-$Environment.json") {
        $deploymentInfo = Get-Content "deployment-info-$Environment.json" | ConvertFrom-Json
        $dbServer = $deploymentInfo.dbServer
        $dbPassword = $deploymentInfo.dbPassword
        $ResourceGroupName = $deploymentInfo.resourceGroup
    }
    else {
        Write-Host "❌ No deployment info found. Deploy infrastructure first." @Red
        exit 1
    }

    # Add firewall rule for current IP
    Write-Host "Adding firewall rule for current IP..." @Blue
    $currentIP = (Invoke-WebRequest -Uri "https://api.ipify.org").Content.Trim()
    
    az postgres flexible-server firewall-rule create `
        --resource-group $ResourceGroupName `
        --name $dbServer `
        --rule-name "AllowCurrentIP" `
        --start-ip-address $currentIP `
        --end-ip-address $currentIP `
        --output table

    # Run database migrations
    Write-Host ""
    Write-Host "Running database migrations..." @Blue
    Push-Location "src\PhoneticAnalyzers.Infrastructure"
    
    $connectionString = "Host=$dbServer.postgres.database.azure.com;Database=phonetic_analyzers;Username=pgadmin;Password=$dbPassword;SSL Mode=Require;"
    
    # Install EF tools if not installed
    $efTool = dotnet tool list --global | Select-String "dotnet-ef"
    if (-not $efTool) {
        Write-Host "Installing Entity Framework tools..." @Blue
        dotnet tool install --global dotnet-ef
    }
    
    dotnet ef database update --connection $connectionString
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Database schema updated successfully" @Green
    }
    else {
        Write-Host "❌ Database migration failed" @Red
        Pop-Location
        exit 1
    }
    
    Pop-Location
}

function Test-Deployment {
    Write-Host "🧪 Testing Deployment..." @Yellow
    Write-Host ""

    # Load deployment info
    if (Test-Path "deployment-info-$Environment.json") {
        $deploymentInfo = Get-Content "deployment-info-$Environment.json" | ConvertFrom-Json
        $functionAppIngestion = $deploymentInfo.functionAppIngestion
        $functionAppSearch = $deploymentInfo.functionAppSearch
    }
    else {
        Write-Host "❌ No deployment info found" @Red
        return
    }

    # Test health endpoints
    Write-Host "Testing Ingestion Function health..." @Blue
    try {
        $response = Invoke-WebRequest -Uri "https://$functionAppIngestion.azurewebsites.net/api/health" -TimeoutSec 30
        if ($response.StatusCode -eq 200) {
            Write-Host "✅ Ingestion Function is healthy" @Green
        }
    }
    catch {
        Write-Host "❌ Ingestion Function health check failed: $($_.Exception.Message)" @Red
    }

    Write-Host "Testing Search Function health..." @Blue
    try {
        $response = Invoke-WebRequest -Uri "https://$functionAppSearch.azurewebsites.net/api/health" -TimeoutSec 30
        if ($response.StatusCode -eq 200) {
            Write-Host "✅ Search Function is healthy" @Green
        }
    }
    catch {
        Write-Host "❌ Search Function health check failed: $($_.Exception.Message)" @Red
    }

    Write-Host ""
    Write-Host "🎯 Test your APIs:" @Yellow
    Write-Host "Ingestion: https://$functionAppIngestion.azurewebsites.net/api/ingest" @Cyan
    Write-Host "Search: https://$functionAppSearch.azurewebsites.net/api/search?name=John&maxResults=10" @Cyan
}

function Show-Summary {
    Write-Host ""
    Write-Host "🎉 Deployment Complete!" @Green
    Write-Host "======================" @Green
    Write-Host ""
    
    if (Test-Path "deployment-info-$Environment.json") {
        $deploymentInfo = Get-Content "deployment-info-$Environment.json" | ConvertFrom-Json
        
        Write-Host "📋 Your Azure Resources:" @Yellow
        Write-Host "Resource Group: $($deploymentInfo.resourceGroup)" @Cyan
        Write-Host "PostgreSQL Server: $($deploymentInfo.dbServer).postgres.database.azure.com" @Cyan
        Write-Host "Key Vault: $($deploymentInfo.keyVault)" @Cyan
        Write-Host "Application Insights: $($deploymentInfo.appInsights)" @Cyan
        Write-Host ""
        Write-Host "🌐 Function App URLs:" @Yellow
        Write-Host "Ingestion API: https://$($deploymentInfo.functionAppIngestion).azurewebsites.net" @Cyan
        Write-Host "Search API: https://$($deploymentInfo.functionAppSearch).azurewebsites.net" @Cyan
        Write-Host ""
        Write-Host "🔗 Quick Links:" @Yellow
        Write-Host "Azure Portal: https://portal.azure.com/#@/resource/subscriptions/your-sub/resourceGroups/$($deploymentInfo.resourceGroup)" @Blue
        Write-Host "Function Apps: https://portal.azure.com/#blade/HubsExtension/BrowseResource/resourceType/Microsoft.Web%2Fsites/kind/functionapp" @Blue
        Write-Host ""
    }
    
    Write-Host "💡 Next Steps:" @Yellow
    Write-Host "1. Test your APIs using the URLs above" @Blue
    Write-Host "2. Configure CI/CD pipeline for automatic deployments" @Blue
    Write-Host "3. Set up monitoring alerts and dashboards" @Blue
    Write-Host "4. Review security settings and enable private endpoints" @Blue
    Write-Host ""
    Write-Host "📚 For local development against Azure database:" @Yellow
    Write-Host "   See AZURE_DEPLOYMENT_SETUP.md for configuration steps" @Blue
}

# Main execution
try {
    if (-not (Test-AzureCLI)) {
        exit 1
    }

    Write-Host "🎯 Starting deployment for $Environment environment..." @Yellow
    Write-Host ""

    if (-not $SkipInfrastructure) {
        Deploy-Infrastructure
        Setup-Database
    }
    
    Deploy-Application
    Test-Deployment
    Show-Summary
}
catch {
    Write-Host ""
    Write-Host "❌ Deployment failed: $($_.Exception.Message)" @Red
    Write-Host ""
    Write-Host "💡 Troubleshooting tips:" @Yellow
    Write-Host "1. Check if you're logged into Azure: az account show" @Blue
    Write-Host "2. Verify you have permissions to create resources" @Blue
    Write-Host "3. Check if resource names are unique (try different environment)" @Blue
    Write-Host "4. Review the error message above for specific issues" @Blue
    
    exit 1
}