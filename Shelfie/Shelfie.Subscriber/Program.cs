using EasyNetQ;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Shelfie.Models.Responses;
using Shelfie.Services.Database;
using System;
using System.Threading;
using System.Threading.Tasks;

var host = Host.CreateDefaultBuilder(args)
    .ConfigureAppConfiguration((context, config) =>
    {
        config.AddEnvironmentVariables();
    })
    .ConfigureServices((context, services) =>
    {
        services.AddDbContext<IB220155Context>(options =>
            options.UseSqlServer(context.Configuration.GetConnectionString("DefaultConnection")));
    })
    .Build();

Console.WriteLine("📚 Shelfie Subscriber started...");

var rabbitMqHost = Environment.GetEnvironmentVariable("RABBIT_MQ_HOST") ?? "rabbitmq";
var rabbitMqUser = Environment.GetEnvironmentVariable("RABBIT_MQ_USER") ?? "guest";
var rabbitMqPassword = Environment.GetEnvironmentVariable("RABBIT_MQ_PASS") ?? "guest";

var rabbitConn = $"host={rabbitMqHost};username={rabbitMqUser};password={rabbitMqPassword}";

IBus bus;
try
{
    bus = RabbitHutch.CreateBus(rabbitConn);
    Console.WriteLine("Successfully connected to RabbitMQ");
}
catch (Exception ex)
{
    Console.WriteLine($"Failed to connect to RabbitMQ: {ex.Message}");
    Console.WriteLine("Retrying in 5 seconds...");
    await Task.Delay(5000);

    try
    {
        bus = RabbitHutch.CreateBus(rabbitConn);
        Console.WriteLine("Successfully connected to RabbitMQ on retry");
    }
    catch (Exception retryEx)
    {
        Console.WriteLine($"Failed to connect to RabbitMQ on retry: {retryEx.Message}");
        return;
    }
}

Console.WriteLine("Setting up subscription for CommentCreatedEvent messages...");

var cts = new CancellationTokenSource();

await bus.PubSub.SubscribeAsync<CommentCreatedEvent>("notification_subscriber", async ev =>
{
    try
    {
        using var scope = host.Services.CreateScope();
        var dbContext = scope.ServiceProvider.GetRequiredService<IB220155Context>();

        var notification = new NotificationMessage
        {
            PostId = ev.PostId,
            CommentId = ev.CommentId,
            CommentText = ev.CommentText,
            FromUserId = ev.FromUserId,
            ToUserId = ev.ToUserId,
            FromUserName = ev.FromUserName,
            CreatedAt = DateTime.UtcNow
        };

        await dbContext.Notifications.AddAsync(notification);
        await dbContext.SaveChangesAsync();

        Console.WriteLine($"Notification saved for user {ev.ToUserId} from {ev.FromUserName}");
    }
    catch (Exception ex)
    {
        Console.WriteLine($"Error processing message: {ex.Message}");
        Console.WriteLine(ex.StackTrace);
    }
}, cts.Token);

Console.WriteLine("Listening for CommentCreatedEvent messages... Press Ctrl+C to exit.");

Console.CancelKeyPress += (sender, e) =>
{
    e.Cancel = true;
    cts.Cancel();
};

try
{
    await Task.Delay(-1, cts.Token);
}
catch (TaskCanceledException)
{
    Console.WriteLine("Subscriber is shutting down...");
}
