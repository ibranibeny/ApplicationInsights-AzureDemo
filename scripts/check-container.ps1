param(
    [string]$ResourceGroup = "demo-monitor-rg",
    [string]$AppName       = "appi-demo-web"
)
$ErrorActionPreference = "Continue"

Write-Host "=== container state ===" -ForegroundColor Cyan
az container show -g $ResourceGroup -n $AppName --query "{state:instanceView.currentState.state, restarts:containers[0].instanceView.restartCount, image:containers[0].image}" -o json

Write-Host "`n=== APPLICATIONINSIGHTS_CONNECTION_STRING present? (secure vars are hidden, check non-secure env) ===" -ForegroundColor Cyan
az container show -g $ResourceGroup -n $AppName --query "containers[0].environmentVariables[].name" -o json

Write-Host "`n=== container logs (last) ===" -ForegroundColor Cyan
az container logs -g $ResourceGroup -n $AppName
