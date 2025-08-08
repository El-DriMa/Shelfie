using Shelfie.Models.Enums;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Shelfie.Models.SearchObjects
{
    public class PostSearchObject : BaseSearchObject
    {
        public string? Username { get; set; }
        public PostStateEnum? PostState { get; set; }
    }
}
