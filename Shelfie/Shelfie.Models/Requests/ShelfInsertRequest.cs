using Shelfie.Models.Enums;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Shelfie.Models.Requests
{
    public class ShelfInsertRequest
    {
        [Required]
        public ShelfTypeEnum Name { get; set; } = ShelfTypeEnum.Read;

        [Required]
        [Range(0, int.MaxValue, ErrorMessage = "Books count can't be negative.")]
        public int BooksCount { get; set; } = 0;

        [Required]
        public int UserId { get; set; }
    }
}
