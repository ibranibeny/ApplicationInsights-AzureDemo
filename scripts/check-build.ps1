$ErrorActionPreference = "SilentlyContinue"
$acr = "acrdemovm6d8zen"
Write-Output "=== Latest ACR build run ==="
az acr task list-runs -r $acr --query "[0].{status:status, finished:finishTime}" -o json
Write-Output "=== webdemo tags ==="
az acr repository show-tags -n $acr --repository webdemo -o tsv
