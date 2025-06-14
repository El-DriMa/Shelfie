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
    public class PublisherController : BaseCRUDController<PublisherResponse, PublisherSearchObject, PublisherInsertRequest, PublisherUpdateRequest>
    {
        public PublisherController(ILogger<BaseController<PublisherResponse, PublisherSearchObject>> logger, IPublisherService service) : base(logger, service)
        {
        }
    }
}
