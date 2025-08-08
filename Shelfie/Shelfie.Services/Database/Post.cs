using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Shelfie.Models.Enums;

namespace Shelfie.Services.Database
{
    public class Post : BaseEntity
    {
        [Required]
        public string Content { get; set; } = string.Empty;

        [Required]
        public int UserId { get; set; }
        [ForeignKey("UserId")]
        public User User { get; set; } = null!;

        [Required]
        public int GenreId { get; set; }

        [ForeignKey("GenreId")]
        public Genre Genre { get; set; } = null!;

        public ICollection<Comment> Comments { get; set; } = new List<Comment>();

        [Required]
        public PostStateEnum State { get; set; } = PostStateEnum.Draft;
    }
}
