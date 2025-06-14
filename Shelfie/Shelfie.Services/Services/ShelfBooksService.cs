using MapsterMapper;
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
    }
}
