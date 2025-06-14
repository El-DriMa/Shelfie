using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Shelfie.Models.Requests
{
    public class UserUpdateRequest
    {
        [Required(ErrorMessage = "First name is required.")]
        [MaxLength(50, ErrorMessage = "First name can't be more than 50 characters.")]
        public string? FirstName { get; set; } = string.Empty;

        [Required(ErrorMessage = "Last name is required.")]
        [MaxLength(50, ErrorMessage = "Last name can't be more than 50 characters.")]
        public string? LastName { get; set; } = string.Empty;

        [Required(ErrorMessage = "Email is required.")]
        [MaxLength(100, ErrorMessage = "Email can't be more than 100 characters.")]
        [EmailAddress(ErrorMessage = "Invalid email format.")]
        public string? Email { get; set; } = string.Empty;

        [Required(ErrorMessage = "Username is required.")]
        [MaxLength(100, ErrorMessage = "Username can't be more than 100 characters.")]
        public string? Username { get; set; } = string.Empty;

        [Required(ErrorMessage = "Password is required.")]
        public string? Password { get; set; } = string.Empty;

        public string? PhoneNumber { get; set; }
    }
}
