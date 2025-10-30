# 📋 Quick Reference: What to Create in Azure Portal

## 🎯 **For Office Laptop - CREATE THESE 3 THINGS ONLY**

### **1. Resource Group** 
- **Name:** `rg-phonetic-analyzers-dev`
- **Location:** East US (or your region)

### **2. PostgreSQL Database**
- **Service:** Azure Database for PostgreSQL Flexible Server  
- **Name:** `phonetic-analyzers-db-dev`
- **SKU:** Burstable, B1ms (cheapest)
- **Database:** `phonetic_analyzers`
- **Cost:** ~$15-20/month

### **3. Function App**
- **Name:** `phonetic-analyzers-api-dev`
- **Runtime:** .NET 8 Isolated
- **Plan:** Consumption (FREE)
- **Cost:** ~$0-5/month

## ❌ **DON'T CREATE THESE (Not Needed Yet)**

- ❌ Service Bus - You're not using message queues
- ❌ Event Hub - You're not using event streaming  
- ❌ Key Vault - Not needed for development
- ❌ Premium/Dedicated hosting plans - Consumption is fine

## 🔧 **Your local.settings.json Breakdown**

```json
{
  "Values": {
    // ✅ REQUIRED
    "ConnectionStrings__DefaultConnection": "PUT_YOUR_POSTGRESQL_CONNECTION_HERE",
    "FUNCTIONS_WORKER_RUNTIME": "dotnet-isolated",
    
    // ❌ LEAVE AS-IS (Not needed yet)
    "ServiceBusConnection": "...",
    "EventHubConnection": "...", 
    "KeyVaultUrl": ""
  }
}
```

## 💰 **Total Development Cost**
- **Monthly:** ~$20-30
- **Daily:** ~$0.70-1.00
- **Yearly:** ~$240-360

## 🚀 **After Creating Azure Resources**

1. **Get PostgreSQL connection string** from Azure Portal
2. **Paste it** in your `local.settings.json` 
3. **Start coding** on your office laptop!

You can add Service Bus, Event Hub, etc. later when you actually need them!