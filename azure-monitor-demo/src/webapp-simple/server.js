const express = require('express');
const path = require('path');

// Initialize Application Insights
const appInsights = require('applicationinsights');
appInsights.setup(process.env.APPLICATIONINSIGHTS_CONNECTION_STRING || 'InstrumentationKey=your-instrumentation-key;IngestionEndpoint=https://your-region.in.applicationinsights.azure.com/;LiveEndpoint=https://your-region.livediagnostics.monitor.azure.com/;ApplicationId=your-application-id')
    .setAutoDependencyCorrelation(true)
    .setAutoCollectRequests(true)
    .setAutoCollectPerformance(true, true)
    .setAutoCollectExceptions(true)
    .setAutoCollectDependencies(true)
    .setAutoCollectConsole(true)
    .setUseDiskRetryCaching(true)
    .setSendLiveMetrics(true)
    .start();

const client = appInsights.defaultClient;

const app = express();
const port = process.env.PORT || 3000;

// Middleware
app.use(express.json());
app.use(express.static(path.join(__dirname, 'public')));

// In-memory data for demo
let products = [
    { id: 1, name: 'Azure Monitor', category: 'Monitoring', price: 199.99 },
    { id: 2, name: 'Application Insights', category: 'Analytics', price: 299.99 },
    { id: 3, name: 'Log Analytics', category: 'Logging', price: 149.99 },
    { id: 4, name: 'Azure Alerts', category: 'Notifications', price: 99.99 },
    { id: 5, name: 'Azure Metrics', category: 'Metrics', price: 249.99 }
];

// Routes
app.get('/', (req, res) => {
    client.trackEvent({ name: 'HomePage_Visited' });
    res.send(`
<!DOCTYPE html>
<html>
<head>
    <title>Azure Monitor Demo</title>
    <style>
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; margin: 40px; background: #f5f5f5; }
        .container { max-width: 1200px; margin: 0 auto; background: white; padding: 30px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        h1 { color: #0078d4; text-align: center; margin-bottom: 30px; }
        .nav { display: flex; justify-content: center; gap: 20px; margin-bottom: 30px; flex-wrap: wrap; }
        .nav a { background: #0078d4; color: white; padding: 10px 20px; text-decoration: none; border-radius: 5px; transition: background 0.3s; }
        .nav a:hover { background: #106ebe; }
        .info { background: #e6f3ff; padding: 20px; border-radius: 5px; margin-bottom: 20px; border-left: 4px solid #0078d4; }
        .status { display: flex; gap: 20px; margin-bottom: 20px; flex-wrap: wrap; }
        .status-item { background: #f8f9fa; padding: 15px; border-radius: 5px; flex: 1; min-width: 200px; text-align: center; }
        .status-value { font-size: 24px; font-weight: bold; color: #0078d4; }
        footer { text-align: center; margin-top: 30px; color: #666; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚀 Azure Monitor & Application Insights Demo</h1>
        
        <div class="info">
            <h3>✅ Application Insights Active</h3>
            <p>This demo application is instrumented with Application Insights and generating telemetry data in real-time.</p>
        </div>

        <div class="nav">
            <a href="/health">Health Check</a>
            <a href="/api/products">Products API</a>
            <a href="/error">Generate Error</a>
            <a href="/load">Load Test</a>
            <a href="/memory">Memory Test</a>
            <a href="/dependencies">Dependencies</a>
        </div>

        <div class="status">
            <div class="status-item">
                <div class="status-value">✅</div>
                <div>Application Status</div>
            </div>
            <div class="status-item">
                <div class="status-value">${products.length}</div>
                <div>Products Available</div>
            </div>
            <div class="status-item">
                <div class="status-value">🟢</div>
                <div>Telemetry Active</div>
            </div>
            <div class="status-item">
                <div class="status-value">⚡</div>
                <div>Real-time Monitoring</div>
            </div>
        </div>

        <h3>📊 Demo Features</h3>
        <ul>
            <li><strong>Health Monitoring:</strong> Endpoint para health checks automáticos</li>
            <li><strong>API Telemetry:</strong> Tracking de requests, responses y performance</li>
            <li><strong>Error Tracking:</strong> Simulación y captura de errores</li>
            <li><strong>Load Testing:</strong> Generación de carga para testing</li>
            <li><strong>Memory Monitoring:</strong> Tracking de uso de memoria</li>
            <li><strong>Dependency Tracking:</strong> Monitoring de dependencias externas</li>
        </ul>

        <footer>
            <p>Azure Monitor Demo - Node.js + Application Insights | Server Time: ${new Date().toISOString()}</p>
        </footer>
    </div>
</body>
</html>
    `);
});

