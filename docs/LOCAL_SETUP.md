# Local Development Setup (Detailed Guide)

**💡 This is the detailed guide for Path B from START_HERE.md**

## 🎯 **For Personal/Home Development (Docker Allowed)**

This guide shows you how to set up PhoneticAnalyzers using local PostgreSQL with Docker.

## 📋 **Prerequisites**

### **Required Software**
1. **.NET 8 SDK**: `winget install Microsoft.DotNet.SDK.8`
2. **Docker Desktop**: `winget install Docker.DockerDesktop`
3. **Git**: `winget install Git.Git`
4. **Azure Functions Core Tools**: `npm install -g azure-functions-core-tools@4`

### **Optional Tools**
- **VS Code**: `winget install Microsoft.VisualStudioCode`
- **Visual Studio 2022**: `winget install Microsoft.VisualStudio.2022.Community`
- **pgAdmin**: `winget install PostgreSQL.pgAdmin` (database management)

## 🚀 **Step-by-Step Setup**

### **Step 1: Start PostgreSQL Database**
```powershell
# Pull and start PostgreSQL container
docker run --name postgres-phonetic-dev `
  -e POSTGRES_PASSWORD=postgres `
  -e POSTGRES_DB=phonetic_analyzers_dev `
  -p 5432:5432 `
  -d postgres:15

# Wait for container to start
Start-Sleep -Seconds 30

# Verify it's running
docker ps
```

### **Step 2: Build Solution**
```powershell
# Navigate to project root
cd C:\YourPath\PhoneticAnalyzers

# Restore packages and build
dotnet restore
dotnet build
```

### **Step 3: Setup Database Schema**
```powershell
# Install EF Core tools if not already installed
dotnet tool install --global dotnet-ef

# Navigate to Infrastructure project
cd src\PhoneticAnalyzers.Infrastructure

# Create and apply initial migration
dotnet ef migrations add InitialCreate
dotnet ef database update

# Return to root
cd ..\..
```

### **Step 4: Configure Function Apps**

The local settings should already be configured for local PostgreSQL:

**`src/PhoneticAnalyzers.Functions.Ingestion/local.settings.json`**:
```json
{
  "IsEncrypted": false,
  "Values": {
    "AzureWebJobsStorage": "UseDevelopmentStorage=true",
    "FUNCTIONS_WORKER_RUNTIME": "dotnet-isolated",
    "FUNCTIONS_EXTENSION_VERSION": "~4",
    "ConnectionStrings__DefaultConnection": "Host=localhost;Database=phonetic_analyzers_dev;Username=postgres;Password=postgres",
    "APPLICATIONINSIGHTS_CONNECTION_STRING": "",
    "ASPNETCORE_ENVIRONMENT": "Development"
  }
}
```

### **Step 5: Start Function Apps**
```powershell
# Terminal 1 - Ingestion Function
cd src\PhoneticAnalyzers.Functions.Ingestion
func start

# Terminal 2 - Search Function
cd src\PhoneticAnalyzers.Functions.Search
func start --port 7072
```

### **Step 6: Test Everything**
```powershell
# Terminal 3 - Testing
# Test health endpoint
curl http://localhost:7071/api/health

# Test person ingestion
$body = @{
    externalId = "local-user-001"
    fullName = "John Smith"
    expandNicknames = $true
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:7071/api/ingest" `
    -Method POST `
    -ContentType "application/json" `
    -Body $body

# Test search
curl "http://localhost:7072/api/search?name=Jon%20Smyth&maxResults=10"
```

## 🛠️ **Development Tools Setup**

### **Visual Studio Code**
```powershell
# Install recommended extensions
code --install-extension ms-dotnettools.csharp
code --install-extension ms-azuretools.vscode-azurefunctions
code --install-extension ms-vscode.powershell

