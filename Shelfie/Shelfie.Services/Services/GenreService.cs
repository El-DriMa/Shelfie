using MapsterMapper;
using Shelfie.Models.Requests;
using Shelfie.Models.Responses;
using Shelfie.Models.SearchObjects;
using Shelfie.Services.Database;
using Shelfie.Services.Interfaces;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
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

        public override async Task BeforeInsert(GenreInsertRequest request, Genre entity)
        {
            if (_db.Genres.Any(g => g.Name == request.Name))
                throw new ValidationException("A genre with the same name already exists.");

            entity.IsActive = true;
            await Task.CompletedTask;
        }

        public override async Task BeforeUpdate(GenreUpdateRequest request, Genre entity)
        {
            if (_db.Genres.Any(g => g.Name == request.Name && g.Id != entity.Id))
                throw new ValidationException("A genre with the same name already exists.");

            entity.ModifiedAt = DateTime.Now;
            await Task.CompletedTask;
        }

    }
}
