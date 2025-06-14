using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Shelfie.Models.Enums
{
        public enum ShelfTypeEnum
        {
            [Display(Name = "Currently Reading")]
            CurrentlyReading = 1,

            [Display(Name = "Read")]
            Read = 0,

            [Display(Name = "Want to Read")]
            WantToRead = 2
        }
  
}
