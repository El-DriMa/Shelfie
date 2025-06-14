using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Shelfie.Models.Enums;

namespace Shelfie.Services.Database
{
    public class Shelf : BaseEntity
    {
        [Column(TypeName = "varchar(50)")]
        [Required]
        public ShelfTypeEnum Name { get; set; } = ShelfTypeEnum.Read;

        [Required]
        [Range(0, int.MaxValue, ErrorMessage = "Books count can't be negative.")]
        public int BooksCount { get; set; } = 0;

        [Required]
        public int UserId { get; set; }
        [ForeignKey("UserId")]
        public User User { get; set; } = null!;
        public ICollection<ShelfBooks> ShelfBooks { get; set; } = new List<ShelfBooks>();

    }
}
