using Shelfie.Models.Enums;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Shelfie.Models.Requests
{
    public class ReadingChallengeUpdateRequest
    {
        [MaxLength(100, ErrorMessage = "Challenge name cannot exceed 100 characters.")]
        public string? ChallengeName { get; set; }

        [MaxLength(1000, ErrorMessage = "Description cannot exceed 1000 characters.")]
        public string? Description { get; set; }

        [Required(ErrorMessage = "Goal type is required.")]
        [Column(TypeName = "varchar(20)")]
        public GoalTypeEnum? GoalType { get; set; }

        [Range(1, int.MaxValue, ErrorMessage = "Goal amount must be a positive number.")]
        public int? GoalAmount { get; set; }

        [Required(ErrorMessage = "Start date is required.")]
        public DateOnly? StartDate { get; set; }

        public DateOnly? EndDate { get; set; }

        [Range(0, int.MaxValue, ErrorMessage = "Progress must be a positive number.")]
        public int? Progress { get; set; }

        public bool IsCompleted { get; set; }
    }
}
