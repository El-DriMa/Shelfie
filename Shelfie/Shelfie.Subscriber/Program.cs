using EasyNetQ;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Shelfie.Models.Responses;
using Shelfie.Services.Database;
using System;
using System.Threading.Tasks;

var host = Host.CreateDefaultBuilder(args)
    .ConfigureAppConfiguration((context, config) =>
    {
        config.AddJsonFile("appsettings.json", optional: false, reloadOnChange: true);
    })
    .ConfigureServices((context, services) =>
    {
        services.AddDbContext<IB220155Context>(options =>
            options.UseSqlServer(context.Configuration.GetConnectionString("DefaultConnection")));
    })
    .Build();

var config = host.Services.GetRequiredService<IConfiguration>();

var bus = RabbitHutch.CreateBus("host=localhost");

using var scope = host.Services.CreateScope();
var dbContext = scope.ServiceProvider.GetRequiredService<IB220155Context>();

await bus.PubSub.SubscribeAsync<CommentCreatedEvent>("notification_subscriber", async ev =>
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
});

Console.WriteLine("Listening for notifications. Press any key to exit.");
Console.ReadKey();
