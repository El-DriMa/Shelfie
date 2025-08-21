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
        public string? PhotoUrl { get; set; }
        public int GenreId { get; set; }
        public int AuthorId {  get; set; }
        public int PublisherId { get; set; }
        public string GenreName { get; set; } = string.Empty;
        public string AuthorName { get; set; } = string.Empty;
        public string PublisherName { get; set; } = string.Empty;
        public int YearPublished { get; set; }
        public string ShortDescription { get; set; } = string.Empty;
        public string Language { get; set; } = string.Empty;
        public double AverageRating { get; set; }
        public int ReviewCount { get; set; }

        public List<ShelfBooksResponse> ShelfBooks { get; set; } = new List<ShelfBooksResponse>();
    }
}
