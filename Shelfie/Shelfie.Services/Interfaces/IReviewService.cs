using Shelfie.Models.Requests;
using Shelfie.Models.Responses;
using Shelfie.Models.SearchObjects;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Shelfie.Services.Interfaces
{
    public interface IReviewService : ICRUDService<ReviewResponse,ReviewSearchObject,ReviewInsertRequest,ReviewUpdateRequest>
    {
        Task<PagedResult<ReviewResponse>> GetPagedForUser(ReviewSearchObject search, int userId);
    }
}
