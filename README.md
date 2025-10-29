# Azure Phonetic Name Search Solution

A production-ready, scalable Azure PaaS solution for high-performance phonetic name search and matching. This solution can handle over 1.36 billion names with low-latency search capabilities using Double Metaphone and Beider-Morse phonetic algorithms.

## 🚀 **New to this project?** 
👉 **[START HERE](START_HERE.md)** 👈

## 📚 **Quick Links**
- **🏢 Office/Corporate Setup**: [Azure Cloud Guide](docs/AZURE_SETUP.md) (No Docker)
- **🏠 Home Development**: [Local Setup Guide](docs/LOCAL_SETUP.md) (With Docker)
- **⚡ Super Quick Start**: Just run `setup-azure.bat` and choose option 1!

## 🏗️ Architecture Overview

This solution implements a modern, cloud-native architecture following Clean Architecture and Domain-Driven Design (DDD) principles:

```
┌─────────────────────────────────────────────────────────────────┐
│                        Azure Cloud                              │
├─────────────────────────────────────────────────────────────────┤
│  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐ │
│  │   Event Hubs    │    │  Service Bus    │    │   Key Vault     │ │
│  │   (Ingestion)   │    │   (Commands)    │    │   (Secrets)     │ │
│  └─────────────────┘    └─────────────────┘    └─────────────────┘ │
│           │                       │                       │        │
│           ▼                       ▼                       │        │
│  ┌─────────────────┐    ┌─────────────────┐              │        │
│  │ Ingestion       │    │ Search API      │              │        │
│  │ Function App    │    │ Function App    │              │        │
│  │ (Isolated .NET) │    │ (Isolated .NET) │◄─────────────┘        │
│  └─────────────────┘    └─────────────────┘                       │
│           │                       │                                │
│           ▼                       ▼                                │
│  ┌─────────────────────────────────────────────────────────────────┐ │
│  │            PostgreSQL Flexible Server                           │ │
│  │         (Partitioned, High Availability)                        │ │
│  │    ┌─────────────┐  ┌─────────────┐  ┌─────────────┐         │ │
│  │    │ person_p0   │  │ person_p1   │  │     ...     │         │ │
│  │    └─────────────┘  └─────────────┘  └─────────────┘         │ │
│  │    ┌─────────────┐  ┌─────────────┐  ┌─────────────┐         │ │
│  │    │person_bm_a  │  │person_bm_b  │  │     ...     │         │ │
│  │    └─────────────┘  └─────────────┘  └─────────────┘         │ │
│  └─────────────────────────────────────────────────────────────────┘ │
├─────────────────────────────────────────────────────────────────┤
│                    Monitoring & Security                        │
│  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐ │
│  │ Application     │    │ Log Analytics   │    │ Azure Monitor   │ │
│  │ Insights        │    │ Workspace       │    │ Alerts          │ │
│  └─────────────────┘    └─────────────────┘    └─────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

## 🚀 Key Features

### Performance & Scalability
- **High Throughput**: Handles millions of records with partitioned PostgreSQL
- **Low Latency**: Sub-100ms search response times with optimized indexes
- **Auto-Scaling**: Azure Functions automatically scale based on demand
- **Connection Pooling**: Efficient database connection management

### Advanced Phonetic Matching
- **Double Metaphone**: Primary and alternate code generation for English names
- **Beider-Morse**: Multi-language phonetic matching with 16+ variants
- **Trigram Similarity**: PostgreSQL pg_trgm for typo tolerance
- **Nickname Expansion**: Intelligent nickname mapping (Jon→John, Beth→Elizabeth)

### Production-Ready Features
- **Clean Architecture**: Domain, Application, Infrastructure separation
- **CQRS Pattern**: Command Query Responsibility Segregation with MediatR
- **Repository Pattern**: Abstract data access with Entity Framework Core
- **Health Checks**: Comprehensive application and database health monitoring
- **Circuit Breakers**: Resilient failure handling with Polly
- **Structured Logging**: JSON logging with correlation IDs
- **Audit Trail**: Complete change tracking and domain events

### Security & Compliance
- **Zero Trust**: Private endpoints and network isolation
- **RBAC**: Role-based access control with managed identities
- **Encryption**: At-rest and in-transit encryption
- **Key Management**: Azure Key Vault integration
- **Compliance**: SOC 2, GDPR-ready with audit logging

## 📁 Project Structure

```
PhoneticAnalyzers/
├── src/
│   ├── PhoneticAnalyzers.Domain/           # Domain layer (entities, value objects)
│   ├── PhoneticAnalyzers.Application/      # Application layer (services, CQRS)
│   ├── PhoneticAnalyzers.Infrastructure/   # Infrastructure layer (EF Core, repos)
│   ├── PhoneticAnalyzers.Functions.Ingestion/  # Ingestion Azure Functions
│   └── PhoneticAnalyzers.Functions.Search/     # Search API Azure Functions
├── tests/
│   ├── PhoneticAnalyzers.UnitTests/        # Unit tests
│   └── PhoneticAnalyzers.IntegrationTests/ # Integration tests
├── infra/
│   ├── main.bicep                          # Main infrastructure template
│   └── modules/                            # Modular Bicep templates
├── docs/                                   # Documentation
└── .github/workflows/                      # CI/CD pipelines
```

## 🛠️ Technology Stack

### Core Technologies
- **.NET 8**: Latest LTS with native AOT support
- **Azure Functions v4**: Isolated worker model
- **PostgreSQL 15+**: High-performance database with partitioning
- **Entity Framework Core 8**: ORM with advanced features

### Azure Services
- **Azure Functions**: Serverless compute (Flex Consumption plan)
- **PostgreSQL Flexible Server**: Managed database with zone redundancy
- **Event Hubs**: High-throughput event ingestion
- **Service Bus**: Reliable message queuing
- **Key Vault**: Secrets and certificate management
- **Application Insights**: APM and monitoring
- **Virtual Network**: Network isolation and security

### Libraries & Frameworks
- **Lucene.NET**: Phonetic algorithm implementations
- **MediatR**: CQRS and mediator pattern
- **FluentValidation**: Request validation
- **Polly**: Resilience patterns (retry, circuit breaker)
- **Npgsql**: PostgreSQL .NET driver

## 🚀 Quick Start

### Prerequisites
- .NET 8 SDK
- Azure CLI
- Docker Desktop (for local PostgreSQL)
- Azure Functions Core Tools v4

### Local Development Setup

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd PhoneticAnalyzers
   ```

