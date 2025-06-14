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
    
    }
}
