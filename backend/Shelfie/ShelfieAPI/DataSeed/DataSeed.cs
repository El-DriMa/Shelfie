﻿using Microsoft.AspNetCore.Authorization;
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
        new Book { Title = "The Silent Spring", TotalPages = 320, CoverImage = null, AuthorId = 1, PublisherId = 1, GenreId = 1, YearPublished = 1962, ShortDescription = "Environmental science classic", Language = "English" },
        new Book { Title = "To Kill a Mockingbird", TotalPages = 281, CoverImage = null, AuthorId = 2, PublisherId = 2, GenreId = 2, YearPublished = 1960, ShortDescription = "Pulitzer Prize-winning novel", Language = "English" },
        new Book { Title = "1984", TotalPages = 328, CoverImage = null, AuthorId = 3, PublisherId = 3, GenreId = 3, YearPublished = 1949, ShortDescription = "Dystopian social science fiction", Language = "English" },
        new Book { Title = "Pride and Prejudice", TotalPages = 279, CoverImage = null, AuthorId = 4, PublisherId = 4, GenreId = 4, YearPublished = 1813, ShortDescription = "Classic romantic novel", Language = "English" },
        new Book { Title = "Moby-Dick", TotalPages = 635, CoverImage = null, AuthorId = 5, PublisherId = 5, GenreId = 5, YearPublished = 1851, ShortDescription = "Epic sea story", Language = "English" },
        new Book { Title = "War and Peace", TotalPages = 1225, CoverImage = null, AuthorId = 6, PublisherId = 6, GenreId = 6, YearPublished = 1869, ShortDescription = "Historical novel", Language = "English" },
        new Book { Title = "The Great Gatsby", TotalPages = 180, CoverImage = null, AuthorId = 7, PublisherId = 7, GenreId = 7, YearPublished = 1925, ShortDescription = "Jazz Age novel", Language = "English" },
        new Book { Title = "Crime and Punishment", TotalPages = 430, CoverImage = null, AuthorId = 8, PublisherId = 8, GenreId = 8, YearPublished = 1866, ShortDescription = "Philosophical crime novel", Language = "English" },
        new Book { Title = "The Catcher in the Rye", TotalPages = 277, CoverImage = null, AuthorId = 9, PublisherId = 9, GenreId = 9, YearPublished = 1951, ShortDescription = "Coming-of-age novel", Language = "English" },
        new Book { Title = "Brave New World", TotalPages = 268, CoverImage = null, AuthorId = 10, PublisherId = 10, GenreId = 10, YearPublished = 1932, ShortDescription = "Science fiction dystopia", Language = "English" },
        new Book { Title = "Jane Eyre", TotalPages = 500, CoverImage = null, AuthorId = 11, PublisherId = 11, GenreId = 11, YearPublished = 1847, ShortDescription = "Gothic novel", Language = "English" },
        new Book { Title = "The Hobbit", TotalPages = 310, CoverImage = null, AuthorId = 12, PublisherId = 12, GenreId = 12, YearPublished = 1937, ShortDescription = "Fantasy novel", Language = "English" },
        new Book { Title = "Fahrenheit 451", TotalPages = 194, CoverImage = null, AuthorId = 13, PublisherId = 13, GenreId = 13, YearPublished = 1953, ShortDescription = "Dystopian novel", Language = "English" },
        new Book { Title = "The Odyssey", TotalPages = 500, CoverImage = null, AuthorId = 14, PublisherId = 14, GenreId = 14, YearPublished = -800, ShortDescription = "Epic Greek poem", Language = "English" },
        new Book { Title = "Don Quixote", TotalPages = 863, CoverImage = null, AuthorId = 15, PublisherId = 15, GenreId = 15, YearPublished = 1605, ShortDescription = "Classic Spanish novel", Language = "English" }
    };

            _context.Books.AddRange(books);
            _context.SaveChanges();

            return Ok("Books seeded.");
        }



    }
}

