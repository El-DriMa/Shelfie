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
    public class StatisticsService : BaseService<StatisticsResponse, StatisticsSearchObject, Statistics>, IStatisticsService
    {
        public StatisticsService(IB220155Context db, IMapper mapper) : base(db, mapper)
        {
        }
        public override IQueryable<Statistics> AddFilter(StatisticsSearchObject search, IQueryable<Statistics> query)
        {
            if (search.UserId.HasValue)
            {
                query = query.Where(s => s.UserId == search.UserId.Value);
            }

            return query;
        }

        public async Task<PagedResult<StatisticsResponse>> GetPagedForUser(StatisticsSearchObject search, int userId)
        {
            var query = _db.Statistics.Where(s => s.UserId == userId).AsQueryable();

            int totalCount = await query.CountAsync();

            if (search?.Page.HasValue == true && search?.PageSize.HasValue == true)
                query = query.Skip(search.Page.Value * search.PageSize.Value).Take(search.PageSize.Value);

            var list = await query.ToListAsync();
            var result = Mapper.Map<List<StatisticsResponse>>(list);

            return new PagedResult<StatisticsResponse> { Items = result ?? new(), TotalCount = totalCount };
        }
    }
}
