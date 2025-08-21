using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Shelfie.Services.Database;

namespace ShelfieAPI.DataSeed
{
    [Route("api/[controller]")]
    [ApiController]
    [AllowAnonymous]
    public class DataSeed : ControllerBase
    {
        private readonly IB220155Context _context;
        public DataSeed(IB220155Context context)
        {
            _context = context;
        }

        [HttpPost("authors")]
        public IActionResult SeedAuthors()
        {
            if (_context.Set<Author>().Any()) return BadRequest("Authors already seeded.");

            var authors = new List<Author>
            {
                new Author { FirstName = "Jane", LastName = "Austen", BirthCountry = "United Kingdom", BirthDate = new DateOnly(1775,12,16), DeathDate = new DateOnly(1817,7,18), ShortBio = "English novelist."},
                new Author { FirstName = "Mark", LastName = "Twain", BirthCountry = "United States", BirthDate = new DateOnly(1835,11,30), DeathDate = new DateOnly(1910,4,21), ShortBio = "American writer."},
                new Author { FirstName = "Charles", LastName = "Dickens", BirthCountry = "United Kingdom", BirthDate = new DateOnly(1812,2,7), DeathDate = new DateOnly(1870,6,9), ShortBio = "English writer."},
                new Author { FirstName = "Leo", LastName = "Tolstoy", BirthCountry = "Russia", BirthDate = new DateOnly(1828,9,9), DeathDate = new DateOnly(1910,11,20), ShortBio = "Russian novelist."},
                new Author { FirstName = "Agatha", LastName = "Christie", BirthCountry = "United Kingdom", BirthDate = new DateOnly(1890,9,15), DeathDate = new DateOnly(1976,1,12), ShortBio = "Mystery writer."},
                new Author { FirstName = "J.K.", LastName = "Rowling", BirthCountry = "United Kingdom", BirthDate = new DateOnly(1965,7,31), ShortBio = "Author of Harry Potter."},
                new Author { FirstName = "George", LastName = "Orwell", BirthCountry = "United Kingdom", BirthDate = new DateOnly(1903,6,25), DeathDate = new DateOnly(1950,1,21), ShortBio = "Dystopian writer."},
                new Author { FirstName = "Ernest", LastName = "Hemingway", BirthCountry = "United States", BirthDate = new DateOnly(1899,7,21), DeathDate = new DateOnly(1961,7,2), ShortBio = "American novelist."},
                new Author { FirstName = "F. Scott", LastName = "Fitzgerald", BirthCountry = "United States", BirthDate = new DateOnly(1896,9,24), DeathDate = new DateOnly(1940,12,21), ShortBio = "Jazz Age novelist."},
                new Author { FirstName = "Virginia", LastName = "Woolf", BirthCountry = "United Kingdom", BirthDate = new DateOnly(1882,1,25), DeathDate = new DateOnly(1941,3,28), ShortBio = "Modernist writer."},
                new Author { FirstName = "James", LastName = "Joyce", BirthCountry = "Ireland", BirthDate = new DateOnly(1882,2,2), DeathDate = new DateOnly(1941,1,13), ShortBio = "Irish novelist."},
                new Author { FirstName = "Herman", LastName = "Melville", BirthCountry = "United States", BirthDate = new DateOnly(1819,8,1), DeathDate = new DateOnly(1891,9,28), ShortBio = "Author of Moby Dick."},
                new Author { FirstName = "J.R.R.", LastName = "Tolkien", BirthCountry = "United Kingdom", BirthDate = new DateOnly(1892,1,3), DeathDate = new DateOnly(1973,9,2), ShortBio = "Fantasy author."},
                new Author { FirstName = "Harper", LastName = "Lee", BirthCountry = "United States", BirthDate = new DateOnly(1926,4,28), DeathDate = new DateOnly(2016,2,19), ShortBio = "To Kill a Mockingbird."},
                new Author { FirstName = "Mary", LastName = "Shelley", BirthCountry = "United Kingdom", BirthDate = new DateOnly(1797,8,30), DeathDate = new DateOnly(1851,2,1), ShortBio = "Author of Frankenstein."}
            };

            _context.Set<Author>().AddRange(authors);
            _context.SaveChanges();
            return Ok("Authors seeded.");
        }

