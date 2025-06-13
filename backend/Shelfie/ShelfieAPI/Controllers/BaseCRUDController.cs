using Microsoft.AspNetCore.Authorization;
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
    public class BaseCRUDController<TModel, TSearch, TInsert, TUpdate>
            : BaseController<TModel, TSearch>
            where TSearch : BaseSearchObject where TModel : class where TInsert : class  where TUpdate : class  
    {
        protected new ICRUDService<TModel, TSearch, TInsert, TUpdate> _service;
        protected readonly ILogger<BaseController<TModel, TSearch>> _logger;

        public BaseCRUDController(ILogger<BaseController<TModel, TSearch>> logger,ICRUDService<TModel, TSearch, TInsert, TUpdate> service) : base(logger,service)
        {
            _service = service;
            _logger = logger;
        }

        [HttpPost]
        public virtual async Task<TModel> Insert(TInsert request)
        {
            return await _service.Insert(request);
        }

        [HttpPut("{id}")]
        public virtual async Task<TModel> Update(int id,TUpdate request)
        {
            return await _service.Update(id,request);
        }

        [Authorize]
        [HttpDelete("{id}")]
        public virtual async Task<IActionResult> Delete(int id)
        {
            var result = await _service.Delete(id);

            if (!result)
            {
                return NotFound();
            }

            return NoContent();
        }

    }
}
