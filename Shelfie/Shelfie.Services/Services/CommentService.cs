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
    public class CommentService : BaseCRUDService<CommentResponse, CommentSearchObject, Comment, CommentInsertRequest, CommentUpdateRequest>, ICommentService
    {
        private INotificationService _notificationService;
        public IBus bus;
        public CommentService(IB220155Context context, IMapper mapper, INotificationService notificationService, IBus bus) : base(context, mapper)
        {
            _notificationService = notificationService;
            this.bus = bus;
        }

        public override async Task<PagedResult<CommentResponse>> GetPaged(CommentSearchObject search)
        {
            var query = _db.Set<Comment>().Include(x => x.User).AsQueryable();

            query = AddFilter(search, query);

            int count = await query.CountAsync();

            if (search?.Page.HasValue == true && search?.PageSize.HasValue == true)
            {
                query = query.Skip((search.Page.Value - 1) * search.PageSize.Value).Take(search.PageSize.Value);
            }

            var list = await query.ToListAsync();

            var result = list.Select(c =>
            {
                var response = Mapper.Map<CommentResponse>(c);
                response.Username= c.User.Username;
                return response;
            }).ToList();

            return new PagedResult<CommentResponse>
            {
                Items = result,
                TotalCount = count
            };
        }

        public async Task<PagedResult<CommentResponse>> GetPagedByPost(CommentSearchObject search, int postId)
        {
            var query = _db.Comments.Where(c=>c.PostId==postId).Include(x=>x.User).AsQueryable();

            int totalCount = await query.CountAsync();

            if (search?.Page.HasValue == true && search?.PageSize.HasValue == true)
                query = query.Skip(search.Page.Value * search.PageSize.Value).Take(search.PageSize.Value);

            var list = await query.ToListAsync();
            var result = list.Select(c =>
            {
                var response = Mapper.Map<CommentResponse>(c);
                response.Username = c.User.Username;
                return response;
            }).ToList();

            return new PagedResult<CommentResponse> { Items = result ?? new(), TotalCount = totalCount };
        }

        public override async Task<CommentResponse> Insert(CommentInsertRequest request)
        {
            var entity = Mapper.Map<Comment>(request);

            var post = await _db.Posts.FindAsync(entity.PostId);
            if (post == null)
                throw new Exception("Post not found");

            await _db.Comments.AddAsync(entity);
            await BeforeInsert(request, entity);
            await _db.SaveChangesAsync();

            if (entity.UserId != post.UserId)
            {
                var ev = new CommentCreatedEvent
                {
                    PostId = entity.PostId,
                    CommentId = entity.Id,
                    CommentText = entity.Content,
                    FromUserId = entity.UserId,
                    ToUserId = post.UserId,
                    FromUserName = (await _db.Users.FindAsync(entity.UserId))?.Username ?? ""
                };

                await bus.PubSub.PublishAsync(ev);
            }

            return Mapper.Map<CommentResponse>(entity);
        }

        public override async Task BeforeInsert(CommentInsertRequest request, Comment entity)
        {
            if (entity is BaseEntity baseEntity)
            {
                baseEntity.IsActive = true;
            }
            await Task.CompletedTask;
        }

    }
}
