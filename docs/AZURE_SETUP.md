# Azure Cloud Setup (Detailed Guide)

**💡 This is the detailed guide for Path A from START_HERE.md**

## 🎯 **For Fintech/Corporate Environments (No Docker)**

This guide shows you how to set up PhoneticAnalyzers using Azure PostgreSQL when Docker is not allowed.

## 📋 **Prerequisites**

### **Required Software**
1. **.NET 8 SDK**: `winget install Microsoft.DotNet.SDK.8`
2. **Azure CLI**: `winget install Microsoft.AzureCLI`
3. **Azure Functions Core Tools**: `npm install -g azure-functions-core-tools@4`

### **Azure Requirements**
- Azure subscription with resource creation permissions
- Estimated cost: ~$20-40/month for development

## 🚀 **Step-by-Step Setup**

### **Step 1: Login to Azure**
```powershell
az login
az account show  # Verify you're logged in
az account set --subscription "your-subscription-name"  # If multiple subscriptions
```

### **Step 2: Deploy Infrastructure**
```powershell
# Navigate to project folder
cd C:\YourPath\PhoneticAnalyzers

# Option A: Simple menu (recommended)
.\setup-azure.bat
# Choose option 1: Development (Simple) - NO VNet

# Option B: Direct PowerShell
.\deploy-dev-simple.ps1 -Environment dev
```

**What this creates:**
- Azure Database for PostgreSQL Flexible Server (B1ms, 32GB storage)
- 2x Azure Function Apps (Consumption plan)
- Application Insights for monitoring
- Storage Account for function apps
- Firewall rules for your IP address

### **Step 3: Configure Local Development**

After deployment, update your local settings files with the provided connection strings:

**`src/PhoneticAnalyzers.Functions.Ingestion/local.settings.json`**:
```json
{
  "IsEncrypted": false,
  "Values": {
    "AzureWebJobsStorage": "UseDevelopmentStorage=true",
    "FUNCTIONS_WORKER_RUNTIME": "dotnet-isolated",
    "FUNCTIONS_EXTENSION_VERSION": "~4",
    "ConnectionStrings__DefaultConnection": "Host=YOUR_SERVER.postgres.database.azure.com;Database=phonetic_analyzers;Username=pgadmin;Password=YOUR_PASSWORD;SSL Mode=Require;",
    "APPLICATIONINSIGHTS_CONNECTION_STRING": "YOUR_AI_CONNECTION_STRING",
    "ASPNETCORE_ENVIRONMENT": "Development"
  }
}
```

**💡 The deployment script provides the exact connection strings to copy!**

### **Step 4: Build and Run**
```powershell
# Build the solution
dotnet restore
dotnet build

# Start Ingestion Function (Terminal 1)
cd src\PhoneticAnalyzers.Functions.Ingestion
func start

# Start Search Function (Terminal 2)
cd src\PhoneticAnalyzers.Functions.Search
func start --port 7072
```

### **Step 5: Test Everything**
```powershell
# Test health endpoint
curl http://localhost:7071/api/health

# Test person ingestion
$body = @{
    externalId = "test-001"
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

## 🔒 **Security Features**

### **Development Setup (Simple)**
- ✅ SSL/TLS encryption for all connections
- ✅ IP-based firewall (your office IP automatically added)
- ✅ Azure AD authentication for management
- ✅ Application Insights monitoring
- ✅ Encrypted storage (AES-256)

### **Production Setup (Enhanced)**
For production, use VNet with private endpoints:
```powershell
.\deploy-dev-simple.ps1 -Environment prod -EnableVNet
```

## 💰 **Cost Management**

### **Development Costs (Monthly)**
- PostgreSQL B1ms: ~$15-25
- Function Apps (Consumption): ~$0-5
- Storage & Monitoring: ~$5-10
- **Total: ~$20-40**

### **Cost Optimization**
```powershell
# Stop database when not developing (saves 70% cost)
az postgres flexible-server stop --resource-group rg-phoneticanalyzers-dev-* --name psql-*

