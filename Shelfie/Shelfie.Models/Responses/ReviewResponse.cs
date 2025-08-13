using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Shelfie.Models.Responses
{
    public class ReviewResponse
    {
        public int Id { get; set; }
        public int BookId { get; set; }
        public string BookTitle { get; set; } = string.Empty;
        public int UserId { get; set; }
        public string? UserFullName { get; set; } = string.Empty;
        public string? Username {  get; set; } = string.Empty;
        public int Rating { get; set; }
        public string Description { get; set; } = string.Empty;
    }
}