        [HttpPost("genres")]
        public IActionResult SeedGenres()
        {
            if (_context.Set<Genre>().Any()) return BadRequest("Genres already seeded.");

            var genres = new List<Genre>
            {
                new Genre { Name = "Fantasy" },
                new Genre { Name = "Science Fiction" },
                new Genre { Name = "Mystery" },
                new Genre { Name = "Thriller" },
                new Genre { Name = "Romance" },
                new Genre { Name = "Historical" },
                new Genre { Name = "Biography" },
                new Genre { Name = "Self-help" },
                new Genre { Name = "Drama" },
                new Genre { Name = "Adventure" },
                new Genre { Name = "Horror" },
                new Genre { Name = "Crime" },
                new Genre { Name = "Classic" },
                new Genre { Name = "Poetry" },
                new Genre { Name = "Young Adult" }
            };

            _context.Set<Genre>().AddRange(genres);
            _context.SaveChanges();
            return Ok("Genres seeded.");
        }
        [HttpPost("publishers")]
        public IActionResult SeedPublishers()
        {
            if (_context.Set<Publisher>().Any()) return BadRequest("Publishers already seeded.");

            var publishers = new List<Publisher>
            {
                new Publisher { Name = "Penguin Random House", HeadquartersLocation = "New York, USA", ContactEmail = "contact@penguinrandomhouse.com", ContactPhone = "123456789", YearFounded = 1927, Country = "USA" },
                new Publisher { Name = "HarperCollins", HeadquartersLocation = "New York, USA", ContactEmail = "info@harpercollins.com", ContactPhone = "987654321", YearFounded = 1989, Country = "USA" },
                new Publisher { Name = "Simon & Schuster", HeadquartersLocation = "New York, USA", ContactEmail = "contact@simonandschuster.com", ContactPhone = "555123456", YearFounded = 1924, Country = "USA" },
                new Publisher { Name = "Hachette Livre", HeadquartersLocation = "Paris, France", ContactEmail = "contact@hachette.com", ContactPhone = "33123456789", YearFounded = 1826, Country = "France" },
                new Publisher { Name = "Macmillan Publishers", HeadquartersLocation = "London, UK", ContactEmail = "info@macmillan.com", ContactPhone = "442012345678", YearFounded = 1843, Country = "UK" },
                new Publisher { Name = "Scholastic", HeadquartersLocation = "New York, USA", ContactEmail = "contact@scholastic.com", ContactPhone = "123123123", YearFounded = 1920, Country = "USA" },
                new Publisher { Name = "Bloomsbury", HeadquartersLocation = "London, UK", ContactEmail = "info@bloomsbury.com", ContactPhone = "442076543210", YearFounded = 1986, Country = "UK" },
                new Publisher { Name = "Oxford University Press", HeadquartersLocation = "Oxford, UK", ContactEmail = "contact@oup.com", ContactPhone = "442086432100", YearFounded = 1586, Country = "UK" },
                new Publisher { Name = "Pearson", HeadquartersLocation = "London, UK", ContactEmail = "info@pearson.com", ContactPhone = "442071234567", YearFounded = 1844, Country = "UK" },
                new Publisher { Name = "Cengage", HeadquartersLocation = "Boston, USA", ContactEmail = "contact@cengage.com", ContactPhone = "16173234567", YearFounded = 2007, Country = "USA" },
                new Publisher { Name = "Wiley", HeadquartersLocation = "Hoboken, USA", ContactEmail = "info@wiley.com", ContactPhone = "19083974567", YearFounded = 1807, Country = "USA" },
                new Publisher { Name = "Springer", HeadquartersLocation = "Berlin, Germany", ContactEmail = "contact@springer.com", ContactPhone = "49301234567", YearFounded = 1842, Country = "Germany" },
                new Publisher { Name = "McGraw-Hill Education", HeadquartersLocation = "New York, USA", ContactEmail = "info@mcgrawhill.com", ContactPhone = "123456789", YearFounded = 1888, Country = "USA" },
                new Publisher { Name = "SAGE Publications", HeadquartersLocation = "Thousand Oaks, USA", ContactEmail = "contact@sagepub.com", ContactPhone = "18005551234", YearFounded = 1965, Country = "USA" },
                new Publisher { Name = "Taylor & Francis", HeadquartersLocation = "Abingdon, UK", ContactEmail = "info@taylorandfrancis.com", ContactPhone = "442012345679", YearFounded = 1798, Country = "UK" }
            };

            _context.Set<Publisher>().AddRange(publishers);
            _context.SaveChanges();
            return Ok("Publishers seeded.");
        }

