﻿using Microsoft.AspNetCore.Authorization;
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
        public async Task<IActionResult> GetCurrentUser()
        {
            var userIdStr = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (!int.TryParse(userIdStr, out int userId))
                return Unauthorized();

            var user = await _context.Users.FindAsync(userId);
            if (user == null)
                return NotFound();

            return Ok(_mapper.Map<UserResponse>(user));
        }
    }
}
