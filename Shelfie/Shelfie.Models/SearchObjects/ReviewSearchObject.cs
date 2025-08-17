using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Shelfie.Models.SearchObjects
{
    public class ReviewSearchObject : BaseSearchObject
    {
        public int? BookId { get; set; }  
        public string? BookName { get; set; }
        public int? UserId { get; set; }   
        public string? Username { get; set; }
        public int? Rating { get; set; }   
    }
}
