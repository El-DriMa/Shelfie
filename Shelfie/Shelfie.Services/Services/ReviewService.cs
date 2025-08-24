using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using Shelfie.Models.Enums;
using Shelfie.Models.Requests;
using Shelfie.Models.Responses;
using Shelfie.Models.SearchObjects;
using Shelfie.Services.Database;
using Shelfie.Services.Interfaces;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading.Tasks;

namespace Shelfie.Services.Services
{
    public class ReviewService : BaseCRUDService<ReviewResponse, ReviewSearchObject, Review, ReviewInsertRequest, ReviewUpdateRequest>, IReviewService
    {
        public ReviewService(IB220155Context context, IMapper mapper) : base(context, mapper)
        {
        }

        public override async Task<PagedResult<ReviewResponse>> GetPaged(ReviewSearchObject search)
        {
            var query = _db.Set<Review>()
                .Include(x=>x.User)
                .Include(x=>x.Book)
                .AsQueryable();

            query = AddFilter(search, query);

            int count = await query.CountAsync();

            if (search?.Page.HasValue == true && search?.PageSize.HasValue == true)
            {
                query = query.Skip((search.Page.Value - 1) * search.PageSize.Value).Take(search.PageSize.Value);
            }

            var list = await query.ToListAsync();

            var result = list.Select(r =>
            {
                var response = Mapper.Map<ReviewResponse>(r);
                response.UserFullName = $"{r.User.FirstName} {r.User.LastName}".Trim();
                response.Username = r.User.Username;
                return response;

            }).ToList();

            return new PagedResult<ReviewResponse>
            {
                Items = result,
                TotalCount = count
            };
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

            if (!string.IsNullOrWhiteSpace(search.BookName) && !string.IsNullOrWhiteSpace(search.Username))
            {
                query = query.Where(r =>
                    r.Book.Title.Contains(search.BookName) ||
                    r.User.Username.Contains(search.Username));
            }
            else if (!string.IsNullOrWhiteSpace(search.BookName))
            {
                query = query.Where(r => r.Book.Title.Contains(search.BookName));
            }
            else if (!string.IsNullOrWhiteSpace(search.Username))
            {
                query = query.Where(r => r.User.Username.Contains(search.Username));
            }

            if (search.Rating.HasValue)
            {
                query = query.Where(r => r.Rating == search.Rating.Value);
            }

            return query;
        }



        public async Task<PagedResult<ReviewResponse>> GetPagedForUser(ReviewSearchObject search, int userId)
        {
            var query = _db.Reviews.Where(r => r.UserId == userId)
                .Include(r=>r.User)
                .Include(r=>r.Book)
                .AsQueryable();

            int totalCount = await query.CountAsync();

            if (search?.Page.HasValue == true && search?.PageSize.HasValue == true)
                query = query.Skip(search.Page.Value * search.PageSize.Value).Take(search.PageSize.Value);

            var list = await query.ToListAsync();
            var result = list.Select(r =>
            {
                var response = Mapper.Map<ReviewResponse>(r);
                response.UserFullName = $"{r.User.FirstName} {r.User.LastName}".Trim();
                response.Username = r.User.Username;
                return response;

            }).ToList();

            return new PagedResult<ReviewResponse> { Items = result ?? new(), TotalCount = totalCount };
        }

        public override async Task BeforeInsert(ReviewInsertRequest request, Review entity)
        {
            bool existsInRead = await _db.ShelfBooks
                .AnyAsync(ub => ub.Shelf.UserId == request.UserId
                             && ub.BookId == request.BookId
                             && ub.Shelf.Name == ShelfTypeEnum.Read);

            if (!existsInRead)
                throw new Exception("User must have the book in the 'Read' shelf to add a review.");

           
            bool alreadyReviewed = await _db.Reviews
                .AnyAsync(r => r.UserId == request.UserId
                            && r.BookId == request.BookId);

            if (alreadyReviewed)
                throw new Exception("User has already reviewed this book.");

            await base.BeforeInsert(request, entity);
        }

        public override async Task BeforeUpdate(ReviewUpdateRequest request, Review entity)
        {
            if (request.Rating.HasValue)
                entity.Rating = request.Rating.Value;

            if (!string.IsNullOrWhiteSpace(request.Description))
                entity.Description = request.Description;

            entity.ModifiedAt = DateTime.Now;

            await Task.CompletedTask;
        }

    }
}
