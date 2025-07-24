using Shelfie.Models.Enums;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.Json.Serialization;
using System.Threading.Tasks;

namespace Shelfie.Models.Responses
{
    public class ShelfResponse
    {
        public int Id { get; set; }
        [JsonConverter(typeof(JsonStringEnumConverter))]
        public ShelfTypeEnum Name { get; set; }
        public int BooksCount { get; set; }
       // public string UserFullName { get; set; } = string.Empty;
       public int UserId {  get; set; }
    }
}
