#!/usr/bin/env pwsh
# Test script for PhoneticAnalyzers API endpoints

Write-Host "🚀 Testing PhoneticAnalyzers API Endpoints" -ForegroundColor Green
Write-Host "Make sure the function app is running on http://localhost:7071" -ForegroundColor Yellow
Write-Host ""

$baseUrl = "http://localhost:7071/api"

# Test 1: Health Check
Write-Host "1️⃣ Testing Health Check..." -ForegroundColor Cyan
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/health" -Method Get
    Write-Host "✅ Health Check: $($response.status)" -ForegroundColor Green
    Write-Host "   Version: $($response.version)" -ForegroundColor Gray
} catch {
    Write-Host "❌ Health Check Failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "   Make sure the function app is running with 'func start'" -ForegroundColor Yellow
    exit 1
}

Write-Host ""

# Test 2: Ingest Person
Write-Host "2️⃣ Testing Person Ingestion..." -ForegroundColor Cyan
$personData = @{
    externalId = "test-001"
    fullName = "John Smith"
    expandNicknames = $true
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "$baseUrl/ingest" -Method Post -Body $personData -ContentType "application/json"
    Write-Host "✅ Person Ingested: ID $($response.personId)" -ForegroundColor Green
    Write-Host "   Was Created: $($response.wasCreated)" -ForegroundColor Gray
    Write-Host "   Primary Code: $($response.phoneticCodes.primary)" -ForegroundColor Gray
} catch {
    Write-Host "❌ Person Ingestion Failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""

# Test 3: Search Persons
Write-Host "3️⃣ Testing Person Search..." -ForegroundColor Cyan
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/search?name=Jon%20Smyth&maxResults=5" -Method Get
    Write-Host "✅ Search Results: $($response.totalResults) matches" -ForegroundColor Green
    Write-Host "   Query: $($response.query)" -ForegroundColor Gray
    Write-Host "   Execution Time: $($response.executionTime) ms" -ForegroundColor Gray
    
    if ($response.results.Count -gt 0) {
        Write-Host "   First Result: $($response.results[0].fullName) (Score: $($response.results[0].similarityScore))" -ForegroundColor Gray
    }
} catch {
    Write-Host "❌ Person Search Failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""

# Test 4: Batch Ingestion
Write-Host "4️⃣ Testing Batch Ingestion..." -ForegroundColor Cyan
$batchData = @{
    persons = @(
        @{ externalId = "batch-001"; fullName = "Jane Doe"; expandNicknames = $true },
        @{ externalId = "batch-002"; fullName = "Bob Johnson"; expandNicknames = $true },
        @{ externalId = "batch-003"; fullName = "Alice Williams"; expandNicknames = $true }
    )
} | ConvertTo-Json -Depth 3

try {
    $response = Invoke-RestMethod -Uri "$baseUrl/ingest/batch" -Method Post -Body $batchData -ContentType "application/json"
    Write-Host "✅ Batch Processed: $($response.successful) successful, $($response.failed) failed" -ForegroundColor Green
    Write-Host "   Total Processed: $($response.totalProcessed)" -ForegroundColor Gray
} catch {
    Write-Host "❌ Batch Ingestion Failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""

# Final search test to show all data
Write-Host "5️⃣ Final Search Test (all names)..." -ForegroundColor Cyan
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/search?name=John&maxResults=10" -Method Get
    Write-Host "✅ Total Records Found: $($response.totalResults)" -ForegroundColor Green
    
    foreach ($result in $response.results) {
        Write-Host "   • $($result.fullName) (ID: $($result.externalId))" -ForegroundColor Gray
    }
} catch {
    Write-Host "❌ Final Search Failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "🎉 API Testing Complete!" -ForegroundColor Green
Write-Host "📖 To understand the code, explore:" -ForegroundColor Yellow
Write-Host "   • src/PhoneticAnalyzers.Functions.Ingestion/PhoneticAnalyzersFunctions.cs" -ForegroundColor Gray
Write-Host "   • src/PhoneticAnalyzers.Application/Commands/" -ForegroundColor Gray
Write-Host "   • src/PhoneticAnalyzers.Application/Queries/" -ForegroundColor Gray