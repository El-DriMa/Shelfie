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
    public class CommentController : BaseCRUDController<CommentResponse, CommentSearchObject, CommentInsertRequest, CommentUpdateRequest>
    {
        public CommentController(ILogger<BaseController<CommentResponse, CommentSearchObject>> logger, ICommentService service) : base(logger, service)
        {
        }
    }
}
