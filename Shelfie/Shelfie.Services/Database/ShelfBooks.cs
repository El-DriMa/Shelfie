using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Shelfie.Services.Database
{
    public class ShelfBooks : BaseEntity
    {
        [Required]
        public int ShelfId { get; set; }
        [ForeignKey("ShelfId")]
        public Shelf Shelf { get; set; } = null!;

        [Required]
        public int BookId { get; set; }
        [ForeignKey("BookId")]
        public Book Book { get; set; } = null!;
    }
}