app.get('/health', (req, res) => {
    const startTime = Date.now();
    
    client.trackEvent({ name: 'Health_Check_Requested' });
    
    const health = {
        status: 'healthy',
        timestamp: new Date().toISOString(),
        uptime: process.uptime(),
        memory: process.memoryUsage(),
        environment: process.env.NODE_ENV || 'development',
        version: '1.0.0'
    };
    
    const duration = Date.now() - startTime;
    client.trackMetric({ name: 'Health_Check_Duration', value: duration });
    client.trackDependency({ 
        target: 'internal', 
        name: 'health_check', 
        data: 'health status verification', 
        duration: duration, 
        resultCode: 200, 
        success: true 
    });
    
    res.json(health);
});

app.get('/api/products', (req, res) => {
    const startTime = Date.now();
    
    client.trackEvent({ 
        name: 'Products_API_Called',
        properties: { 
            userAgent: req.get('User-Agent'),
            endpoint: '/api/products'
        }
    });
    
    // Simulate some processing time
    setTimeout(() => {
        const duration = Date.now() - startTime;
        
        client.trackMetric({ name: 'Products_API_Duration', value: duration });
        client.trackMetric({ name: 'Products_Count', value: products.length });
        
        client.trackDependency({ 
            target: 'database', 
            name: 'get_products', 
            data: 'SELECT * FROM products', 
            duration: duration, 
            resultCode: 200, 
            success: true 
        });
        
        res.json({
            success: true,
            count: products.length,
            data: products,
            timestamp: new Date().toISOString()
        });
    }, Math.random() * 100);
});

app.get('/error', (req, res) => {
    client.trackEvent({ name: 'Error_Endpoint_Called' });
    
    const errorTypes = ['validation', 'database', 'network', 'timeout', 'authentication'];
    const errorType = errorTypes[Math.floor(Math.random() * errorTypes.length)];
    
    const error = new Error(`Simulated ${errorType} error for demo purposes`);
    error.code = `${errorType.toUpperCase()}_ERROR`;
    
    client.trackException({ 
        exception: error,
        properties: {
            errorType: errorType,
            endpoint: '/error',
            userAgent: req.get('User-Agent')
        }
    });
    
    client.trackMetric({ name: 'Error_Count', value: 1 });
    
    res.status(500).json({
        error: true,
        message: error.message,
        code: error.code,
        timestamp: new Date().toISOString()
    });
});

app.get('/load', (req, res) => {
    const iterations = parseInt(req.query.iterations) || 1000;
    const startTime = Date.now();
    
    client.trackEvent({ 
        name: 'Load_Test_Started',
        properties: { iterations: iterations.toString() }
    });
    
    // Simulate CPU load
    let result = 0;
    for (let i = 0; i < iterations; i++) {
        result += Math.sqrt(i) * Math.random();
    }
    
    const duration = Date.now() - startTime;
    
    client.trackMetric({ name: 'Load_Test_Duration', value: duration });
    client.trackMetric({ name: 'Load_Test_Iterations', value: iterations });
    client.trackMetric({ name: 'CPU_Load_Result', value: result });
    
    client.trackDependency({ 
        target: 'cpu', 
        name: 'heavy_computation', 
        data: `${iterations} iterations`, 
        duration: duration, 
        resultCode: 200, 
        success: true 
    });
    
    res.json({
        message: 'Load test completed',
        iterations: iterations,
        duration: duration,
        result: result,
        timestamp: new Date().toISOString()
    });
});

