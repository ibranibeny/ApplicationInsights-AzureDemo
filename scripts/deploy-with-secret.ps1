param(
    [string]$ResourceGroup = "demo-monitor-rg",
    [string]$Location = "northeurope"
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
Set-Location $root

$secretFile = Join-Path $root ".secrets\sqlpass.txt"

if (-not (Test-Path $secretFile)) {
    Write-Host "ERROR: .secrets\sqlpass.txt not found. Create it with your SQL admin password (one line)." -ForegroundColor Red
    exit 1
}

$pwdPlain = (Get-Content -Raw $secretFile).Trim()
if ([string]::IsNullOrWhiteSpace($pwdPlain)) {
    Write-Host "ERROR: .secrets\sqlpass.txt is empty." -ForegroundColor Red
    exit 1
}

Write-Host "==> Ensuring resource group '$ResourceGroup' in '$Location'..." -ForegroundColor Cyan
az group create -n $ResourceGroup -l $Location --query "properties.provisioningState" -o tsv

Write-Host "==> Starting ARM deployment 'appinsights-demo' (this can take several minutes)..." -ForegroundColor Cyan
az deployment group create `
    --resource-group $ResourceGroup `
    --template-file "azure-monitor-demo/infra/main.json" `
    --parameters "azure-monitor-demo/infra/main.parameters.json" `
    --parameters administratorPassword=$pwdPlain `
    --name "appinsights-demo" `
    --query "{state:properties.provisioningState, error:properties.error}" -o json

$exit = $LASTEXITCODE

# Always remove the plaintext secret after the attempt
Remove-Item $secretFile -Force -ErrorAction SilentlyContinue
Write-Host "==> Removed .secrets\sqlpass.txt" -ForegroundColor DarkGray

if ($exit -eq 0) {
    Write-Host "DEPLOY_RESULT=SUCCESS" -ForegroundColor Green
} else {
    Write-Host "DEPLOY_RESULT=FAILED (exit $exit)" -ForegroundColor Red
}
exit $exit
