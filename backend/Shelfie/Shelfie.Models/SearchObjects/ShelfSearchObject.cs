using Shelfie.Models.Enums;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;


namespace Shelfie.Models.SearchObjects
{
    public class ShelfSearchObject : BaseSearchObject
    {
        public int? UserId { get; set; }         
        public ShelfTypeEnum? Name { get; set; }   
        public int? BooksCount { get; set; }        
    }
}
