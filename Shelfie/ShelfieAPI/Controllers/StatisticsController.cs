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
    public class StatisticsController : BaseController<StatisticsResponse, StatisticsSearchObject>
    {
        private readonly IStatisticsService _service;
        public StatisticsController(ILogger<BaseController<StatisticsResponse, StatisticsSearchObject>> logger, IStatisticsService service) : base(logger, service)
        {
            _service = service;
        }

        [HttpGet("user")]
        public async Task<PagedResult<StatisticsResponse>> GetForUser([FromQuery] StatisticsSearchObject search)
        {
            var userIdStr = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (!int.TryParse(userIdStr, out int userId))
                return new PagedResult<StatisticsResponse> { Items = new List<StatisticsResponse>(), TotalCount = 0 };

            var result = await _service.GetPagedForUser(search, userId);

            return result ?? new PagedResult<StatisticsResponse> { Items = new List<StatisticsResponse>(), TotalCount = 0 };
        }

        [HttpGet("all")]
        public async Task<ActionResult<StatisticsResponse>> GetAll()
        {
            var stats = await _service.GetAppStatisticsAsync();
            return Ok(stats);
        }
    }
}
