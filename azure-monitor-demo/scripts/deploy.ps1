# Azure Monitor Demo Deployment Script
param(
    [Parameter(Mandatory=$true)]
    [string]$ResourceGroupName,
      [Parameter(Mandatory=$true)]
    [string]$Location = "North Europe",
    
    [Parameter(Mandatory=$false)]
    [string]$SubscriptionId
)

# Set subscription if provided
if ($SubscriptionId) {
    Write-Host "Setting subscription to: $SubscriptionId"
    az account set --subscription $SubscriptionId
}

# Create resource group
Write-Host "Creating resource group: $ResourceGroupName in $Location"
az group create --name $ResourceGroupName --location $Location

# Deploy ARM template
Write-Host "Deploying ARM template..."
$deploymentResult = az deployment group create `
    --resource-group $ResourceGroupName `
    --template-file "infra\main.json" `
    --parameters "infra\main.parameters.json" `
    --verbose

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Infrastructure deployment completed successfully!" -ForegroundColor Green
    
    # Parse deployment outputs
    $outputs = $deploymentResult | ConvertFrom-Json
    $webAppUrl = $outputs.properties.outputs.webAppUrl.value
    $appInsightsName = $outputs.properties.outputs.applicationInsightsName.value
    $logWorkspaceName = $outputs.properties.outputs.logAnalyticsWorkspaceName.value
    
    Write-Host "`n📊 Deployment Information:" -ForegroundColor Cyan
    Write-Host "Web App URL: $webAppUrl" -ForegroundColor Yellow
    Write-Host "Application Insights: $appInsightsName" -ForegroundColor Yellow
    Write-Host "Log Analytics Workspace: $logWorkspaceName" -ForegroundColor Yellow
    
    # Build and deploy web app
    Write-Host "`n🚀 Building and deploying web application..." -ForegroundColor Cyan
    Set-Location "src\web"
    
    # Publish the application
    dotnet publish -c Release -o bin\Release\publish
    
    # Create deployment package
    Compress-Archive -Path "bin\Release\publish\*" -DestinationPath "deploy.zip" -Force
    
    # Deploy to Azure App Service
    $webAppName = $outputs.properties.outputs.webAppUrl.value.Replace("https://", "").Replace(".azurewebsites.net", "")
    az webapp deployment source config-zip --resource-group $ResourceGroupName --name $webAppName --src "deploy.zip"
    
    Set-Location "..\..\"
    
    # Build and deploy load test function
    Write-Host "`n⚡ Building and deploying load test function..." -ForegroundColor Cyan
    Set-Location "src\loadtest"
    
    # Publish the function
    dotnet publish -c Release -o bin\Release\publish
    
    # Create deployment package
    Compress-Archive -Path "bin\Release\publish\*" -DestinationPath "deploy.zip" -Force
    
    # Deploy to Azure Functions
    $functionName = ($outputs.properties.outputs | ConvertFrom-Json | Where-Object { $_.PSObject.Properties.Name -like "*function*" }).value
    if (-not $functionName) {
        # Extract function name from ARM template variables
        $functionName = "func-load-" + (Get-Random -Minimum 100000 -Maximum 999999)
    }
    
    az functionapp deployment source config-zip --resource-group $ResourceGroupName --name $functionName --src "deploy.zip"
    
    Set-Location "..\..\"
    
    Write-Host "`n🎉 Deployment completed successfully!" -ForegroundColor Green
    Write-Host "`n📖 Next Steps for your demo:" -ForegroundColor Cyan
    Write-Host "1. Open the web application: $webAppUrl" -ForegroundColor White
    Write-Host "2. Navigate to different endpoints to generate metrics:" -ForegroundColor White
    Write-Host "   - $webAppUrl/api/health" -ForegroundColor Gray
    Write-Host "   - $webAppUrl/api/products" -ForegroundColor Gray
    Write-Host "   - $webAppUrl/api/simulate-error" -ForegroundColor Gray
    Write-Host "   - $webAppUrl/api/load-test" -ForegroundColor Gray
    Write-Host "   - $webAppUrl/api/memory-test" -ForegroundColor Gray
    Write-Host "3. Open Application Insights in Azure Portal to view metrics" -ForegroundColor White
    Write-Host "4. Check Azure Monitor for alerts and dashboards" -ForegroundColor White
    Write-Host "5. Load test function will automatically generate traffic every 5 minutes" -ForegroundColor White
    
} else {
    Write-Host "❌ Infrastructure deployment failed!" -ForegroundColor Red
    exit 1
}
