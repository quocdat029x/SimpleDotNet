using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using WebMonitorService;

Host.CreateDefaultBuilder(args)
    .UseWindowsService(options =>
    {
        options.ServiceName = "WebMonitorService";
    })
    .ConfigureServices(services =>
    {
        services.AddHostedService<Worker>();
    })
    .Build()
    .Run();
