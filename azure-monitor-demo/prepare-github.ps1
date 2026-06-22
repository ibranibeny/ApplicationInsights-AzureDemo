# Configuración para GitHub
# Este script prepara el proyecto para ser subido a un repositorio público

Write-Host "🔧 Preparando proyecto para GitHub..." -ForegroundColor Cyan

# Función para limpiar archivos sensibles
function Remove-SensitiveInfo {
    param([string]$FilePath, [string]$Pattern, [string]$Replacement)
    
    if (Test-Path $FilePath) {
        $content = Get-Content $FilePath -Raw
        $cleanContent = $content -replace $Pattern, $Replacement
        Set-Content -Path $FilePath -Value $cleanContent -NoNewline
        Write-Host "✅ Limpiado: $FilePath" -ForegroundColor Green
    }
}

# Limpiar connection strings e información sensible del código
Write-Host "🧹 Limpiando información sensible..." -ForegroundColor Yellow

# Limpiar server.js
Remove-SensitiveInfo -FilePath "src\webapp-simple\server.js" `
    -Pattern "InstrumentationKey=[^;]+;[^']*" `
    -Replacement "process.env.APPLICATIONINSIGHTS_CONNECTION_STRING || 'your-connection-string-here'"

# Limpiar parámetros ARM template
Remove-SensitiveInfo -FilePath "infra\main.parameters.json" `
    -Pattern '"ComplexPassword123!"' `
    -Replacement '"YourSecurePassword123!"'

# Crear archivo de variables de entorno de ejemplo
Write-Host "📝 Creando archivo .env.example..." -ForegroundColor Yellow
@"
# Azure Configuration
AZURE_SUBSCRIPTION_ID=your-subscription-id-here
AZURE_TENANT_ID=your-tenant-id-here

# Application Insights
APPLICATIONINSIGHTS_CONNECTION_STRING=InstrumentationKey=your-key;IngestionEndpoint=https://your-region.in.applicationinsights.azure.com/

# SQL Database
SQL_CONNECTION_STRING=Server=your-server.database.windows.net;Database=your-db;User Id=your-user;Password=your-password;

# App Service
WEBSITE_NODE_DEFAULT_VERSION=18.12.0
"@ | Out-File -FilePath ".env.example" -Encoding UTF8

Write-Host "✅ Archivo .env.example creado" -ForegroundColor Green

# Crear CONTRIBUTING.md
Write-Host "📝 Creando guía de contribución..." -ForegroundColor Yellow
@"
# 🤝 Guía de Contribución

¡Gracias por tu interés en contribuir al proyecto Azure Monitor Demo!

## 🚀 Cómo Contribuir

### 1. Fork y Clone
```bash
git fork https://github.com/your-repo/azure-monitor-demo
git clone https://github.com/your-username/azure-monitor-demo
cd azure-monitor-demo
```

### 2. Crear una Rama
```bash
git checkout -b feature/nueva-funcionalidad
```

### 3. Hacer Cambios
- Mantén el código limpio y documentado
- Sigue las convenciones de naming existentes
- Actualiza documentación si es necesario

### 4. Testear
```powershell
# Ejecutar tests locales
.\scripts\demo-final.ps1
```

### 5. Commit y Push
```bash
git add .
git commit -m "feat: descripción de la nueva funcionalidad"
git push origin feature/nueva-funcionalidad
```

### 6. Crear Pull Request
- Describe los cambios realizados
- Incluye screenshots si aplica
- Referencia issues relacionados

## 📋 Checklist para Pull Requests

- [ ] Código testeado localmente
- [ ] Documentación actualizada
- [ ] Sin información sensible (passwords, keys, etc.)
- [ ] Commit messages claros
- [ ] No hay archivos temporales o logs

## 🏷️ Convenciones

### Commit Messages
- `feat:` nueva funcionalidad
- `fix:` corrección de bugs
- `docs:` cambios en documentación
- `refactor:` refactoring de código
- `test:` agregar o modificar tests

### Código
- Usar nombres descriptivos para variables y funciones
- Comentar código complejo
- Mantener funciones pequeñas y enfocadas

## 🛠️ Configuración de Desarrollo

### Prerrequisitos
- Azure CLI
- PowerShell 5.1+
- Git
- Editor de código (VS Code recomendado)

### Configuración Inicial
```bash
# Instalar extensiones recomendadas para VS Code
code --install-extension ms-vscode.azure-tools
code --install-extension ms-vscode.powershell
```

¡Gracias por contribuir! 🎉
"@ | Out-File -FilePath "CONTRIBUTING.md" -Encoding UTF8

Write-Host "✅ CONTRIBUTING.md creado" -ForegroundColor Green

# Crear README para cada directorio
Write-Host "📝 Creando READMEs de directorios..." -ForegroundColor Yellow

# README para /scripts
@"
# 📜 Scripts

Este directorio contiene todos los scripts de PowerShell para automatizar el despliegue y gestión del entorno de demostración.

## Scripts Disponibles

### 🚀 Despliegue
- **`deploy.ps1`** - Script principal de despliegue de infraestructura
- **`demo-final.ps1`** - Script completo de demostración y pruebas

