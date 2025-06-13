using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Shelfie.Models.Responses
{
    public class PublisherResponse
    {
        public int Id { get; set; }
        public string Name { get; set; } = string.Empty;
        public string HeadquartersLocation { get; set; } = string.Empty;
        public string ContactEmail { get; set; } = string.Empty;
        public string? ContactPhone { get; set; } = string.Empty;
        public int YearFounded { get; set; }
        public string Country { get; set; } = string.Empty;
    }
}