app.get('/memory', (req, res) => {
    const startTime = Date.now();
    
    client.trackEvent({ name: 'Memory_Test_Started' });
    
    // Get memory usage before
    const memBefore = process.memoryUsage();
    
    // Allocate some memory
    const size = parseInt(req.query.size) || 1000000;
    const data = new Array(size).fill('memory test data');
    
    // Get memory usage after
    const memAfter = process.memoryUsage();
    const duration = Date.now() - startTime;
    
    client.trackMetric({ name: 'Memory_Test_Duration', value: duration });
    client.trackMetric({ name: 'Memory_Heap_Used', value: memAfter.heapUsed });
    client.trackMetric({ name: 'Memory_Heap_Total', value: memAfter.heapTotal });
    client.trackMetric({ name: 'Memory_External', value: memAfter.external });
    client.trackMetric({ name: 'Memory_RSS', value: memAfter.rss });
    
    res.json({
        message: 'Memory test completed',
        allocatedSize: size,
        duration: duration,
        memoryBefore: memBefore,
        memoryAfter: memAfter,
        memoryDifference: {
            heapUsed: memAfter.heapUsed - memBefore.heapUsed,
            heapTotal: memAfter.heapTotal - memBefore.heapTotal,
            external: memAfter.external - memBefore.external,
            rss: memAfter.rss - memBefore.rss
        },
        timestamp: new Date().toISOString()
    });
});

app.get('/dependencies', (req, res) => {
    const startTime = Date.now();
    
    client.trackEvent({ name: 'Dependencies_Test_Started' });
    
    // Simulate multiple dependency calls
    const dependencies = [
        { name: 'Azure SQL Database', duration: Math.random() * 50 + 10 },
        { name: 'Azure Storage', duration: Math.random() * 30 + 5 },
        { name: 'External API', duration: Math.random() * 100 + 20 },
        { name: 'Redis Cache', duration: Math.random() * 10 + 2 }
    ];
    
    dependencies.forEach(dep => {
        client.trackDependency({
            target: dep.name.toLowerCase().replace(/\s+/g, '_'),
            name: dep.name,
            data: 'test operation',
            duration: dep.duration,
            resultCode: 200,
            success: true
        });
        
        client.trackMetric({ 
            name: `Dependency_${dep.name.replace(/\s+/g, '_')}_Duration`, 
            value: dep.duration 
        });
    });
    
    const totalDuration = Date.now() - startTime;
    client.trackMetric({ name: 'Dependencies_Test_Total_Duration', value: totalDuration });
    
    res.json({
        message: 'Dependencies test completed',
        dependencies: dependencies,
        totalDuration: totalDuration,
        timestamp: new Date().toISOString()
    });
});

// Error handling middleware
app.use((err, req, res, next) => {
    client.trackException({ 
        exception: err,
        properties: {
            url: req.url,
            method: req.method,
            userAgent: req.get('User-Agent')
        }
    });
    
    res.status(500).json({
        error: true,
        message: 'Internal server error',
        timestamp: new Date().toISOString()
    });
});

// 404 handler
app.use((req, res) => {
    client.trackEvent({ 
        name: '404_Not_Found',
        properties: {
            url: req.url,
            method: req.method,
            userAgent: req.get('User-Agent')
        }
    });
    
    res.status(404).json({
        error: true,
        message: 'Resource not found',
        url: req.url,
        timestamp: new Date().toISOString()
    });
});

app.listen(port, () => {
    console.log(`Server running on port ${port}`);
    
    client.trackEvent({ 
        name: 'Application_Started',
        properties: {
            port: port.toString(),
            environment: process.env.NODE_ENV || 'development',
            nodeVersion: process.version
        }
    });
    
    client.trackMetric({ name: 'Application_Startup_Time', value: Date.now() });
});

// Graceful shutdown
process.on('SIGTERM', () => {
    client.trackEvent({ name: 'Application_Shutdown' });
    client.flush();
});

process.on('SIGINT', () => {
    client.trackEvent({ name: 'Application_Shutdown' });
    client.flush();
    process.exit(0);
});
