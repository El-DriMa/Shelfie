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
    public class RoleController : BaseController<RoleResponse, RoleSearchObject>
    {
        public RoleController(ILogger<BaseController<RoleResponse, RoleSearchObject>> logger, IRoleService service) : base(logger, service)
        {
        }
    }
}