### 🔄 Utilidades
- **`generate-traffic.ps1`** - Generador de tráfico para pruebas
- **`final-test.ps1`** - Tests de verificación del entorno
- **`test-environment.ps1`** - Validación del entorno

## Uso

```powershell
# Ejecutar desde el directorio raíz del proyecto
.\scripts\deploy.ps1
.\scripts\demo-final.ps1
```

## Prerrequisitos

- Azure CLI configurado
- PowerShell 5.1+
- Permisos en Azure subscription
"@ | Out-File -FilePath "scripts\README.md" -Encoding UTF8

# README para /docs
@"
# 📚 Documentación

Este directorio contiene toda la documentación del proyecto Azure Monitor Demo.

## Documentos Disponibles

### 🎯 Guías Principales
- **`DEMO-GUIDE.md`** - Guía completa para presentaciones
- **`DEPLOYMENT.md`** - Instrucciones detalladas de despliegue

### 📊 Referencias
- **`DEMO-READY-FINAL.md`** - Estado final del proyecto y resumen
- **`FINAL-SUMMARY.md`** - Resumen técnico completo

## Orden de Lectura Recomendado

1. **DEPLOYMENT.md** - Para entender cómo desplegar
2. **DEMO-GUIDE.md** - Para preparar presentaciones
3. **DEMO-READY-FINAL.md** - Para verificar el estado final

## Contribuciones

Al actualizar documentación:
- Mantener formato Markdown consistente
- Incluir ejemplos prácticos
- Actualizar TOCs cuando sea necesario
"@ | Out-File -FilePath "docs\README.md" -Encoding UTF8

# README para /src
@"
# 💻 Código Fuente

Este directorio contiene todo el código fuente de las aplicaciones de demostración.

## Estructura

### 🌐 Aplicaciones Web
- **`webapp-simple/`** - Aplicación Node.js con Express y Application Insights
- **`web/`** - Aplicación .NET Core (alternativa)
- **`web-node/`** - Aplicación Node.js básica

### ⚡ Azure Functions
- **`loadtest/`** - Functions para generación automática de carga

## Tecnologías

### Node.js Application (`webapp-simple/`)
- **Express.js** - Framework web
- **Application Insights SDK** - Telemetría
- **Node.js 18 LTS** - Runtime

### .NET Application (`web/`)
- **ASP.NET Core** - Framework web
- **Application Insights** - Telemetría
- **.NET 8** - Runtime

## Configuración

### Variables de Entorno Requeridas
```
APPLICATIONINSIGHTS_CONNECTION_STRING=your-connection-string
WEBSITE_NODE_DEFAULT_VERSION=18.12.0
```

### Endpoints Disponibles
- `GET /` - Dashboard principal
- `GET /health` - Health check
- `GET /api/products` - API de productos
- `GET /error` - Simulación de errores
- `GET /load` - Pruebas de carga
- `GET /memory` - Pruebas de memoria
- `GET /dependencies` - Simulación de dependencias

## Desarrollo Local

```bash
# Para Node.js
cd src/webapp-simple
npm install
npm start

# Para .NET
cd src/web
dotnet restore
dotnet run
```
"@ | Out-File -FilePath "src\README.md" -Encoding UTF8

Write-Host "✅ READMEs de directorios creados" -ForegroundColor Green

# Crear archivo de configuración para GitHub Actions (opcional)
Write-Host "📝 Creando configuración GitHub Actions..." -ForegroundColor Yellow
New-Item -ItemType Directory -Path ".github\workflows" -Force | Out-Null

@"
name: 🧪 Validate ARM Templates

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  validate-arm:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    
    - name: Login to Azure
      uses: azure/login@v1
      with:
        creds: \${{ secrets.AZURE_CREDENTIALS }}
    
    - name: Validate ARM Template
      run: |
        az deployment group validate \
          --resource-group "temp-validation-rg" \
          --template-file infra/main.json \
          --parameters infra/main.parameters.json
  
  validate-scripts:
    runs-on: windows-latest
    steps:
    - uses: actions/checkout@v3
    
    - name: Test PowerShell Scripts
      run: |
        # Test script syntax
        Get-ChildItem -Path scripts -Filter "*.ps1" | ForEach-Object {
          \$errors = \$null
          \$null = [System.Management.Automation.PSParser]::Tokenize((Get-Content \$_.FullName -Raw), [ref]\$errors)
          if (\$errors) {
            Write-Error "Syntax errors in \$(\$_.Name): \$errors"
            exit 1
          }
        }
      shell: pwsh
"@ | Out-File -FilePath ".github\workflows\validate.yml" -Encoding UTF8

Write-Host "✅ GitHub Actions configurado" -ForegroundColor Green

Write-Host "🎉 Proyecto preparado para GitHub!" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Próximos pasos:" -ForegroundColor White
Write-Host "1. Revisar archivos modificados" -ForegroundColor Cyan
Write-Host "2. Ejecutar: git add ." -ForegroundColor Cyan
Write-Host "3. Ejecutar: git commit -m 'Initial commit'" -ForegroundColor Cyan
Write-Host "4. Crear repositorio en GitHub" -ForegroundColor Cyan
Write-Host "5. Ejecutar: git remote add origin <repo-url>" -ForegroundColor Cyan
Write-Host "6. Ejecutar: git push -u origin main" -ForegroundColor Cyan