        [HttpPost("roles")]
        public IActionResult SeedRoles()
        {
            if (_context.Set<Role>().Any()) return BadRequest("Roles already seeded.");

            var roles = new List<Role>
            {
                new Role { Name = "Admin", Description = "Administrator with full permissions" },
                new Role { Name = "User", Description = "Regular user with limited permissions" }
            };

            _context.Set<Role>().AddRange(roles);
            _context.SaveChanges();
            return Ok("Roles seeded.");
        }

        [HttpPost("books")]
        public IActionResult SeedBooks()
        {
            if (_context.Books.Any())
                return BadRequest("Books already seeded.");

            var books = new List<Book>
            {
                new Book { Title = "Pride and Prejudice", TotalPages = 279, PhotoUrl = null, AuthorId = 1, PublisherId = 1, GenreId = 5, YearPublished = 1813, ShortDescription = "Classic romantic novel", Language = "English" },
                new Book { Title = "The Adventures of Tom Sawyer", TotalPages = 274, PhotoUrl = null, AuthorId = 2, PublisherId = 2, GenreId = 10, YearPublished = 1876, ShortDescription = "American classic", Language = "English" },
                new Book { Title = "Great Expectations", TotalPages = 505, PhotoUrl = null, AuthorId = 3, PublisherId = 3, GenreId = 13, YearPublished = 1861, ShortDescription = "Coming-of-age novel", Language = "English" },
                new Book { Title = "War and Peace", TotalPages = 1225, PhotoUrl = null, AuthorId = 4, PublisherId = 4, GenreId = 6, YearPublished = 1869, ShortDescription = "Historical novel", Language = "English" },
                new Book { Title = "Murder on the Orient Express", TotalPages = 256, PhotoUrl = null, AuthorId = 5, PublisherId = 5, GenreId = 3, YearPublished = 1934, ShortDescription = "Mystery novel", Language = "English" },
                new Book { Title = "Harry Potter and the Philosopher's Stone", TotalPages = 223, PhotoUrl = null, AuthorId = 6, PublisherId = 6, GenreId = 1, YearPublished = 1997, ShortDescription = "Fantasy novel", Language = "English" },
                new Book { Title = "1984", TotalPages = 328, PhotoUrl = null, AuthorId = 7, PublisherId = 7, GenreId = 2, YearPublished = 1949, ShortDescription = "Dystopian novel", Language = "English" },
                new Book { Title = "The Old Man and the Sea", TotalPages = 127, PhotoUrl = null, AuthorId = 8, PublisherId = 8, GenreId = 13, YearPublished = 1952, ShortDescription = "Short novel", Language = "English" },
                new Book { Title = "The Great Gatsby", TotalPages = 180, PhotoUrl = null, AuthorId = 9, PublisherId = 9, GenreId = 13, YearPublished = 1925, ShortDescription = "Jazz Age novel", Language = "English" },
                new Book { Title = "Mrs Dalloway", TotalPages = 296, PhotoUrl = null, AuthorId = 10, PublisherId = 10, GenreId = 9, YearPublished = 1925, ShortDescription = "Modernist novel", Language = "English" },
                new Book { Title = "Ulysses", TotalPages = 730, PhotoUrl = null, AuthorId = 11, PublisherId = 11, GenreId = 13, YearPublished = 1922, ShortDescription = "Stream-of-consciousness novel", Language = "English" },
                new Book { Title = "Moby-Dick", TotalPages = 635, PhotoUrl = null, AuthorId = 12, PublisherId = 12, GenreId = 10, YearPublished = 1851, ShortDescription = "Epic sea story", Language = "English" },
                new Book { Title = "The Hobbit", TotalPages = 310, PhotoUrl = null, AuthorId = 13, PublisherId = 13, GenreId = 1, YearPublished = 1937, ShortDescription = "Fantasy novel", Language = "English" },
                new Book { Title = "To Kill a Mockingbird", TotalPages = 281, PhotoUrl = null, AuthorId = 14, PublisherId = 14, GenreId = 9, YearPublished = 1960, ShortDescription = "Pulitzer-winning novel", Language = "English" },
                new Book { Title = "Frankenstein", TotalPages = 280, PhotoUrl = null, AuthorId = 15, PublisherId = 15, GenreId = 11, YearPublished = 1818, ShortDescription = "Gothic horror novel", Language = "English" }
            };

            _context.Books.AddRange(books);
            _context.SaveChanges();

            return Ok("Books seeded.");
        }

