#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Simplified Azure deployment for development (No VNet required)

.DESCRIPTION
    This script creates a development environment without VNet complexity.
    Perfect for getting started quickly with basic security via IP firewall.

.PARAMETER Environment
    The environment to deploy to (dev, prod)

.PARAMETER Location
    Azure region for deployment (default: East US 2)

.PARAMETER EnableVNet
    Enable VNet and private endpoints (recommended for production)

.EXAMPLE
    .\deploy-dev-simple.ps1 -Environment dev
    
.EXAMPLE
    .\deploy-dev-simple.ps1 -Environment prod -EnableVNet
#>

param(
    [Parameter(Mandatory = $true)]
    [ValidateSet("dev", "prod")]
    [string]$Environment,
    
    [string]$Location = "East US 2",
    
    [switch]$EnableVNet
)

# Colors for output
$Red = @{ ForegroundColor = "Red" }
$Green = @{ ForegroundColor = "Green" }
$Yellow = @{ ForegroundColor = "Yellow" }
$Blue = @{ ForegroundColor = "Blue" }
$Cyan = @{ ForegroundColor = "Cyan" }

Write-Host "🚀 PhoneticAnalyzers Simple Azure Deployment" @Blue
Write-Host "=============================================" @Blue
Write-Host "Environment: $Environment" @Cyan
Write-Host "Location: $Location" @Cyan
Write-Host "VNet Enabled: $EnableVNet" @Cyan
Write-Host ""

if ($Environment -eq "dev" -and -not $EnableVNet) {
    Write-Host "📋 Development Setup (Simplified):" @Yellow
    Write-Host "  ✅ PostgreSQL with IP firewall (no VNet)" @Green
    Write-Host "  ✅ Function Apps with public endpoints" @Green
    Write-Host "  ✅ Basic security suitable for development" @Green
    Write-Host "  ✅ Cost optimized (~$20-40/month)" @Green
    Write-Host ""
} elseif ($Environment -eq "prod" -or $EnableVNet) {
    Write-Host "🔒 Production Setup (Enhanced Security):" @Yellow
    Write-Host "  ✅ PostgreSQL with private endpoints" @Green
    Write-Host "  ✅ Function Apps in VNet" @Green
    Write-Host "  ✅ Enterprise-grade security" @Green
    Write-Host "  ⚠️  Higher cost (~$100-200/month)" @Yellow
    Write-Host ""
}

# Generate unique names
$timestamp = Get-Date -Format "yyyyMMdd"
$random = Get-Random -Minimum 1000 -Maximum 9999

$resourceGroupName = "rg-phoneticanalyzers-$Environment-$timestamp"
$dbServerName = "psql-phoneticanalyzers-$Environment-$random"
$functionAppIngestion = "func-phoneticanalyzers-ing-$Environment-$random"
$functionAppSearch = "func-phoneticanalyzers-src-$Environment-$random"
$storageAccountName = "stphoneticanalyzers$Environment$random"
$appInsightsName = "ai-phoneticanalyzers-$Environment-$random"

# Database configuration
$dbConfig = @{
    dev = @{
        sku = "Standard_B1ms"
        tier = "Burstable"
        storage = 32
        backup_retention = 7
    }
    prod = @{
        sku = "Standard_D2s_v3"
        tier = "GeneralPurpose"
        storage = 128
        backup_retention = 30
    }
}

