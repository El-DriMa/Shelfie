using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Shelfie.Services.Database
{
    public class Publisher : BaseEntity
    {
        [Required(ErrorMessage = "Publisher name is required.")]
        [StringLength(200, ErrorMessage = "Publisher name can't be longer than 200 characters.")]
        public string Name { get; set; } = string.Empty;

        [StringLength(500, ErrorMessage = "Headquarters location can't be longer than 500 characters.")]
        public string HeadquartersLocation { get; set; } = string.Empty;

        [Required(ErrorMessage = "Contact email is required.")]
        [EmailAddress(ErrorMessage = "Invalid email format.")]
        public string ContactEmail { get; set; } = string.Empty;

        public string? ContactPhone { get; set; } = string.Empty;  

        [Range(1500, 2025, ErrorMessage = "Year founded must be a valid year.")]
        public int YearFounded { get; set; }

        [Required(ErrorMessage = "Country is required.")]
        public string Country { get; set; } = string.Empty;

        public ICollection<Book> Books { get; set; } = new List<Book>();

    }
}