# Start when needed
az postgres flexible-server start --resource-group rg-phoneticanalyzers-dev-* --name psql-*
```

## 📊 **Monitoring**

### **Application Insights**
- Real-time performance metrics
- Exception tracking
- Dependency monitoring (database calls)
- Custom logging and alerts

Access: https://portal.azure.com → Application Insights → your-app-insights

### **Database Monitoring**
- Connection monitoring
- Query performance insights  
- Automatic performance recommendations
- Resource utilization alerts

## 🔧 **Development Workflow**

### **Daily Startup**
```powershell
# 1. Start function apps (2 terminals)
cd src\PhoneticAnalyzers.Functions.Ingestion && func start
cd src\PhoneticAnalyzers.Functions.Search && func start --port 7072

# 2. Open IDE
code .  # VS Code
# OR open PhoneticAnalyzers.sln
```

### **Making Database Changes**
```powershell
cd src\PhoneticAnalyzers.Infrastructure

# Add migration
dotnet ef migrations add YourMigrationName

# Update database (connects to Azure)
dotnet ef database update
```

### **Deploying Code Changes**
```powershell
# Deploy to Azure Function Apps
cd src\PhoneticAnalyzers.Functions.Ingestion
func azure functionapp publish your-ingestion-function-name

cd src\PhoneticAnalyzers.Functions.Search
func azure functionapp publish your-search-function-name
```

## 🆘 **Troubleshooting**

### **Connection Issues**
```powershell
# Test database connectivity
az postgres flexible-server connect --name YOUR_SERVER --admin-user pgadmin

# Check firewall rules
az postgres flexible-server firewall-rule list --resource-group YOUR_RG --name YOUR_SERVER

# Add new IP address
az postgres flexible-server firewall-rule create --resource-group YOUR_RG --name YOUR_SERVER --rule-name "NewIP" --start-ip-address X.X.X.X --end-ip-address X.X.X.X
```

### **Function App Issues**
```powershell
# View function logs
func azure functionapp logstream YOUR_FUNCTION_APP

# Restart function app
az functionapp restart --resource-group YOUR_RG --name YOUR_FUNCTION_APP

# Check application settings
az functionapp config appsettings list --resource-group YOUR_RG --name YOUR_FUNCTION_APP
```

### **Build Issues**
```powershell
# Clean build
dotnet clean
dotnet restore --force
dotnet build
```

## 🏢 **Team Development**

### **Shared Environment**
- Multiple developers can use the same Azure database
- Use different `externalId` prefixes to separate test data
- Cost-effective for small teams

### **Individual Environments**
```powershell
# Each developer gets their own environment
.\deploy-dev-simple.ps1 -Environment dev-john
.\deploy-dev-simple.ps1 -Environment dev-jane
```

## 🚀 **Scaling to Production**

### **Production Deployment**
```powershell
# Deploy production environment
.\deploy-dev-simple.ps1 -Environment prod -EnableVNet

# Features included:
# - High availability PostgreSQL
# - VNet with private endpoints
# - Premium Function App plans
# - Enhanced monitoring
# - Backup and disaster recovery
```

### **CI/CD Pipeline**
The solution includes GitHub Actions workflows for:
- Automated testing
- Infrastructure deployment
- Application deployment
- Database migrations

## 📋 **Environment Comparison**

| Feature | Development (Simple) | Development (VNet) | Production |
|---------|---------------------|-------------------|------------|
| **Cost/Month** | $20-40 | $60-80 | $100-200 |
| **Setup Time** | 5 minutes | 10 minutes | 15 minutes |
| **Database** | B1ms, Public + Firewall | B2s, Private endpoint | D2s_v3, HA + Private |
| **Function Apps** | Consumption | Premium | Premium |
| **Security** | IP firewall | VNet isolation | Full enterprise |
| **Monitoring** | Basic | Enhanced | Complete |
| **Backup** | 7 days | 14 days | 30 days |

## ✅ **Success Criteria**

Your setup is successful when:
- [ ] Health endpoint returns 200 OK
- [ ] Can ingest test persons
- [ ] Can search for persons
- [ ] No database connection errors
- [ ] Application Insights receiving data
- [ ] Function apps auto-reload on code changes

---

**🎉 Congratulations!** You now have a production-grade development environment running in Azure without any Docker complexity!

For more advanced scenarios, see:
- **VNet Setup**: For enhanced security requirements
- **Production Guide**: For live deployment
- **Monitoring Guide**: For detailed observability setup