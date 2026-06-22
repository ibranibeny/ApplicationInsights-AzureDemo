# Quick quota probe across candidate regions
$ErrorActionPreference = "SilentlyContinue"
$regions = @("northeurope","westeurope","eastus","uksouth","swedencentral")
foreach ($r in $regions) {
    $row = az vm list-usage -l $r --query "[?localName=='Total Regional vCPUs'].{used:currentValue, limit:limit}" -o json | ConvertFrom-Json
    if ($row) {
        Write-Output ("{0,-16} vCPU used={1} limit={2}" -f $r, $row[0].used, $row[0].limit)
    } else {
        Write-Output ("{0,-16} (no data)" -f $r)
    }
}
