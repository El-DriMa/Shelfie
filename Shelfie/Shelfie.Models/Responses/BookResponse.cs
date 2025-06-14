using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Shelfie.Models.Responses
{
    public class BookResponse
    {
        public int Id { get; set; }
        public string Title { get; set; } = string.Empty;
        public int TotalPages { get; set; }
        public byte[]? CoverImage { get; set; }
        public string GenreName { get; set; } = string.Empty;
        public string AuthorName { get; set; } = string.Empty;
        public string PublisherName { get; set; } = string.Empty;
        public int YearPublished { get; set; }
        public string ShortDescription { get; set; } = string.Empty;
        public string Language { get; set; } = string.Empty;
        public List<ReviewResponse> Reviews { get; set; } = new List<ReviewResponse>(); 
        public List<ShelfBooksResponse> ShelfBooks { get; set; } = new List<ShelfBooksResponse>();
    }
}
