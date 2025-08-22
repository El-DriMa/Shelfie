﻿using Microsoft.Extensions.Primitives;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Shelfie.Models.SearchObjects
{
    public class UserRoleSearchObject : BaseSearchObject
    {
        public int? UserId { get; set; }
        public string? RoleName { get; set; }

    }
}
