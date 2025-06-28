using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using Shelfie.Models.Requests;
using Shelfie.Models.Responses;
using Shelfie.Models.SearchObjects;
using Shelfie.Services.Database;
using Shelfie.Services.Interfaces;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection.Metadata.Ecma335;
using System.Text;
using System.Threading.Tasks;

namespace Shelfie.Services.Services
{
    public class BookService : BaseCRUDService<BookResponse,BookSearchObject,Book,BookInsertRequest,BookUpdateRequest>, IBookService
    {
        public BookService(IB220155Context context,IMapper mapper) : base (context,mapper)
        {
            
        }
        public override async Task BeforeInsert(BookInsertRequest request, Book entity)
        {
            if (_db.Books.Any(b => b.Title == request.Title && b.AuthorId == request.AuthorId))
            {
               throw new InvalidOperationException("A book with the same title and author already exists.");
            }
        }

        public override async Task<BookResponse> Insert(BookInsertRequest request)
        {
            var entity = Mapper.Map<Book>(request);

            await _db.AddAsync(entity);
            await BeforeInsert(request, entity);
            await _db.SaveChangesAsync();

            await _db.Entry(entity).Reference(b => b.Genre).LoadAsync();
            await _db.Entry(entity).Reference(b => b.Author).LoadAsync();
            await _db.Entry(entity).Reference(b => b.Publisher).LoadAsync();

            var response = Mapper.Map<BookResponse>(entity);

            return response;
        }


        public override IQueryable<Book> AddFilter(BookSearchObject search, IQueryable<Book> query)
        {
            query = query
                   .Include(b => b.Genre)
                   .Include(b => b.Author)
                   .Include(b => b.Publisher);


            if (!string.IsNullOrWhiteSpace(search.FTS))
            {
                query = query.Where(b =>
                    b.Title.Contains(search.FTS) ||
                    b.Author.FirstName.Contains(search.FTS) ||
                    b.Author.LastName.Contains(search.FTS) ||
                    b.Genre.Name.Contains(search.FTS) ||
                    b.Publisher.Name.Contains(search.FTS));
            }

            if (!string.IsNullOrWhiteSpace(search.Title))
            {
                query = query.Where(b => b.Title.Contains(search.Title));
            }

            if (!string.IsNullOrWhiteSpace(search.GenreName))
            {
                query = query.Where(b => b.Genre.Name.Contains(search.GenreName));
            }

            if (!string.IsNullOrWhiteSpace(search.AuthorName))
            {
                query = query.Where(b =>
                    b.Author.FirstName.Contains(search.AuthorName) ||
                    b.Author.LastName.Contains(search.AuthorName));
            }

            if (!string.IsNullOrWhiteSpace(search.PublisherName))
            {
                query = query.Where(b => b.Publisher.Name.Contains(search.PublisherName));
            }

            return query;
        }



        public override async Task<PagedResult<BookResponse>> GetPaged(BookSearchObject search)
        {
            var query = _db.Books.AsQueryable();
            query = AddFilter(search, query);

            var totalCount = await query.CountAsync();

            if (search.Page.HasValue && search.PageSize.HasValue)
            {
                int skip = (search.Page.Value - 1) * search.PageSize.Value;
                query = query.Skip(skip).Take(search.PageSize.Value);
            }

            var list = await query.ToListAsync();

            var result = list.Select(b =>
            {
                var response = Mapper.Map<BookResponse>(b);
                response.AuthorName = $"{b.Author.FirstName} {b.Author.LastName}".Trim();
                return response;
            }).ToList();

            return new PagedResult<BookResponse>
            {
                Items = result,
                TotalCount = totalCount
            };
        }

        public async Task<PagedResult<BookResponse>> GetPagedForUser(BookSearchObject search, int userId)
        {
            var baseQuery = _db.ShelfBooks
                .Include(sb => sb.Shelf)
                .Include(sb => sb.Book)
                .Where(sb => sb.Shelf.UserId == userId)
                .Select(sb => sb.Book)
                .AsQueryable();

            int totalCount = await baseQuery.CountAsync();

            if (totalCount == 0)
            {
                return new PagedResult<BookResponse> { Items = new List<BookResponse>(), TotalCount = 0 };
            }

            if (search?.Page.HasValue == true && search?.PageSize.HasValue == true)
            {
                baseQuery = baseQuery.Skip(search.Page.Value * search.PageSize.Value).Take(search.PageSize.Value);
            }

            var list = await baseQuery.ToListAsync();

            var result = Mapper.Map<List<BookResponse>>(list) ?? new List<BookResponse>();

            return new PagedResult<BookResponse>
            {
                Items = result,
                TotalCount = totalCount
            };
        }

        public async Task<BookResponse> GetById(int id)
        {
            var book = await _db.Books
                .Include(b => b.Genre)
                .Include(b => b.Author)
                .Include(b => b.Publisher)
                .FirstOrDefaultAsync(b => b.Id == id);

            if (book == null)
            {
                throw new KeyNotFoundException($"Book with ID {id} not found.");
            }

            var response = Mapper.Map<BookResponse>(book);
            response.AuthorName = $"{book.Author.FirstName} {book.Author.LastName}".Trim();

            return response;
        }


    }
}

