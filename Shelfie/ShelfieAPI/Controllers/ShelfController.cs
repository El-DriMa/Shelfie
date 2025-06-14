using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Shelfie.Models.Requests;
using Shelfie.Models.SearchObjects;
using Shelfie.Services.Database;
using Shelfie.Services.Interfaces;
using Shelfie.Models.Responses;
using System.Security.Claims;

namespace ShelfieAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class ShelfController : BaseCRUDController<ShelfResponse, ShelfSearchObject, ShelfInsertRequest, ShelfUpdateRequest>
    {
        private readonly IShelfService _service;
        public ShelfController(ILogger<BaseController<ShelfResponse, ShelfSearchObject>> logger, IShelfService service) : base(logger, service)
        {
            _service = service;
        }

        [HttpGet("user")]
        public async Task<PagedResult<ShelfResponse>> GetForUser([FromQuery] ShelfSearchObject search)
        {
            var userIdStr = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (!int.TryParse(userIdStr, out int userId))
                return new PagedResult<ShelfResponse> { Items = new List<ShelfResponse>(), TotalCount = 0 };

            var result = await _service.GetPagedForUser(search, userId);

            return result ?? new PagedResult<ShelfResponse> { Items = new List<ShelfResponse>(), TotalCount = 0 };
        }
    }
}
