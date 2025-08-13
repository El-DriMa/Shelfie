using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Internal;
using Shelfie.Models.Enums;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using static Shelfie.Services.Database.ReadingChallenge;

namespace Shelfie.Services.Database
{
    public class IB220155Context : DbContext
    {
        public IB220155Context()
        {
            
        }

        public IB220155Context(DbContextOptions<IB220155Context> options) : base(options)
        {
            
        }

        public DbSet<Author> Authors { get; set; }
        public DbSet<Book> Books { get; set; }
        public DbSet<Genre> Genres { get; set; }
        public DbSet<Publisher> Publishers { get; set; }
        public DbSet<ReadingChallenge> ReadingChallenges { get; set; }
        public DbSet<Role> Roles { get; set; }
        public DbSet<Shelf> Shelves { get; set; }
        public DbSet<Statistics> Statistics { get; set; }
        public DbSet<User> Users { get; set; }
        public DbSet<UserRole> UserRoles { get; set; }
        public DbSet<ShelfBooks> ShelfBooks { get; set; }
        public DbSet<Post> Posts { get; set; }
        public DbSet<Comment> Comments { get; set; }
        public DbSet<NotificationMessage> Notifications{ get; set; }
        public DbSet<Review> Reviews { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<ReadingChallenge>()
                .Property(r => r.GoalType)
                .HasConversion(
                    v => v.ToString(),
                    v => (GoalTypeEnum)Enum.Parse(typeof(GoalTypeEnum), v));

            modelBuilder.Entity<Shelf>()
                .Property(s => s.Name)
                .HasConversion(
                    v => v.ToString(),
                    v => (ShelfTypeEnum)Enum.Parse(typeof(ShelfTypeEnum), v));

            modelBuilder.Entity<Shelf>()
                .HasIndex(s => new { s.UserId, s.Name })
                .IsUnique();

            modelBuilder.Entity<Book>(entity =>
            {
                    entity.HasOne(b => b.Genre)
                     .WithMany(g => g.Books)
                     .HasForeignKey(b => b.GenreId)
                     .OnDelete(DeleteBehavior.Restrict);

                    entity.HasOne(b => b.Author)
                        .WithMany(a => a.Books)
                        .HasForeignKey(b => b.AuthorId)
                        .OnDelete(DeleteBehavior.Restrict);

                entity.HasOne(b => b.Publisher)
                    .WithMany(p => p.Books)
                    .OnDelete(DeleteBehavior.Restrict);


                entity.HasMany(b => b.ShelfBooks)
                    .WithOne(sb => sb.Book)
                    .HasForeignKey(sb => sb.BookId)
                    .OnDelete(DeleteBehavior.NoAction);
            });

            

            modelBuilder.Entity<ReadingChallenge>(entity =>
            {
                entity.HasOne(r => r.User)
                    .WithMany()
                    .OnDelete(DeleteBehavior.Cascade);
            });

            modelBuilder.Entity<Shelf>(entity =>
            {
                entity.HasOne(s => s.User)
                    .WithMany()
                    .OnDelete(DeleteBehavior.Cascade);

                entity.HasMany(s => s.ShelfBooks)
                    .WithOne(sb => sb.Shelf)
                    .HasForeignKey(sb => sb.ShelfId)
                    .OnDelete(DeleteBehavior.Cascade);
            });

            modelBuilder.Entity<Statistics>(entity =>
            {
                entity.HasOne(s => s.BookWithMostPages)
                    .WithMany()
                    .OnDelete(DeleteBehavior.NoAction);

                entity.HasOne(s => s.BookWithLeastPages)
                    .WithMany()
                    .OnDelete(DeleteBehavior.NoAction);

                entity.HasOne(s => s.User)
                    .WithMany()
                    .OnDelete(DeleteBehavior.Cascade);

                entity.HasOne(s => s.MostReadGenre)
                    .WithMany()
                    .OnDelete(DeleteBehavior.Restrict);
            });

            modelBuilder.Entity<Genre>(entity =>
            {
                entity.HasKey(g => g.Id);
                entity.Property(g => g.Name)
                    .IsRequired()
                    .HasMaxLength(100);

                entity.HasMany(g => g.Books)
                    .WithOne(b => b.Genre)
                    .HasForeignKey(b => b.GenreId)
                    .OnDelete(DeleteBehavior.Restrict);

                entity.HasMany(g => g.Posts)
                    .WithOne(p => p.Genre)
                    .HasForeignKey(p => p.GenreId)
                    .OnDelete(DeleteBehavior.Cascade);
            });

            modelBuilder.Entity<Post>(entity =>
            {
                entity.HasMany(p => p.Comments)
                    .WithOne(c => c.Post)
                    .HasForeignKey(c => c.PostId)
                    .OnDelete(DeleteBehavior.Cascade);
            });

            modelBuilder.Entity<Comment>(entity =>
            {
                entity.HasKey(c => c.Id);
                entity.Property(c => c.Content)
                    .HasMaxLength(1000);

                entity.HasOne(c => c.Post)
                    .WithMany(p => p.Comments)
                    .HasForeignKey(c => c.PostId)
                    .OnDelete(DeleteBehavior.Cascade);

                entity.HasOne(c => c.User)
                    .WithMany()
                    .HasForeignKey(c => c.UserId)
                    .OnDelete(DeleteBehavior.Restrict);
            });
        }

    }
}