        [HttpPost("shelves")]
        public IActionResult SeedShelves()
        {
            if (_context.Set<Shelf>().Any()) return BadRequest("Shelves already seeded.");

            var shelves = new List<Shelf>
           {
               new Shelf { Name = Shelfie.Models.Enums.ShelfTypeEnum.Read, BooksCount = 0, UserId = 1 },
               new Shelf { Name = Shelfie.Models.Enums.ShelfTypeEnum.CurrentlyReading, BooksCount = 0, UserId = 1 },
               new Shelf { Name = Shelfie.Models.Enums.ShelfTypeEnum.WantToRead, BooksCount = 0, UserId = 1 },
           };

            _context.Set<Shelf>().AddRange(shelves);
            _context.SaveChanges();
            return Ok($"Shelves seeded for user {shelves[0].UserId}");
        }

        [HttpPost("more-books")]
        public IActionResult SeedMoreBooks()
        {
            var books = new List<Book>
            {
                new Book { Title = "Emma", TotalPages = 474, PhotoUrl = null, AuthorId = 1, PublisherId = 1, GenreId = 5, YearPublished = 1815, ShortDescription = "Romantic novel", Language = "English" },
                new Book { Title = "The Prince and the Pauper", TotalPages = 192, PhotoUrl = null, AuthorId = 2, PublisherId = 2, GenreId = 10, YearPublished = 1881, ShortDescription = "Historical tale", Language = "English" },
                new Book { Title = "Oliver Twist", TotalPages = 554, PhotoUrl = null, AuthorId = 3, PublisherId = 3, GenreId = 6, YearPublished = 1839, ShortDescription = "Victorian novel", Language = "English" },
                new Book { Title = "Anna Karenina", TotalPages = 864, PhotoUrl = null, AuthorId = 4, PublisherId = 4, GenreId = 5, YearPublished = 1878, ShortDescription = "Tragic romance", Language = "English" },
                new Book { Title = "And Then There Were None", TotalPages = 272, PhotoUrl = null, AuthorId = 5, PublisherId = 5, GenreId = 3, YearPublished = 1939, ShortDescription = "Mystery classic", Language = "English" },
                new Book { Title = "Harry Potter and the Chamber of Secrets", TotalPages = 251, PhotoUrl = null, AuthorId = 6, PublisherId = 6, GenreId = 1, YearPublished = 1998, ShortDescription = "Fantasy sequel", Language = "English" },
                new Book { Title = "Animal Farm", TotalPages = 112, PhotoUrl = null, AuthorId = 7, PublisherId = 7, GenreId = 2, YearPublished = 1945, ShortDescription = "Political satire", Language = "English" },
                new Book { Title = "A Farewell to Arms", TotalPages = 355, PhotoUrl = null, AuthorId = 8, PublisherId = 8, GenreId = 6, YearPublished = 1929, ShortDescription = "War romance", Language = "English" },
                new Book { Title = "Tender Is the Night", TotalPages = 317, PhotoUrl = null, AuthorId = 9, PublisherId = 9, GenreId = 13, YearPublished = 1934, ShortDescription = "Psychological novel", Language = "English" },
                new Book { Title = "To the Lighthouse", TotalPages = 209, PhotoUrl = null, AuthorId = 10, PublisherId = 10, GenreId = 9, YearPublished = 1927, ShortDescription = "Modernist work", Language = "English" },
                new Book { Title = "Dubliners", TotalPages = 152, PhotoUrl = null, AuthorId = 11, PublisherId = 11, GenreId = 13, YearPublished = 1914, ShortDescription = "Short story collection", Language = "English" },
                new Book { Title = "Billy Budd", TotalPages = 192, PhotoUrl = null, AuthorId = 12, PublisherId = 12, GenreId = 10, YearPublished = 1924, ShortDescription = "Maritime tale", Language = "English" },
                new Book { Title = "The Silmarillion", TotalPages = 365, PhotoUrl = null, AuthorId = 13, PublisherId = 13, GenreId = 1, YearPublished = 1977, ShortDescription = "Mythopoeic work", Language = "English" },
                new Book { Title = "Go Set a Watchman", TotalPages = 278, PhotoUrl = null, AuthorId = 14, PublisherId = 14, GenreId = 9, YearPublished = 2015, ShortDescription = "Sequel to Mockingbird", Language = "English" },
                new Book { Title = "Mathilda", TotalPages = 123, PhotoUrl = null, AuthorId = 15, PublisherId = 15, GenreId = 11, YearPublished = 1819, ShortDescription = "Gothic fiction", Language = "English" },
                new Book { Title = "Northanger Abbey", TotalPages = 251, PhotoUrl = null, AuthorId = 1, PublisherId = 1, GenreId = 5, YearPublished = 1817, ShortDescription = "Romantic satire", Language = "English" },
                new Book { Title = "Roughing It", TotalPages = 412, PhotoUrl = null, AuthorId = 2, PublisherId = 2, GenreId = 10, YearPublished = 1872, ShortDescription = "Travel literature", Language = "English" },
                new Book { Title = "A Tale of Two Cities", TotalPages = 341, PhotoUrl = null, AuthorId = 3, PublisherId = 3, GenreId = 6, YearPublished = 1859, ShortDescription = "Revolutionary drama", Language = "English" },
                new Book { Title = "Resurrection", TotalPages = 592, PhotoUrl = null, AuthorId = 4, PublisherId = 4, GenreId = 6, YearPublished = 1899, ShortDescription = "Spiritual awakening", Language = "English" },
                new Book { Title = "The Mysterious Affair at Styles", TotalPages = 296, PhotoUrl = null, AuthorId = 5, PublisherId = 5, GenreId = 3, YearPublished = 1920, ShortDescription = "Debut mystery", Language = "English" },
                new Book { Title = "Harry Potter and the Prisoner of Azkaban", TotalPages = 317, PhotoUrl = null, AuthorId = 6, PublisherId = 6, GenreId = 1, YearPublished = 1999, ShortDescription = "Fantasy sequel", Language = "English" },
                new Book { Title = "Homage to Catalonia", TotalPages = 232, PhotoUrl = null, AuthorId = 7, PublisherId = 7, GenreId = 6, YearPublished = 1938, ShortDescription = "War memoir", Language = "English" },
                new Book { Title = "The Sun Also Rises", TotalPages = 251, PhotoUrl = null, AuthorId = 8, PublisherId = 8, GenreId = 13, YearPublished = 1926, ShortDescription = "Postwar novel", Language = "English" },
                new Book { Title = "This Side of Paradise", TotalPages = 305, PhotoUrl = null, AuthorId = 9, PublisherId = 9, GenreId = 13, YearPublished = 1920, ShortDescription = "Debut novel", Language = "English" },
                new Book { Title = "Jacob's Room", TotalPages = 224, PhotoUrl = null, AuthorId = 10, PublisherId = 10, GenreId = 9, YearPublished = 1922, ShortDescription = "Modernist novel", Language = "English" }
            };

            _context.Books.AddRange(books);
            _context.SaveChanges();

            return Ok("More books seeded.");
        }


    }
}

