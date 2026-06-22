# 🚀 Azure Monitor & Application Insights Demo

A complete demonstration environment for Azure Monitor and Application Insights that includes infrastructure as code, applications with integrated telemetry, and automation scripts.

## 📋 Project Description

This project demonstrates the complete capabilities of Azure Monitor and Application Insights through:

- **Infrastructure as Code (ARM Templates)**: Automated deployment of all Azure resources
- **Web Application with Telemetry**: Node.js + Express with integrated Application Insights  
- **Automatic Load Generation**: Azure Functions to maintain constant traffic
- **Alerts and Monitoring**: Complete proactive alerts configuration
- **Demo Scripts**: Automation for live presentations

## 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   App Service   │    │ Application     │    │  Log Analytics  │
│   (Node.js)     │───▶│   Insights      │───▶│   Workspace     │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│  SQL Database   │    │   Azure         │    │  Storage        │
│                 │    │   Functions     │    │  Account        │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```


## ✨ Features

### 🎯 Demo Application
- **Interactive Dashboard**: Modern interface with real-time metrics
- **RESTful API**: Endpoints to generate different types of telemetry
- **Error Simulation**: Controlled exception generation
- **Load Testing**: Performance testing endpoints
- **Health Checks**: Automatic health monitoring

### 📊 Complete Telemetry
- **Request Tracking**: All HTTP requests with timing
- **Exception Tracking**: Error capture and analysis
- **Dependency Tracking**: External calls monitoring
- **Custom Metrics**: Specific business metrics
- **Custom Events**: Custom application events

### 🚨 Configured Alerts
- **High Response Time**: Latency > 2000ms
- **Error Rate**: Error rate > 10%
- **High CPU Usage**: CPU > 80%

## 🚀 Quick Start

### Prerequisites
- Azure CLI installed and configured
- PowerShell 5.1 or higher
- Active Azure subscription

### 1. Clone Repository
```bash
git clone <repository-url>
cd azure-monitor-demo
```

### 2. Configure Variables
```powershell
# Edit parameters in infra/main.parameters.json
$resourceGroup = "demo-monitor-rg"
$location = "North Europe"
```

### 3. Deploy Infrastructure
```powershell
# Run deployment script
.\scripts\deploy.ps1
```

### 4. Verify Operation
```powershell
# Run environment tests
.\scripts\demo-final.ps1
```

## 📁 Project Structure

```
azure-monitor-demo/
├── 📁 infra/                     # Infrastructure as Code
│   ├── main.json                 # Main ARM Template
│   └── main.parameters.json      # Configuration parameters
├── 📁 src/                       # Source code
│   ├── 📁 webapp-simple/         # Node.js Application
│   │   ├── server.js             # Express server with AI
│   │   ├── package.json          # Node.js dependencies
│   │   └── web.config            # IIS configuration
│   ├── 📁 web/                   # .NET Application (alternative)
│   └── 📁 loadtest/              # Azure Functions for load
├── 📁 scripts/                   # Utility scripts
│   ├── deploy.ps1               # Deployment script
│   ├── demo-final.ps1           # Demo script
│   └── generate-traffic.ps1     # Traffic generator
└── 📁 docs/                     # Documentation
    ├── DEMO-GUIDE.md            # Demo guide
    └── DEPLOYMENT.md            # Deployment guide
```

## 🎯 Application Endpoints

### API Endpoints
- **GET /** - Main dashboard with interactive UI
- **GET /health** - Health check with system metrics
- **GET /api/products** - Products API with DB simulation
- **GET /error** - Controlled error generation
- **GET /load?iterations=N** - CPU load test
- **GET /memory?size=N** - Memory consumption test
- **GET /dependencies** - External dependencies simulation

### Generated Telemetry
Each endpoint generates specific telemetry:
- Request timing and response codes
- Custom events for business analysis
- Custom metrics for KPIs
- Exception tracking with full context
- Simulated dependency tracking

## 📊 Monitoring and Alerts

### Automatic Metrics
- **HTTP Requests**: Count and timing of all requests
- **Response Times**: Application latency
- **Error Rates**: 4xx/5xx error percentage
- **CPU/Memory**: Server resource usage
- **Dependencies**: External calls performance

### Custom Metrics
- `Health_Check_Duration`: Health checks timing
- `Products_API_Duration`: Products API latency
- `Load_Test_Duration`: Load tests duration
- `Memory_Usage_Delta`: Memory usage changes
- `Error_Count`: Error count by type

### Custom Events
- `HomePage_Visited`: Dashboard visits
- `Products_API_Called`: API calls
- `Error_Generated`: Simulated errors
- `Load_Test_Started`: Load test start
- `Application_Started`: Application startup

## 🎪 Demo Guide

### Preparation (5 minutes)
1. Verify all resources are deployed
2. Run `.\demo-final.ps1` to generate initial traffic
3. Open Azure Portal in Application Insights

### Live Demo (15 minutes)
1. **Show application working** (3 min)
   - Navigate through dashboard
   - Test different endpoints
   - Generate errors and load

2. **Real-time Application Insights** (5 min)
   - Live Metrics Stream
   - Application Map
   - Performance metrics

3. **Telemetry analysis** (4 min)
   - Exception tracking
   - Custom events and metrics
   - Log Analytics queries

4. **Alerts and monitoring** (3 min)
   - Show configured alerts
   - Explain thresholds and actions

## 💰 Cost Estimation

For a demo environment (24 hours):
- **App Service (B1)**: ~$0.50/day
- **Application Insights**: ~$0.10/day  
- **SQL Database (Basic)**: ~$0.15/day
- **Storage Account**: ~$0.01/day
- **Total**: ~$0.76/day

## 🧹 Resource Cleanup

To delete all resources after demo:
```powershell
az group delete --name demo-monitor-rg --yes --no-wait
```

## 🔧 Troubleshooting

### Application not responding
```powershell
# Check status
az webapp show --name <app-name> --resource-group <rg> --query "state"

# Restart if needed
az webapp restart --name <app-name> --resource-group <rg>
```

### No data in Application Insights
```powershell
# Generate test traffic
.\scripts\demo-final.ps1

# Verify connection string
az webapp config appsettings list --name <app-name> --resource-group <rg>
```

## 📖 Additional Documentation

- [Demo Guide](docs/DEMO-GUIDE.md)
- [Deployment Guide](docs/DEPLOYMENT.md)
- [Final Summary](docs/DEMO-READY-FINAL.md)
- [Contributing Guide](CONTRIBUTING.md)

## 🤝 Contributing

Contributions are welcome. Please:
1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## 📄 License

This project is under the MIT License. See [LICENSE](LICENSE) for more details.

## 🏷️ Tags

`azure` `monitor` `application-insights` `telemetry` `demo` `arm-templates` `nodejs` `express` `infrastructure-as-code` `devops`

---

**Built with ❤️ to demonstrate Azure Monitor capabilities**
