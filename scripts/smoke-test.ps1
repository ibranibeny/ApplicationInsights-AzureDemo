$ErrorActionPreference = "SilentlyContinue"
$fqdn = az container show -g demo-monitor-rg -n appi-demo-web --query "ipAddress.fqdn" -o tsv
Write-Output "FQDN=$fqdn"
$base = "http://${fqdn}:8080"
Write-Output "=== GET $base/api/health ==="
try { (Invoke-WebRequest -Uri "$base/api/health" -TimeoutSec 30 -UseBasicParsing).Content } catch { "HEALTH_ERROR: $($_.Exception.Message)" }
Write-Output ""
Write-Output "=== GET $base/api/products ==="
try { (Invoke-WebRequest -Uri "$base/api/products" -TimeoutSec 30 -UseBasicParsing).Content } catch { "PRODUCTS_ERROR: $($_.Exception.Message)" }
Write-Output ""
Write-Output "=== Generate traffic (15 mixed requests) ==="
$paths = @("/api/health","/api/products","/api/simulate-error","/api/load-test","/api/memory-test")
for ($i=0; $i -lt 15; $i++) {
    $p = $paths | Get-Random
    try { $r = Invoke-WebRequest -Uri "$base$p" -TimeoutSec 30 -UseBasicParsing; Write-Output ("{0} -> {1}" -f $p, $r.StatusCode) }
    catch { Write-Output ("{0} -> ERR {1}" -f $p, $_.Exception.Response.StatusCode.value__) }
}