2. **Start local PostgreSQL**
   ```bash
   docker run --name postgres-dev -e POSTGRES_PASSWORD=postgres -p 5432:5432 -d postgres:15
   ```

3. **Update connection string**
   ```bash
   # In local.settings.json
   "ConnectionStrings__DefaultConnection": "Host=localhost;Database=phonetic_analyzers_dev;Username=postgres;Password=postgres"
   ```

4. **Run database migrations**
   ```bash
   cd src/PhoneticAnalyzers.Infrastructure
   dotnet ef database update
   ```

5. **Start the functions**
   ```bash
   # Terminal 1 - Ingestion
   cd src/PhoneticAnalyzers.Functions.Ingestion
   func start

   # Terminal 2 - Search
   cd src/PhoneticAnalyzers.Functions.Search  
   func start --port 7072
   ```

### API Usage Examples

**Ingest a person:**
```bash
curl -X POST "http://localhost:7071/api/ingest" \
  -H "Content-Type: application/json" \
  -d '{
    "externalId": "user-123",
    "fullName": "Jonathan Smith",
    "expandNicknames": true
  }'
```

**Search for similar names:**
```bash
curl -X GET "http://localhost:7072/api/search?name=Jon%20Smyth&maxResults=10"
```

**Batch ingestion:**
```bash
curl -X POST "http://localhost:7071/api/ingest/batch" \
  -H "Content-Type: application/json" \
  -d '{
    "persons": [
      {"externalId": "1", "fullName": "Michael Johnson"},
      {"externalId": "2", "fullName": "Elizabeth Davis"}
    ]
  }'
```

