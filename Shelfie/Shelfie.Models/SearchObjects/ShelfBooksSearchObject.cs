using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Shelfie.Models.SearchObjects
{
    public class ShelfBooksSearchObject : BaseSearchObject
    {
        public int? ShelfId { get; set; } 
        public int? BookId { get; set; }   
        public string? Username { get; set; }
        public string? BookTitle { get; set; }
        public string? ShelfName { get; set; }
    }
}
