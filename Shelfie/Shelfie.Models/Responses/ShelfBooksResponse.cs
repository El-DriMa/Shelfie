using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Shelfie.Models.Responses
{
    public class ShelfBooksResponse
    {
        public int Id { get; set; }
        public string ShelfName { get; set; } = string.Empty;
        public string BookTitle { get; set; } = string.Empty;
    }
}
