using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Xml.Linq;

namespace Shelfie.Models.Responses
{
    public class PostResponse
    {
        public int Id { get; set; }
        public string Content { get; set; } = string.Empty;
        public string Username { get; set; } =string.Empty;
        public string GenreName { get; set; }=string.Empty;

        public ICollection<CommentResponse> Comments { get; set; } = new List<CommentResponse>();
    }
}
