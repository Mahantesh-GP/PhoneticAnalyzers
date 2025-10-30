# 🏢 Azure Portal Setup Guide for Office Laptop

## 🎯 **What You NEED vs What's OPTIONAL**

### **✅ REQUIRED (Minimum Setup)**
| Service | Purpose | Required? | Cost |
|---------|---------|-----------|------|
| **Azure Functions** | API endpoints | ✅ **YES** | ~$0-5/month |
| **PostgreSQL Database** | Data storage | ✅ **YES** | ~$15-25/month |
| **Application Insights** | Monitoring/logs | ⚠️ **Recommended** | ~$0-5/month |

### **❌ OPTIONAL (Not Needed Initially)**
| Service | Purpose | Required? | When Needed |
|---------|---------|-----------|-------------|
| **Service Bus** | Message queuing | ❌ **NO** | Only for async processing |
| **Event Hub** | Event streaming | ❌ **NO** | Only for real-time events |
| **Key Vault** | Secret management | ❌ **NO** | Production security |
| **Storage Account** | File storage | ⚠️ **Maybe** | Function app needs it |

---

## 🚀 **STEP-BY-STEP: Minimum Azure Setup**

### **Step 1: Create Resource Group**
```bash
# In Azure Portal or CLI
Resource Group Name: rg-phonetic-analyzers-dev
Location: East US (or your preferred region)
```

### **Step 2: Create PostgreSQL Database**
```bash
Service: Azure Database for PostgreSQL Flexible Server
Name: phonetic-analyzers-db-dev
Username: phoneticadmin
Password: [Choose a strong password]
Database Name: phonetic_analyzers
SKU: Burstable, B1ms (cheapest option)
Storage: 32 GiB
```

**Connection String Format:**
```
Server=your-server.postgres.database.azure.com;Database=phonetic_analyzers;Port=5432;User Id=phoneticadmin;Password=your-password;Ssl Mode=Require;
```

### **Step 3: Create Function App**
```bash
Function App Name: phonetic-analyzers-api-dev
Publish: Code
Runtime Stack: .NET 8 (LTS) Isolated
Operating System: Windows
Plan: Consumption (Serverless) - FREE tier
```

### **Step 4: Create Application Insights (Recommended)**
```bash
Name: phonetic-analyzers-insights-dev
Resource Group: rg-phonetic-analyzers-dev
Region: Same as your other resources
```

---

## 🔧 **Configuration After Creation**

### **Function App Settings**
In Azure Portal → Function App → Configuration → Application Settings:

```json
{
  "ConnectionStrings__DefaultConnection": "Server=your-server.postgres.database.azure.com;Database=phonetic_analyzers;Port=5432;User Id=phoneticadmin;Password=your-password;Ssl Mode=Require;",
  "FUNCTIONS_WORKER_RUNTIME": "dotnet-isolated",
  "FUNCTIONS_EXTENSION_VERSION": "~4",
  "ASPNETCORE_ENVIRONMENT": "Development"
}
```

### **Database Firewall Rules**
1. Go to PostgreSQL server → Connection security
2. Add your office IP address
3. ✅ Allow access to Azure services

---

## 💰 **Cost Breakdown (Development)**

### **Minimum Setup (~$20-30/month)**
- **PostgreSQL Flexible Server (B1ms):** ~$15-20/month
- **Function App (Consumption):** ~$0-5/month (free tier covers most dev usage)
- **Application Insights:** ~$0-5/month (free tier covers most dev usage)
- **Total:** ~$20-30/month

### **What You DON'T Need (Save Money)**
- ❌ **Service Bus:** $0 saved (you're not using message queuing yet)
- ❌ **Event Hub:** $0 saved (you're not using event streaming)
- ❌ **Premium Functions:** $50+ saved (consumption plan is fine)
- ❌ **High-tier PostgreSQL:** $100+ saved (B1ms is sufficient for development)

---

## 🔄 **Deployment Options**

### **Option 1: Manual Deployment (Easiest)**
1. Create resources in Azure Portal (steps above)
2. Deploy code using Visual Studio:
   - Right-click project → Publish
   - Choose Azure Functions
   - Select your function app

### **Option 2: Automated Deployment (Using Existing Scripts)**
```powershell
# Use the setup script I created
.\setup-azure.bat
# Choose option 1: Development (Simple)
```

### **Option 3: ARM Template/Bicep (Advanced)**
```powershell
# Deploy using existing bicep templates
az deployment group create \
  --resource-group rg-phonetic-analyzers-dev \
  --template-file infra/main.bicep
```

---

## 🛠️ **Local Development vs Azure**

### **For Local Development (Office Laptop):**
```json
// local.settings.json
{
  "ConnectionStrings__DefaultConnection": "Server=your-azure-postgres.postgres.database.azure.com;...",
  "AzureWebJobsStorage": "UseDevelopmentStorage=true"
}
```

### **For Azure Production:**
Same connection string, but configured in:
- Azure Portal → Function App → Configuration → Application Settings

---

## 🚀 **Quick Setup Commands**

### **If you want to use Azure CLI:**
```bash
# 1. Create resource group
az group create --name rg-phonetic-analyzers-dev --location eastus

# 2. Create PostgreSQL server
az postgres flexible-server create \
  --resource-group rg-phonetic-analyzers-dev \
  --name phonetic-analyzers-db-dev \
  --admin-user phoneticadmin \
  --admin-password YourStrongPassword123! \
  --sku-name Standard_B1ms \
  --storage-size 32 \
  --database-name phonetic_analyzers

# 3. Create Function App
az functionapp create \
  --resource-group rg-phonetic-analyzers-dev \
  --name phonetic-analyzers-api-dev \
  --storage-account phoneticstorage \
  --consumption-plan-location eastus \
  --runtime dotnet-isolated \
  --functions-version 4
```

---

## ✅ **What You DON'T Need to Create**

### **Service Bus - Skip This**
- **Why:** You're not using message queues yet
- **When to add:** Only if you need async processing between services
- **Cost saving:** ~$10-50/month

### **Event Hub - Skip This** 
- **Why:** You're not doing real-time event streaming
- **When to add:** Only if you need to process millions of events
- **Cost saving:** ~$20-100/month

### **Key Vault - Skip This Initially**
- **Why:** You can put connection strings in Function App settings for development
- **When to add:** Production deployment for security
- **Cost saving:** ~$5-15/month

---

## 🎯 **Recommended Office Setup Process**

1. **Start Simple:** Create only PostgreSQL + Function App
2. **Test Local:** Connect your local dev environment to Azure PostgreSQL
3. **Deploy Function:** Deploy your API to Azure Functions
4. **Add Monitoring:** Add Application Insights if needed
5. **Scale Later:** Add Service Bus/Event Hub only when you need them

## 📋 **Summary: Create These 3 Things**

1. **Resource Group:** `rg-phonetic-analyzers-dev`
2. **PostgreSQL Flexible Server:** `phonetic-analyzers-db-dev`  
3. **Function App:** `phonetic-analyzers-api-dev`

**Total monthly cost:** ~$20-30 for development

Everything else in your `local.settings.json` can stay as placeholder values until you actually need those services!