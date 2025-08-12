﻿using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Shelfie.Models.Requests
{
    public class PublisherUpdateRequest
    {
        
        [StringLength(200, ErrorMessage = "Publisher name can't be longer than 200 characters.")]
        public string? Name { get; set; } = string.Empty;

        [StringLength(500, ErrorMessage = "Headquarters location can't be longer than 500 characters.")]
        public string? HeadquartersLocation { get; set; } = string.Empty;

        
        [EmailAddress(ErrorMessage = "Invalid email format.")]
        public string? ContactEmail { get; set; } = string.Empty;

        public string? ContactPhone { get; set; } = string.Empty;

        [Range(1500, 2025, ErrorMessage = "Year founded must be a valid year.")]
        public int? YearFounded { get; set; }

        
        public string? Country { get; set; } = string.Empty;
    }
}
