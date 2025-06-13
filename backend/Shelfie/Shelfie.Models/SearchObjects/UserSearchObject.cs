using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Shelfie.Models.SearchObjects
{
    public class UserSearchObject : BaseSearchObject
    {
        public string? FTS { get; set; }
        public bool? IsRoleIncluded { get; set; }
    }
}
