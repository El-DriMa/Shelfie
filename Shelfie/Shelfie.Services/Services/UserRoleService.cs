﻿using MapsterMapper;
using Microsoft.EntityFrameworkCore;
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
    public class UserRoleService : BaseCRUDService<UserRoleResponse, UserRoleSearchObject, UserRole, UserRoleInsertRequest, UserRoleUpdateRequest>, IUserRoleService
    {
        public UserRoleService(IB220155Context context, IMapper mapper) : base(context, mapper)
        {
        }

        public override IQueryable<UserRole> AddFilter(UserRoleSearchObject search, IQueryable<UserRole> query)
        {
            if (!string.IsNullOrWhiteSpace(search.RoleName))
            {
                query = query.Where(r => r.Role.Name.Contains(search.RoleName));
            }

            if (search.UserId.HasValue)
            {
                query = query.Where(ur => ur.UserId == search.UserId.Value);
            }

            return query;
        }
        public async Task UpdateRoles(int userId, List<string> roles)
        {
            var user = await _db.Users
                .Include(u => u.UserRoles)
                .FirstOrDefaultAsync(u => u.Id == userId);

            if (user == null)
                throw new ValidationException("User not found.");

            _db.UserRoles.RemoveRange(user.UserRoles);

            foreach (var roleName in roles)
            {
                var role = await _db.Roles.FirstOrDefaultAsync(r => r.Name == roleName);
                if (role != null)
                {
                    user.UserRoles.Add(new UserRole
                    {
                        RoleId = role.Id,
                        UserId = user.Id
                    });
                }
            }

            await _db.SaveChangesAsync();
        }

        public override async Task<PagedResult<UserRoleResponse>> GetPaged(UserRoleSearchObject search)
        {
            var query = _db.Set<UserRole>().Include(x=>x.User).AsQueryable();

            query = AddFilter(search, query);

            int count = await query.CountAsync();

            if (search?.Page.HasValue == true && search?.PageSize.HasValue == true)
            {
                query = query.Skip((search.Page.Value - 1) * search.PageSize.Value).Take(search.PageSize.Value);
            }

            var list = await query.ToListAsync();

            var result = Mapper.Map<List<UserRoleResponse>>(list);

            return new PagedResult<UserRoleResponse>
            {
                Items = result,
                TotalCount = count
            };
        }

    }
}
