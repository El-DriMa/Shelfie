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
            var query = _db.Posts.Where(p => p.UserId == userId).Include(x=>x.Genre).Include(x=>x.User).AsQueryable();

            int totalCount = await query.CountAsync();

            if (search?.Page.HasValue == true && search?.PageSize.HasValue == true)
                query = query.Skip(search.Page.Value * search.PageSize.Value).Take(search.PageSize.Value);

            var list = await query.ToListAsync();
            var result = list.Select(p =>
            {
                var response = Mapper.Map<PostResponse>(p);
                response.Username = p.User.Username;
                return response;
            }).ToList();

            return new PagedResult<PostResponse> { Items = result ?? new(), TotalCount = totalCount };
        }

        public async Task<PagedResult<PostResponse>> GetPagedForUserByGenre(PostSearchObject search, int userId,int genreId)
        {
            var query = _db.Posts.Where(p => p.UserId == userId && p.GenreId==genreId).Include(x => x.Genre).Include(x => x.User).AsQueryable();

            int totalCount = await query.CountAsync();

            if (search?.Page.HasValue == true && search?.PageSize.HasValue == true)
                query = query.Skip(search.Page.Value * search.PageSize.Value).Take(search.PageSize.Value);

            var list = await query.ToListAsync();
            var result = list.Select(p =>
            {
                var response = Mapper.Map<PostResponse>(p);
                response.Username = p.User.Username;
                return response;
            }).ToList();

            return new PagedResult<PostResponse> { Items = result ?? new(), TotalCount = totalCount };
        }

        public async Task<PagedResult<PostResponse>> GetPagedByGenre(PostSearchObject search, int genreId)
        {
            var query = _db.Posts.Where(p => p.GenreId == genreId).Include(x => x.Genre).Include(x => x.User).AsQueryable();

            int totalCount = await query.CountAsync();

            if (search?.Page.HasValue == true && search?.PageSize.HasValue == true)
                query = query.Skip(search.Page.Value * search.PageSize.Value).Take(search.PageSize.Value);

            var list = await query.ToListAsync();
            var result = list.Select(p =>
            {
                var response = Mapper.Map<PostResponse>(p);
                response.Username = p.User.Username;
                return response;
            }).ToList();

            return new PagedResult<PostResponse> { Items = result ?? new(), TotalCount = totalCount };
        }

        public override async Task<PagedResult<PostResponse>> GetPaged(PostSearchObject search)
        {
            var query = _db.Set<Post>().Include(x=>x.Genre).Include(x=>x.User).AsQueryable();

            query = AddFilter(search, query);

            int count = await query.CountAsync();

            if (search?.Page.HasValue == true && search?.PageSize.HasValue == true)
            {
                query = query.Skip((search.Page.Value - 1) * search.PageSize.Value).Take(search.PageSize.Value);
            }

            var list = await query.ToListAsync();

            var result = list.Select(p =>
            {
                var response = Mapper.Map<PostResponse>(p);
                response.Username = p.User.Username;
                return response;
            }).ToList();

            return new PagedResult<PostResponse>
            {
                Items = result,
                TotalCount = count
            };
        }
    }
}
