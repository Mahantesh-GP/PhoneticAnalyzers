# PhoneticAnalyzers Project - START HERE 🚀

**👋 New to this project? This is your ONLY starting point!**

## 🎯 **What is PhoneticAnalyzers?**

A .NET 8 Azure Functions application that provides **phonetic name matching** services using algorithms like Double Metaphone and Beider-Morse. Perfect for:
- Customer deduplication  
- Record linkage
- Fuzzy name matching
- Data quality improvements

## 📁 **Project Structure Overview:**

```
PhoneticAnalyzers/
├── 📂 src/
│   ├── 📂 PhoneticAnalyzers.Domain/          # Core entities & business logic
│   ├── 📂 PhoneticAnalyzers.Application/     # CQRS commands & queries  
│   ├── 📂 PhoneticAnalyzers.Infrastructure/  # Database & repositories
│   └── 📂 PhoneticAnalyzers.Functions.Ingestion/  # 🚀 MAIN API ENDPOINTS
├── 📂 infra/                                 # Bicep templates for Azure
├── 📂 docs/                                 # Setup & architecture guides
└── 📂 tests/                                # Unit & integration tests
```

## 🔥 **API Endpoints Available:**

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/health` | GET | Health check |
| `/ingest` | POST | Add single person |
| `/ingest/batch` | POST | Add multiple persons |
| `/search?name=John` | GET | Search by name (phonetic matching) |
| `/person/{id}` | GET | Get person by ID |

## ⚡ **Choose Your Setup Path:**

### **🏢 Path 1: Quick Local Test** (5 minutes)
**✅ Best for:** Testing the API endpoints immediately  
**✅ Includes:** In-memory database, no external dependencies  
**✅ Requirements:** Just .NET 8 SDK

```powershell
# Run this command to start immediately:
cd src\PhoneticAnalyzers.Functions.Ingestion
func start
```

📋 **Guide:** [AZURE_SETUP.md](docs/AZURE_SETUP.md)

### **� Path 3: Local Development** (Full Database)
**✅ Best for:** Local development with persistent storage  
**✅ Includes:** Local PostgreSQL, complete functionality  
**✅ Requirements:** Docker Desktop OR manual PostgreSQL installation  
📋 **Guide:** [LOCAL_SETUP.md](docs/LOCAL_SETUP.md)

---

## ⚡ **Super Quick Start Commands:**

### **🚀 Option 1: Just Run It!** (Fastest - 1 minute)
```powershell
# Windows: Just double-click this file
.\start-functions.bat

# Or manually:
cd src\PhoneticAnalyzers.Functions.Ingestion
func start
```

### **🧪 Option 2: Test Everything** (2 minutes)  
```powershell
# Start the function (Terminal 1)
.\start-functions.bat

# Test all endpoints (Terminal 2) 
.\test-api.ps1
```

### **🏢 Option 3: Azure Setup** (10 minutes)
```powershell
# For office/production environments
.\setup-azure.bat
```

---

## 🧪 **Test the API:**

Once running, test with these commands:

```bash
# Health check
curl http://localhost:7071/api/health

# Add a person  
curl -X POST http://localhost:7071/api/ingest \
  -H "Content-Type: application/json" \
  -d '{"externalId":"emp001","fullName":"John Smith"}'

# Search for similar names
curl "http://localhost:7071/api/search?name=Jon%20Smyth&maxResults=10"
```

**Or use the test script:**
```powershell
.\test-api.ps1
```

## 🆘 **Common Issues & Solutions:**

#### **"Function tools missing"**
```powershell
npm install -g azure-functions-core-tools@4 --unsafe-perm true
```

#### **"Build errors"**  
```powershell
dotnet clean
dotnet restore  
dotnet build
```

#### **"Can't start function"**
Make sure you're in the right directory:
```powershell
cd src\PhoneticAnalyzers.Functions.Ingestion
func start
```

## 📁 **Key Files & Folders:**

```
PhoneticAnalyzers/
├── 🚀 START_HERE.md                    ← You are here!
├── ⚡ start-functions.bat              ← Double-click to start
├── 🧪 test-api.ps1                     ← Test all endpoints
├── src/
│   └── PhoneticAnalyzers.Functions.Ingestion/
│       ├── PhoneticAnalyzersFunctions.cs  ← 🎯 MAIN API ENDPOINTS
│       ├── Program.cs                      ← Dependency injection setup  
│       └── local.settings.json            ← Configuration
├── docs/                               ← Detailed setup guides
└── infra/                             ← Azure deployment templates
```

## 🎓 **Understanding the Code:**

### **Main API File:** 
`src/PhoneticAnalyzers.Functions.Ingestion/PhoneticAnalyzersFunctions.cs`
- Contains all HTTP endpoints
- Shows how CQRS commands/queries work
- Examples of JSON request/response handling

### **Architecture Layers:**
- **Domain:** Core business entities (`Person`, value objects)
- **Application:** CQRS commands & queries (business logic)  
- **Infrastructure:** Database, repositories, external services
- **Functions:** HTTP API endpoints (presentation layer)

### **Key Concepts:**
- **Clean Architecture:** Separation of concerns
- **CQRS:** Commands (write) vs Queries (read)
- **MediatR:** Handles command/query routing
- **Entity Framework:** Database ORM with migrations

## 📚 **Additional Documentation:**
- [Azure Setup Guide](docs/AZURE_SETUP.md) - Full cloud deployment
- [Local Setup Guide](docs/LOCAL_SETUP.md) - Local development
- [Architecture Overview](docs/ARCHITECTURE_OVERVIEW.md) - Technical details

---

**💡 Tip:** Start with **Path 1 (Quick Local Test)** to see the API in action immediately, then explore the code structure!

**🚀 Ready to start? Run:** `.\start-functions.bat`