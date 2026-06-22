param(
    [string]$ResourceGroup = "demo-monitor-rg",
    [string]$AppName       = "appi-demo-web",
    [string]$Workspace     = "log-demo-vm6d8zen"
)
$ErrorActionPreference = "Continue"

Write-Host "=== connection string endpoints (key masked) ===" -ForegroundColor Cyan
$cs = az monitor app-insights component show --app $AppName --resource-group $ResourceGroup --query "connectionString" -o tsv
$cs -replace 'InstrumentationKey=[0-9a-fA-F-]+','InstrumentationKey=***MASKED***'

Write-Host "`n=== Log Analytics workspace customerId ===" -ForegroundColor Cyan
$wsId = az monitor log-analytics workspace show -g $ResourceGroup -n $Workspace --query "customerId" -o tsv
Write-Host "customerId=$wsId"

Write-Host "`n=== direct LA query: AppRequests (last 1h) ===" -ForegroundColor Cyan
az monitor log-analytics query -w $wsId --analytics-query "AppRequests | where TimeGenerated > ago(1h) | summarize count()" -o json

Write-Host "`n=== direct LA query: any table counts (last 1h) ===" -ForegroundColor Cyan
az monitor log-analytics query -w $wsId --analytics-query "union AppRequests, AppExceptions, AppTraces, AppDependencies | where TimeGenerated > ago(1h) | summarize count() by Type" -o json