function Test-Prerequisites {
    Write-Host "🔍 Checking Prerequisites..." @Yellow
    
    # Check Azure CLI
    try {
        $account = az account show --output json 2>$null | ConvertFrom-Json
        if ($account) {
            Write-Host "✅ Azure CLI: Logged in as $($account.user.name)" @Green
        }
        else {
            Write-Host "❌ Azure CLI: Not logged in" @Red
            Write-Host "Please run: az login" @Yellow
            return $false
        }
    }
    catch {
        Write-Host "❌ Azure CLI: Not installed" @Red
        Write-Host "Please install: winget install Microsoft.AzureCLI" @Yellow
        return $false
    }

    # Check .NET
    try {
        $dotnetVersion = dotnet --version 2>$null
        if ($dotnetVersion -and $dotnetVersion.StartsWith("8")) {
            Write-Host "✅ .NET 8 SDK: $dotnetVersion" @Green
        }
        else {
            Write-Host "❌ .NET 8 SDK: Not found" @Red
            Write-Host "Please install: winget install Microsoft.DotNet.SDK.8" @Yellow
            return $false
        }
    }
    catch {
        Write-Host "❌ .NET 8 SDK: Not installed" @Red
        return $false
    }

    # Check Function Tools
    try {
        $funcVersion = func --version 2>$null
        if ($funcVersion -and $funcVersion.StartsWith("4")) {
            Write-Host "✅ Azure Functions Core Tools: $funcVersion" @Green
        }
        else {
            Write-Host "⚠️  Azure Functions Core Tools: Version 4 recommended" @Yellow
        }
    }
    catch {
        Write-Host "⚠️  Azure Functions Core Tools: Not found (optional for deployment)" @Yellow
    }

    Write-Host ""
    return $true
}

