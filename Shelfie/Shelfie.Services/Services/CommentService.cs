using MapsterMapper;
using Shelfie.Models.Requests;
using Shelfie.Models.Responses;
using Shelfie.Models.SearchObjects;
using Shelfie.Services.Database;
using Shelfie.Services.Interfaces;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Shelfie.Services.Services
{
    public class CommentService : BaseCRUDService<CommentResponse, CommentSearchObject, Comment, CommentInsertRequest, CommentUpdateRequest>, ICommentService
    {
        public CommentService(IB220155Context context, IMapper mapper) : base(context, mapper)
        {
        }
    }
}
