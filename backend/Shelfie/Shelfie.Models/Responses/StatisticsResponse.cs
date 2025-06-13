using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Shelfie.Models.Responses
{
    public class StatisticsResponse
    {
        public int Id { get; set; }
        public int TotalReadBooks { get; set; }
        public int TotalBooksInShelf { get; set; }
        public int TotalPagesRead { get; set; }
        public string MostReadGenreName { get; set; } = string.Empty;
        public string BookWithLeastPagesTitle { get; set; } = string.Empty;
        public string BookWithMostPagesTitle { get; set; } = string.Empty;
    }
}