function New-AzureInfrastructure {
    Write-Host "🏗️ Creating Azure Infrastructure..." @Yellow
    Write-Host ""

    # Create Resource Group
    Write-Host "Creating resource group: $resourceGroupName" @Blue
    az group create --name $resourceGroupName --location $Location --output table
    
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to create resource group"
    }

    # Get database password
    Write-Host ""
    $dbPassword = Read-Host "Enter PostgreSQL admin password (min 8 characters)" -AsSecureString
    $dbPasswordPlain = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($dbPassword))
    
    # Validate password
    if ($dbPasswordPlain.Length -lt 8) {
        throw "Password must be at least 8 characters long"
    }

    # Create PostgreSQL Flexible Server
    Write-Host ""
    Write-Host "Creating PostgreSQL server: $dbServerName" @Blue
    
    if ($EnableVNet -or $Environment -eq "prod") {
        Write-Host "  Setting up with VNet and private endpoints..." @Cyan
        # Create VNet first
        New-VirtualNetwork
        # Create PostgreSQL with private access
        New-PostgreSQLWithVNet -Password $dbPasswordPlain
    }
    else {
        Write-Host "  Setting up with IP firewall (development mode)..." @Cyan
        # Create PostgreSQL with public access but IP restrictions
        New-PostgreSQLSimple -Password $dbPasswordPlain
    }

    # Create Storage Account
    Write-Host ""
    Write-Host "Creating storage account: $storageAccountName" @Blue
    az storage account create `
        --name $storageAccountName `
        --resource-group $resourceGroupName `
        --location $Location `
        --sku "Standard_LRS" `
        --output table

    # Create Application Insights
    Write-Host ""
    Write-Host "Creating Application Insights: $appInsightsName" @Blue
    az monitor app-insights component create `
        --app $appInsightsName `
        --location $Location `
        --resource-group $resourceGroupName `
        --output table

    # Create Function Apps
    Write-Host ""
    Write-Host "Creating Function Apps..." @Blue
    New-FunctionApps -DatabasePassword $dbPasswordPlain

    Write-Host ""
    Write-Host "✅ Infrastructure created successfully!" @Green
    
    # Save deployment info
    $deploymentInfo = @{
        resourceGroup = $resourceGroupName
        dbServer = $dbServerName
        dbPassword = $dbPasswordPlain
        functionAppIngestion = $functionAppIngestion
        functionAppSearch = $functionAppSearch
        appInsights = $appInsightsName
        vnetEnabled = $EnableVNet -or ($Environment -eq "prod")
        environment = $Environment
        location = $Location
    }
    
    $deploymentInfo | ConvertTo-Json | Out-File "deployment-info-$Environment.json"
    Write-Host "💾 Deployment info saved to: deployment-info-$Environment.json" @Blue
}

function New-PostgreSQLSimple {
    param([string]$Password)
    
    az postgres flexible-server create `
        --resource-group $resourceGroupName `
        --name $dbServerName `
        --location $Location `
        --admin-user "pgadmin" `
        --admin-password $Password `
        --sku-name $dbConfig[$Environment].sku `
        --tier $dbConfig[$Environment].tier `
        --storage-size $dbConfig[$Environment].storage `
        --backup-retention $dbConfig[$Environment].backup_retention `
        --version "15" `
        --public-access "0.0.0.0" `
        --output table

    if ($LASTEXITCODE -ne 0) {
        throw "Failed to create PostgreSQL server"
    }

    # Create database
    Write-Host "Creating database: phonetic_analyzers" @Blue
    az postgres flexible-server db create `
        --resource-group $resourceGroupName `
        --server-name $dbServerName `
        --database-name "phonetic_analyzers" `
        --output table

    # Add current IP to firewall
    Write-Host "Adding your IP to firewall..." @Blue
    $currentIP = (Invoke-WebRequest -Uri "https://api.ipify.org" -UseBasicParsing).Content.Trim()
    
    az postgres flexible-server firewall-rule create `
        --resource-group $resourceGroupName `
        --name $dbServerName `
        --rule-name "AllowCurrentIP" `
        --start-ip-address $currentIP `
        --end-ip-address $currentIP `
        --output table

    Write-Host "📋 Your IP ($currentIP) has been added to the firewall" @Cyan
    Write-Host "💡 To add more IPs later, use the Azure portal or run:" @Yellow
    Write-Host "   az postgres flexible-server firewall-rule create --resource-group $resourceGroupName --name $dbServerName --rule-name 'NewIP' --start-ip-address X.X.X.X --end-ip-address X.X.X.X" @Blue
}

function New-VirtualNetwork {
    Write-Host "Creating Virtual Network..." @Blue
    
    # Create VNet
    az network vnet create `
        --resource-group $resourceGroupName `
        --name "vnet-phoneticanalyzers-$Environment" `
        --address-prefix "10.0.0.0/16" `
        --subnet-name "subnet-functions" `
        --subnet-prefix "10.0.1.0/24" `
        --output table

    # Create subnet for database
    az network vnet subnet create `
        --resource-group $resourceGroupName `
        --vnet-name "vnet-phoneticanalyzers-$Environment" `
        --name "subnet-database" `
        --address-prefix "10.0.2.0/24" `
        --delegations "Microsoft.DBforPostgreSQL/flexibleServers" `
        --output table
}

function New-PostgreSQLWithVNet {
    param([string]$Password)
    
    Write-Host "Creating PostgreSQL with VNet integration..." @Blue
    
    az postgres flexible-server create `
        --resource-group $resourceGroupName `
        --name $dbServerName `
        --location $Location `
        --admin-user "pgadmin" `
        --admin-password $Password `
        --sku-name $dbConfig[$Environment].sku `
        --tier $dbConfig[$Environment].tier `
        --storage-size $dbConfig[$Environment].storage `
        --backup-retention $dbConfig[$Environment].backup_retention `
        --version "15" `
        --vnet "vnet-phoneticanalyzers-$Environment" `
        --subnet "subnet-database" `
        --private-dns-zone "phoneticanalyzers$Environment.private.postgres.database.azure.com" `
        --output table

    if ($LASTEXITCODE -ne 0) {
        throw "Failed to create PostgreSQL server with VNet"
    }

    # Create database
    Write-Host "Creating database: phonetic_analyzers" @Blue
    az postgres flexible-server db create `
        --resource-group $resourceGroupName `
        --server-name $dbServerName `
        --database-name "phonetic_analyzers" `
        --output table
}

function New-FunctionApps {
    param([string]$DatabasePassword)
    
    # Get connection strings
    if ($EnableVNet -or $Environment -eq "prod") {
        $dbConnectionString = "Host=$dbServerName.private.postgres.database.azure.com;Database=phonetic_analyzers;Username=pgadmin;Password=$DatabasePassword;SSL Mode=Require;"
    }
    else {
        $dbConnectionString = "Host=$dbServerName.postgres.database.azure.com;Database=phonetic_analyzers;Username=pgadmin;Password=$DatabasePassword;SSL Mode=Require;"
    }
    
    $aiConnectionString = az monitor app-insights component show `
        --app $appInsightsName `
        --resource-group $resourceGroupName `
        --query "connectionString" -o tsv

    # Create Ingestion Function App
    Write-Host "Creating Ingestion Function App..." @Blue
    az functionapp create `
        --resource-group $resourceGroupName `
        --name $functionAppIngestion `
        --storage-account $storageAccountName `
        --functions-version 4 `
        --runtime "dotnet-isolated" `
        --runtime-version "8.0" `
        --consumption-plan-location $Location `
        --output table

    # Create Search Function App
    Write-Host "Creating Search Function App..." @Blue
    az functionapp create `
        --resource-group $resourceGroupName `
        --name $functionAppSearch `
        --storage-account $storageAccountName `
        --functions-version 4 `
        --runtime "dotnet-isolated" `
        --runtime-version "8.0" `
        --consumption-plan-location $Location `
        --output table

    # Configure VNet integration if enabled
    if ($EnableVNet -or $Environment -eq "prod") {
        Write-Host "Configuring VNet integration..." @Blue
        
        az functionapp vnet-integration add `
            --resource-group $resourceGroupName `
            --name $functionAppIngestion `
            --vnet "vnet-phoneticanalyzers-$Environment" `
            --subnet "subnet-functions" `
            --output table

        az functionapp vnet-integration add `
            --resource-group $resourceGroupName `
            --name $functionAppSearch `
            --vnet "vnet-phoneticanalyzers-$Environment" `
            --subnet "subnet-functions" `
            --output table
    }

    # Configure app settings
    Write-Host "Configuring application settings..." @Blue
    
    az functionapp config appsettings set `
        --resource-group $resourceGroupName `
        --name $functionAppIngestion `
        --settings `
            "ConnectionStrings__DefaultConnection=$dbConnectionString" `
            "APPLICATIONINSIGHTS_CONNECTION_STRING=$aiConnectionString" `
            "ASPNETCORE_ENVIRONMENT=$Environment" `
        --output table

    az functionapp config appsettings set `
        --resource-group $resourceGroupName `
        --name $functionAppSearch `
        --settings `
            "ConnectionStrings__DefaultConnection=$dbConnectionString" `
            "APPLICATIONINSIGHTS_CONNECTION_STRING=$aiConnectionString" `
            "ASPNETCORE_ENVIRONMENT=$Environment" `
        --output table

    # Enable managed identity
    Write-Host "Enabling managed identities..." @Blue
    az functionapp identity assign --resource-group $resourceGroupName --name $functionAppIngestion --output table
    az functionapp identity assign --resource-group $resourceGroupName --name $functionAppSearch --output table
}

