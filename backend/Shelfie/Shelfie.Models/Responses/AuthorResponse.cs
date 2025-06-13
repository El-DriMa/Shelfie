using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Shelfie.Models.Responses
{
    public class AuthorResponse
    {
        public int Id { get; set; }
        public string FirstName { get; set; } = string.Empty;

        public string LastName { get; set; } = string.Empty;

        public string BirthCountry { get; set; } = string.Empty;

       
        public DateOnly BirthDate { get; set; }
        public DateOnly? DeathDate { get; set; }

        public string ShortBio { get; set; } = string.Empty;

        //public virtual ICollection<BookResponse> Books { get; set; } = new List<BookResponse>();

    }
}
