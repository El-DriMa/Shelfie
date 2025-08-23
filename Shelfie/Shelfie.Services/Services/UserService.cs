using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using Shelfie.Models.Enums;
using Shelfie.Models.Requests;
using Shelfie.Models.Responses;
using Shelfie.Models.SearchObjects;
using Shelfie.Services.Database;
using Shelfie.Services.Helpers;
using Shelfie.Services.Interfaces;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
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
                query = query.Where(u => u.FirstName.Contains(search.FTS) || u.LastName.Contains(search.FTS) || u.Username.Contains(search.FTS));
            }

            return query;
        }

        public override async Task BeforeInsert(UserInsertRequest request, User entity)
        {
            if (await _db.Users.AnyAsync(u => u.Username == request.Username))
                throw new ValidationException("Username already exists.");

            if (entity is BaseEntity baseEntity)
            {
                baseEntity.IsActive = true;
            }

            await Task.CompletedTask;
        }

        public override async Task<UserResponse> Insert(UserInsertRequest request)
        {
            await BeforeInsert(request, null);

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

            var shelves = new List<Shelf>
                {
                    new Shelf { Name = ShelfTypeEnum.Read, UserId = user.Id },
                    new Shelf { Name = ShelfTypeEnum.CurrentlyReading, UserId = user.Id },
                    new Shelf { Name = ShelfTypeEnum.WantToRead, UserId = user.Id }
                };

            await _db.Shelves.AddRangeAsync(shelves);

            await _db.SaveChangesAsync();

            return Mapper.Map<UserResponse>(user);
        }
        public override async Task BeforeUpdate(UserUpdateRequest request, User entity)
        {
            if (!string.IsNullOrWhiteSpace(request.FirstName))
                entity.FirstName = request.FirstName;

            if (!string.IsNullOrWhiteSpace(request.LastName))
                entity.LastName = request.LastName;

            if (!string.IsNullOrWhiteSpace(request.Email))
                entity.Email = request.Email;


            if (!string.IsNullOrWhiteSpace(request.PhoneNumber))
                entity.PhoneNumber = request.PhoneNumber;

            if (request.IsActive.HasValue)
                entity.IsActive = request.IsActive.Value;


            entity.ModifiedAt = DateTime.Now;

            await Task.CompletedTask;
        }

        public async Task<UserResponse> GetCurrentUser(int userId, string appType)
        {
            var user = await _db.Users
                .Include(u => u.UserRoles)
                .ThenInclude(ur => ur.Role)
                .FirstOrDefaultAsync(u => u.Id == userId);

            if (user == null)
                throw new ValidationException("User not found.");

            bool allowed = appType switch
            {
                "desktop" => user.UserRoles.Any(ur => ur.Role.Name == "Admin"),
                "mobile" => user.UserRoles.Any(ur => ur.Role.Name == "User"),
                _ => true
            };

            if (!allowed)
            {
                return new UserResponse { Id = -1, Username = "FORBIDDEN" };
            }



            user.LastLoginAt = DateTime.Now;
            await _db.SaveChangesAsync();

            var response = Mapper.Map<UserResponse>(user);
            response.Roles = user.UserRoles.Select(ur => ur.Role.Name).ToList();
            return response;
        }

        public async Task ChangePassword(int userId, ChangePasswordRequest request)
        {
            var user = await _db.Users.FirstOrDefaultAsync(u => u.Id == userId);
            if (user == null)
                throw new ValidationException("User not found.");

            if (!PasswordHelper.VerifyPassword(request.OldPassword, user.PasswordHash, user.PasswordSalt))
                throw new ValidationException("Old password is not correct!");

            if (PasswordHelper.VerifyPassword(request.NewPassword, user.PasswordHash, user.PasswordSalt))
                throw new ValidationException("New password can not be then same as old password");

            PasswordHelper.CreatePasswordHash(request.NewPassword, out string hash, out string salt);
            user.PasswordHash = hash;
            user.PasswordSalt = salt;
            user.ModifiedAt = DateTime.Now;

            await _db.SaveChangesAsync();
        }

        public virtual async Task<PagedResult<UserResponse>> GetPaged(UserSearchObject search)
        {
            var query = _db.Set<User>().Include(x=>x.UserRoles).ThenInclude(r=>r.Role).AsQueryable();

            query = AddFilter(search, query);

            int count = await query.CountAsync();

            if (search?.Page.HasValue == true && search?.PageSize.HasValue == true)
            {
                query = query.Skip((search.Page.Value - 1) * search.PageSize.Value).Take(search.PageSize.Value);
            }

            var list = await query.ToListAsync();

            var result = Mapper.Map<List<UserResponse>>(list);

            return new PagedResult<UserResponse>
            {
                Items = result,
                TotalCount = count
            };
        }

    }
}
