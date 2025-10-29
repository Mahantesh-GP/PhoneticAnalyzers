#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Quick setup script for PhoneticAnalyzers development environment

.DESCRIPTION
    This script automates the setup of the PhoneticAnalyzers project for development.
    It checks prerequisites, starts services, and verifies the setup.

.PARAMETER SkipPrerequisiteCheck
    Skip checking if prerequisites are installed

.PARAMETER StartServices
    Start all required services (Docker, PostgreSQL, Function Apps)

.PARAMETER RunTests
    Run all tests after setup

.EXAMPLE
    .\setup-dev.ps1 -StartServices -RunTests
#>

param(
    [switch]$SkipPrerequisiteCheck,
    [switch]$StartServices,
    [switch]$RunTests
)

# Colors for output
$Red = @{ ForegroundColor = "Red" }
$Green = @{ ForegroundColor = "Green" }
$Yellow = @{ ForegroundColor = "Yellow" }
$Blue = @{ ForegroundColor = "Blue" }

Write-Host "🚀 PhoneticAnalyzers Development Setup" @Blue
Write-Host "=====================================" @Blue
Write-Host ""

function Test-Command {
    param($Command)
    try {
        Get-Command $Command -ErrorAction Stop | Out-Null
        return $true
    }
    catch {
        return $false
    }
}

function Check-Prerequisites {
    Write-Host "📋 Checking Prerequisites..." @Yellow
    
    $prerequisites = @(
        @{ Name = ".NET 8 SDK"; Command = "dotnet"; Version = "8.0" },
        @{ Name = "Docker"; Command = "docker"; Version = "" },
        @{ Name = "Azure Functions Core Tools"; Command = "func"; Version = "4" },
        @{ Name = "Git"; Command = "git"; Version = "" }
    )
    
    $allGood = $true
    
    foreach ($prereq in $prerequisites) {
        if (Test-Command $prereq.Command) {
            $version = & $prereq.Command --version 2>$null | Select-Object -First 1
            Write-Host "✅ $($prereq.Name): $version" @Green
        }
        else {
            Write-Host "❌ $($prereq.Name): Not found" @Red
            $allGood = $false
        }
    }
    
    if (-not $allGood) {
        Write-Host ""
        Write-Host "❌ Missing prerequisites. Please install them first:" @Red
        Write-Host "   - .NET 8 SDK: https://dotnet.microsoft.com/download/dotnet/8.0" @Yellow
        Write-Host "   - Docker Desktop: https://www.docker.com/products/docker-desktop/" @Yellow
        Write-Host "   - Azure Functions Core Tools: npm install -g azure-functions-core-tools@4" @Yellow
        Write-Host "   - Git: https://git-scm.com/download/win" @Yellow
        exit 1
    }
    
    Write-Host ""
}

function Start-PostgreSQLContainer {
    Write-Host "🐘 Starting PostgreSQL Database..." @Yellow
    
    # Check if container already exists
    $existingContainer = docker ps -a --filter "name=postgres-phonetic-dev" --format "table {{.Names}}\t{{.Status}}" | Select-String "postgres-phonetic-dev"
    
    if ($existingContainer) {
        Write-Host "Container already exists. Checking status..." @Blue
        $isRunning = docker ps --filter "name=postgres-phonetic-dev" --filter "status=running" --format "{{.Names}}"
        
        if ($isRunning) {
            Write-Host "✅ PostgreSQL container is already running" @Green
        }
        else {
            Write-Host "Starting existing container..." @Blue
            docker start postgres-phonetic-dev
            Start-Sleep -Seconds 10
            Write-Host "✅ PostgreSQL container started" @Green
        }
    }
    else {
        Write-Host "Creating new PostgreSQL container..." @Blue
        docker run --name postgres-phonetic-dev `
            -e POSTGRES_PASSWORD=postgres `
            -e POSTGRES_DB=phonetic_analyzers_dev `
            -p 5432:5432 `
            -d postgres:15
        
        Write-Host "Waiting for PostgreSQL to be ready..." @Blue
        Start-Sleep -Seconds 30
        Write-Host "✅ PostgreSQL container created and started" @Green
    }
    Write-Host ""
}

function Restore-Packages {
    Write-Host "📦 Restoring NuGet packages..." @Yellow
    dotnet restore
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Packages restored successfully" @Green
    }
    else {
        Write-Host "❌ Failed to restore packages" @Red
        exit 1
    }
    Write-Host ""
}

function Build-Solution {
    Write-Host "🔨 Building solution..." @Yellow
    dotnet build
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Solution built successfully" @Green
    }
    else {
        Write-Host "❌ Build failed" @Red
        exit 1
    }
    Write-Host ""
}

