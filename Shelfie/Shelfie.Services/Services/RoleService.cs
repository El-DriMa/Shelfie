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
    public class RoleService : BaseService<RoleResponse, RoleSearchObject, Role>, IRoleService
    {
        public RoleService(IB220155Context context, IMapper mapper) : base(context, mapper)
        {
        }

        public override IQueryable<Role> AddFilter(RoleSearchObject search, IQueryable<Role> query)
        {
            if (!string.IsNullOrWhiteSpace(search.Name))
            {
                query = query.Where(r => r.Name.Contains(search.Name));
            }

            return query;
        }

    }
}
