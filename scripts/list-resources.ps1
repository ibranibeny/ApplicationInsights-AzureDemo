param([string]$ResourceGroup = "demo-monitor-rg")
$ErrorActionPreference = "Continue"
Write-Host "=== resources in $ResourceGroup ===" -ForegroundColor Cyan
az resource list -g $ResourceGroup --query "[].{name:name, type:type, location:location}" -o table
