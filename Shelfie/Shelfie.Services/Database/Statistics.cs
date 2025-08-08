using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Shelfie.Services.Database
{
    public class Statistics : BaseEntity
    {
        [Required]
        public int UserId { get; set; }
        [ForeignKey("UserId")]
        public User User { get; set; } = null!;

        [Range(0, int.MaxValue, ErrorMessage = "Total read books must be a positive number or zero.")]
        public int TotalReadBooks { get; set; } = 0;

        public int TotalBooksInShelf { get; set; } = 0;

        [Range(0, int.MaxValue, ErrorMessage = "Total pages read must be a positive number or zero.")]
        public int TotalPagesRead { get; set; } = 0;

        public int MostReadGenreId { get; set; }
        [ForeignKey("MostReadGenreId")]
        public Genre MostReadGenre { get; set; } = null!;  

        public int BookWithLeastPagesId { get; set; } 
        [ForeignKey("BookWithLeastPagesId")]
        public Book BookWithLeastPages { get; set; } = null!;  

        public int BookWithMostPagesId { get; set; }  
        [ForeignKey("BookWithMostPagesId")]
        public Book BookWithMostPages { get; set; } = null!;
        public DateTime? FirstBookReadDate { get; set; }
        public DateTime? LastBookReadDate { get; set; } 
        public int UniqueGenresCount { get; set; } 
        public int TopAuthorId { get; set; } 
        [ForeignKey("TopAuthorId")]
        public Author TopAuthor { get; set; } = null!;


    }
}