# Open project
code .
```

**Recommended VS Code settings** (`.vscode/settings.json`):
```json
{
    "dotnet.defaultSolution": "PhoneticAnalyzers.sln",
    "files.exclude": {
        "**/bin": true,
        "**/obj": true
    },
    "azureFunctions.projectLanguage": "C#",
    "azureFunctions.projectRuntime": "~4",
    "azureFunctions.deploySubpath": "."
}
```

### **Visual Studio 2022**
1. Open `PhoneticAnalyzers.sln`
2. Set startup projects:
   - Right-click Solution → Properties
   - Multiple startup projects
   - Set both Function projects to "Start"
3. Press F5 to debug

## 🗄️ **Database Management**

### **Using pgAdmin (GUI)**
```powershell
# Install pgAdmin
winget install PostgreSQL.pgAdmin

# Connect to database:
# Host: localhost
# Port: 5432
# Database: phonetic_analyzers_dev
# Username: postgres
# Password: postgres
```

### **Using Command Line**
```powershell
# Connect to PostgreSQL
docker exec -it postgres-phonetic-dev psql -U postgres -d phonetic_analyzers_dev

# Common commands:
\l                          # List databases
\dt                         # List tables
\d person                   # Describe person table
SELECT * FROM person;       # Query data
\q                          # Exit
```

### **Database Operations**
```powershell
# Add new migration (after making entity changes)
cd src\PhoneticAnalyzers.Infrastructure
dotnet ef migrations add YourMigrationName
dotnet ef database update

# Reset database (if needed)
dotnet ef database drop --force
dotnet ef database update
```

## 🔧 **Daily Development Workflow**

### **Starting Development**
```powershell
# 1. Start Docker Desktop (if not already running)

# 2. Start PostgreSQL container (if stopped)
docker start postgres-phonetic-dev

# 3. Start function apps (2 terminals)
# Terminal 1:
cd src\PhoneticAnalyzers.Functions.Ingestion
func start

# Terminal 2:
cd src\PhoneticAnalyzers.Functions.Search
func start --port 7072

# 4. Open your IDE
code .  # or open .sln file
```

### **Making Code Changes**
1. Edit code in your IDE
2. Function apps auto-reload on save
3. Test changes immediately
4. Database changes require migrations (see above)

### **Ending Development Session**
```powershell
# 1. Stop function apps (Ctrl+C in terminals)

# 2. Optionally stop PostgreSQL container
docker stop postgres-phonetic-dev

# 3. PostgreSQL data persists between stops/starts
```

## 🧪 **Running Tests**

### **Unit Tests**
```powershell
# Run all unit tests
dotnet test tests/PhoneticAnalyzers.UnitTests/

# Run with coverage
dotnet test tests/PhoneticAnalyzers.UnitTests/ --collect:"XPlat Code Coverage"
```

### **Integration Tests**
```powershell
# Ensure PostgreSQL is running
docker ps | findstr postgres

# Run integration tests
dotnet test tests/PhoneticAnalyzers.IntegrationTests/

# Tests will use test database (configured in test settings)
```

### **Load Testing**
```powershell
# Install NBomber for load testing (optional)
dotnet add package NBomber

# Create simple load test
$body = '{"externalId":"load-test-{0}","fullName":"John Smith {0}","expandNicknames":true}'

# Use your preferred load testing tool
```

## 🆘 **Troubleshooting**

### **Docker Issues**
```powershell
# Check Docker status
docker --version
docker ps

# PostgreSQL container not starting
docker logs postgres-phonetic-dev

# Remove and recreate container
docker rm -f postgres-phonetic-dev
docker run --name postgres-phonetic-dev `
  -e POSTGRES_PASSWORD=postgres `
  -e POSTGRES_DB=phonetic_analyzers_dev `
  -p 5432:5432 `
  -d postgres:15
```

### **Database Connection Issues**
```powershell
# Test connection directly
docker exec -it postgres-phonetic-dev psql -U postgres -d phonetic_analyzers_dev

# Check if database exists
docker exec -it postgres-phonetic-dev psql -U postgres -c "\l"

# Recreate database
docker exec -it postgres-phonetic-dev psql -U postgres -c "DROP DATABASE IF EXISTS phonetic_analyzers_dev;"
docker exec -it postgres-phonetic-dev psql -U postgres -c "CREATE DATABASE phonetic_analyzers_dev;"
```

### **Port Conflicts**
```powershell
# Check what's using port 5432
netstat -ano | findstr :5432

