using MapsterMapper;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Shelfie.Models.Requests;
using Shelfie.Models.Responses;
using Shelfie.Models.SearchObjects;
using Shelfie.Services.Database;
using Shelfie.Services.Interfaces;
using System.Security.Claims;

namespace ShelfieAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class NotificationController : BaseCRUDController<NotificationResponse, NotificationSearchObject, NotificationInsertRequest, NotificationUpdateRequest>
    {
        private readonly IMapper _mapper;
        private readonly IB220155Context _context;
        private readonly INotificationService _service;
        public NotificationController(ILogger<BaseController<NotificationResponse, NotificationSearchObject>> logger, INotificationService service, IMapper mapper, IB220155Context context) : base(logger, service)
        {
            _context = context;
            _mapper = mapper;
            _service = service;
        }


        [HttpGet("user")]
        public async Task<PagedResult<NotificationResponse>> GetForUser([FromQuery] NotificationSearchObject search)
        {
            var userIdStr = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (!int.TryParse(userIdStr, out int userId))
                return new PagedResult<NotificationResponse> { Items = new List<NotificationResponse>(), TotalCount = 0 };

            var result = await _service.GetPagedForUser(search, userId);

            return result ?? new PagedResult<NotificationResponse> { Items = new List<NotificationResponse>(), TotalCount = 0 };
        }

    }
}
