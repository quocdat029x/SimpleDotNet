using System.Net;

namespace WebMonitorService;

public class Worker : BackgroundService
{
    private readonly ILogger<Worker> _logger;
    private readonly string _exeDir;
    private readonly string _logFile;
    private readonly string _url = "http://localhost:8080";

    public Worker(ILogger<Worker> logger)
    {
        _logger = logger;

        _exeDir = AppContext.BaseDirectory;
        _logFile = Path.Combine(_exeDir, "status_log.txt");
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        while (!stoppingToken.IsCancellationRequested)
        {
            try
            {
                using var client = new HttpClient();
                var response = await client.GetAsync(_url);
                var log = $"{DateTime.Now:yyyy-MM-dd HH:mm:ss} - {(int)response.StatusCode} {response.StatusCode}";
                await File.AppendAllTextAsync(_logFile, log + Environment.NewLine);

                if (response.StatusCode != HttpStatusCode.OK)
                {
                    _logger.LogError("Status != 200 OK. Stopping service.");
                    Environment.Exit(1); 
                }
            }
            catch (Exception ex)
            {
                await File.AppendAllTextAsync(_logFile, $"{DateTime.Now} - ERROR: {ex.Message}\n");
                Environment.Exit(1);
            }

            await Task.Delay(60000, stoppingToken);
        }
    }
}
