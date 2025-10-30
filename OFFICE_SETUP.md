# 🏢 Office Laptop Setup Guide

## 🎯 **Quick Setup for Office Environment**

### **Step 1: Pull Latest Code**
```powershell
git pull origin main
```

### **Step 2: Create local.settings.json**
The `local.settings.json` file is gitignored for security, so you need to create it:

1. Navigate to: `src\PhoneticAnalyzers.Functions.Ingestion\`
2. Copy `local.settings.template.json` to `local.settings.json`:

```powershell
cd src\PhoneticAnalyzers.Functions.Ingestion
copy local.settings.template.json local.settings.json
```

### **Step 3: Configure PostgreSQL Connection**
Edit the newly created `local.settings.json` file and update the connection string:

```json
{
  "IsEncrypted": false,
  "Values": {
    "AzureWebJobsStorage": "UseDevelopmentStorage=true",
    "FUNCTIONS_WORKER_RUNTIME": "dotnet-isolated",
    "FUNCTIONS_EXTENSION_VERSION": "~4",
    "ConnectionStrings__DefaultConnection": "YOUR_POSTGRESQL_CONNECTION_HERE",
    "ASPNETCORE_ENVIRONMENT": "Development"
  }
}
```

### **Step 4: PostgreSQL Connection Options**

#### **Option A: Azure PostgreSQL (Recommended for Office)**
```
Server=your-server.postgres.database.azure.com;Database=phonetic_analyzers;Port=5432;User Id=your-username;Password=your-password;Ssl Mode=Require;
```

#### **Option B: Local PostgreSQL (If IT Allows)**
```
Host=localhost;Database=phonetic_analyzers;Username=postgres;Password=your-password;Port=5432;
```

### **Step 5: Test the Setup**
```powershell
# Navigate to the function directory
cd src\PhoneticAnalyzers.Functions.Ingestion

# Start the function
func start

# Test in another terminal
curl http://localhost:7071/api/health
```

## 🔧 **Files You Should See After git pull:**

```
PhoneticAnalyzers/
├── src/
│   └── PhoneticAnalyzers.Functions.Ingestion/
│       ├── PhoneticAnalyzersFunctions.cs          ✅ Main API endpoints
│       ├── local.settings.template.json           ✅ Template (copy this)
│       └── Program.cs                             ✅ DI setup
├── docs/
│   ├── POSTGRESQL_SETUP.md                       ✅ PostgreSQL guide
│   └── UI_INTEGRATION.md                         ✅ UI integration examples
├── test-api.ps1                                   ✅ API test script
├── start-functions.bat                            ✅ Quick start script
└── START_HERE.md                                  ✅ Updated guide
```

## 🚀 **Quick Commands for Office Setup:**

```powershell
# 1. Pull latest code
git pull

# 2. Create local.settings.json from template
cd src\PhoneticAnalyzers.Functions.Ingestion
copy local.settings.template.json local.settings.json

# 3. Edit local.settings.json with your PostgreSQL connection

# 4. Start the function app
func start

# 5. Test it works
.\test-api.ps1
```

## 🆘 **If You Don't See the Files:**

1. **Refresh Solution Explorer** in Visual Studio
2. **Show All Files** (folder icon with dots)
3. **Rebuild Solution** (Build → Rebuild Solution)
4. **Close and Reopen** Visual Studio

## 📋 **What's Now Available:**

- ✅ **Main API File:** `PhoneticAnalyzersFunctions.cs` with all HTTP endpoints
- ✅ **Configuration Template:** `local.settings.template.json` 
- ✅ **PostgreSQL Guide:** Complete setup instructions
- ✅ **Test Scripts:** Automated API testing
- ✅ **Quick Start:** One-click setup scripts

The project is now complete and ready for office development!