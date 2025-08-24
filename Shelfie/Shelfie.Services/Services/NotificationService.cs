using EasyNetQ;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
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
    public class NotificationService : BaseCRUDService<NotificationResponse, NotificationSearchObject, NotificationMessage, NotificationInsertRequest, NotificationUpdateRequest>, INotificationService
    {
        private readonly IBus _bus;
        private IMapper _mapper;
        private readonly IB220155Context _context;
        public NotificationService(IB220155Context context, IMapper mapper, IBus bus) : base(context, mapper)
        {
            _context = context;
            _bus = bus;
            _mapper = mapper;
        }


        public virtual async Task BeforeUpdate(NotificationUpdateRequest request, NotificationMessage entity)
        {
            if (entity is BaseEntity baseEntity)
            {
                baseEntity.ModifiedAt = DateTime.Now;
            }

            entity.IsRead = true;

            await Task.CompletedTask;
        }

        public override async Task<NotificationResponse> Update(int id, NotificationUpdateRequest request)
        {
            var entity = await _context.Notifications.FindAsync(id);
            if (entity == null) return null;

            await BeforeUpdate(request, entity);

            await _context.SaveChangesAsync();

            return _mapper.Map<NotificationResponse>(entity);
        }


        public async Task<PagedResult<NotificationResponse>> GetPagedForUser(NotificationSearchObject search, int userId)
        {
            var query = _db.Notifications.Where(p => p.ToUserId == userId)
                .OrderByDescending(p => p.CreatedAt)
                .AsQueryable();

            int totalCount = await query.CountAsync();

            if (search?.Page.HasValue == true && search?.PageSize.HasValue == true)
                query = query.Skip(search.Page.Value * search.PageSize.Value).Take(search.PageSize.Value);

            var list = await query.ToListAsync();
            var result = list.Select(p =>
            {
                var response = Mapper.Map<NotificationResponse>(p);
                return response;
            }).ToList();

            return new PagedResult<NotificationResponse> { Items = result ?? new(), TotalCount = totalCount };
        }
    }
}
