using Microsoft.EntityFrameworkCore;
using Shelfie.Services.Database;
using Shelfie.Services.Helpers;
using Shelfie.Services.Interfaces;
using System.Security.Claims;
using System.Text;

namespace ShelfieAPI.Authentication
{
    public class BasicAuthMiddleware
    {
        private readonly RequestDelegate _next;

        public BasicAuthMiddleware(RequestDelegate next) => _next = next;

        public async Task InvokeAsync(HttpContext context, IB220155Context db)
        {
            if (context.Request.Path.StartsWithSegments("/User") && context.Request.Method == HttpMethods.Post)
            {
                await _next(context);
                return;
            }

            if (context.Request.Path.StartsWithSegments("/covers"))
            {
                await _next(context);
                return;
            }
            if (context.Request.Path.StartsWithSegments("/api/dataseed") 
               )
            {
                await _next(context);
                return;
            }
            if (!context.Request.Headers.TryGetValue("Authorization", out var authHeader) ||
                !authHeader.ToString().StartsWith("Basic "))
            {
                context.Response.StatusCode = 401;
                await context.Response.WriteAsync("Authentication required");
                return;
            }

            var encodedCredentials = authHeader.ToString().Substring("Basic ".Length).Trim();
            var credentialBytes = Convert.FromBase64String(encodedCredentials);
            var credentials = Encoding.UTF8.GetString(credentialBytes).Split(':');
            if (credentials.Length != 2)
            {
                context.Response.StatusCode = 401;
                await context.Response.WriteAsync("Invalid authentication header");
                return;
            }

            var username = credentials[0];
            var password = credentials[1];

            var user = db.Users.Include(u => u.UserRoles).ThenInclude(ur => ur.Role)
                .FirstOrDefault(u => u.Username == username);

            if (user == null || !PasswordHelper.VerifyPassword(password, user.PasswordHash, user.PasswordSalt))
            {
                context.Response.StatusCode = 401;
                await context.Response.WriteAsync("Invalid username or password");
                return;
            }
            
            user.LastLoginAt = DateTime.Now;
            await db.SaveChangesAsync();

            var claims = new List<Claim>
        {
            new Claim(ClaimTypes.Name, user.Username),
            new Claim(ClaimTypes.NameIdentifier, user.Id.ToString())
        };

            foreach (var role in user.UserRoles)
                claims.Add(new Claim(ClaimTypes.Role, role.Role.Name));

            var identity = new ClaimsIdentity(claims, "Basic");
            context.User = new ClaimsPrincipal(identity);

            await _next(context);
        }
    }
}