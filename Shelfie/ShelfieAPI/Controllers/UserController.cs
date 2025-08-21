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



    }
}
