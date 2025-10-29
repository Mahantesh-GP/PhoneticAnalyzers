# 📁 Documentation Overview

This folder contains detailed guides for different setup scenarios:

## 📋 **Setup Guides**

### **🏢 [AZURE_SETUP.md](AZURE_SETUP.md)**
**For office/corporate environments where Docker is not allowed**
- Uses Azure Database for PostgreSQL
- No local containers needed
- Enterprise security and monitoring
- Cost: ~$20-40/month for development

### **🏠 [LOCAL_SETUP.md](LOCAL_SETUP.md)**
**For home/personal development where Docker is allowed**
- Uses local PostgreSQL in Docker
- Free to run
- Offline development capability
- Fastest startup time

## 🔧 **Configuration Guides**

### **🔒 [VNET_REQUIREMENTS.md](VNET_REQUIREMENTS.md)**
**Understanding when you need Virtual Networks**
- Simple vs. secure development setups
- Cost comparison
- Security feature comparison
- When to upgrade from simple to VNet

## 🎯 **Which Guide to Follow?**

1. **New to the project?** → Start with **[../START_HERE.md](../START_HERE.md)**
2. **Corporate/fintech environment?** → Follow **[AZURE_SETUP.md](AZURE_SETUP.md)**
3. **Personal development?** → Follow **[LOCAL_SETUP.md](LOCAL_SETUP.md)**
4. **Need VNet guidance?** → Check **[VNET_REQUIREMENTS.md](VNET_REQUIREMENTS.md)**

## 📚 **Additional Resources**

- **Main Documentation**: [../README.md](../README.md)
- **Architecture Overview**: See main README.md
- **API Examples**: See setup guides above
- **Deployment Scripts**: `../setup-azure.bat` and `../deploy-dev-simple.ps1`

---

**💡 Tip**: Always start with [../START_HERE.md](../START_HERE.md) - it will guide you to the right detailed guide based on your situation!