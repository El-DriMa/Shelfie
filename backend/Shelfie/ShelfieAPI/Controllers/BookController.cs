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
    public class BookController : BaseCRUDController<BookResponse, BookSearchObject, BookInsertRequest, BookUpdateRequest>
    {
        private readonly IBookService _bookService;

        public BookController(ILogger<BaseController<BookResponse, BookSearchObject>> logger, IBookService service) : base(logger, service)
        {
            _bookService = service;
        }


        [HttpGet("user")]
        public async Task<PagedResult<BookResponse>> GetForUser([FromQuery] BookSearchObject search)
        {
            var userIdStr = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (!int.TryParse(userIdStr, out int userId))
                return new PagedResult<BookResponse> { Items = new List<BookResponse>(), TotalCount = 0 };

            var result = await _bookService.GetPagedForUser(search, userId);

            return result ?? new PagedResult<BookResponse> { Items = new List<BookResponse>(), TotalCount = 0 };
        }


    }
}
