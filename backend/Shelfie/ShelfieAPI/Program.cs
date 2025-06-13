using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using Shelfie.Services.Database;
using Shelfie.Services.Interfaces;
using Shelfie.Services.Services;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.

builder.Services.AddControllers();

builder.Configuration.AddEnvironmentVariables();

var connectionString = builder.Configuration.GetConnectionString("DefaultConnection");

builder.Services.AddDbContext<IB220155Context>(options =>
    options.UseSqlServer(connectionString));

builder.Services.AddSingleton<IMapper, Mapper>();


builder.Services.AddTransient<IAuthorService, AuthorService>();
builder.Services.AddTransient<IBookService, BookService>();
builder.Services.AddTransient<IGenreService, GenreService>();
builder.Services.AddTransient<IPublisherService, PublisherService>();
builder.Services.AddTransient<IReadingChallengeService, ReadingChallengeService>();
builder.Services.AddTransient<IReviewService, ReviewService>();
builder.Services.AddTransient<IRoleService, RoleService>();
builder.Services.AddTransient<IShelfService, ShelfService>();
builder.Services.AddTransient<IStatisticsService, StatisticsService>();
builder.Services.AddTransient<IUserService, UserService>();
builder.Services.AddTransient<IUserRoleService, UserRoleService>();
builder.Services.AddTransient<IShelfBooksService, ShelfBooksService>();
builder.Services.AddTransient<IPostService, PostService>();
builder.Services.AddTransient<ICommentService, CommentService>();



// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
});


var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();



app.UseAuthorization();

app.MapControllers();
//app.Urls.Add("http://0.0.0.0:5000");

app.Run();
