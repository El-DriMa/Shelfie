using Shelfie.Models.Requests;
using Shelfie.Models.Responses;
using Shelfie.Models.SearchObjects;
using Shelfie.Services.Database;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Shelfie.Services.Interfaces
{
    public interface IPostService : ICRUDService<PostResponse,PostSearchObject,PostInsertRequest,PostUpdateRequest>
    {
        Task<PagedResult<PostResponse>> GetPagedForUser(PostSearchObject search, int userId);
        Task<PagedResult<PostResponse>> GetPagedForUserByGenre(PostSearchObject search, int userId, int genreId);
        Task<PagedResult<PostResponse>> GetPagedByGenre(PostSearchObject search, int genreId);
    }
}
