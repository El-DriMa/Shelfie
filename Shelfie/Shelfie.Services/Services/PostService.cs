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
    public class PostService : BaseCRUDService<PostResponse, PostSearchObject, Post, PostInsertRequest, PostUpdateRequest>, IPostService
    {
        public PostService(IB220155Context context, IMapper mapper) : base(context, mapper)
        {
        }

        public override IQueryable<Post> AddFilter(PostSearchObject search, IQueryable<Post> query)
        {
            if (!string.IsNullOrWhiteSpace(search.Username))
            {
                query = query.Where(g => g.User.Username.Contains(search.Username));
            }

            return query;
        }

        public async Task<PagedResult<PostResponse>> GetPagedForUser(PostSearchObject search, int userId)
        {
            var query = _db.Posts.Where(p => p.UserId == userId).AsQueryable();

            int totalCount = await query.CountAsync();

            if (search?.Page.HasValue == true && search?.PageSize.HasValue == true)
                query = query.Skip(search.Page.Value * search.PageSize.Value).Take(search.PageSize.Value);

            var list = await query.ToListAsync();
            var result = Mapper.Map<List<PostResponse>>(list);

            return new PagedResult<PostResponse> { Items = result ?? new(), TotalCount = totalCount };
        }
    }
}
