using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Shelfie.Models.Requests
{
    public class AuthorInsertRequest
    {
        [Required(AllowEmptyStrings = false, ErrorMessage = "First name cannot be empty.")]
        [MaxLength(50, ErrorMessage = "First name can't be more than 50 characters.")]
        public string FirstName { get; set; } = string.Empty;

        [Required(AllowEmptyStrings = false, ErrorMessage = "Last name cannot be empty.")]
        [MaxLength(50, ErrorMessage = "Last name can't be more than 50 characters.")]
        public string LastName { get; set; } = string.Empty;

        [Required(AllowEmptyStrings = false, ErrorMessage = "Birth country cannot be empty.")]
        [MaxLength(100, ErrorMessage = "Birth country can't be more than 100 characters.")]
        public string BirthCountry { get; set; } = string.Empty;

        [Required(ErrorMessage = "Birth date is required.")]
        public DateOnly BirthDate { get; set; }

        public DateOnly? DeathDate { get; set; }

        [MaxLength(1000, ErrorMessage = "Short bio can't be more than 1000 characters.")]
        public string ShortBio { get; set; } = string.Empty;
    }
}
