using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Shelfie.Models.Requests;
using Shelfie.Models.SearchObjects;
using Shelfie.Services.Database;
using Shelfie.Services.Interfaces;
using Shelfie.Models.Responses;
using System.Security.Claims;
using Microsoft.EntityFrameworkCore;
using MapsterMapper;
using System.Runtime.CompilerServices;

namespace ShelfieAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class BookController : BaseCRUDController<BookResponse, BookSearchObject, BookInsertRequest, BookUpdateRequest>
    {
        private readonly IBookService _bookService;
        private readonly IMapper _mapper;
        private readonly IB220155Context _context;

        public BookController(ILogger<BaseController<BookResponse, BookSearchObject>> logger, IBookService service, IB220155Context context, IMapper mapper) : base(logger, service)
        {
            _bookService = service;
            _context = context;
            _mapper = mapper;
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

        [HttpGet("recommended/{userId}")]
        public async Task<IActionResult> GetRecommendedBooks(int userId)
        {
            var userBookIds = await _context.ShelfBooks
                .Where(sb => sb.Shelf.UserId == userId)
                .Select(sb => sb.BookId)
                .ToListAsync();

            var genres = await _context.ShelfBooks
                .Where(sb => sb.Shelf.UserId == userId)
                .Select(sb => sb.Book.GenreId)
                .Distinct()
                .ToListAsync();

            var authors = await _context.ShelfBooks
                .Where(sb => sb.Shelf.UserId == userId)
                .Select(sb => sb.Book.AuthorId)
                .Distinct()
                .ToListAsync();

            var recommendedBooks = await _context.Books
                .Include(b => b.Genre)
                .Include(b => b.Author)
                .Include(b=>b.Publisher)
                .Where(b => (genres.Contains(b.GenreId) || authors.Contains(b.AuthorId))
                            && !userBookIds.Contains(b.Id))
                .ToListAsync();

            var result = recommendedBooks.Select(b =>
            {
                var response = _mapper.Map<BookResponse>(b);
                response.AuthorName = $"{b.Author.FirstName} {b.Author.LastName}".Trim();
                return response;
            }).ToList();

            var pagedResult = new PagedResult<BookResponse>
            {
                Items = result,
                TotalCount = result.Count
            };

            return Ok(pagedResult);
        }

    }
}
