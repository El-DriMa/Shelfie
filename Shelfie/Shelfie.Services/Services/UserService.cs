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
                query = query.Where(u => u.FirstName.Contains(search.FTS) || u.LastName.Contains(search.FTS));
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


            if (!string.IsNullOrWhiteSpace(request.Password))
            {
                PasswordHelper.CreatePasswordHash(request.Password, out string hash, out string salt);
                entity.PasswordHash = hash;
                entity.PasswordSalt = salt;
            }

            if (!string.IsNullOrWhiteSpace(request.PhoneNumber))
                entity.PhoneNumber = request.PhoneNumber;

            entity.ModifiedAt = DateTime.Now;

            await Task.CompletedTask;
        }
    }
}
