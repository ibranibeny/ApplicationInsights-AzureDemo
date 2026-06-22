# Test Script for Azure Monitor Demo Environment
Write-Host "🧪 Testing Azure Monitor Demo Environment" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan

# Get web app information
Write-Host "`n🔍 Getting deployment information..." -ForegroundColor Yellow
$webApps = az webapp list --resource-group "demo-monitor-rg" --query "[].{name:name, url:defaultHostName}" --output json | ConvertFrom-Json

if ($webApps.Count -gt 0) {
    $webApp = $webApps | Where-Object { $_.name -notlike "*func-load*" } | Select-Object -First 1
    $functionApp = $webApps | Where-Object { $_.name -like "*func-load*" } | Select-Object -First 1
    
    if ($webApp) {
        $webAppUrl = "https://$($webApp.url)"
        Write-Host "✅ Web App found: $($webApp.name)" -ForegroundColor Green
        Write-Host "🌐 URL: $webAppUrl" -ForegroundColor Green
        
        # Test the endpoints
        Write-Host "`n🚀 Testing application endpoints..." -ForegroundColor Yellow
        
        $endpoints = @(
            @{Name="Health Check"; Path="/api/health"},
            @{Name="Products API"; Path="/api/products"},
            @{Name="Swagger UI"; Path="/swagger"}
        )
        
        foreach ($endpoint in $endpoints) {
            try {
                Write-Host "Testing $($endpoint.Name): $webAppUrl$($endpoint.Path)" -ForegroundColor White
                $response = Invoke-WebRequest -Uri "$webAppUrl$($endpoint.Path)" -Method GET -TimeoutSec 30
                if ($response.StatusCode -eq 200) {
                    Write-Host "  ✅ $($endpoint.Name) - Status: $($response.StatusCode)" -ForegroundColor Green
                } else {
                    Write-Host "  ⚠️ $($endpoint.Name) - Status: $($response.StatusCode)" -ForegroundColor Yellow
                }
            }
            catch {
                Write-Host "  ❌ $($endpoint.Name) - Error: $($_.Exception.Message)" -ForegroundColor Red
            }
        }
        
        # Generate some test traffic
        Write-Host "`n🔄 Generating test traffic for metrics..." -ForegroundColor Yellow
        
        $testEndpoints = @("/api/health", "/api/products", "/api/simulate-error")
        
        for ($i = 1; $i -le 10; $i++) {
            $endpoint = $testEndpoints | Get-Random
            try {
                $response = Invoke-WebRequest -Uri "$webAppUrl$endpoint" -Method GET -TimeoutSec 10
                Write-Host "  Request $i to $endpoint - Status: $($response.StatusCode)" -ForegroundColor Gray
            }
            catch {
                Write-Host "  Request $i to $endpoint - Error (expected for simulate-error)" -ForegroundColor Gray
            }
            Start-Sleep -Milliseconds 500
        }
        
        Write-Host "`n📊 Demo URLs for your presentation:" -ForegroundColor Cyan
        Write-Host "=================================" -ForegroundColor Cyan
        Write-Host "🌐 Main Application: $webAppUrl" -ForegroundColor White
        Write-Host "📋 Swagger UI: $webAppUrl/swagger" -ForegroundColor White
        Write-Host "❤️ Health Check: $webAppUrl/api/health" -ForegroundColor White
        Write-Host "📦 Products API: $webAppUrl/api/products" -ForegroundColor White
        Write-Host "💥 Simulate Errors: $webAppUrl/api/simulate-error" -ForegroundColor White
        Write-Host "🔥 Load Test: $webAppUrl/api/load-test" -ForegroundColor White
        Write-Host "💾 Memory Test: $webAppUrl/api/memory-test" -ForegroundColor White
        
        # Get Application Insights information
        Write-Host "`n📈 Azure Monitor Resources:" -ForegroundColor Cyan
        Write-Host "============================" -ForegroundColor Cyan
        
        $appInsights = az monitor app-insights component show --resource-group "demo-monitor-rg" --query "[0].{name:name, appId:appId}" --output json | ConvertFrom-Json
        if ($appInsights) {
            Write-Host "📊 Application Insights: $($appInsights.name)" -ForegroundColor White
            Write-Host "🔍 App ID: $($appInsights.appId)" -ForegroundColor Gray
        }
        
        Write-Host "`n🎯 Next Steps for your demo:" -ForegroundColor Cyan
        Write-Host "=============================" -ForegroundColor Cyan
        Write-Host "1. Open Azure Portal: https://portal.azure.com" -ForegroundColor White
        Write-Host "2. Navigate to Resource Group: demo-monitor-rg" -ForegroundColor White
        Write-Host "3. Open Application Insights resource" -ForegroundColor White
        Write-Host "4. Use the URLs above to generate traffic" -ForegroundColor White
        Write-Host "5. Show Live Metrics, Application Map, and Logs" -ForegroundColor White
        
    } else {
        Write-Host "❌ No web app found in the resource group" -ForegroundColor Red
    }
} else {
    Write-Host "❌ No web apps found in resource group 'demo-monitor-rg'" -ForegroundColor Red
    Write-Host "Please verify that the deployment completed successfully." -ForegroundColor Yellow
}

Write-Host "`n🎉 Environment test completed!" -ForegroundColor Green
