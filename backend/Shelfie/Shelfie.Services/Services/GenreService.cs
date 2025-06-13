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
    public class GenreService : BaseCRUDService<GenreResponse, GenreSearchObject, Genre, GenreInsertRequest, GenreUpdateRequest>, IGenreService
    {
        public GenreService(IB220155Context context, IMapper mapper) : base(context, mapper)
        {
        }
        public override IQueryable<Genre> AddFilter(GenreSearchObject search, IQueryable<Genre> query)
        {
            if (!string.IsNullOrWhiteSpace(search.Name))
            {
                query = query.Where(g => g.Name.Contains(search.Name));
            }

            return query;
        }
    }
}
