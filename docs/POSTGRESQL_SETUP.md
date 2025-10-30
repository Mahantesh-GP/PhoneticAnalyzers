# PostgreSQL Connection Configuration Guide

## 🎯 **Where to Configure PostgreSQL Connection**

### **1. Local Development (Functions)**
**File:** `src\PhoneticAnalyzers.Functions.Ingestion\local.settings.json`

Replace the connection string:
```json
{
  "IsEncrypted": false,
  "Values": {
    "ConnectionStrings__DefaultConnection": "YOUR_POSTGRESQL_CONNECTION_STRING_HERE"
  }
}
```

### **2. Azure App Service (Production)**
**Location:** Azure Portal → Your App Service → Configuration → Application Settings

Add these settings:
- **Name:** `ConnectionStrings__DefaultConnection`
- **Value:** Your PostgreSQL connection string

### **3. Environment Variable (Alternative)**
You can also set it as an environment variable:
```bash
export DefaultConnection="YOUR_CONNECTION_STRING"
```

## 🔧 **PostgreSQL Connection String Formats**

### **Azure Database for PostgreSQL:**
```
Server=your-server.postgres.database.azure.com;Database=your-database;Port=5432;User Id=your-username;Password=your-password;Ssl Mode=Require;
```

### **Local PostgreSQL:**
```
Host=localhost;Database=phonetic_analyzers_dev;Username=postgres;Password=postgres;Port=5432;
```

### **Docker PostgreSQL:**
```
Host=localhost;Database=phonetic_analyzers;Username=postgres;Password=mypassword;Port=5432;
```

### **Connection String with SSL (Production):**
```
Host=your-host;Database=your-db;Username=your-user;Password=your-password;Port=5432;SSL Mode=Require;Trust Server Certificate=true;
```

## 🚀 **Quick Setup Examples**

### **Option 1: Local PostgreSQL (Docker)**
1. Start PostgreSQL:
```powershell
docker run --name postgres-dev -e POSTGRES_PASSWORD=mypassword -e POSTGRES_DB=phonetic_analyzers -p 5432:5432 -d postgres:15
```

2. Update connection string in `local.settings.json`:
```json
"ConnectionStrings__DefaultConnection": "Host=localhost;Database=phonetic_analyzers;Username=postgres;Password=mypassword;Port=5432;"
```

### **Option 2: Azure PostgreSQL Flexible Server**
1. Get connection string from Azure Portal
2. Update `local.settings.json`:
```json
"ConnectionStrings__DefaultConnection": "Server=your-server.postgres.database.azure.com;Database=phonetic_analyzers;Port=5432;User Id=your-username;Password=your-password;Ssl Mode=Require;"
```

### **Option 3: Local PostgreSQL Installation**
1. Install PostgreSQL locally
2. Create database:
```sql
CREATE DATABASE phonetic_analyzers;
```
3. Update connection string:
```json
"ConnectionStrings__DefaultConnection": "Host=localhost;Database=phonetic_analyzers;Username=postgres;Password=your-password;Port=5432;"
```

## 🔄 **Apply Database Migrations**

After updating the connection string:

```powershell
# Navigate to Infrastructure project
cd src\PhoneticAnalyzers.Infrastructure

# Run migrations
dotnet ef database update --startup-project ..\PhoneticAnalyzers.Functions.Ingestion
```

## ✅ **Test Connection**

Start the function and test:
```powershell
cd src\PhoneticAnalyzers.Functions.Ingestion
func start
```

Then test the health endpoint:
```powershell
curl http://localhost:7071/api/health
```

## 🆘 **Troubleshooting**

### **"Could not connect to server"**
- Check if PostgreSQL is running
- Verify host, port, username, password
- Check firewall settings

### **"Database does not exist"**
- Create the database manually
- Or run migrations to create it

### **SSL/TLS errors**
- Add `SSL Mode=Require` for Azure
- Add `Trust Server Certificate=true` if needed
- For local development, you might need `SSL Mode=Disable`

### **Permission errors**
- Verify username/password
- Check database permissions
- Ensure user has CREATE/ALTER permissions for migrations

## 📋 **Complete Example**

Here's a complete `local.settings.json` example:

```json
{
  "IsEncrypted": false,
  "Values": {
    "AzureWebJobsStorage": "UseDevelopmentStorage=true",
    "FUNCTIONS_WORKER_RUNTIME": "dotnet-isolated",
    "FUNCTIONS_EXTENSION_VERSION": "~4",
    "ConnectionStrings__DefaultConnection": "Host=localhost;Database=phonetic_analyzers;Username=postgres;Password=postgres;Port=5432;",
    "ASPNETCORE_ENVIRONMENT": "Development"
  }
}
```

Replace the `ConnectionStrings__DefaultConnection` value with your actual PostgreSQL connection string!