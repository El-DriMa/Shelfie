using Shelfie.Services.Database;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Shelfie.Services.Validations
{
    public class Validations
    {
        
        public static ValidationResult? ValidateEndDateAfterStartDate(DateOnly endDate, ValidationContext context)
        {
            var challenge = (ReadingChallenge)context.ObjectInstance;
            if (endDate <= challenge.StartDate)
            {
                return new ValidationResult("End date must be after start date.");
            }
            return ValidationResult.Success;
        }

      
        public static ValidationResult? ValidateDeathDateAfterBirthDate(DateOnly? deathDate, ValidationContext context)
        {
            if (deathDate.HasValue)
            {
                var author = (Author)context.ObjectInstance;
                if (deathDate.HasValue && deathDate <= author.BirthDate)
                {
                    return new ValidationResult("Death date must be after birth date.");
                }
            }
            return ValidationResult.Success;
        }
    }
}
