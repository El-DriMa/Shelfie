using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using Shelfie.Models.Enums;
using Shelfie.Models.Requests;
using Shelfie.Models.Responses;
using Shelfie.Models.SearchObjects;
using Shelfie.Services.Database;
using Shelfie.Services.Interfaces;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Shelfie.Services.Services
{
    public class StatisticsService : BaseService<StatisticsResponse, StatisticsSearchObject, Statistics>, IStatisticsService
    {
        public StatisticsService(IB220155Context db, IMapper mapper) : base(db, mapper)
        {
        }
        public override IQueryable<Statistics> AddFilter(StatisticsSearchObject search, IQueryable<Statistics> query)
        {
            if (search.UserId.HasValue)
            {
                query = query.Where(s => s.UserId == search.UserId.Value);
            }

            return query;
        }

        public async Task<PagedResult<StatisticsResponse>> GetPagedForUser(StatisticsSearchObject search, int userId)
        {
            var totalReadBooks = await _db.ShelfBooks
                .Where(x => x.Shelf.Name == ShelfTypeEnum.Read && x.Shelf.UserId == userId)
                .CountAsync();

            var totalBooksInShelf = await _db.ShelfBooks
                .Where(x => x.Shelf.UserId == userId)
                .CountAsync();

            var totalPagesRead = await _db.ShelfBooks
                .Where(x => x.Shelf.Name == ShelfTypeEnum.Read && x.Shelf.UserId == userId)
                .SumAsync(x => x.PagesRead);

            var mostReadGenreName = await _db.ShelfBooks
                .Where(x => x.Shelf.Name == ShelfTypeEnum.Read && x.Shelf.UserId == userId)
                .GroupBy(x => x.Book.Genre)
                .OrderByDescending(g => g.Count())
                .Select(g => g.Key.Name)
                .FirstOrDefaultAsync() ?? "No data";

            var bookWithLeastPages = await _db.ShelfBooks
                .Where(x => x.Shelf.Name == ShelfTypeEnum.Read && x.Shelf.UserId == userId)
                .OrderBy(x => x.Book.TotalPages)
                .Select(x => new { x.Book.Title, x.Book.TotalPages })
                .FirstOrDefaultAsync();

            var bookWithMostPages = await _db.ShelfBooks
                .Where(x => x.Shelf.Name == ShelfTypeEnum.Read && x.Shelf.UserId == userId)
                .OrderByDescending(x => x.Book.TotalPages)
                .Select(x => new { x.Book.Title, x.Book.TotalPages })
                .FirstOrDefaultAsync();

            var firstBookReadDate = await _db.ShelfBooks
                .Where(x => x.Shelf.Name == ShelfTypeEnum.Read && x.Shelf.UserId == userId)
                .OrderBy(x => x.CreatedAt)
                .Select(x => (DateTime?)x.CreatedAt)
                .FirstOrDefaultAsync();

            var lastBookReadDate = await _db.ShelfBooks
                .Where(x => x.Shelf.Name == ShelfTypeEnum.Read && x.Shelf.UserId == userId)
                .OrderByDescending(x => x.CreatedAt)
                .Select(x => (DateTime?)x.CreatedAt)
                .FirstOrDefaultAsync();

            var uniqueGenres = await _db.ShelfBooks
                .Where(x => x.Shelf.Name == ShelfTypeEnum.Read && x.Shelf.UserId == userId)
                .Select(x => x.Book.Genre.Name)
                .Distinct()
                .ToListAsync();

            var uniqueGenresCount = uniqueGenres.Count;

            var topAuthor = await _db.ShelfBooks
                .Where(x => x.Shelf.Name == ShelfTypeEnum.Read && x.Shelf.UserId == userId)
                .GroupBy(x => new { x.Book.AuthorId, x.Book.Author.FirstName, x.Book.Author.LastName })
                .OrderByDescending(g => g.Count())
                .Select(g => new
                {
                    g.Key.AuthorId,
                    FullName = g.Key.FirstName + " " + g.Key.LastName
                })
                .FirstOrDefaultAsync();

            int topAuthorId = topAuthor?.AuthorId ?? 0;
            string topAuthorName = topAuthor?.FullName ?? "No data";

            var result = new StatisticsResponse
            {
                UserId = userId,
                TotalReadBooks = totalReadBooks,
                TotalBooksInShelf = totalBooksInShelf,
                TotalPagesRead = (int)totalPagesRead,
                MostReadGenreName = mostReadGenreName,
                BookWithLeastPagesTitle = bookWithLeastPages?.Title ?? "No data",
                BookWithLeastPagesCount = bookWithLeastPages?.TotalPages ?? 0,
                BookWithMostPagesTitle = bookWithMostPages?.Title ?? "No data",
                BookWithMostPagesCount = bookWithMostPages?.TotalPages ?? 0,
                FirstBookReadDate = firstBookReadDate,
                LastBookReadDate = lastBookReadDate,
                UniqueGenresCount = uniqueGenresCount,
                UniqueGenresNames = uniqueGenres,
                TopAuthorId = topAuthorId,
                TopAuthor = topAuthorName
            };

            return new PagedResult<StatisticsResponse>
            {
                Items = new List<StatisticsResponse> { result },
                TotalCount = 1
            };
        }
    }
}