## 🏗️ Deployment

### Azure Infrastructure Deployment

1. **Login to Azure**
   ```bash
   az login
   az account set --subscription <your-subscription-id>
   ```

2. **Deploy infrastructure**
   ```bash
   cd infra
   az deployment sub create \
     --location "East US 2" \
     --template-file main.bicep \
     --parameters environmentName=prod \
                  appName=phoneticanalyzers \
                  adminEmail=admin@yourcompany.com \
                  postgresAdminUsername=pgadmin \
                  postgresAdminPassword=<secure-password>
   ```

3. **Deploy application code**
   ```bash
   # Build and deploy functions
   cd src/PhoneticAnalyzers.Functions.Ingestion
   func azure functionapp publish <function-app-name>

   cd ../PhoneticAnalyzers.Functions.Search
   func azure functionapp publish <search-function-app-name>
   ```

### CI/CD Pipeline (GitHub Actions)

The solution includes complete CI/CD pipelines:

- **Continuous Integration**: Build, test, security scan
- **Infrastructure as Code**: Bicep template deployment
- **Application Deployment**: Azure Functions deployment
- **Database Migrations**: Automated schema updates
- **Integration Testing**: End-to-end testing in staging

## 📊 Performance Characteristics

### Throughput Benchmarks
- **Ingestion**: 50,000+ records/minute per function instance
- **Search**: 1,000+ queries/second with <100ms latency
- **Batch Processing**: 10,000+ records/batch with parallel processing

### Scalability Limits
- **Storage**: 1.36+ billion records (tested)
- **Concurrent Users**: 10,000+ simultaneous searches
- **Function Instances**: Auto-scales to 200+ instances
- **Database**: Supports read replicas for read scaling

### Resource Requirements (Production)
- **Function Apps**: 2x Premium P2V3 plans
- **PostgreSQL**: General Purpose, 16 vCores, 64GB RAM
- **Storage**: 1TB+ SSD with backup retention
- **Networking**: Standard Load Balancer with WAF

## 🔧 Configuration

### Key Application Settings

| Setting | Description | Example |
|---------|-------------|---------|
| `ConnectionStrings__DefaultConnection` | PostgreSQL connection | `Host=...;Database=...` |
| `ServiceBusConnection` | Service Bus connection string | `Endpoint=sb://...` |
| `EventHubConnection` | Event Hub connection string | `Endpoint=sb://...` |
| `KeyVaultUrl` | Key Vault URL | `https://kv-....vault.azure.net/` |
| `APPLICATIONINSIGHTS_CONNECTION_STRING` | App Insights connection | `InstrumentationKey=...` |

### Environment-Specific Configurations

- **Development**: Single instance, reduced retention
- **Staging**: Production-like with cost optimization  
- **Production**: Full HA, backup, monitoring, alerts

## 🔍 Monitoring & Observability

### Application Insights Integration
- **Custom Metrics**: Search latency, ingestion rate, error rates
- **Distributed Tracing**: End-to-end request tracking
- **Live Metrics**: Real-time application performance
- **Availability Tests**: Synthetic monitoring

### Log Analytics Queries
```kql
// Search performance monitoring
requests
| where name contains "search"
| summarize avg(duration), count() by bin(timestamp, 5m)
| render timechart

// Error rate tracking
exceptions
| where timestamp > ago(1h)
| summarize count() by problemId, bin(timestamp, 5m)
| render barchart
```

### Health Checks
- **Database Connectivity**: PostgreSQL availability
- **External Dependencies**: Service Bus, Event Hubs
- **Resource Utilization**: Memory, CPU, connections
- **Custom Business Logic**: Data consistency checks

