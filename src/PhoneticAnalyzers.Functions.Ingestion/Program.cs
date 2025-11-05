using Azure.Identity;
using Microsoft.Azure.Functions.Worker;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using PhoneticAnalyzers.Application.Services.Phonetic;
using PhoneticAnalyzers.Domain.Repositories;
using PhoneticAnalyzers.Infrastructure.Persistence;
using PhoneticAnalyzers.Infrastructure.Persistence.Repositories;

using System.Reflection;

var host = new HostBuilder()
    .ConfigureFunctionsWorkerDefaults()
    .ConfigureAppConfiguration((context, config) =>
    {
        var environment = context.HostingEnvironment.EnvironmentName;
        
        config.AddJsonFile("appsettings.json", optional: true, reloadOnChange: true)
              .AddJsonFile($"appsettings.{environment}.json", optional: true, reloadOnChange: true)
              .AddEnvironmentVariables();

        // Add Azure Key Vault if not in development
        if (!context.HostingEnvironment.IsDevelopment())
        {
            var keyVaultUrl = Environment.GetEnvironmentVariable("KeyVaultUrl");
            if (!string.IsNullOrEmpty(keyVaultUrl))
            {
                config.AddAzureKeyVault(new Uri(keyVaultUrl), new DefaultAzureCredential());
            }
        }
    })
    .ConfigureServices((context, services) =>
    {
        // Application Insights
        services.AddApplicationInsightsTelemetryWorkerService();
        services.ConfigureFunctionsApplicationInsights();

        // Database context
        var connectionString = context.Configuration.GetConnectionString("DefaultConnection")
                            ?? throw new InvalidOperationException("Database connection string is required");

        services.AddDbContext<PhoneticAnalyzersDbContext>(options =>
        {
            options.UseNpgsql(connectionString, npgsqlOptions =>
            {
                npgsqlOptions.MigrationsAssembly(typeof(PhoneticAnalyzersDbContext).Assembly.FullName);
                npgsqlOptions.EnableRetryOnFailure(
                    maxRetryCount: 3,
                    maxRetryDelay: TimeSpan.FromSeconds(5),
                    errorCodesToAdd: null);
            });

            if (context.HostingEnvironment.IsDevelopment())
            {
                options.EnableSensitiveDataLogging();
                options.EnableDetailedErrors();
            }
        });

        // Repositories
        services.AddScoped<IPersonRepository, PersonRepository>();

        // Phonetic encoding services
        services.AddSingleton<DoubleMetaphoneEncoder>();
        services.AddSingleton<BeiderMorseEncoder>();
        services.AddSingleton<IPhoneticEncoderFactory, PhoneticEncoderFactory>();
        services.AddScoped<IPhoneticEncodingService, PhoneticEncodingService>();
        services.AddSingleton<INicknameService, InMemoryNicknameService>();

        // HTTP Client (retry policy can be added later)
        services.AddHttpClient("RetryClient");

        // Health checks
        services.AddHealthChecks()
            .AddDbContextCheck<PhoneticAnalyzersDbContext>("database")
            .AddCheck("self", () => Microsoft.Extensions.Diagnostics.HealthChecks.HealthCheckResult.Healthy("Function app is healthy"));

        // MediatR for CQRS
        services.AddMediatR(cfg => cfg.RegisterServicesFromAssembly(typeof(PhoneticAnalyzers.Application.Services.Phonetic.IPhoneticEncodingService).Assembly));

        // Logging configuration
        services.Configure<LoggerFilterOptions>(options =>
        {
            // Remove default console logger rule
            var defaultRule = options.Rules.FirstOrDefault(rule => rule.ProviderName == "Microsoft.Extensions.Logging.Console.ConsoleLoggerProvider");
            if (defaultRule is not null)
            {
                options.Rules.Remove(defaultRule);
            }
        });
    })
    .ConfigureLogging((context, logging) =>
    {
        logging.ClearProviders();
        
        if (context.HostingEnvironment.IsDevelopment())
        {
            logging.AddConsole();
            logging.SetMinimumLevel(LogLevel.Debug);
        }
        else
        {
            logging.SetMinimumLevel(LogLevel.Information);
        }

        // Add structured logging
        logging.AddJsonConsole(options =>
        {
            options.IncludeScopes = true;
            options.TimestampFormat = "yyyy-MM-ddTHH:mm:ss.fffZ";
        });
    })
    .Build();

// Ensure database is created and migrated (optional for startup)
var skipDbInit = Environment.GetEnvironmentVariable("SKIP_DATABASE_INIT");
if (string.IsNullOrEmpty(skipDbInit) || !bool.TryParse(skipDbInit, out var shouldSkip) || !shouldSkip)
{
    using (var scope = host.Services.CreateScope())
    {
        try
        {
            var context = scope.ServiceProvider.GetRequiredService<PhoneticAnalyzersDbContext>();
            var logger = scope.ServiceProvider.GetRequiredService<ILogger<Program>>();
            
            logger.LogInformation("Attempting to migrate database...");
            await context.Database.MigrateAsync();
            logger.LogInformation("Database migration completed successfully");
        }
        catch (Exception ex)
        {
            var logger = scope.ServiceProvider.GetRequiredService<ILogger<Program>>();
            logger.LogWarning(ex, "Database migration failed. Function will start but database operations may fail until connection is established.");
            // Don't throw - allow function to start even if database is not available
        }
    }
}
else
{
    Console.WriteLine("Skipping database initialization due to SKIP_DATABASE_INIT environment variable");
}

await host.RunAsync();

