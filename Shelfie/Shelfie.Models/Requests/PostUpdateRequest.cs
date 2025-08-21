using Shelfie.Models.Enums;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Shelfie.Models.Requests
{
    public class PostUpdateRequest
    {
        public PostStateEnum? State { get; set; } 

    }
}
