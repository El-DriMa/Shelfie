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
        public CommentService(IB220155Context context, IMapper mapper) : base(context, mapper)
        {
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
    }
}
