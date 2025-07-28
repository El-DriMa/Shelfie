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
using System.Text;
using System.Threading.Tasks;

namespace Shelfie.Services.Services
{
    public class ShelfBooksService : BaseCRUDService<ShelfBooksResponse, ShelfBooksSearchObject, ShelfBooks, ShelfBooksInsertRequest, ShelfBooksUpdateRequest> ,IShelfBooksService
    {
        public ShelfBooksService(IB220155Context context, IMapper mapper) : base(context, mapper)
        {
        }

        public override IQueryable<ShelfBooks> AddFilter(ShelfBooksSearchObject search, IQueryable<ShelfBooks> query)
        {
            if (search.ShelfId.HasValue)
            {
                query = query.Where(sb => sb.ShelfId == search.ShelfId.Value);
            }

            if (search.BookId.HasValue)
            {
                query = query.Where(sb => sb.BookId == search.BookId.Value);
            }

            return query;
        }

        public override async Task BeforeInsert(ShelfBooksInsertRequest request, ShelfBooks entity)
        {
            var shelf = await _db.Shelves.FindAsync(request.ShelfId);
            var userId = shelf?.UserId;

            var existing = await _db.ShelfBooks
                .Include(sb => sb.Shelf)
                .Where(sb => sb.BookId == request.BookId && sb.Shelf.UserId == userId)
                .FirstOrDefaultAsync();

            if (existing != null)
            {
                throw new InvalidOperationException("This book is already in one of your shelves.");
            }
        }

        public override async Task<ShelfBooksResponse> Insert(ShelfBooksInsertRequest request)
        {
            var entity = Mapper.Map<ShelfBooks>(request);

            await _db.AddAsync(entity);
            await BeforeInsert(request, entity);
            var shelf = await _db.Shelves.Where(x=>x.Id==request.ShelfId).FirstOrDefaultAsync();
            if(shelf != null)
            {
                shelf.BooksCount++;
                shelf.ModifiedAt = DateTime.UtcNow;
            }
            await _db.SaveChangesAsync();

            var response = Mapper.Map<ShelfBooksResponse>(entity);

            return response;
        }


        public override async Task<PagedResult<ShelfBooksResponse>> GetPaged(ShelfBooksSearchObject search)
        {
            var query = _db.ShelfBooks
                .Include(sb => sb.Shelf)
                .Include(sb => sb.Book).ThenInclude(sb=>sb.Author)
                .AsQueryable();
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
                var response = Mapper.Map<ShelfBooksResponse>(b);
                response.AuthorName = $"{b.Book.Author.FirstName} {b.Book.Author.LastName}".Trim();
                response.TotalPages = b.Book.TotalPages;

                return response;
            }).ToList();

            return new PagedResult<ShelfBooksResponse>
            {
                Items = result,
                TotalCount = totalCount
            };
        }
        public override async Task BeforeDelete(ShelfBooks entity) {
            var shelf = await _db.Shelves.Where(x=>x.Id==entity.ShelfId).FirstOrDefaultAsync();
            if (shelf != null)
            {
                shelf.BooksCount--;
                shelf.ModifiedAt= DateTime.UtcNow;
            }
        }
        public override async Task<bool> Delete(int id)
        {
            var set = _db.Set<ShelfBooks>();

            var entity = await set.FindAsync(id);
            if (entity == null)
            {
                return false;
            }

            await BeforeDelete(entity);
            set.Remove(entity);

            await _db.SaveChangesAsync();

            return true;
        }

        public override async Task BeforeUpdate(ShelfBooksUpdateRequest request, ShelfBooks entity)
        {
            Console.WriteLine("BEFORE UPDATE CALLED");
            if (request.PagesRead < entity.PagesRead || request.PagesRead > entity.Book.TotalPages)
            {
                throw new InvalidOperationException("Pages read cannot be decreased or exceed the total number of pages.");
            }
        }

        public override async Task<ShelfBooksResponse> Update(int id, ShelfBooksUpdateRequest request)
        {
            var set = _db.Set<ShelfBooks>();

            var entity = await set
                .Include(x => x.Book)
                .FirstOrDefaultAsync(x => x.Id == id);

            await BeforeUpdate(request, entity);

            Mapper.Map(request, entity);


            await _db.SaveChangesAsync();

            return Mapper.Map<ShelfBooksResponse>(entity);
        }
    }
}
