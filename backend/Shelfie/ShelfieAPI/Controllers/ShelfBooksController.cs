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
    public class ShelfBooksController : BaseCRUDController<ShelfBooksResponse, ShelfBooksSearchObject, ShelfBooksInsertRequest, ShelfBooksUpdateRequest>
    {
        public ShelfBooksController(ILogger<BaseController<ShelfBooksResponse, ShelfBooksSearchObject>> logger, IShelfBooksService service) : base(logger, service)
        {
        }
    }
}
