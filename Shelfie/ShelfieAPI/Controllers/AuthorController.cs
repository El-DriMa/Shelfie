using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Shelfie.Models.Requests;
using Shelfie.Models.SearchObjects;
using Shelfie.Services.Database;
using Shelfie.Services.Interfaces;
using Shelfie.Models.Responses;

namespace ShelfieAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class AuthorController : BaseCRUDController<AuthorResponse, AuthorSearchObject, AuthorInsertRequest, AuthorUpdateRequest>
    {
        public AuthorController(ILogger<BaseController<AuthorResponse,AuthorSearchObject>> logger,IAuthorService service) : base(logger, service) { }
        

    }
}
