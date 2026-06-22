# Verifies the mesh telemetry: lists the distinct cloud role names (= Application Map
# nodes) and the inter-service dependency edges captured in the last 30 minutes.
param(
    [string]$ResourceGroup = "demo-monitor-rg",
    [string]$Workspace     = "log-demo-vm6d8zen"
)
$ErrorActionPreference = "Stop"

$cid = az monitor log-analytics workspace show --resource-group $ResourceGroup --workspace-name $Workspace --query "customerId" -o tsv
if ([string]::IsNullOrWhiteSpace($cid)) { Write-Host "VERIFY=FAILED (no workspace)"; exit 1 }

Write-Host "==> Application Map nodes (distinct cloud role names, last 30m):" -ForegroundColor Cyan
$nodesQuery = 'AppRequests | where TimeGenerated > ago(30m) | summarize Requests=count() by AppRoleName | order by AppRoleName asc'
az monitor log-analytics query -w $cid --analytics-query $nodesQuery -o table

Write-Host ""
Write-Host "==> Inter-service edges (caller role -> dependency target, last 30m):" -ForegroundColor Cyan
$edgesQuery = 'AppDependencies | where TimeGenerated > ago(30m) | summarize Calls=count() by AppRoleName, DependencyType, Target | order by AppRoleName asc'
az monitor log-analytics query -w $cid --analytics-query $edgesQuery -o table

Write-Host ""
Write-Host "VERIFY=DONE" -ForegroundColor Green
