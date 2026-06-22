# ----------------------------------------------------------------------------
# Deploy the Application Insights demo web app to Azure Container Instances (ACI)
# instead of Azure App Service (which is blocked by dedicated-worker quota=0 on
# this subscription).
#
# Flow:
#   1. Resource group
#   2. Log Analytics workspace
#   3. Workspace-based Application Insights  -> connection string
#   4. Azure Container Registry (Basic)
#   5. az acr build  (builds the Dockerfile in the cloud, no local Docker needed)
#   6. Azure Container Instance running the image, with the App Insights
#      connection string injected as a secure env var.
#
# Requires: Windows Azure CLI logged in (this WSL/PowerShell shell already is).
# ----------------------------------------------------------------------------
param(
    [string]$ResourceGroup = "demo-monitor-rg",
    [string]$Location       = "northeurope",
    [string]$AppName        = "appi-demo-web"
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
Set-Location $root

# Allow dynamic extension install (application-insights) without prompting.
az config set extension.use_dynamic_install=yes_without_prompt --only-show-errors | Out-Null

# Short unique-ish token for globally-unique names (ACR, DNS label).
$token   = -join ((48..57) + (97..122) | Get-Random -Count 8 | ForEach-Object { [char]$_ })
$acrName = "acrdemo$token"                 # ACR: alphanumeric, 5-50 chars
$dnsName = "appi-demo-$token"              # DNS label: unique in region
$image   = "webdemo:latest"
$workspaceName = "log-demo-$token"

Write-Host "==> [1/6] Resource group '$ResourceGroup' ($Location)..." -ForegroundColor Cyan
az group create -n $ResourceGroup -l $Location --query "properties.provisioningState" -o tsv

Write-Host "==> [2/6] Log Analytics workspace '$workspaceName'..." -ForegroundColor Cyan
$workspaceId = az monitor log-analytics workspace create `
    --resource-group $ResourceGroup `
    --workspace-name $workspaceName `
    --location $Location `
    --query "id" -o tsv

Write-Host "==> [3/6] Application Insights '$AppName' (workspace-based)..." -ForegroundColor Cyan
$connString = az monitor app-insights component create `
    --app $AppName `
    --location $Location `
    --resource-group $ResourceGroup `
    --workspace $workspaceId `
    --query "connectionString" -o tsv

if ([string]::IsNullOrWhiteSpace($connString)) {
    Write-Host "ERROR: Failed to obtain App Insights connection string." -ForegroundColor Red
    Write-Host "DEPLOY_RESULT=FAILED"
    exit 1
}

Write-Host "==> [4/6] Container registry '$acrName' (Basic)..." -ForegroundColor Cyan
az acr create `
    --resource-group $ResourceGroup `
    --name $acrName `
    --sku Basic `
    --admin-enabled true `
    --query "provisioningState" -o tsv

Write-Host "==> [5/6] Building image in the cloud (az acr build)..." -ForegroundColor Cyan
az acr build `
    --registry $acrName `
    --image $image `
    "azure-monitor-demo/src/web"
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: az acr build failed." -ForegroundColor Red
    Write-Host "DEPLOY_RESULT=FAILED"
    exit 1
}

$acrServer = az acr show -n $acrName --query "loginServer" -o tsv
$acrUser   = az acr credential show -n $acrName --query "username" -o tsv
$acrPass   = az acr credential show -n $acrName --query "passwords[0].value" -o tsv

Write-Host "==> [6/6] Creating container instance '$AppName'..." -ForegroundColor Cyan
az container create `
    --resource-group $ResourceGroup `
    --name $AppName `
    --image "$acrServer/$image" `
    --cpu 1 --memory 1.5 `
    --os-type Linux `
    --registry-login-server $acrServer `
    --registry-username $acrUser `
    --registry-password $acrPass `
    --dns-name-label $dnsName `
    --ports 8080 `
    --environment-variables "ASPNETCORE_URLS=http://+:8080" `
    --secure-environment-variables "APPLICATIONINSIGHTS_CONNECTION_STRING=$connString" `
    --query "provisioningState" -o tsv
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: az container create failed." -ForegroundColor Red
    Write-Host "DEPLOY_RESULT=FAILED"
    exit 1
}

$fqdn = az container show -g $ResourceGroup -n $AppName --query "ipAddress.fqdn" -o tsv
Write-Host ""
Write-Host "DEPLOY_RESULT=SUCCESS" -ForegroundColor Green
Write-Host "APP_URL=http://${fqdn}:8080" -ForegroundColor Yellow
Write-Host "APP_INSIGHTS=$AppName" -ForegroundColor Yellow
Write-Host "Try: http://${fqdn}:8080/api/health  and  /api/products  and  /api/simulate-error" -ForegroundColor Gray
