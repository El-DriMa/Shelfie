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
    public class AuthorService : BaseCRUDService<AuthorResponse, AuthorSearchObject, Author, AuthorInsertRequest, AuthorUpdateRequest>, IAuthorService
    {
        public AuthorService(IB220155Context context, IMapper mapper) : base(context, mapper)
        {
        }

        public override async Task BeforeInsert(AuthorInsertRequest request, Author entity)
        {
      
            if (_db.Authors.Any(a => a.FirstName == request.FirstName && a.LastName == request.LastName))
            {
                throw new ValidationException("An author with the same name already exists.");
            }
        }
        public override IQueryable<Author> AddFilter(AuthorSearchObject search, IQueryable<Author> query)
        {
            if (!string.IsNullOrWhiteSpace(search.FTS))
            {
                query = query.Where(a =>
                    a.FirstName.Contains(search.FTS) ||
                    a.LastName.Contains(search.FTS));
            }

            return query;
        }

        public override async Task BeforeUpdate(AuthorUpdateRequest request, Author entity)
        {
            if (!string.IsNullOrWhiteSpace(request.FirstName))
                entity.FirstName = request.FirstName;

            if (!string.IsNullOrWhiteSpace(request.LastName))
                entity.LastName = request.LastName;

            if (!string.IsNullOrWhiteSpace(request.BirthCountry))
                entity.BirthCountry = request.BirthCountry;

            if (request.BirthDate.HasValue)
                entity.BirthDate = request.BirthDate.Value;

            if (request.DeathDate.HasValue)
                entity.DeathDate = request.DeathDate.Value;

            if (!string.IsNullOrWhiteSpace(request.ShortBio))
                entity.ShortBio = request.ShortBio;

            if (_db.Authors.Any(a =>
                a.Id != entity.Id &&
                a.FirstName == entity.FirstName &&
                a.LastName == entity.LastName))
            {
                throw new ValidationException("An author with the same name already exists.");
            }

            if (entity.DeathDate.HasValue && entity.DeathDate.Value <= entity.BirthDate)
            {
                throw new ValidationException("Death date must be after birth date.");
            }

            await Task.CompletedTask;
        }

        public override async Task BeforeDelete(Author entity)
        {
            if (_db.Books.Any(b => b.AuthorId == entity.Id))
            {
                throw new ValidationException("Author cannot be deleted because there are books linked to this author.");
            }
            await Task.CompletedTask;
        }



    }
}
