﻿using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Shelfie.Models.Enums;
using Shelfie.Services.Database;
using Shelfie.Services.Helpers;

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

        [HttpPost("seed-all")]
        public IActionResult SeedAll()
        {
            if (!_context.Set<Author>().Any())
            {
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
            }

            if (!_context.Set<Genre>().Any())
            {
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
            }

            if (!_context.Set<Publisher>().Any())
            {
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
            }

            
            if (!_context.Set<Role>().Any())
            {
                var roles = new List<Role>
                {
                    new Role { Name = "Admin", Description = "Administrator with full permissions" },
                    new Role { Name = "User", Description = "Regular user with limited permissions" }
                };
                _context.Set<Role>().AddRange(roles);
                _context.SaveChanges();
            }

            if (!_context.Books.Any())
            {
                var books = new List<Book>
                {
                    new Book { Title = "Pride and Prejudice", TotalPages = 279, PhotoUrl = "covers/5ba49406-fbb1-4138-8b39-91623895f709.jpg", AuthorId = 1, PublisherId = 1, GenreId = 5, YearPublished = 1813, ShortDescription = "Classic romantic novel", Language = "English" },
                    new Book { Title = "The Adventures of Tom Sawyer", TotalPages = 274, PhotoUrl = null, AuthorId = 2, PublisherId = 2, GenreId = 10, YearPublished = 1876, ShortDescription = "American classic", Language = "English" },
                    new Book { Title = "Great Expectations", TotalPages = 505, PhotoUrl = null, AuthorId = 3, PublisherId = 3, GenreId = 13, YearPublished = 1861, ShortDescription = "Coming-of-age novel", Language = "English" },
                    new Book { Title = "War and Peace", TotalPages = 1225, PhotoUrl = null, AuthorId = 4, PublisherId = 4, GenreId = 6, YearPublished = 1869, ShortDescription = "Historical novel", Language = "English" },
                    new Book { Title = "Murder on the Orient Express", TotalPages = 256, PhotoUrl = null, AuthorId = 5, PublisherId = 5, GenreId = 3, YearPublished = 1934, ShortDescription = "Mystery novel", Language = "English" },
                    new Book { Title = "Harry Potter and the Philosopher's Stone", TotalPages = 223, PhotoUrl = null, AuthorId = 6, PublisherId = 6, GenreId = 1, YearPublished = 1997, ShortDescription = "Fantasy novel", Language = "English" },
                    new Book { Title = "1984", TotalPages = 328, PhotoUrl = "covers/fde22249-32bc-4478-9500-0579fc59835c.jpg", AuthorId = 7, PublisherId = 7, GenreId = 2, YearPublished = 1949, ShortDescription = "Dystopian novel", Language = "English" },
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
            }


            if (!_context.Set<User>().Any())
            {
                var users = new List<User>
                {
                    new User { FirstName="Desktop", LastName="Admin", Username = "desktop", Email = "desktop@example.com" },
                    new User { FirstName="Mobile", LastName="Test", Username = "mobile", Email = "mobile@example.com" },  
                    new User { FirstName="Alice",LastName="Doe", Username = "alice", Email = "alice@example.com" },
                    new User { FirstName="Bob",LastName="Macy", Username = "bob", Email = "bob@example.com" },
                };

                foreach (var user in users)
                {
                    PasswordHelper.CreatePasswordHash("test", out string hash, out string salt);
                    user.PasswordHash = hash;
                    user.PasswordSalt = salt;
                    user.IsActive = true;
                }

                _context.Set<User>().AddRange(users);
                _context.SaveChanges();

                var adminRole = _context.Set<Role>().FirstOrDefault(r => r.Name == "Admin");
                var userRole = _context.Set<Role>().FirstOrDefault(r => r.Name == "User");

                var userRoles = new List<UserRole>
                    {
                        new UserRole { UserId = users[0].Id, RoleId = adminRole.Id },
                        new UserRole { UserId = users[1].Id, RoleId = userRole.Id },
                        new UserRole { UserId = users[2].Id, RoleId = userRole.Id },
                        new UserRole { UserId = users[3].Id, RoleId = userRole.Id },
                    };
                _context.Set<UserRole>().AddRange(userRoles);
                _context.SaveChanges();
            }

            if (!_context.Set<Shelf>().Any())
            {
                var shelves = new List<Shelf>
                {
                    new Shelf { Name = Shelfie.Models.Enums.ShelfTypeEnum.Read, BooksCount = 2, UserId = 2 },
                    new Shelf { Name = Shelfie.Models.Enums.ShelfTypeEnum.CurrentlyReading, BooksCount = 0, UserId = 2 },
                    new Shelf { Name = Shelfie.Models.Enums.ShelfTypeEnum.WantToRead, BooksCount = 0, UserId = 2 },
                    new Shelf { Name = Shelfie.Models.Enums.ShelfTypeEnum.Read, BooksCount = 2, UserId = 3 },
                    new Shelf { Name = Shelfie.Models.Enums.ShelfTypeEnum.CurrentlyReading, BooksCount = 0, UserId = 3 },
                    new Shelf { Name = Shelfie.Models.Enums.ShelfTypeEnum.WantToRead, BooksCount = 0, UserId = 3 }
                };
                _context.Set<Shelf>().AddRange(shelves);
                _context.SaveChanges();
            }

            if (!_context.Set<ShelfBooks>().Any())
            {
                var shelfBooks = new List<ShelfBooks>
                    {
                        new ShelfBooks { ShelfId = 1, BookId = 6, PagesRead = 50 },
                        new ShelfBooks { ShelfId = 1, BookId = 4, PagesRead = 50 },
                        new ShelfBooks { ShelfId = 4, BookId = 4, PagesRead = 100 },
                        new ShelfBooks { ShelfId = 4, BookId = 2, PagesRead = 20 }
                    };
                _context.Set<ShelfBooks>().AddRange(shelfBooks);
                _context.SaveChanges();
            }


            if (!_context.Set<Post>().Any())
            {
                var posts = new List<Post>
                    {
                        new Post { Content = "Excited to start reading Harry Potter!", UserId = 2, GenreId = 1, State = PostStateEnum.Published },
                        new Post { Content = "Just finished War and Peace, amazing!", UserId = 3, GenreId = 6, State = PostStateEnum.Published },
                        new Post { Content = "Looking for a good mystery book.", UserId = 2, GenreId = 3, State = PostStateEnum.Draft }
                    };
                _context.Set<Post>().AddRange(posts);
                _context.SaveChanges();
            }


            if (!_context.Set<ReadingChallenge>().Any())
            {
                var challenges = new List<ReadingChallenge>
                    {
                        new ReadingChallenge { UserId = 2, ChallengeName = "Read 5 Books", Description = "Complete 5 books this month", GoalType = GoalTypeEnum.Books, GoalAmount = 5, StartDate = DateOnly.FromDateTime(DateTime.Now), EndDate = DateOnly.FromDateTime(DateTime.Now.AddMonths(1)), Progress = 0, IsCompleted = false },
                        new ReadingChallenge { UserId = 3, ChallengeName = "Read 1000 Pages", Description = "Reach 1000 pages", GoalType = GoalTypeEnum.Pages, GoalAmount = 1000, StartDate = DateOnly.FromDateTime(DateTime.Now), EndDate = DateOnly.FromDateTime(DateTime.Now.AddMonths(2)), Progress = 200, IsCompleted = false }
                    };
                _context.Set<ReadingChallenge>().AddRange(challenges);
                _context.SaveChanges();
            }

            if (!_context.Set<Review>().Any())
            {
                var reviews = new List<Review>
                    {
                        new Review { BookId = 6, UserId = 2, Rating = 5, Description = "Loved it!" },
                        new Review { BookId = 4, UserId = 2, Rating = 4, Description = "Historical masterpiece" },
                        new Review { BookId = 2, UserId = 3, Rating = 3, Description = "Good, but not my favorite" }
                    };
                _context.Set<Review>().AddRange(reviews);
                _context.SaveChanges();
            }

            

            return Ok("All data seeded successfully.");
        }
    }
}

