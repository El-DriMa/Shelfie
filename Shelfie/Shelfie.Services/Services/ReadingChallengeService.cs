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
    public class ReadingChallengeService : BaseCRUDService<ReadingChallengeResponse, ReadingChallengeSearchObject, ReadingChallenge, ReadingChallengeInsertRequest, ReadingChallengeUpdateRequest>, IReadingChallengeService
    {
        public ReadingChallengeService(IB220155Context context, IMapper mapper) : base(context, mapper)
        {
        }

        public override IQueryable<ReadingChallenge> AddFilter(ReadingChallengeSearchObject search, IQueryable<ReadingChallenge> query)
        {
            if (!string.IsNullOrWhiteSpace(search.Name))
            {
                query = query.Where(rc => rc.ChallengeName.Contains(search.Name));
            }

            if (!string.IsNullOrWhiteSpace(search.Username))
            {
                query = query.Where(rc => rc.User.Username.Contains(search.Username));
            }


            if (search.UserId.HasValue)
            {
                query = query.Where(rc => rc.UserId == search.UserId.Value);
            }

            return query;
        }

        public async Task<PagedResult<ReadingChallengeResponse>> GetPagedForUser(ReadingChallengeSearchObject search, int userId)
        {
            var query = _db.ReadingChallenges.Where(rc => rc.UserId == userId).AsQueryable();

            int totalCount = await query.CountAsync();

            if (search?.Page.HasValue == true && search?.PageSize.HasValue == true)
                query = query.Skip(search.Page.Value * search.PageSize.Value).Take(search.PageSize.Value);

            var list = await query.ToListAsync();
            var result = Mapper.Map<List<ReadingChallengeResponse>>(list);

            return new PagedResult<ReadingChallengeResponse> { Items = result ?? new(), TotalCount = totalCount };
        }

        public virtual async Task<PagedResult<ReadingChallengeResponse>> GetPaged(ReadingChallengeSearchObject search)
        {
            var query = _db.Set<ReadingChallenge>().Include(x=>x.User).AsQueryable();

            query = AddFilter(search, query);

            int count = await query.CountAsync();

            if (search?.Page.HasValue == true && search?.PageSize.HasValue == true)
            {
                query = query.Skip((search.Page.Value - 1) * search.PageSize.Value).Take(search.PageSize.Value);
            }

            var list = await query.ToListAsync();

            var result = list.Select(x =>
            {
                var response = Mapper.Map<ReadingChallengeResponse>(x);
                response.Username = x.User.Username;
                return response;
            }).ToList();

            return new PagedResult<ReadingChallengeResponse>
            {
                Items = result,
                TotalCount = count
            };
        }
    

        public override async Task BeforeUpdate(ReadingChallengeUpdateRequest request, ReadingChallenge entity)
        {
            if (!string.IsNullOrWhiteSpace(request.ChallengeName))
                entity.ChallengeName = request.ChallengeName;

            if (!string.IsNullOrWhiteSpace(request.Description))
                entity.Description = request.Description;

            if (request.GoalType.HasValue)
                entity.GoalType = request.GoalType.Value;

            if (request.GoalAmount.HasValue)
                entity.GoalAmount = request.GoalAmount.Value;

            if (request.StartDate.HasValue)
                entity.StartDate = (DateOnly)request.StartDate;

            if (request.EndDate.HasValue)
                entity.EndDate = (DateOnly)request.EndDate;

            if (request.Progress.HasValue)
                entity.Progress = request.Progress.Value;

            entity.IsCompleted = request.IsCompleted;

            entity.ModifiedAt = DateTime.Now;

            await Task.CompletedTask;
        }

    }
}
