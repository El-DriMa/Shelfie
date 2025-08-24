using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Shelfie.Models.Requests;
using Shelfie.Models.SearchObjects;
using Shelfie.Services.Database;
using Shelfie.Services.Interfaces;
using Shelfie.Models.Responses;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;
using MapsterMapper;
using System.ComponentModel.DataAnnotations;
using Shelfie.Services.Services;
using Shelfie.Services.Helpers;
using System.Text;

namespace ShelfieAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class UserController : BaseCRUDController<UserResponse, UserSearchObject, UserInsertRequest, UserUpdateRequest>
    {
        private readonly IB220155Context _context;
        private readonly IMapper _mapper;
        public UserController(ILogger<BaseController<UserResponse, UserSearchObject>> logger, IUserService service, IB220155Context context, IMapper mapper) : base(logger, service)
        {
            _context = context;
            _mapper = mapper;
        }

        [HttpGet("me")]
        public async Task<IActionResult> GetCurrentUser([FromServices] IUserService userService)
        {
            var userIdStr = HttpContext.User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (!int.TryParse(userIdStr, out int userId))
                return Unauthorized();

            var appType = HttpContext.Request.Headers["X-App-Type"].FirstOrDefault() ?? "swagger";

            var user = await userService.GetCurrentUser(userId, appType);
            if (user == null)
                return NotFound();

            return Ok(user);
        }

        [HttpPost("change-password")]
        public async Task<IActionResult> ChangePassword([FromBody] ChangePasswordRequest request, [FromServices] IUserService userService)
        {
            var userIdStr = HttpContext.User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (!int.TryParse(userIdStr, out int userId))
                return Unauthorized();

            try
            {
                await userService.ChangePassword(userId, request);
                return Ok("Password has been changed successfully");
            }
            catch (ValidationException ex)
            {
                return BadRequest(ex.Message);
            }
        }

        [HttpPost("{id}/cover")]
        [RequestSizeLimit(10_000_000)]
        public async Task<ActionResult<UserResponse>> UploadCover(int id, [FromForm] CoverUploadRequest request, [FromServices] IUserService userService, [FromServices] IWebHostEnvironment env)
        {
            try
            {
                var coverImage = request.CoverImage;
                var user = await userService.GetById(id);
                if (user == null)
                    return NotFound($"User with ID {id} not found");
                if (coverImage == null || coverImage.Length == 0)
                    return BadRequest("No file uploaded or file is empty.");

                var currentUserIdStr = HttpContext.User.FindFirstValue(ClaimTypes.NameIdentifier);
                if (!int.TryParse(currentUserIdStr, out int currentUserId))
                    return Unauthorized();

                var isAdmin = User.IsInRole("Admin");
                if (id != currentUserId && !isAdmin)
                    return BadRequest("You can only upload cover for your own profile");

                var uploads = Path.Combine(env.WebRootPath ?? Path.Combine(Directory.GetCurrentDirectory(), "wwwroot"), "covers");
                if (!Directory.Exists(uploads))
                    Directory.CreateDirectory(uploads);

                var fileName = Guid.NewGuid() + Path.GetExtension(coverImage.FileName);
                var filePath = Path.Combine(uploads, fileName);
                using (var stream = new FileStream(filePath, FileMode.Create))
                {
                    await coverImage.CopyToAsync(stream);
                }

                var userEntityForUpdate = await _context.Users.FindAsync(id);
                if (userEntityForUpdate != null)
                {
                    userEntityForUpdate.PhotoUrl = $"covers/{fileName}";
                    await _context.SaveChangesAsync();

                    var updatedUser = await userService.GetById(id);
                    return Ok(updatedUser);
                }
                return NotFound($"User entity with ID {id} not found in database");
            }
            catch (Exception ex)
            {
                return BadRequest($"Error uploading cover: {ex.Message}");
            }
        }

        [HttpPost("login/admin")]
        public async Task<IActionResult> LoginAdmin([FromHeader(Name = "Authorization")] string authHeader)
        {
            var user = await ValidateUser(authHeader);
            if (user == null)
                return Unauthorized(new { message = "Wrong credentials" });

            bool isAdmin = user.UserRoles.Any(ur => ur.Role.Name == "Admin");
            if (!isAdmin)
                return Unauthorized(new { message = "You don't have access to admin app" });

            return Ok(new { message = "Admin login successful" });
        }

        [HttpPost("login/user")]
        public async Task<IActionResult> LoginUser([FromHeader(Name = "Authorization")] string authHeader)
        {
            var user = await ValidateUser(authHeader);
            if (user == null)
                return Unauthorized(new { message = "Wrong credentials" });

            bool isRegularUser = user.UserRoles.Any(ur => ur.Role.Name == "User");
            if (!isRegularUser)
                return Unauthorized(new { message = "You don't have access to this app" });

            return Ok(new { message = "User login successful" });
        }

        private async Task<User?> ValidateUser(string authHeader)
        {
            if (string.IsNullOrEmpty(authHeader) || !authHeader.StartsWith("Basic "))
                return null;

            var encoded = authHeader.Substring("Basic ".Length).Trim();
            var bytes = Convert.FromBase64String(encoded);
            var parts = Encoding.UTF8.GetString(bytes).Split(':');
            if (parts.Length != 2) return null;

            var user = await _context.Users.Include(u => u.UserRoles).ThenInclude(ur => ur.Role)
                .FirstOrDefaultAsync(u => u.Username == parts[0]);

            if (user == null || !PasswordHelper.VerifyPassword(parts[1], user.PasswordHash, user.PasswordSalt))
                return null;

            user.LastLoginAt = DateTime.Now;
            await _context.SaveChangesAsync();

            return user;
        }

        [HttpPost("admin-change-password")]
        public async Task<IActionResult> AdminChangePassword(
            [FromBody] AdminChangePasswordRequest request,
            [FromServices] IUserService userService)
        {
            var currentUserIdStr = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (!int.TryParse(currentUserIdStr, out int currentUserId))
                return Unauthorized();

            if (request.UserId == currentUserId)
                return BadRequest("Cannot reset your own password via admin endpoint. Use your own change password screen.");

            await userService.AdminChangePassword(request.UserId, request.NewPassword);
            return Ok("Password has been changed successfully");
        }


    }
}
