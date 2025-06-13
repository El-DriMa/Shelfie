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
    public class ReadingChallengeController : BaseCRUDController<ReadingChallengeResponse, ReadingChallengeSearchObject, ReadingChallengeInsertRequest, ReadingChallengeUpdateRequest>
    {
        private readonly IReadingChallengeService _service;
        public ReadingChallengeController(ILogger<BaseController<ReadingChallengeResponse, ReadingChallengeSearchObject>> logger, IReadingChallengeService service) : base(logger, service)
        {
            _service = service;
        }

        [HttpGet("user")]
        public async Task<PagedResult<ReadingChallengeResponse>> GetForUser([FromQuery] ReadingChallengeSearchObject search)
        {
            var userIdStr = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (!int.TryParse(userIdStr, out int userId))
                return new PagedResult<ReadingChallengeResponse> { Items = new List<ReadingChallengeResponse>(), TotalCount = 0 };

            var result = await _service.GetPagedForUser(search, userId);

            return result ?? new PagedResult<ReadingChallengeResponse> { Items = new List<ReadingChallengeResponse>(), TotalCount = 0 };
        }
    }
}
