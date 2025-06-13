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
    public class UserRoleController : BaseCRUDController<UserRoleResponse, UserRoleSearchObject, UserRoleInsertRequest, UserRoleUpdateRequest>
    {
        public UserRoleController(ILogger<BaseController<UserRoleResponse, UserRoleSearchObject>> logger, IUserRoleService service) : base(logger, service)
        {
        }
    }
}
