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
    public class ReviewService : BaseCRUDService<ReviewResponse, ReviewSearchObject, Review, ReviewInsertRequest, ReviewUpdateRequest>, IReviewService
    {
        public ReviewService(IB220155Context context, IMapper mapper) : base(context, mapper)
        {
        }

        public override IQueryable<Review> AddFilter(ReviewSearchObject search, IQueryable<Review> query)
        {
            if (search.BookId.HasValue)
            {
                query = query.Where(r => r.BookId == search.BookId.Value);
            }

            if (search.UserId.HasValue)
            {
                query = query.Where(r => r.UserId == search.UserId.Value);
            }

            if (search.Rating.HasValue)
            {
                query = query.Where(r => r.Rating == search.Rating.Value);
            }

            return query;
        }

        public async Task<PagedResult<ReviewResponse>> GetPagedForUser(ReviewSearchObject search, int userId)
        {
            var query = _db.Reviews.Where(r => r.UserId == userId).AsQueryable();

            int totalCount = await query.CountAsync();

            if (search?.Page.HasValue == true && search?.PageSize.HasValue == true)
                query = query.Skip(search.Page.Value * search.PageSize.Value).Take(search.PageSize.Value);

            var list = await query.ToListAsync();
            var result = Mapper.Map<List<ReviewResponse>>(list);

            return new PagedResult<ReviewResponse> { Items = result ?? new(), TotalCount = totalCount };
        }
    }
}
