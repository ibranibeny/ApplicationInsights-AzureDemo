const express = require('express');
const appInsights = require('applicationinsights');
const path = require('path');

// Configure Application Insights
const connectionString = process.env.APPLICATIONINSIGHTS_CONNECTION_STRING;
if (connectionString) {
    appInsights.setup(connectionString)
        .setAutoDependencyCorrelation(true)
        .setAutoCollectRequests(true)
        .setAutoCollectPerformance(true, true)
        .setAutoCollectExceptions(true)
        .setAutoCollectDependencies(true)
        .setAutoCollectConsole(true)
        .setUseDiskRetryCaching(true)
        .setSendLiveMetrics(true)
        .start();
    
    console.log('Application Insights configured successfully');
} else {
    console.log('Application Insights connection string not found');
}

const app = express();
const port = process.env.PORT || 3000;
const client = appInsights.defaultClient;

// Middleware
app.use(express.json());
app.use(express.static(path.join(__dirname, 'public')));

// Routes
app.get('/', (req, res) => {
    if (client) {
        client.trackEvent({name: 'HomePage', properties: {route: '/'}});
    }
    res.send(`
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Azure Monitor Demo</title>
        <style>
            body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; margin: 40px; background: #f5f5f5; }
            .container { max-width: 800px; margin: 0 auto; background: white; padding: 30px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
            .header { text-align: center; color: #0078d4; margin-bottom: 30px; }
            .endpoint { background: #f8f9fa; padding: 15px; margin: 10px 0; border-radius: 5px; border-left: 4px solid #0078d4; }
            .endpoint h3 { margin: 0 0 10px 0; color: #333; }
            .endpoint p { margin: 5px 0; color: #666; }
            .btn { background: #0078d4; color: white; padding: 10px 20px; text-decoration: none; border-radius: 5px; display: inline-block; margin: 5px; }
            .btn:hover { background: #106ebe; }
            .status { padding: 10px; border-radius: 5px; margin: 10px 0; }
            .success { background: #d4edda; color: #155724; border: 1px solid #c3e6cb; }
        </style>
    </head>
    <body>
        <div class="container">
            <div class="header">
                <h1>🎯 Azure Monitor Demo Environment</h1>
                <p>Aplicación funcionando con Node.js + Application Insights</p>
            </div>

            <div class="status success">
                <strong>✅ Estado:</strong> Aplicación funcionando y enviando telemetría a Application Insights
            </div>

            <div class="endpoint">
                <h3>📊 API Endpoints Disponibles</h3>
                <p><strong>/api/health</strong> - Health check con telemetría</p>
                <a href="/api/health" class="btn">Test Health</a>
            </div>

            <div class="endpoint">
                <h3>📦 Products API</h3>
                <p><strong>/api/products</strong> - Lista de productos con métricas</p>
                <a href="/api/products" class="btn">Get Products</a>
            </div>

            <div class="endpoint">
                <h3>💥 Error Simulation</h3>
                <p><strong>/api/simulate-error</strong> - Genera errores (30% probabilidad)</p>
                <a href="/api/simulate-error" class="btn">Simulate Error</a>
            </div>

            <div class="endpoint">
                <h3>🔥 Load Testing</h3>
                <p><strong>/api/load-test</strong> - Simula carga de CPU</p>
                <a href="/api/load-test" class="btn">Load Test</a>
            </div>

            <div class="endpoint">
                <h3>💾 Memory Testing</h3>
                <p><strong>/api/memory-test</strong> - Simula uso de memoria</p>
                <a href="/api/memory-test" class="btn">Memory Test</a>
            </div>

            <div style="margin-top: 30px; padding: 20px; background: #e7f3ff; border-radius: 5px;">
                <h3>🎪 Para tu Demo:</h3>
                <ol>
                    <li>Abre <strong>Azure Portal</strong> → Resource Group: <code>demo-monitor-rg</code></li>
                    <li>Ve a <strong>Application Insights</strong> → <strong>Live Metrics</strong></li>
                    <li>Haz clic en los botones para generar tráfico</li>
                    <li>Observa métricas en tiempo real</li>
                </ol>
            </div>
        </div>
    </body>
    </html>
    `);
});

