using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Shelfie.Models.SearchObjects
{
    public class NotificationSearchObject : BaseSearchObject
    {
        public int? ToUserId { get; set; }
        public bool? IsRead { get; set; } 
        public DateTime? FromDate { get; set; }
        public DateTime? ToDate { get; set; } 
    }
}
