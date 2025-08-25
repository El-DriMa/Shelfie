using EasyNetQ;
using MapsterMapper;
using Microsoft.AspNetCore.Diagnostics;
using Microsoft.EntityFrameworkCore;
using Shelfie.Services.Database;
using Shelfie.Services.Interfaces;
using Shelfie.Services.Services;
using ShelfieAPI.Authentication;
using System.ComponentModel.DataAnnotations;
using Microsoft.Extensions.FileProviders;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddControllers();

builder.Configuration.AddEnvironmentVariables();

var connectionString = builder.Configuration.GetConnectionString("DefaultConnection");

builder.Services.AddDbContext<IB220155Context>(options =>
    options.UseSqlServer(connectionString));

var rabbitMqHost = Environment.GetEnvironmentVariable("RABBIT_MQ_HOST") ?? "rabbitmq";
var rabbitMqUser = Environment.GetEnvironmentVariable("RABBIT_MQ_USER") ?? "guest";
var rabbitMqPass = Environment.GetEnvironmentVariable("RABBIT_MQ_PASS") ?? "guest";

var rabbitConn = $"host={rabbitMqHost};username={rabbitMqUser};password={rabbitMqPass}";

builder.Services.AddSingleton<IBus>(_ => RabbitHutch.CreateBus(rabbitConn));


builder.Services.AddSingleton<IMapper, Mapper>();


builder.Services.AddTransient<IAuthorService, AuthorService>();
builder.Services.AddTransient<IBookService, BookService>();
builder.Services.AddTransient<IGenreService, GenreService>();
builder.Services.AddTransient<IPublisherService, PublisherService>();
builder.Services.AddTransient<IReadingChallengeService, ReadingChallengeService>();
builder.Services.AddTransient<IRoleService, RoleService>();
builder.Services.AddTransient<IShelfService, ShelfService>();
builder.Services.AddTransient<IStatisticsService, StatisticsService>();
builder.Services.AddTransient<IUserService, UserService>();
builder.Services.AddTransient<IUserRoleService, UserRoleService>();
builder.Services.AddTransient<IShelfBooksService, ShelfBooksService>();
builder.Services.AddTransient<IPostService, PostService>();
builder.Services.AddTransient<ICommentService, CommentService>();
builder.Services.AddTransient<INotificationService, NotificationService>();
builder.Services.AddTransient<IReviewService, ReviewService>();



// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.AddSecurityDefinition("basic", new Microsoft.OpenApi.Models.OpenApiSecurityScheme
    {
        Name = "Authorization",
        Type = Microsoft.OpenApi.Models.SecuritySchemeType.Http,
        Scheme = "basic",
        In = Microsoft.OpenApi.Models.ParameterLocation.Header,
        Description = "Basic Authentication header"
    });

    c.AddSecurityRequirement(new Microsoft.OpenApi.Models.OpenApiSecurityRequirement
    {
        {
            new Microsoft.OpenApi.Models.OpenApiSecurityScheme
            {
                Reference = new Microsoft.OpenApi.Models.OpenApiReference
                {
                    Type = Microsoft.OpenApi.Models.ReferenceType.SecurityScheme,
                    Id = "basic"
                }
            },
            new string[] { }
        }
    });
});



var app = builder.Build();

using (var scope = app.Services.CreateScope())
{
    var context = scope.ServiceProvider.GetRequiredService<IB220155Context>();

    if (context.Database.EnsureCreated())
    {
        if (!context.Users.Any())
        {
            var seeder = new ShelfieAPI.DataSeed.DataSeed(context);
            seeder.SeedAll();
        }
    }
}



// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

app.UseExceptionHandler(appBuilder =>
{
    appBuilder.Run(async context =>
    {
        var exceptionHandlerPathFeature = context.Features.Get<IExceptionHandlerPathFeature>();
        var exception = exceptionHandlerPathFeature?.Error;

        context.Response.ContentType = "application/json";

        if (exception is ValidationException validationException)
        {
            context.Response.StatusCode = 400;
            await context.Response.WriteAsJsonAsync(new { message = validationException.Message });
        }
        else if (exception is Exception)
        {
            context.Response.StatusCode = 500;
            await context.Response.WriteAsJsonAsync(new { message = exception.Message });
        }
    });
});


app.UseMiddleware<BasicAuthMiddleware>();

app.UseAuthentication();
app.UseAuthorization();

app.UseStaticFiles();

app.MapControllers();
//app.Urls.Add("http://0.0.0.0:5000");

app.Run();
