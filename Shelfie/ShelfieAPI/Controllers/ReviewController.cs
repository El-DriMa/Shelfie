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
    public class ReviewController : BaseCRUDController<ReviewResponse, ReviewSearchObject, ReviewInsertRequest, ReviewUpdateRequest>
    {
        private readonly IReviewService _service;
        public ReviewController(ILogger<BaseController<ReviewResponse, ReviewSearchObject>> logger, IReviewService service) : base(logger, service)
        {
            _service = service;
        }


        [HttpGet("user")]
        public async Task<PagedResult<ReviewResponse>> GetForUser([FromQuery] ReviewSearchObject search)
        {
            var userIdStr = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (!int.TryParse(userIdStr, out int userId))
                return new PagedResult<ReviewResponse> { Items = new List<ReviewResponse>(), TotalCount = 0 };

            var result = await _service.GetPagedForUser(search, userId);

            return result ?? new PagedResult<ReviewResponse> { Items = new List<ReviewResponse>(), TotalCount = 0 };
        }

    }
}
