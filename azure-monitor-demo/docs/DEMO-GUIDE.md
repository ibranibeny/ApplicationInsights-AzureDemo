# 🎯 Azure Monitor Demo Guide - Quick Start

## ✅ Deployed Resources
- ✅ Resource Group: `demo-monitor-rg`
- ✅ App Service: `app-bwkinh757hlog`
- ✅ Application Insights: `appi-[unique-id]`
- ✅ Log Analytics Workspace: `log-[unique-id]`
- ✅ SQL Database: `sql-[unique-id]` / `sqldb-[unique-id]`
- ✅ Configured Alerts (3 alerts)

## 🚀 Start Demo NOW (without waiting for code)

### 1. **Open Azure Portal**
```
https://portal.azure.com/#@/resource/subscriptions//resourceGroups/demo-monitor-rg/overview
```

### 2. **Show Deployed Infrastructure**
- Show all resources in the Resource Group
- Explain the architecture: App Service + Application Insights + SQL + Storage

### 3. **Demonstrate Application Insights (ALREADY available)**
1. Click on `Application Insights` resource
2. Go to **"Live Metrics"** - works immediately
3. Show basic server metrics
4. Go to **"Application Map"** - shows dependencies
5. Explore **"Performance"** - infrastructure metrics

### 4. **Azure Monitor - Infrastructure Metrics**
1. From App Service → **"Metrics"**
2. Add metrics:
   - CPU Percentage
   - Memory Percentage  
   - Http Requests
   - Response Time
3. Create real-time charts

### 5. **Preconfigured Alerts**
1. Go to **"Monitor"** → **"Alerts"**
2. Show the 3 preconfigured alerts:
   - High Response Time (>5s)
   - High Error Rate (>10%)
   - High CPU Usage (>80%)

## 🔧 Once the App is ready

### Application URLs:
- **Main**: https://app-bwkinh757hlog.azurewebsites.net
- **Swagger**: https://app-bwkinh757hlog.azurewebsites.net/swagger
- **Health**: https://app-bwkinh757hlog.azurewebsites.net/api/health
- **Products**: https://app-bwkinh757hlog.azurewebsites.net/api/products
- **Errors**: https://app-bwkinh757hlog.azurewebsites.net/api/simulate-error
- **CPU Load**: https://app-bwkinh757hlog.azurewebsites.net/api/load-test
- **Memory**: https://app-bwkinh757hlog.azurewebsites.net/api/memory-test

### Generate Traffic:
```powershell
.\generate-traffic.ps1
```

## 📊 Demo Key Points

### Application Insights:
- ✅ **Live Metrics**: Real-time monitoring
- ✅ **Application Map**: Dependencies visualization
- ✅ **Performance**: Performance analysis
- ✅ **Failures**: Error management
- ✅ **Logs**: Advanced KQL queries

### Azure Monitor:
- ✅ **Metrics Explorer**: Custom metrics
- ✅ **Alerts**: Automatic notifications
- ✅ **Workbooks**: Interactive reports
- ✅ **Dashboards**: Executive visualization

## 🎪 Demo Flow (15-20 min)

1. **Intro** (2 min): Show deployed architecture
2. **Live Metrics** (3 min): Real-time + generate traffic
3. **Application Map** (2 min): Visual dependencies
4. **Performance** (3 min): Latency analysis
5. **Alerts** (2 min): Configuration and triggers
6. **Logs/KQL** (3 min): Advanced queries
7. **Custom Metrics** (2 min): Create dashboards
8. **Q&A** (2 min): Client questions

## ⚡ Emergency Commands

If something fails, you can generate basic metrics:
```powershell
# Verify resources
az resource list -g "demo-monitor-rg" --output table

# View App Service metrics
az monitor metrics list --resource "/subscriptions/[sub-id]/resourceGroups/demo-monitor-rg/providers/Microsoft.Web/sites/app-bwkinh757hlog" --metric "CpuPercentage"

# Restart App Service if needed
az webapp restart -g "demo-monitor-rg" -n "app-bwkinh757hlog"
```

---
🎉 **Everything is ready to impress your clients!**
