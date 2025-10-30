# 🏠 Complete Local Development Setup (No Azure Required)

**Perfect for when you're waiting for Azure CLI approval!**

## 🎯 **What You'll Get**
- ✅ Full local development environment
- ✅ No cloud dependencies
- ✅ No Azure CLI required
- ✅ No Docker required (optional PostgreSQL installer)
- ✅ Everything runs on your local machine

## 📋 **Prerequisites (No Admin Rights Needed)**

### **Option A: With Docker (If Allowed)**
```powershell
winget install Microsoft.DotNet.SDK.8
winget install Docker.DockerDesktop
```

### **Option B: Without Docker (Direct PostgreSQL Install)**
1. **Download .NET 8**: https://dotnet.microsoft.com/download/dotnet/8.0
2. **Download PostgreSQL**: https://www.postgresql.org/download/windows/
   - Choose "Windows x86-64" installer
   - During install: Password = `postgres`, Port = `5432`

## 🚀 **Setup Steps**

### **Step 1: Start Database**

#### **With Docker:**
```powershell
docker run --name postgres-local -e POSTGRES_PASSWORD=postgres -e POSTGRES_DB=phonetic_analyzers_dev -p 5432:5432 -d postgres:15
```

#### **Without Docker (Direct Install):**
```powershell
# After PostgreSQL installation, create database
# Open Command Prompt and run:
createdb -U postgres phonetic_analyzers_dev
# Enter password: postgres
```

### **Step 2: Verify Database Connection**
```powershell
# Test connection (both methods)
psql -h localhost -U postgres -d phonetic_analyzers_dev
# Enter password: postgres
# Type \q to exit
```

### **Step 3: Build and Setup Project**
```powershell
# Navigate to project
cd C:\Path\To\PhoneticAnalyzers

# Restore and build
dotnet restore
dotnet build

# Setup database schema
cd src\PhoneticAnalyzers.Infrastructure
dotnet tool install --global dotnet-ef
dotnet ef database update
cd ..\..
```

### **Step 4: Start Development**
```powershell
# Terminal 1 - Ingestion Function
cd src\PhoneticAnalyzers.Functions.Ingestion
func start

# Terminal 2 - Search Function  
cd src\PhoneticAnalyzers.Functions.Search
func start --port 7072
```

### **Step 5: Test Everything Works**
```powershell
# Test health
curl http://localhost:7071/api/health

# Test data ingestion
$body = @{
    externalId = "local-test-001"
    fullName = "John Smith"
    expandNicknames = $true
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:7071/api/ingest" -Method POST -ContentType "application/json" -Body $body

# Test search
curl "http://localhost:7072/api/search?name=Jon%20Smyth&maxResults=10"
```

## 🛠️ **Development Workflow**

### **Daily Startup**
```powershell
# 1. Start database (if using Docker)
docker start postgres-local

# 2. Start function apps
cd src\PhoneticAnalyzers.Functions.Ingestion && func start
cd src\PhoneticAnalyzers.Functions.Search && func start --port 7072

# 3. Open IDE
code .  # VS Code
```

### **Making Changes**
1. Edit code in VS Code or Visual Studio
2. Function apps auto-reload
3. Test APIs immediately
4. Database changes: `dotnet ef migrations add YourChange && dotnet ef database update`

## 💾 **Local Database Management**

### **View Data (Command Line)**
```powershell
# Connect to database
psql -h localhost -U postgres -d phonetic_analyzers_dev

# Useful commands:
\dt                          # List all tables
SELECT * FROM person;        # View person data
SELECT * FROM beider_morse_variant; # View phonetic data
\q                          # Exit
```

### **View Data (GUI - Optional)**
```powershell
# Install pgAdmin for visual database management
winget install PostgreSQL.pgAdmin

# Connect: Host=localhost, Port=5432, User=postgres, Password=postgres
```

## 🔧 **Troubleshooting**

### **PostgreSQL Issues**
```powershell
# Check if PostgreSQL is running
# With Docker:
docker ps | findstr postgres

# Without Docker:
Get-Service postgresql*  # Windows service

# Restart if needed
# Docker: docker restart postgres-local  
# Service: Restart-Service postgresql*
```

### **Port Conflicts**
```powershell
# Check what's using port 5432
netstat -ano | findstr :5432

# If conflict, use different port for PostgreSQL
# Docker: docker run -p 5433:5432 ...
# Update connection string to use port 5433
```

### **Function App Issues**
```powershell
# Check .NET version
dotnet --version  # Should be 8.0.x

# Detailed function startup
func start --verbose

# Clean build if needed
dotnet clean && dotnet restore && dotnet build
```

## 🎯 **Benefits of This Setup**

✅ **No waiting**: Start developing immediately  
✅ **No approvals**: Everything runs locally  
✅ **Full features**: Same functionality as cloud setup  
✅ **Cost-free**: No Azure charges  
✅ **Fast**: No network latency  
✅ **Offline**: Works without internet  

## 🚀 **When Azure CLI Gets Approved**

When you get Azure CLI access, you can easily migrate:

```powershell
# Export your local data
pg_dump -h localhost -U postgres phonetic_analyzers_dev > local_data.sql

# Deploy to Azure
.\setup-azure.bat

# Import your data to Azure
psql -h YOUR_AZURE_SERVER.postgres.database.azure.com -U pgladmin -d phonetic_analyzers < local_data.sql
```

## 💡 **Pro Tips**

1. **Use Git**: Commit your changes regularly
2. **Sample data**: Create test datasets for different scenarios
3. **Performance**: Local setup is actually faster for development
4. **Learning**: Great way to understand the architecture without cloud complexity

---

**🎉 Perfect!** You now have a complete development environment that requires zero cloud approvals!