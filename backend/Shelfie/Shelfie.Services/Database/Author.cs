using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Shelfie.Services.Database
{
    public class Author : BaseEntity
    {
        [Required, MaxLength(50)]
        public string FirstName { get; set; } = string.Empty;

        [Required, MaxLength(50)]
        public string LastName { get; set; } = string.Empty;

        [Required, MaxLength(100)]
        public string BirthCountry { get; set; } = string.Empty;

        [Required]
        public DateOnly BirthDate { get; set; }
        [CustomValidation(typeof(Validations.Validations), nameof(Validations.Validations.ValidateDeathDateAfterBirthDate), ErrorMessage = "Death date must be after birth date.")]
        public DateOnly? DeathDate { get; set; }

        [MaxLength(1000)]
        public string ShortBio { get; set; } = string.Empty;

        public ICollection<Book> Books { get; set; } = new List<Book>();

       

    }
}
