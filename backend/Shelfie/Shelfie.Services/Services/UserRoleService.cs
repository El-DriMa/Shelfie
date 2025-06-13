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
    public class UserRoleService : BaseCRUDService<UserRoleResponse, UserRoleSearchObject, UserRole, UserRoleInsertRequest, UserRoleUpdateRequest>, IUserRoleService
    {
        public UserRoleService(IB220155Context context, IMapper mapper) : base(context, mapper)
        {
        }

        public override IQueryable<UserRole> AddFilter(UserRoleSearchObject search, IQueryable<UserRole> query)
        {
            if (search.UserId.HasValue)
            {
                query = query.Where(ur => ur.UserId == search.UserId.Value);
            }

            return query;
        }
    }
}
