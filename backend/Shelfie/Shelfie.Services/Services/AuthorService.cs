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
    public class AuthorService : BaseCRUDService<AuthorResponse, AuthorSearchObject, Author, AuthorInsertRequest, AuthorUpdateRequest>, IAuthorService
    {
        public AuthorService(IB220155Context context, IMapper mapper) : base(context, mapper)
        {
        }

        public override async Task BeforeInsert(AuthorInsertRequest request, Author entity)
        {
      
            if (_db.Authors.Any(a => a.FirstName == request.FirstName && a.LastName == request.LastName))
            {
                throw new InvalidOperationException("An author with the same name already exists.");
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


    }
}
