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
    public class PublisherService : BaseCRUDService<PublisherResponse, PublisherSearchObject, Publisher, PublisherInsertRequest, PublisherUpdateRequest>, IPublisherService
    {
        public PublisherService(IB220155Context context, IMapper mapper) : base(context, mapper)
        {
        }
        public override IQueryable<Publisher> AddFilter(PublisherSearchObject search, IQueryable<Publisher> query)
        {
            if (!string.IsNullOrWhiteSpace(search.FTS))
            {
                query = query.Where(p =>
                    p.Name.Contains(search.FTS) ||
                    p.ContactEmail.Contains(search.FTS));
            }

            return query;
        }

        public override async Task BeforeInsert(PublisherInsertRequest request, Publisher entity)
        {
            if (_db.Publishers.Any(p => p.Name == request.Name))
                throw new ValidationException("A publisher with the same name already exists.");

            entity.IsActive = true;
            await Task.CompletedTask;
        }

        public override async Task BeforeUpdate(PublisherUpdateRequest request, Publisher entity)
        {
            if (_db.Publishers.Any(p => p.Name == request.Name && p.Id != entity.Id))
                throw new ValidationException("A publisher with the same name already exists.");

            if (!string.IsNullOrWhiteSpace(request.Name))
                entity.Name = request.Name;

            if (!string.IsNullOrWhiteSpace(request.HeadquartersLocation))
                entity.HeadquartersLocation = request.HeadquartersLocation;

            if (!string.IsNullOrWhiteSpace(request.ContactEmail))
                entity.ContactEmail = request.ContactEmail;

            if (!string.IsNullOrWhiteSpace(request.ContactPhone))
                entity.ContactPhone = request.ContactPhone;

            if (request.YearFounded.HasValue && request.YearFounded.Value > 0)
                entity.YearFounded = request.YearFounded.Value;

            if (!string.IsNullOrWhiteSpace(request.Country))
                entity.Country = request.Country;

            entity.ModifiedAt = DateTime.Now;

            await Task.CompletedTask;
        }

    }
}