// API Endpoints
app.get('/api/health', (req, res) => {
    const startTime = Date.now();
    
    if (client) {
        client.trackEvent({name: 'HealthCheck', properties: {status: 'healthy'}});
        client.trackMetric({name: 'HealthCheckCalls', value: 1});
    }
    
    setTimeout(() => {
        const duration = Date.now() - startTime;
        if (client) {
            client.trackMetric({name: 'HealthCheckDuration', value: duration});
        }
        
        res.json({
            status: 'healthy',
            timestamp: new Date().toISOString(),
            server: 'Node.js',
            duration: duration
        });
    }, Math.random() * 200); // Random delay 0-200ms
});

app.get('/api/products', (req, res) => {
    const startTime = Date.now();
    
    const products = [
        { id: 1, name: 'Demo Product 1', price: 19.99, description: 'Sample product for demo' },
        { id: 2, name: 'Demo Product 2', price: 29.99, description: 'Another sample product' },
        { id: 3, name: 'Demo Product 3', price: 39.99, description: 'Third sample product' }
    ];
    
    setTimeout(() => {
        const duration = Date.now() - startTime;
        
        if (client) {
            client.trackDependency({target: 'InMemory', name: 'GetProducts', data: 'SELECT * FROM Products', duration: duration, resultCode: 200, success: true});
            client.trackMetric({name: 'ProductCount', value: products.length});
            client.trackEvent({name: 'ProductsRequested', properties: {count: products.length.toString()}});
        }
        
        res.json(products);
    }, Math.random() * 500); // Random delay 0-500ms
});

app.get('/api/simulate-error', (req, res) => {
    const shouldError = Math.random() < 0.3; // 30% chance of error
    
    if (shouldError) {
        const error = new Error('Simulated error for demo purposes');
        
        if (client) {
            client.trackException({exception: error});
            client.trackEvent({name: 'ErrorSimulated', properties: {errorType: 'Simulated'}});
        }
        
        console.error('Simulated error:', error.message);
        res.status(500).json({error: 'Simulated error occurred', timestamp: new Date().toISOString()});
    } else {
        if (client) {
            client.trackEvent({name: 'SuccessfulOperation'});
        }
        
        res.json({message: 'Operation completed successfully', timestamp: new Date().toISOString()});
    }
});

app.get('/api/load-test', (req, res) => {
    const startTime = Date.now();
    
    // Simulate CPU load
    const iterations = 1000000;
    let result = 0;
    for (let i = 0; i < iterations; i++) {
        result += Math.sqrt(Math.random());
    }
    
    const duration = Date.now() - startTime;
    
    if (client) {
        client.trackMetric({name: 'LoadTestDuration', value: duration});
        client.trackEvent({name: 'LoadTestCompleted', properties: {iterations: iterations.toString()}});
    }
    
    res.json({
        message: 'Load test completed',
        duration: duration,
        iterations: iterations,
        result: result
    });
});

app.get('/api/memory-test', (req, res) => {
    const startMemory = process.memoryUsage();
    
    // Allocate memory
    const data = [];
    for (let i = 0; i < 1000; i++) {
        data.push(Buffer.alloc(1024 * 10)); // 10KB each
    }
    
    const endMemory = process.memoryUsage();
    const memoryUsed = endMemory.heapUsed - startMemory.heapUsed;
    
    if (client) {
        client.trackMetric({name: 'MemoryAllocated', value: memoryUsed});
        client.trackEvent({name: 'MemoryTestCompleted', properties: {memoryUsed: memoryUsed.toString()}});
    }
    
    // Clean up
    data.length = 0;
    
    res.json({
        message: 'Memory test completed',
        memoryAllocated: memoryUsed,
        memoryUsage: endMemory
    });
});

// Start server
app.listen(port, () => {
    console.log(`Azure Monitor Demo App listening on port ${port}`);
    if (client) {
        client.trackEvent({name: 'ServerStarted', properties: {port: port.toString()}});
    }
});
