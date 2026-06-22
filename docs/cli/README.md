# Azure CLI Instruction Path — Azure Monitor & Application Insights Demo

Scripted deploy / demo / teardown using the **Azure CLI** (invoked from PowerShell),
per the project constitution (Infrastructure as Code is the source of truth).

This path deploys the adopted upstream project
[`mhuescar/azure-monitor-demo`](https://github.com/mhuescar/azure-monitor-demo) (MIT),
vendored at `../../azure-monitor-demo/`.

> All facts below were confirmed by reading `azure-monitor-demo/infra/main.json`,
> `infra/main.parameters.json`, and `scripts/deploy.ps1`.

## What gets deployed

The ARM template (`azure-monitor-demo/infra/main.json`) creates, in one resource group:

| Resource | Type | SKU / notes |
|----------|------|-------------|
| Log Analytics workspace | `Microsoft.OperationalInsights/workspaces` | PerGB2018, 30-day retention |
| Application Insights | `Microsoft.Insights/components` | **workspace-based** (linked to the workspace above) |
| Storage account | `Microsoft.Storage/storageAccounts` | Standard_LRS |
| SQL Server + Database | `Microsoft.Sql/servers(/databases)` | Basic (5 DTU, 1 GB) |
| App Service plan | `Microsoft.Web/serverfarms` | **B1 (Windows)** |
| Web App | `Microsoft.Web/sites` | hosts the .NET demo app (`src/web`) |
| Functions app (load generator) | `Microsoft.Web/sites` (functionapp) | `dotnet-isolated`, runs every 5 min |
| 2 metric alerts | `Microsoft.Insights/metricAlerts` | High response time (>5 s), high error rate (>10%) |

Resource names are auto-generated from a `resourceToken` (uniqueString), so collisions
are unlikely. The App Insights connection string is injected automatically into the Web
App and Functions app settings as `APPLICATIONINSIGHTS_CONNECTION_STRING` by the
template — it is never stored in source.

## Prerequisites & Authentication

```powershell
# Azure CLI + the Application Insights extension
az version
az extension add -n application-insights   # required for app-insights commands

# Authenticate and select the target subscription (FR-008)
az login
az account set --subscription "<subscription-id-or-name>"
```

You also need **PowerShell 5.1+** and the **.NET SDK** (the upstream `deploy.ps1`
runs `dotnet publish` for the web app and the load-test function).

## Security note (read before deploying)

The SQL administrator **password is intentionally NOT stored** in
`infra/main.parameters.json` (the upstream committed value was removed during adoption
for constitution compliance — no secrets in source). You MUST supply it at deploy time.
Choose a strong password and pass it as a parameter override (below). Do not commit it.

## Deploy

```powershell
# Parameters (choose once)
$rg       = "demo-monitor-rg"
$location = "northeurope"

# 1. Resource group (idempotent)
az group create --name $rg --location $location

# 2. Deploy the ARM template. Supply the SQL admin password at runtime (not committed).
#    Read it securely so it never lands in your shell history / source.
$sqlPwd = Read-Host -AsSecureString "SQL admin password"
$sqlPwdPlain = [System.Net.NetworkCredential]::new('', $sqlPwd).Password

az deployment group create `
  --resource-group $rg `
  --template-file "azure-monitor-demo/infra/main.json" `
  --parameters "azure-monitor-demo/infra/main.parameters.json" `
  --parameters administratorPassword=$sqlPwdPlain
```

ARM deployments are **incremental by default**, so re-running this command with the
same parameters does not create duplicates and reports `Succeeded` (idempotency, SC-004).

### Deploy the application code

The upstream `azure-monitor-demo/scripts/deploy.ps1` performs steps 1–2 above **and**
builds/zips/deploys the .NET web app (`src/web`) and the load-test function
(`src/loadtest`). To use it directly:

```powershell
cd azure-monitor-demo
./scripts/deploy.ps1 -ResourceGroupName demo-monitor-rg -Location "North Europe" -SubscriptionId "<subscription-id>"
```

> The script will prompt for the SQL admin password via the ARM deployment because the
> parameters file no longer contains it.

## Get the Application Insights connection string (do NOT commit it)

```powershell
$appi = az monitor app-insights component show `
  --resource-group $rg `
  --query "[0].name" -o tsv         # discover the auto-generated appi-* name

az monitor app-insights component show `
  --resource-group $rg --app $appi `
  --query connectionString -o tsv
```

The template already wires this value into the Web App settings, so the app is
instrumented on first boot.

## Verify telemetry (SC-003)

1. Open the Web App URL (printed by `deploy.ps1`) and hit a few endpoints:
   `/api/health`, `/api/products`, `/api/simulate-error`, `/api/load-test`,
   `/api/memory-test`.
2. In the portal, open the **Application Insights** resource → **Live Metrics**.
   Requests should appear within ~5 minutes.
3. If nothing appears: confirm the Web App has the
   `APPLICATIONINSIGHTS_CONNECTION_STRING` app setting
   (`az webapp config appsettings list -g $rg -n <webapp>`), then re-generate traffic.

## Edge cases

- **Wrong/unauthenticated subscription** → run `az login` and `az account set` before
  any create step.
- **Resource-name collision** → names are derived from `uniqueString(...)`, so this is
  rare; if a deployment conflict occurs, ARM reuses matching resources (incremental)
  or fails with a clear message — it does not leave a silent partial state.
- **Region without a required SKU** → the deployment errors out naming the resource;
  pick a region that offers B1 App Service + Basic SQL (e.g. `northeurope`,
  `westeurope`, `eastus`). List regions with `az account list-locations -o table`.

## Teardown (FR-006, SC-005)

```powershell
az group delete --name demo-monitor-rg --yes --no-wait

# Verify nothing remains
az group exists --name demo-monitor-rg   # expect: false (after deletion completes)
```

## Demo walkthrough

See [demo walkthrough](../demo-walkthrough.md) for the suggested 15-minute flow
(Live Metrics → Application Map → Failures → Logs). Load is also generated
automatically every 5 minutes by the deployed Functions app, and on demand via
`azure-monitor-demo/scripts/generate-traffic.ps1`.
