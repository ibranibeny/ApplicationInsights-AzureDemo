# Check ACI + ACR feasibility on the subscription
$ErrorActionPreference = "SilentlyContinue"
Write-Output "=== Subscription ==="
az account show --query "name" -o tsv

Write-Output "=== Microsoft.ContainerInstance registered? ==="
az provider show -n Microsoft.ContainerInstance --query "registrationState" -o tsv

Write-Output "=== Microsoft.ContainerRegistry registered? ==="
az provider show -n Microsoft.ContainerRegistry --query "registrationState" -o tsv

Write-Output "=== ACI usage in northeurope ==="
az container list --query "length(@)" -o tsv 2>$null
