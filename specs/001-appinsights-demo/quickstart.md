# Quickstart: Azure Monitor & Application Insights Demo

**Feature**: `001-appinsights-demo` | **Date**: 2026-06-22

This quickstart shows both ways to stand up the demo: the **Azure CLI** path
(scripted) and the **Azure portal** path (click-through). Pick one — they produce an
equivalent environment. Upstream project: `mhuescar/azure-monitor-demo` (MIT).

> Honesty note: Exact parameter names and template behavior come from the upstream
> README and Microsoft Learn; confirm them against the vendored repo before a live run.

## Prerequisites

- Azure subscription with permission to create resources.
- Azure CLI installed; PowerShell 5.1+.
- App Insights CLI extension: `az extension add -n application-insights`.

## Parameters (choose once, reuse everywhere)

| Parameter | Example | Notes |
|-----------|---------|-------|
| Subscription | `<subscription>` | `az account set --subscription "<subscription>"` |
| Resource group | `demo-monitor-rg` | Container for single-step teardown |
| Region | `northeurope` | Use a region that offers all SKUs |
| Naming prefix | `aidemo` | Avoids collisions across presenters |

## Option A — Azure CLI (PowerShell)

```powershell
# 1. Authenticate and select subscription
az login
az account set --subscription "<subscription>"

# 2. App Insights CLI extension
az extension add -n application-insights

# 3. Create the resource group
az group create --name demo-monitor-rg --location northeurope

# 4. Deploy the upstream ARM template
az deployment group create `
  --resource-group demo-monitor-rg `
  --template-file azure-monitor-demo/infra/main.json `
  --parameters azure-monitor-demo/infra/main.parameters.json

# 5. Get the App Insights connection string (do NOT commit it)
az monitor app-insights component show `
  --resource-group demo-monitor-rg `
  --app <appinsights-name> --query connectionString -o tsv
```

Then generate traffic and observe (upstream `scripts/demo-final.ps1` /
`generate-traffic.ps1`), and watch **Application Insights → Live Metrics**.

## Option B — Azure Portal

1. **Create a resource → Resource group** → `demo-monitor-rg`, `North Europe`.
2. **Create a resource → Monitoring & Diagnostics → Application Insights** → select the
   resource group/region, name it → **Review + create**.
3. Create an **App Service plan (B1)** + **Web App (Node.js)**.
4. Create **SQL Database (Basic)**, **Storage Account**, and **Functions app**.
5. **App Insights → Overview → Essentials → Connection string** → copy → paste into
   **Web App → Settings → Environment variables** as
   `APPLICATIONINSIGHTS_CONNECTION_STRING`.
6. Deploy the sample app, browse its endpoints, and watch **Live Metrics**.

## Verify (either path)

- Application Insights **Live Metrics** shows requests within ~5 minutes.
- **Application Map** shows the app and its dependencies.
- **Failures** shows exceptions from the `/error` endpoint.

## Teardown

```powershell
# CLI
az group delete --name demo-monitor-rg --yes --no-wait
```

Portal: **Resource groups → demo-monitor-rg → Delete resource group**.

## Cost-bearing resources (delete after the demo)

| Resource | SKU | Approx. cost* |
|----------|-----|---------------|
| App Service | B1 | ~$0.50/day |
| Application Insights (ingestion) | pay-as-you-go | ~$0.10/day |
| SQL Database | Basic | ~$0.15/day |
| Storage Account | Standard | ~$0.01/day |
| Log Analytics workspace | pay-as-you-go | included with ingestion |
| Azure Functions (load gen) | Consumption | minimal |

\* Estimates are from the upstream README (~$0.76/day total) and are **approximate and
not independently verified**. Always tear down after the presentation (Constitution
IV).