function Setup-Database {
    Write-Host "🗄️ Setting up database..." @Yellow
    
    Push-Location "src\PhoneticAnalyzers.Infrastructure"
    
    # Install EF tools if not installed
    $efTool = dotnet tool list --global | Select-String "dotnet-ef"
    if (-not $efTool) {
        Write-Host "Installing Entity Framework tools..." @Blue
        dotnet tool install --global dotnet-ef
    }
    
    # Check if migrations exist
    $migrationsExist = Test-Path "Migrations"
    
    if (-not $migrationsExist) {
        Write-Host "Creating initial migration..." @Blue
        dotnet ef migrations add InitialCreate
    }
    
    Write-Host "Updating database..." @Blue
    dotnet ef database update
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Database setup completed" @Green
    }
    else {
        Write-Host "❌ Database setup failed" @Red
        Pop-Location
        exit 1
    }
    
    Pop-Location
    Write-Host ""
}

function Test-DatabaseConnection {
    Write-Host "🔌 Testing database connection..." @Yellow
    
    # Test with docker exec
    $testResult = docker exec postgres-phonetic-dev psql -U postgres -d phonetic_analyzers_dev -c "SELECT 1;" 2>$null
    
    if ($testResult) {
        Write-Host "✅ Database connection successful" @Green
    }
    else {
        Write-Host "❌ Database connection failed" @Red
        Write-Host "   Try: docker logs postgres-phonetic-dev" @Yellow
    }
    Write-Host ""
}

function Start-FunctionApps {
    Write-Host "⚡ Starting Function Apps..." @Yellow
    Write-Host ""
    Write-Host "Starting Ingestion Function App..." @Blue
    Write-Host "Navigate to: src\PhoneticAnalyzers.Functions.Ingestion" @Yellow
    Write-Host "Run: func start" @Yellow
    Write-Host ""
    
    if (Test-Path "src\PhoneticAnalyzers.Functions.Search") {
        Write-Host "Starting Search Function App..." @Blue
        Write-Host "Navigate to: src\PhoneticAnalyzers.Functions.Search" @Yellow
        Write-Host "Run: func start --port 7072" @Yellow
        Write-Host ""
    }
    
    Write-Host "💡 Open separate PowerShell terminals for each function app" @Blue
    Write-Host ""
}

function Run-Tests {
    Write-Host "🧪 Running Tests..." @Yellow
    
    if (Test-Path "tests\PhoneticAnalyzers.UnitTests") {
        Write-Host "Running unit tests..." @Blue
        dotnet test tests\PhoneticAnalyzers.UnitTests\
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Unit tests passed" @Green
        }
        else {
            Write-Host "❌ Unit tests failed" @Red
        }
    }
    
    if (Test-Path "tests\PhoneticAnalyzers.IntegrationTests") {
        Write-Host "Running integration tests..." @Blue
        dotnet test tests\PhoneticAnalyzers.IntegrationTests\
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Integration tests passed" @Green
        }
        else {
            Write-Host "❌ Integration tests failed" @Red
        }
    }
    Write-Host ""
}

function Show-NextSteps {
    Write-Host "🎉 Setup Complete!" @Green
    Write-Host "================" @Green
    Write-Host ""
    Write-Host "Next Steps:" @Blue
    Write-Host "1. Start Function Apps in separate terminals:" @Yellow
    Write-Host "   Terminal 1: cd src\PhoneticAnalyzers.Functions.Ingestion && func start" @Blue
    if (Test-Path "src\PhoneticAnalyzers.Functions.Search") {
        Write-Host "   Terminal 2: cd src\PhoneticAnalyzers.Functions.Search && func start --port 7072" @Blue
    }
    Write-Host ""
    Write-Host "2. Test the APIs:" @Yellow
    Write-Host "   Health: curl http://localhost:7071/api/health" @Blue
    Write-Host "   Ingest: See DEVELOPMENT_SETUP.md for examples" @Blue
    Write-Host ""
    Write-Host "3. Open in your IDE:" @Yellow
    Write-Host "   code . # VS Code" @Blue
    Write-Host "   # or open PhoneticAnalyzers.sln in Visual Studio" @Blue
    Write-Host ""
    Write-Host "📚 See DEVELOPMENT_SETUP.md for detailed information" @Green
}

# Main execution
try {
    if (-not $SkipPrerequisiteCheck) {
        Check-Prerequisites
    }
    
    Restore-Packages
    Build-Solution
    
    if ($StartServices) {
        Start-PostgreSQLContainer
        Setup-Database
        Test-DatabaseConnection
    }
    
    if ($RunTests) {
        Run-Tests
    }
    
    if ($StartServices) {
        Start-FunctionApps
    }
    
    Show-NextSteps
}
catch {
    Write-Host ""
    Write-Host "❌ Setup failed: $($_.Exception.Message)" @Red
    Write-Host ""
    Write-Host "💡 Try running with individual steps:" @Yellow
    Write-Host "   .\setup-dev.ps1 -SkipPrerequisiteCheck" @Blue
    Write-Host "   .\setup-dev.ps1 -StartServices" @Blue
    Write-Host "   .\setup-dev.ps1 -RunTests" @Blue
    exit 1
}