using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Http;
using Microsoft.Extensions.Logging;
using System.Net.Http;
using System.Text.Json;

namespace LoadTestFunction
{
    public class LoadGenerator
    {
        private readonly ILogger _logger;
        private readonly HttpClient _httpClient;

        public LoadGenerator(ILoggerFactory loggerFactory, IHttpClientFactory httpClientFactory)
        {
            _logger = loggerFactory.CreateLogger<LoadGenerator>();
            _httpClient = httpClientFactory.CreateClient();
        }

        [Function("GenerateLoad")]
        public async Task<HttpResponseData> GenerateLoad([HttpTrigger(AuthorizationLevel.Anonymous, "get", "post")] HttpRequestData req)
        {
            _logger.LogInformation("Load generation function triggered manually.");

            var targetUrl = Environment.GetEnvironmentVariable("TARGET_WEB_APP_URL");
            if (string.IsNullOrEmpty(targetUrl))
            {
                _logger.LogError("TARGET_WEB_APP_URL environment variable not set");
                var errorResponse = req.CreateResponse(System.Net.HttpStatusCode.InternalServerError);
                await errorResponse.WriteStringAsync("Target URL not configured");
                return errorResponse;
            }

            await GenerateTrafficAsync(targetUrl);

            var response = req.CreateResponse(System.Net.HttpStatusCode.OK);
            await response.WriteStringAsync("Load generation completed");
            return response;
        }

        [Function("ScheduledLoadGenerator")]
        public async Task ScheduledLoadGenerator([TimerTrigger("0 */5 * * * *")] TimerInfo myTimer)
        {
            _logger.LogInformation("Scheduled load generation triggered at: {time}", DateTime.Now);

            var targetUrl = Environment.GetEnvironmentVariable("TARGET_WEB_APP_URL");
            if (string.IsNullOrEmpty(targetUrl))
            {
                _logger.LogError("TARGET_WEB_APP_URL environment variable not set");
                return;
            }

            await GenerateTrafficAsync(targetUrl);
        }

        private async Task GenerateTrafficAsync(string baseUrl)
        {
            var endpoints = new[]
            {
                "/api/health",
                "/api/products",
                "/api/simulate-error",
                "/api/load-test",
                "/api/memory-test"
            };

            var tasks = new List<Task>();

            // Generate multiple concurrent requests
            for (int i = 0; i < 20; i++)
            {
                var endpoint = endpoints[Random.Shared.Next(endpoints.Length)];
                var url = $"{baseUrl.TrimEnd('/')}{endpoint}";

                tasks.Add(MakeRequestAsync(url, i));
            }

            await Task.WhenAll(tasks);
            _logger.LogInformation("Generated {count} requests to various endpoints", tasks.Count);
        }

        private async Task MakeRequestAsync(string url, int requestNumber)
        {
            try
            {
                _logger.LogInformation("Making request {number} to {url}", requestNumber, url);
                
                var response = await _httpClient.GetAsync(url);
                
                if (response.IsSuccessStatusCode)
                {
                    _logger.LogInformation("Request {number} to {url} succeeded with status {status}", 
                        requestNumber, url, response.StatusCode);
                }
                else
                {
                    _logger.LogWarning("Request {number} to {url} failed with status {status}", 
                        requestNumber, url, response.StatusCode);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Request {number} to {url} failed with exception", requestNumber, url);
            }
        }
    }
}
