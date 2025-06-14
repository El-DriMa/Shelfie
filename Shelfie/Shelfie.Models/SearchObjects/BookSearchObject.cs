using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Shelfie.Models.SearchObjects
{
    public class BookSearchObject : BaseSearchObject
    {
        public string? Title { get; set; }
        public string? GenreName { get; set; }
        public string? AuthorName { get; set; }
        public string? PublisherName { get; set; }
        public string? FTS { get; set; }
    }
}
