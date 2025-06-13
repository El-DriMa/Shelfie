using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Shelfie.Models.Requests;
using Shelfie.Models.SearchObjects;
using Shelfie.Services.Database;
using Shelfie.Services.Interfaces;
using Shelfie.Models.Responses;

namespace ShelfieAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class GenreController : BaseCRUDController<GenreResponse, GenreSearchObject, GenreInsertRequest, GenreUpdateRequest>
    {
        public GenreController(ILogger<BaseController<GenreResponse, GenreSearchObject>> logger, IGenreService service) : base(logger, service)
        {
        }
    }
}