function Install-DatabaseSchema {
    Write-Host "🗄️ Setting up Database Schema..." @Yellow
    Write-Host ""

    # Load deployment info
    if (-not (Test-Path "deployment-info-$Environment.json")) {
        Write-Host "❌ Deployment info not found. Deploy infrastructure first." @Red
        return $false
    }

    $deploymentInfo = Get-Content "deployment-info-$Environment.json" | ConvertFrom-Json
    
    # Build connection string
    if ($deploymentInfo.vnetEnabled) {
        $connectionString = "Host=$($deploymentInfo.dbServer).private.postgres.database.azure.com;Database=phonetic_analyzers;Username=pgadmin;Password=$($deploymentInfo.dbPassword);SSL Mode=Require;"
    }
    else {
        $connectionString = "Host=$($deploymentInfo.dbServer).postgres.database.azure.com;Database=phonetic_analyzers;Username=pgadmin;Password=$($deploymentInfo.dbPassword);SSL Mode=Require;"
    }

    # Install EF tools if needed
    $efTool = dotnet tool list --global | Select-String "dotnet-ef"
    if (-not $efTool) {
        Write-Host "Installing Entity Framework tools..." @Blue
        dotnet tool install --global dotnet-ef
    }

    # Run migrations
    Write-Host "Running database migrations..." @Blue
    Push-Location "src\PhoneticAnalyzers.Infrastructure"
    
    try {
        dotnet ef database update --connection $connectionString
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Database schema updated successfully" @Green
        }
        else {
            Write-Host "❌ Database migration failed" @Red
            return $false
        }
    }
    finally {
        Pop-Location
    }
    
    return $true
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
        Write-Host "PostgreSQL Server: $($deploymentInfo.dbServer)" @Cyan
        Write-Host "Environment: $($deploymentInfo.environment)" @Cyan
        Write-Host "VNet Enabled: $($deploymentInfo.vnetEnabled)" @Cyan
        Write-Host ""
        
        Write-Host "🌐 Function App URLs:" @Yellow
        Write-Host "Ingestion API: https://$($deploymentInfo.functionAppIngestion).azurewebsites.net" @Cyan
        Write-Host "Search API: https://$($deploymentInfo.functionAppSearch).azurewebsites.net" @Cyan
        Write-Host ""
        
        if (-not $deploymentInfo.vnetEnabled) {
            Write-Host "🔒 Security Configuration (Development):" @Yellow
            Write-Host "✅ PostgreSQL accessible via IP firewall" @Green
            Write-Host "✅ Function Apps have public endpoints" @Green
            Write-Host "✅ SSL/TLS encryption for all connections" @Green
            Write-Host "⚠️  For production, consider enabling VNet" @Yellow
        }
        else {
            Write-Host "🔒 Security Configuration (Production):" @Yellow
            Write-Host "✅ PostgreSQL in private subnet" @Green
            Write-Host "✅ Function Apps with VNet integration" @Green
            Write-Host "✅ No direct internet access to database" @Green
            Write-Host "✅ Enterprise-grade security" @Green
        }
        
        Write-Host ""
        Write-Host "💰 Estimated Monthly Cost:" @Yellow
        if ($Environment -eq "dev" -and -not $deploymentInfo.vnetEnabled) {
            Write-Host "📊 Development (Simple): ~$20-40/month" @Green
        }
        elseif ($Environment -eq "dev" -and $deploymentInfo.vnetEnabled) {
            Write-Host "📊 Development (VNet): ~$60-80/month" @Yellow
        }
        else {
            Write-Host "📊 Production: ~$100-200/month" @Yellow
        }
        
        Write-Host ""
        Write-Host "💡 Next Steps:" @Yellow
        Write-Host "1. Update local.settings.json files (see LOCAL_DEVELOPMENT_AZURE.md)" @Blue
        Write-Host "2. Test locally: cd src\PhoneticAnalyzers.Functions.Ingestion && func start" @Blue
        Write-Host "3. Deploy code: func azure functionapp publish $($deploymentInfo.functionAppIngestion)" @Blue
        Write-Host "4. Monitor: https://portal.azure.com/#@/resource/subscriptions/.../resourceGroups/$($deploymentInfo.resourceGroup)" @Blue
    }
}

