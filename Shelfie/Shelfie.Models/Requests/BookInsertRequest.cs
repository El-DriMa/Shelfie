using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Shelfie.Models.Requests
{
    public class BookInsertRequest
    {
        [Required(ErrorMessage = "Title is required.")]
        [MaxLength(200, ErrorMessage = "Title can't be longer than 200 characters.")]
        public string Title { get; set; } = string.Empty;

        [Range(1, int.MaxValue, ErrorMessage = "Total pages must be a positive number.")]
        public int TotalPages { get; set; } = 0;

        public string? PhotoUrl { get; set; }

        [Required(ErrorMessage = "Genre is required.")]
        public int GenreId { get; set; }

        [Required(ErrorMessage = "Author is required.")]
        public int AuthorId { get; set; }

        [Required(ErrorMessage = "Publisher is required.")]
        public int PublisherId { get; set; }

        [Required(ErrorMessage = "Year Published is required.")]
        [Range(1, 2025, ErrorMessage = "Year Published must be a valid year.")]
        public int YearPublished { get; set; }

        [MaxLength(1000, ErrorMessage = "Short description can't be longer than 1000 characters.")]
        public string ShortDescription { get; set; } = string.Empty;

        [MaxLength(50, ErrorMessage = "Language can't be longer than 50 characters.")]
        public string Language { get; set; } = string.Empty;
    }
}
