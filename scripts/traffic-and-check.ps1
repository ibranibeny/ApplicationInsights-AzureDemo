$ErrorActionPreference = "SilentlyContinue"
$fqdn = az container show -g demo-monitor-rg -n appi-demo-web --query "ipAddress.fqdn" -o tsv
$base = "http://${fqdn}:8080"
$paths = @("/api/health","/api/products","/api/simulate-error","/api/load-test","/api/memory-test")
Write-Output "=== generating 40 requests ==="
for ($i=0; $i -lt 40; $i++) {
    $p = $paths | Get-Random
    try { Invoke-WebRequest -Uri "$base$p" -TimeoutSec 30 -UseBasicParsing | Out-Null } catch {}
}
Write-Output "done generating"

$appId = az monitor app-insights component show --app appi-demo-web --resource-group demo-monitor-rg --query "appId" -o tsv
Write-Output "=== union of all telemetry (last 30m) ==="
az monitor app-insights query --app $appId --analytics-query "union requests, dependencies, exceptions, traces, customEvents, customMetrics | where timestamp > ago(30m) | summarize count() by itemType | order by count_ desc" -o table
