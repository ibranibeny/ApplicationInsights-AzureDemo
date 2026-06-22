$ErrorActionPreference = "SilentlyContinue"
$acr = "acrdemovm6d8zen"
$runId = az acr task list-runs -r $acr --query "[0].runId" -o tsv
Write-Output "=== Run $runId logs ==="
az acr task logs -r $acr --run-id $runId
