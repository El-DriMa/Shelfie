using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Shelfie.Models.Requests;
using Shelfie.Models.SearchObjects;
using Shelfie.Services.Database;
using Shelfie.Services.Interfaces;
using Shelfie.Models.Responses;
using System.ComponentModel.DataAnnotations;

namespace ShelfieAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class UserRoleController : BaseCRUDController<UserRoleResponse, UserRoleSearchObject, UserRoleInsertRequest, UserRoleUpdateRequest>
    {
        public UserRoleController(ILogger<BaseController<UserRoleResponse, UserRoleSearchObject>> logger, IUserRoleService service) : base(logger, service)
        {

        }

        [HttpPost("{userId}/update-roles")]
        public async Task<IActionResult> UpdateRoles(int userId, [FromBody] List<string> roles, [FromServices] IUserRoleService service)
        {
            try
            {
                await service.UpdateRoles(userId, roles);
                return Ok("Roles updated successfully");
            }
            catch (ValidationException ex)
            {
                return BadRequest(ex.Message);
            }
        }

    }
}
