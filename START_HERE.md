# 🚀 START HERE - PhoneticAnalyzers Setup

**👋 New to this project? This is your ONLY starting point!**

## 📋 **What is PhoneticAnalyzers?**

A production-ready Azure solution for phonetic name search and matching that can handle over 1 billion names with low-latency search using Double Metaphone and Beider-Morse algorithms.

## 🎯 **Choose Your Path (Pick ONE)**

### **🏢 Path A: For Office Systems (Fintech/Corporate)**
**✅ No Docker allowed? This is for you!**

#### **⚡ Super Quick (Recommended)**
1. **Prerequisites** (Run as Administrator):
   ```powershell
   winget install Microsoft.DotNet.SDK.8
   winget install Microsoft.AzureCLI
   ```

2. **Login to Azure**:
   ```powershell
   az login
   ```

3. **Deploy Everything**:
   ```powershell
   .\setup-azure.bat
   # Choose option 1: Development (Simple)
   ```

4. **Start Developing**:
   ```powershell
   # Terminal 1:
   cd src\PhoneticAnalyzers.Functions.Ingestion
   func start
   
   # Terminal 2:
   cd src\PhoneticAnalyzers.Functions.Search
   func start --port 7072
   ```

5. **Test It Works**:
   ```powershell
   curl http://localhost:7071/api/health
   ```

**🎉 Done! You're developing with enterprise Azure PostgreSQL!**

---

### **🏠 Path B: For Personal/Home Development**
**✅ Docker allowed? You can use local PostgreSQL**

#### **Quick Local Setup**
1. **Prerequisites**:
   ```powershell
   winget install Microsoft.DotNet.SDK.8
   winget install Docker.DockerDesktop
   ```

2. **Start PostgreSQL**:
   ```powershell
   docker run --name postgres-dev -e POSTGRES_PASSWORD=postgres -p 5432:5432 -d postgres:15
   ```

3. **Build & Run**:
   ```powershell
   dotnet build
   cd src\PhoneticAnalyzers.Functions.Ingestion
   func start
   ```

---

## 🎯 **What You Get**

### **Path A (Azure Cloud)**
- ✅ Enterprise PostgreSQL in Azure (~$25/month)
- ✅ No Docker needed (fintech-friendly)
- ✅ Production-like development environment
- ✅ Full monitoring and security
- ✅ Team collaboration ready

### **Path B (Local Docker)**
- ✅ Free local development
- ✅ Faster startup (no cloud dependencies)
- ✅ Works offline
- ⚠️ Requires Docker (may be blocked in corporate)

## 🆘 **Troubleshooting**

### **Common Issues**

#### **"winget not found"**
Download installers manually:
- .NET 8: https://dotnet.microsoft.com/download/dotnet/8.0
- Azure CLI: https://aka.ms/installazurecliwindows

#### **"Function tools missing"**
```powershell
npm install -g azure-functions-core-tools@4 --unsafe-perm true
```

#### **"Can't connect to Azure database"**
Your IP needs to be added to firewall - this happens automatically during setup.

#### **"Build errors"**
```powershell
dotnet clean
dotnet restore
dotnet build
```

### **Need More Help?**
- **Azure Path**: See detailed guide in `docs/AZURE_SETUP.md`
- **Local Path**: See detailed guide in `docs/LOCAL_SETUP.md`
- **Architecture**: See `README.md` for full project overview

## 🎯 **Project Structure**

```
PhoneticAnalyzers/
├── 🚀 START_HERE.md           ← You are here!
├── 📖 README.md               ← Full project documentation  
├── ⚡ setup-azure.bat         ← One-click Azure setup
├── src/                       ← Your code lives here
│   ├── PhoneticAnalyzers.Domain/
│   ├── PhoneticAnalyzers.Application/
│   ├── PhoneticAnalyzers.Infrastructure/
│   ├── PhoneticAnalyzers.Functions.Ingestion/
│   └── PhoneticAnalyzers.Functions.Search/
├── tests/                     ← Unit & integration tests
├── infra/                     ← Azure infrastructure (Bicep)
└── docs/                      ← Detailed documentation
```

## 🔄 **Development Workflow**

### **Daily Development**
1. **Start function apps** (2 terminals)
2. **Make code changes** in VS Code/Visual Studio
3. **Test APIs** at `http://localhost:7071`
4. **Auto-reload** when you save files

### **Database Changes**
```powershell
cd src\PhoneticAnalyzers.Infrastructure
dotnet ef migrations add YourChange
dotnet ef database update
```

### **Deploy to Production**
```powershell
.\setup-azure.bat
# Choose option 3: Production environment
```

## ✅ **Success Checklist**

After setup, verify:
- [ ] Health endpoint: `curl http://localhost:7071/api/health`
- [ ] Can ingest data: POST to `/api/ingest`
- [ ] Can search data: GET `/api/search?name=John`
- [ ] Database connected (no connection errors)
- [ ] Monitoring working (Application Insights)

## 📚 **Learning Resources**

### **Architecture Patterns Used**
- **Clean Architecture**: Domain, Application, Infrastructure layers
- **CQRS**: Command Query Responsibility Segregation
- **Domain-Driven Design**: Rich domain models
- **Repository Pattern**: Data access abstraction

### **Technologies Used**
- **.NET 8**: Latest LTS framework
- **Azure Functions**: Serverless compute
- **PostgreSQL**: High-performance database
- **Entity Framework**: ORM with migrations
- **MediatR**: CQRS implementation

## 💰 **Costs**

### **Azure Path (Development)**
- PostgreSQL: ~$15-25/month
- Function Apps: ~$0-5/month  
- Storage & Monitoring: ~$5-10/month
- **Total: ~$20-40/month**

### **Local Path**
- **Free** (uses local Docker)

## 🎯 **Next Steps**

1. **✅ Get it running** (follow Path A or B above)
2. **📚 Understand the code** (explore `src/` folder)
3. **🧪 Run tests** (`dotnet test`)
4. **🔧 Add features** (use CQRS patterns)
5. **🚀 Deploy to production** (when ready)

---

## 🎉 **You're Ready!**

Pick your path above and follow the simple steps. You'll be up and running in 10-20 minutes!

**Questions?** Check the detailed docs in the `docs/` folder or the main `README.md`.

**🚀 Happy coding!**