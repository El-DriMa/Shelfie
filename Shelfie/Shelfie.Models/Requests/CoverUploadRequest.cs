using Microsoft.AspNetCore.Http;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Shelfie.Models.Requests
{
    public class CoverUploadRequest
    {
        public IFormFile? CoverImage { get; set; }
    }
}