# Kill process if needed
taskkill /PID <PID> /F

# Or use different port for PostgreSQL
docker run --name postgres-phonetic-dev `
  -e POSTGRES_PASSWORD=postgres `
  -e POSTGRES_DB=phonetic_analyzers_dev `
  -p 5433:5432 `
  -d postgres:15

# Update connection string to use port 5433
```

### **Function App Issues**
```powershell
# Check .NET version
dotnet --version

# Verbose function startup
func start --verbose

# Clean and rebuild
dotnet clean
dotnet restore
dotnet build
```

## 📊 **Performance Optimization**

### **PostgreSQL Tuning**
```sql
-- Connect to database and run these optimizations
docker exec -it postgres-phonetic-dev psql -U postgres -d phonetic_analyzers_dev

-- Create indexes for better search performance
CREATE INDEX IF NOT EXISTS idx_person_dm_primary ON person(dm_primary);
CREATE INDEX IF NOT EXISTS idx_person_dm_alternate ON person(dm_alternate);
CREATE INDEX IF NOT EXISTS idx_person_fullname_gin ON person USING gin(full_name gin_trgm_ops);

-- Enable query statistics
ALTER SYSTEM SET shared_preload_libraries = 'pg_stat_statements';
```

### **Function App Performance**
```json
// In local.settings.json, add:
{
  "Values": {
    "FUNCTIONS_WORKER_PROCESS_COUNT": "4",
    "AzureFunctionsJobHost__functionTimeout": "00:05:00"
  }
}
```

## 🔄 **Data Management**

### **Sample Data Loading**
```powershell
# Create sample data script
$samplePersons = @(
    @{externalId="sample-001"; fullName="John Smith"},
    @{externalId="sample-002"; fullName="Jane Doe"},
    @{externalId="sample-003"; fullName="Michael Johnson"}
)

foreach ($person in $samplePersons) {
    $body = $person | ConvertTo-Json
    Invoke-RestMethod -Uri "http://localhost:7071/api/ingest" `
        -Method POST `
        -ContentType "application/json" `
        -Body $body
}
```

### **Database Backup & Restore**
```powershell
# Backup
docker exec postgres-phonetic-dev pg_dump -U postgres phonetic_analyzers_dev > backup.sql

# Restore
docker exec -i postgres-phonetic-dev psql -U postgres phonetic_analyzers_dev < backup.sql
```

## 🚀 **Moving to Production**

When ready to deploy to Azure:

```powershell
# Deploy to Azure (see Azure setup guide)
.\setup-azure.bat
# Choose option 3: Production environment

# Migrate your local data (optional)
# Export from local PostgreSQL and import to Azure PostgreSQL
```

## 💡 **Tips & Best Practices**

### **Development Tips**
- Use descriptive `externalId` values for testing
- Keep test data separate with prefixes (`test-`, `dev-`, etc.)
- Use pgAdmin to inspect database during development
- Set up Git hooks to run tests before commits

### **Performance Tips**
- Enable PostgreSQL query logging for optimization
- Use Application Insights locally by adding connection string
- Profile function cold starts and optimize accordingly
- Test with realistic data volumes

### **Security Tips**
- Change default PostgreSQL password in production
- Use environment variables for sensitive configuration
- Enable SSL for PostgreSQL in production
- Regular backup and test restore procedures

## ✅ **Local Development Checklist**

- [ ] Docker Desktop installed and running
- [ ] .NET 8 SDK installed
- [ ] PostgreSQL container running
- [ ] Database schema created (migrations applied)
- [ ] Both function apps starting without errors
- [ ] Health endpoints responding
- [ ] Can ingest and search test data
- [ ] IDE configured with proper extensions
- [ ] Git repository initialized and configured

---

**🎉 Perfect!** You now have a complete local development environment that mirrors the production architecture!

For deployment to Azure, see the **Azure Setup Guide** in the docs folder.