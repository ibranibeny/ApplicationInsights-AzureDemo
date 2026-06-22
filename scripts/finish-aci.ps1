# Finish the ACI deployment reusing the already-created resources from deploy-aci.ps1:
#   ACR=acrdemovm6d8zen, App Insights=appi-demo-web, RG=demo-monitor-rg
param(
    [string]$ResourceGroup = "demo-monitor-rg",
    [string]$Location       = "northeurope",
    [string]$AppName        = "appi-demo-web",
    [string]$AcrName        = "acrdemovm6d8zen",
    [string]$DnsName        = "appi-demo-vm6d8zen"
)
$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
Set-Location $root
$image = "webdemo:latest"

Write-Host "==> Rebuilding image in ACR '$AcrName' (Program.cs async fix)..." -ForegroundColor Cyan
az acr build --registry $AcrName --image $image "azure-monitor-demo/src/web"
if ($LASTEXITCODE -ne 0) { Write-Host "DEPLOY_RESULT=FAILED (build)"; exit 1 }

Write-Host "==> Reading App Insights connection string..." -ForegroundColor Cyan
$connString = az monitor app-insights component show --app $AppName --resource-group $ResourceGroup --query "connectionString" -o tsv
if ([string]::IsNullOrWhiteSpace($connString)) { Write-Host "DEPLOY_RESULT=FAILED (no conn string)"; exit 1 }

$acrServer = az acr show -n $AcrName --query "loginServer" -o tsv
$acrUser   = az acr credential show -n $AcrName --query "username" -o tsv
$acrPass   = az acr credential show -n $AcrName --query "passwords[0].value" -o tsv

Write-Host "==> Creating container instance '$AppName'..." -ForegroundColor Cyan
az container create `
    --resource-group $ResourceGroup `
    --name $AppName `
    --image "$acrServer/$image" `
    --cpu 1 --memory 1.5 `
    --os-type Linux `
    --registry-login-server $acrServer `
    --registry-username $acrUser `
    --registry-password $acrPass `
    --dns-name-label $DnsName `
    --ports 8080 `
    --environment-variables "ASPNETCORE_URLS=http://+:8080" `
    --secure-environment-variables "APPLICATIONINSIGHTS_CONNECTION_STRING=$connString" `
    --query "provisioningState" -o tsv
if ($LASTEXITCODE -ne 0) { Write-Host "DEPLOY_RESULT=FAILED (container)"; exit 1 }

$fqdn = az container show -g $ResourceGroup -n $AppName --query "ipAddress.fqdn" -o tsv
Write-Host ""
Write-Host "DEPLOY_RESULT=SUCCESS" -ForegroundColor Green
Write-Host "APP_URL=http://${fqdn}:8080" -ForegroundColor Yellow
Write-Host "Endpoints: /api/health  /api/products  /api/simulate-error  /api/load-test  /api/memory-test" -ForegroundColor Gray
