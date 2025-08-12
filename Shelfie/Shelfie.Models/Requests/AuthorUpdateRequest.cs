using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Shelfie.Models.Requests
{
    public class AuthorUpdateRequest
    {
       
        [MaxLength(50, ErrorMessage = "First name can't be more than 50 characters.")]
        public string? FirstName { get; set; } = string.Empty;

       
        [MaxLength(50, ErrorMessage = "Last name can't be more than 50 characters.")]
        public string? LastName { get; set; } = string.Empty;

        
        [MaxLength(100, ErrorMessage = "Birth country can't be more than 100 characters.")]
        public string? BirthCountry { get; set; } = string.Empty;


        public DateOnly? BirthDate { get; set; }

        public DateOnly? DeathDate { get; set; }

        [MaxLength(1000, ErrorMessage = "Short bio can't be more than 1000 characters.")]
        public string? ShortBio { get; set; } = string.Empty;
    }
}
