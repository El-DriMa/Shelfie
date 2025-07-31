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
        private readonly ICommentService _service;
        public CommentController(ILogger<BaseController<CommentResponse, CommentSearchObject>> logger, ICommentService service) : base(logger, service)
        {
           _service = service;
        }

        [HttpGet("Post/{postId}")]
        public async Task<PagedResult<CommentResponse>> GetByPost(int postId, [FromQuery] CommentSearchObject search)
        {

            var result = await _service.GetPagedByPost(search, postId);

            return result ?? new PagedResult<CommentResponse> { Items = new List<CommentResponse>(), TotalCount = 0 };
        }
    }
}
