using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Shelfie.Models.Responses
{
    public class StatisticsResponse
    {
        public int UserId { get; set; }
        public int TotalReadBooks { get; set; }
        public int TotalBooksInShelf { get; set; }
        public int TotalPagesRead { get; set; }
        public string MostReadGenreName { get; set; } = "No data";
        public string BookWithLeastPagesTitle { get; set; } = "No data";
        public int BookWithLeastPagesCount { get; set; } = 0;
        public string BookWithMostPagesTitle { get; set; } = "No data";
        public int BookWithMostPagesCount { get; set; } = 0;
        public DateTime? FirstBookReadDate { get; set; }
        public DateTime? LastBookReadDate { get; set; }
        public int UniqueGenresCount { get; set; }
        public List<string> UniqueGenresNames { get; set; } = new List<string>();
        public int TopAuthorId { get; set; }
        public string TopAuthor { get; set; } = "No data";



        //

        public int TotalUsers { get; set; }
        public int TotalBooks { get; set; }
        public int TotalAuthors { get; set; }
        public int TotalReviews { get; set; }
        public List<string> MostReadGenres { get; set; } = new List<string>();
        public List<int> MostReadGenresCounts { get; set; } = new List<int>();
        public List<string> TopUsers { get; set; } = new List<string>();
        public List<int> TopUsersCounts { get; set; } = new List<int>();
        public double AverageRating { get; set; }
    }
}
