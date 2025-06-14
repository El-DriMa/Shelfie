using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Shelfie.Models.Enums
{
    public enum GoalTypeEnum
    {
        [Display(Name = "Pages")]
        Pages = 0,

        [Display(Name = "Books")]
        Books = 1
    }
}
