using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Shelfie.Models.Enums;

namespace Shelfie.Services.Database
{
    public class ReadingChallenge : BaseEntity
    {
        public int UserId { get; set; }

        [ForeignKey("UserId")]
        public User User { get; set; } = null!;

        [Required(ErrorMessage = "Challenge name is required.")]
        [MaxLength(100, ErrorMessage = "Challenge name cannot exceed 100 characters.")]
        public string ChallengeName { get; set; } = string.Empty;

        [MaxLength(1000, ErrorMessage = "Description cannot exceed 1000 characters.")]
        public string Description { get; set; } = string.Empty;

   
        [Column(TypeName = "varchar(20)")]
        [Required]
        public GoalTypeEnum GoalType { get; set; }

        [Range(1, int.MaxValue, ErrorMessage = "GoalAmount must be a positive number.")]
        public int GoalAmount { get; set; }

        [Required(ErrorMessage = "Start date is required.")]
        public DateOnly StartDate { get; set; }

        [Required(ErrorMessage = "End date is required.")]
        [CustomValidation(typeof(Validations.Validations), nameof(Validations.Validations.ValidateEndDateAfterStartDate))]
        public DateOnly EndDate { get; set; }

        [Range(0, int.MaxValue, ErrorMessage = "Progress must be a positive number.")]
        public int Progress { get; set; }

        public bool IsCompleted { get; set; }
    }
}
