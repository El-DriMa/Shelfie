using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Shelfie.Models.Responses
{
    public class ReadingChallengeResponse
    {
        public int Id { get; set; }
        public string ChallengeName { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
        public string GoalType { get; set; } = string.Empty;
        public int GoalAmount { get; set; }
        public DateOnly StartDate { get; set; }
        public DateOnly EndDate { get; set; }
        public int Progress { get; set; }
        public bool IsCompleted { get; set; }
        public int UserId { get; set; }
        public string? Username { get; set; }
    }
}