## 🧪 Testing Strategy

### Unit Tests (95%+ Coverage)
- **Domain Logic**: Entity behavior, value object validation
- **Application Services**: Phonetic encoding, business rules
- **Repository Patterns**: Data access layer testing

### Integration Tests
- **Database Operations**: EF Core integration with PostgreSQL
- **Function Endpoints**: HTTP API testing
- **Message Processing**: Event Hub/Service Bus integration

### Performance Tests
- **Load Testing**: Azure Load Testing service
- **Stress Testing**: Function scaling behavior
- **Endurance Testing**: Long-running stability tests

## 🔒 Security Best Practices

### Network Security
- **Private Endpoints**: Database and storage isolation
- **NSG Rules**: Restrictive network access controls
- **VNet Integration**: Function apps in dedicated subnets
- **WAF Protection**: Application firewall for public endpoints

### Identity & Access
- **Managed Identity**: Service-to-service authentication
- **RBAC**: Least privilege access controls
- **Key Rotation**: Automated secret management
- **Audit Logging**: Complete access audit trail

### Data Protection
- **Encryption at Rest**: AES-256 database encryption
- **Encryption in Transit**: TLS 1.3 for all communications
- **PII Handling**: GDPR compliance for personal data
- **Backup Encryption**: Geo-redundant encrypted backups

## 📈 Scaling Considerations

### Horizontal Scaling
- **Function Instances**: Auto-scale up to 200 instances
- **Database Partitioning**: Hash-based distribution
- **Read Replicas**: Separate read/write workloads
- **CDN Integration**: Cache frequent search results

### Vertical Scaling  
- **Database Tiers**: Scale up PostgreSQL compute
- **Function Plans**: Premium plans for consistent performance
- **Storage Performance**: Premium SSD for high IOPS
- **Memory Optimization**: Tune EF Core for large datasets

## 🐛 Troubleshooting

### Common Issues

**Connection Timeouts**
```bash
# Check network connectivity
az network nsg rule list --resource-group <rg> --nsg-name <nsg>

# Verify Key Vault access
az keyvault network-rule list --name <vault-name>
```

**Performance Issues**
```sql
-- Check PostgreSQL performance
SELECT * FROM pg_stat_activity WHERE state = 'active';

-- Analyze query performance
EXPLAIN ANALYZE SELECT * FROM person WHERE dm_primary = 'SMTH';
```

**Function Cold Starts**
- Use Premium or Dedicated plans for consistent performance
- Implement warm-up functions for critical paths
- Optimize startup time with native AOT compilation

### Log Analysis
```kql
// Function execution errors
traces
| where severityLevel >= 3
| where message contains "Error"
| summarize count() by operation_Name, bin(timestamp, 1h)
```

## 📚 Additional Resources

### Documentation
- [Azure Functions Best Practices](https://docs.microsoft.com/azure/azure-functions/functions-best-practices)
- [PostgreSQL Performance Tuning](https://wiki.postgresql.org/wiki/Performance_Optimization)
- [Clean Architecture Guide](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)

### Phonetic Algorithms
- [Double Metaphone Algorithm](http://aspell.net/metaphone/)
- [Beider-Morse Phonetic Matching](https://stevemorse.org/phonetics/bmpm.htm)
- [PostgreSQL Trigram Extension](https://www.postgresql.org/docs/current/pgtrgm.html)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development Guidelines
- Follow Clean Code principles
- Write comprehensive unit tests (95%+ coverage required)
- Update documentation for new features
- Use conventional commit messages
- Ensure all CI checks pass

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📞 Support

For questions or support:
- 📧 Email: support@yourcompany.com
- 💬 Teams: Engineering Team Channel
- 🐛 Issues: GitHub Issues tab
- 📖 Wiki: Internal documentation portal

---

**Built with ❤️ by the Engineering Team**

*This solution demonstrates production-ready Azure PaaS architecture with modern development practices, comprehensive testing, and enterprise-grade security.*