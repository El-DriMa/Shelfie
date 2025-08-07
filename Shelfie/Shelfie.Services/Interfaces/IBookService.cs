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
    public interface IBookService : ICRUDService<BookResponse,BookSearchObject,BookInsertRequest,BookUpdateRequest>
    {
       Task<PagedResult<BookResponse>> GetPagedForUser(BookSearchObject search, int userId);
        Task<PagedResult<BookResponse>> GetRecommendedBooksAsync(BookSearchObject search,int userId);


    }
}