# Main execution
try {
    if (-not (Test-Prerequisites)) {
        exit 1
    }

    Write-Host "🎯 Starting $Environment deployment..." @Yellow
    if ($Environment -eq "dev" -and -not $EnableVNet) {
        Write-Host "💡 Using simplified setup (no VNet) for faster development" @Blue
    }
    Write-Host ""

    New-AzureInfrastructure
    
    if (Install-DatabaseSchema) {
        Show-Summary
        
        Write-Host ""
        Write-Host "🚀 Ready for development!" @Green
        Write-Host "See LOCAL_DEVELOPMENT_AZURE.md for local setup instructions" @Blue
    }
    else {
        Write-Host "⚠️  Infrastructure created but database setup failed" @Yellow
        Write-Host "You can retry database setup later with:" @Blue
        Write-Host "cd src\PhoneticAnalyzers.Infrastructure" @Cyan
        Write-Host "dotnet ef database update --connection 'YOUR_CONNECTION_STRING'" @Cyan
    }
}
catch {
    Write-Host ""
    Write-Host "❌ Deployment failed: $($_.Exception.Message)" @Red
    Write-Host ""
    Write-Host "🧹 Clean up partial deployment:" @Yellow
    Write-Host "az group delete --name $resourceGroupName --yes --no-wait" @Blue
    
    exit 1
}