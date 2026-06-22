# Verify telemetry ingestion into the workspace-based Application Insights component
# by querying the backing Log Analytics workspace directly (AppRequests/AppExceptions/...).
# NOTE: the classic `az monitor app-insights query` (requests/exceptions schema) can return
# empty for workspace-based components; querying the workspace tables is the reliable path.
param(
    [string]$ResourceGroup = "demo-monitor-rg",
    [string]$AppName       = "appi-demo-web",
    [string]$Workspace     = "log-demo-vm6d8zen",
    [string]$Lookback      = "30m"
)
$ErrorActionPreference = "Continue"

$wsId = az monitor log-analytics workspace show -g $ResourceGroup -n $Workspace --query "customerId" -o tsv
Write-Output "WorkspaceCustomerId=$wsId"

Write-Output "=== telemetry counts (last $Lookback) ==="
az monitor log-analytics query -w $wsId --analytics-query "union AppRequests, AppExceptions, AppTraces, AppDependencies, AppCustomEvents | where TimeGenerated > ago($Lookback) | summarize count() by Type | order by count_ desc" -o table

Write-Output "=== request result codes (last $Lookback) ==="
az monitor log-analytics query -w $wsId --analytics-query "AppRequests | where TimeGenerated > ago($Lookback) | summarize count() by ResultCode | order by count_ desc" -o table

Write-Output "=== recent exceptions (last $Lookback) ==="
az monitor log-analytics query -w $wsId --analytics-query "AppExceptions | where TimeGenerated > ago($Lookback) | project TimeGenerated, ProblemId, OuterMessage | take 10" -o table
