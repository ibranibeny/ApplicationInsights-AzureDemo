# Script to generate test traffic to the application
param(
    [Parameter(Mandatory=$false)]
    [string]$AppUrl = "https://app-bwkinh757hlog.azurewebsites.net"
)

Write-Host "🚀 Generating traffic to: $AppUrl" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# Available endpoints once the app is running
$endpoints = @(
    @{Name="Home/Swagger"; Path="/"},
    @{Name="Health Check"; Path="/api/health"},
    @{Name="Products API"; Path="/api/products"},
    @{Name="Simulate Error"; Path="/api/simulate-error"},
    @{Name="Load Test"; Path="/api/load-test"},
    @{Name="Memory Test"; Path="/api/memory-test"}
)

Write-Host "`n🔍 Checking if application is available..." -ForegroundColor Yellow

try {
    $response = Invoke-WebRequest -Uri $AppUrl -Method GET -TimeoutSec 10
    if ($response.StatusCode -eq 200) {
        Write-Host "✅ Application available!" -ForegroundColor Green
        
        # Generate test traffic
        Write-Host "`n🔄 Generating test traffic..." -ForegroundColor Yellow
        
        for ($i = 1; $i -le 30; $i++) {
            $endpoint = $endpoints | Get-Random
            $url = "$AppUrl$($endpoint.Path)"
            
            try {
                $response = Invoke-WebRequest -Uri $url -Method GET -TimeoutSec 10
                Write-Host "  [$i/30] $($endpoint.Name) - Status: $($response.StatusCode)" -ForegroundColor Green
            }
            catch {
                Write-Host "  [$i/30] $($endpoint.Name) - Error: $($_.Exception.Message)" -ForegroundColor Yellow
            }
            
            Start-Sleep -Milliseconds 500
        }
        
        Write-Host "`n✅ Tráfico generado exitosamente!" -ForegroundColor Green
        Write-Host "`n📊 Ahora puedes:" -ForegroundColor Cyan
        Write-Host "1. Abrir Azure Portal → Resource Group: demo-monitor-rg" -ForegroundColor White
        Write-Host "2. Ir a Application Insights" -ForegroundColor White
        Write-Host "3. Ver Live Metrics" -ForegroundColor White
        Write-Host "4. Explorar métricas y logs" -ForegroundColor White
        
    } else {
        Write-Host "⚠️ Aplicación responde con código: $($response.StatusCode)" -ForegroundColor Yellow
    }
}
catch {
    Write-Host "❌ Aplicación aún no disponible: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "`n💡 Posibles razones:" -ForegroundColor Yellow
    Write-Host "1. El despliegue aún está en proceso" -ForegroundColor White
    Write-Host "2. La aplicación está arrancando" -ForegroundColor White
    Write-Host "3. Problemas de compilación" -ForegroundColor White
    
    Write-Host "`n🔧 Mientras tanto, puedes:" -ForegroundColor Cyan
    Write-Host "1. Verificar logs en Azure Portal → App Service → Log stream" -ForegroundColor White
    Write-Host "2. Revisar métricas básicas de infraestructura" -ForegroundColor White
    Write-Host "3. Configurar Application Insights" -ForegroundColor White
}

Write-Host "`n🌐 URLs para tu demo:" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "App URL: $AppUrl" -ForegroundColor White
Write-Host "Swagger: $AppUrl/swagger" -ForegroundColor White
Write-Host "Health: $AppUrl/api/health" -ForegroundColor White
Write-Host "Products: $AppUrl/api/products" -ForegroundColor White
Write-Host "Errors: $AppUrl/api/simulate-error" -ForegroundColor White
Write-Host "Load Test: $AppUrl/api/load-test" -ForegroundColor White
Write-Host "Memory Test: $AppUrl/api/memory-test" -ForegroundColor White

Write-Host "`n🎯 Para abrir Azure Portal:" -ForegroundColor Cyan
Write-Host "https://portal.azure.com/#@/resource/subscriptions//resourceGroups/demo-monitor-rg/overview" -ForegroundColor White
