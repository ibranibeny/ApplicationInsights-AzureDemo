# Deploy a 5-service mesh on Azure Container Instances so the Application Map shows a
# multi-node distributed topology (like the Microsoft Learn overview screenshot).
#
# Topology (gateway calls two branches, each branch has its own downstream):
#
#   svc-gateway ─┬─> svc-orders  ──> svc-payments
#                └─> svc-catalog ──> svc-inventory
#
# All five share ONE Application Insights resource but report distinct cloud role names,
# so they render as five connected nodes on the map. Inter-service HTTP calls become
# dependencies + correlated requests (the edges).
param(
    [string]$ResourceGroup = "demo-monitor-rg",
    [string]$Location       = "northeurope",
    [string]$AcrName        = "acrdemovm6d8zen",
    [string]$AppInsights    = "appi-demo-web",
    [string]$Image          = "webdemo:latest"
)
$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
Set-Location $root

# Short random token to keep DNS labels globally unique.
$token = -join ((48..57) + (97..122) | Get-Random -Count 6 | ForEach-Object { [char]$_ })
$region = $Location.ToLower()

Write-Host "==> Rebuilding image in ACR '$AcrName' (adds /api/call + role-name initializer)..." -ForegroundColor Cyan
az acr build --registry $AcrName --image $Image "azure-monitor-demo/src/web"
if ($LASTEXITCODE -ne 0) { Write-Host "MESH_RESULT=FAILED (build)"; exit 1 }

Write-Host "==> Reading App Insights connection string..." -ForegroundColor Cyan
$conn = az monitor app-insights component show --app $AppInsights --resource-group $ResourceGroup --query "connectionString" -o tsv
if ([string]::IsNullOrWhiteSpace($conn)) { Write-Host "MESH_RESULT=FAILED (no conn string)"; exit 1 }

$acrServer = az acr show -n $AcrName --query "loginServer" -o tsv
$acrUser   = az acr credential show -n $AcrName --query "username" -o tsv
$acrPass   = az acr credential show -n $AcrName --query "passwords[0].value" -o tsv

function New-Url([string]$label) { "http://$label.$region.azurecontainer.io:8080" }

# Define the five services. DNS labels are deterministic so we can wire downstream URLs
# up front without querying each container after creation.
$svc = @{
    inventory = "svc-inventory-$token"
    payments  = "svc-payments-$token"
    catalog   = "svc-catalog-$token"
    orders    = "svc-orders-$token"
    gateway   = "svc-gateway-$token"
}

# name -> @{ role; label; downstream(csv of base urls) }. Deploy leaves first.
$plan = @(
    @{ key = "inventory"; role = "svc-inventory"; down = "" }
    @{ key = "payments";  role = "svc-payments";  down = "" }
    @{ key = "catalog";   role = "svc-catalog";   down = (New-Url $svc.inventory) }
    @{ key = "orders";    role = "svc-orders";    down = (New-Url $svc.payments) }
    @{ key = "gateway";   role = "svc-gateway";   down = ((New-Url $svc.orders) + "," + (New-Url $svc.catalog)) }
)

foreach ($s in $plan) {
    $label = $svc[$s.key]
    Write-Host "==> Creating $($s.role) ($label)..." -ForegroundColor Cyan
    $envVars = @(
        "ASPNETCORE_URLS=http://+:8080",
        "ASPNETCORE_ENVIRONMENT=Production",
        "SERVICE_ROLE_NAME=$($s.role)"
    )
    if (-not [string]::IsNullOrWhiteSpace($s.down)) { $envVars += "DOWNSTREAM_SERVICES=$($s.down)" }

    az container create `
        --resource-group $ResourceGroup `
        --name $($s.role) `
        --image "$acrServer/$Image" `
        --cpu 1 --memory 1.5 `
        --os-type Linux `
        --registry-login-server $acrServer `
        --registry-username $acrUser `
        --registry-password $acrPass `
        --dns-name-label $label `
        --ports 8080 `
        --environment-variables $envVars `
        --secure-environment-variables "APPLICATIONINSIGHTS_CONNECTION_STRING=$conn" `
        --query "provisioningState" -o tsv
    if ($LASTEXITCODE -ne 0) { Write-Host "MESH_RESULT=FAILED (create $($s.role))"; exit 1 }
}

$gatewayUrl = New-Url $svc.gateway
Write-Host ""
Write-Host "MESH_RESULT=SUCCESS" -ForegroundColor Green
Write-Host "GATEWAY_URL=$gatewayUrl" -ForegroundColor Yellow
Write-Host "Drive the mesh:  curl `"$gatewayUrl/api/call`"" -ForegroundColor Gray
Write-Host "Services: svc-gateway -> (svc-orders -> svc-payments), (svc-catalog -> svc-inventory)" -ForegroundColor Gray
