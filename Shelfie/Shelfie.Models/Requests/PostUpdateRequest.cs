﻿using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Shelfie.Models.Requests
{
    public class PostUpdateRequest
    {
        public string? Content { get; set; } = string.Empty;

    }
}
