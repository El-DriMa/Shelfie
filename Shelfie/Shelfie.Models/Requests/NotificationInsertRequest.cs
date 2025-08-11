using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Shelfie.Models.Requests
{
    public class NotificationInsertRequest
    {
        public int PostId { get; set; }
        public int CommentId { get; set; }
        public string CommentText { get; set; } = string.Empty;
        public int FromUserId { get; set; }
        public string FromUserName { get; set; } = string.Empty;
        public int ToUserId { get; set; }
        public bool IsRead { get; set; }
    }
}
