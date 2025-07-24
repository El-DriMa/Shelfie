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
    public class ShelfService : BaseCRUDService<ShelfResponse, ShelfSearchObject, Shelf, ShelfInsertRequest, ShelfUpdateRequest>, IShelfService
    {
        public ShelfService(IB220155Context context, IMapper mapper) : base(context, mapper)
        {
        }

        public override IQueryable<Shelf> AddFilter(ShelfSearchObject search, IQueryable<Shelf> query)
        {
            if (search.UserId.HasValue)
            {
                query = query.Where(s => s.UserId == search.UserId.Value);
            }

            if (search.Name.HasValue)
            {
                query = query.Where(s => s.Name == search.Name.Value);
            }

            if (search.BooksCount.HasValue)
            {
                query = query.Where(s => s.BooksCount == search.BooksCount.Value);
            }

            return query;
        }

        public async Task<PagedResult<ShelfResponse>> GetPagedForUser(ShelfSearchObject search, int userId)
        {
            var query = _db.Shelves.Where(s => s.UserId == userId).AsQueryable();

            int totalCount = await query.CountAsync();

            if (search?.Page.HasValue == true && search?.PageSize.HasValue == true)
                query = query.Skip(search.Page.Value * search.PageSize.Value).Take(search.PageSize.Value);

            var list = await query.ToListAsync();
            var result = Mapper.Map<List<ShelfResponse>>(list);

            return new PagedResult<ShelfResponse> { Items = result ?? new(), TotalCount = totalCount };
        }

     
    }
}
