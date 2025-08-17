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
        public int ShelfId { get; set; }
        public string? ShelfName { get; set; } = string.Empty;
        public int BookId { get; set; }
        public string? BookTitle { get; set; } = string.Empty;
        public int? PagesRead { get; set; } = 0;
        public int? TotalPages {  get; set; }
        public string AuthorName { get; set; } = string.Empty;
        public DateTime CreatedAt { get; set; }
        public DateTime? ModifiedAt { get; set; }
        public double AverageRating { get; set; }
        public int ReviewCount { get; set; }
        public int? UserId { get; set; }
        public string? Username { get; set; }
    }
}
