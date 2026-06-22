# Drives the mesh: repeatedly calls the gateway's /api/call, which cascades through all
# five services and produces correlated requests + dependencies for the Application Map.
param(
    [Parameter(Mandatory = $true)][string]$GatewayUrl,
    [int]$Count = 40
)
$ErrorActionPreference = "Continue"
$ok = 0; $fail = 0
for ($i = 1; $i -le $Count; $i++) {
    try {
        $r = Invoke-WebRequest -Uri "$GatewayUrl/api/call" -UseBasicParsing -TimeoutSec 60
        if ($r.StatusCode -eq 200) { $ok++ } else { $fail++ }
        Write-Host "[$i/$Count] $($r.StatusCode)" -ForegroundColor Green
    }
    catch {
        $fail++
        Write-Host "[$i/$Count] ERROR $($_.Exception.Message)" -ForegroundColor Red
    }
    Start-Sleep -Milliseconds 400
}
Write-Host "TRAFFIC_DONE ok=$ok fail=$fail" -ForegroundColor Yellow
