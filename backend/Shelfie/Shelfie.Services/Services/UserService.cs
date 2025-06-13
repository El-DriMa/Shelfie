using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using Shelfie.Models.Requests;
using Shelfie.Models.Responses;
using Shelfie.Models.SearchObjects;
using Shelfie.Services.Database;
using Shelfie.Services.Helpers;
using Shelfie.Services.Interfaces;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Shelfie.Services.Services
{
    public class UserService : BaseCRUDService<UserResponse, UserSearchObject, User, UserInsertRequest, UserUpdateRequest>, IUserService
    {
        public UserService(IB220155Context context, IMapper mapper) : base(context, mapper)
        {
        }
        public override IQueryable<User> AddFilter(UserSearchObject search, IQueryable<User> query)
        {
            if (!string.IsNullOrWhiteSpace(search.FTS))
            {
                query = query.Where(u => u.FirstName.Contains(search.FTS) || u.LastName.Contains(search.FTS));
            }

            return query;
        }

        public override async Task<UserResponse> Insert(UserInsertRequest request)
        {
            PasswordHelper.CreatePasswordHash(request.Password, out string hash, out string salt);

            var user = Mapper.Map<User>(request);
            user.PasswordHash = hash;
            user.PasswordSalt = salt;

            var role = await _db.Roles.FirstOrDefaultAsync(r => r.Name == "User");
            if (role != null)
            {
                user.UserRoles.Add(new UserRole
                {
                    RoleId = role.Id,
                    User = user
                });
            }

            await _db.Users.AddAsync(user);
            await _db.SaveChangesAsync();

            return Mapper.Map<UserResponse>(user);
        }

    }
}
