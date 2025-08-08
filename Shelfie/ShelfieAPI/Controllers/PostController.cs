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
    public class PostController : BaseCRUDController<PostResponse, PostSearchObject, PostInsertRequest, PostUpdateRequest>
    {
        private readonly IPostService _service;
        public PostController(ILogger<BaseController<PostResponse, PostSearchObject>> logger, IPostService service) : base(logger, service)
        {
            _service = service;
        }


        [HttpGet("user")]
        public async Task<PagedResult<PostResponse>> GetForUser([FromQuery] PostSearchObject search)
        {
            var userIdStr = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (!int.TryParse(userIdStr, out int userId))
                return new PagedResult<PostResponse> { Items = new List<PostResponse>(), TotalCount = 0 };

            var result = await _service.GetPagedForUser(search, userId);

            return result ?? new PagedResult<PostResponse> { Items = new List<PostResponse>(), TotalCount = 0 };
        }


        [HttpGet("user/{genreId}")]
        public async Task<PagedResult<PostResponse>> GetForUserByGenre(int genreId,[FromQuery] PostSearchObject search)
        {
            var userIdStr = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (!int.TryParse(userIdStr, out int userId))
                return new PagedResult<PostResponse> { Items = new List<PostResponse>(), TotalCount = 0 };

            var result = await _service.GetPagedForUserByGenre(search, userId, genreId);

            return result ?? new PagedResult<PostResponse> { Items = new List<PostResponse>(), TotalCount = 0 };
        }

        [HttpGet("Genre/{genreId}")]
        public async Task<PagedResult<PostResponse>> GetByGenre(int genreId,[FromQuery] PostSearchObject search)
        {

            var result = await _service.GetPagedByGenre(search, genreId);

            return result ?? new PagedResult<PostResponse> { Items = new List<PostResponse>(), TotalCount = 0 };
        }


    }
}

