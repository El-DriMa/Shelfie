using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Shelfie.Models.Requests
{
    public class ShelfBooksInsertRequest
    {
        [Required(ErrorMessage = "Shelf ID is required.")]
        public int ShelfId { get; set; }

        [Required(ErrorMessage = "Book ID is required.")]
        public int BookId { get; set; }
    }
}
