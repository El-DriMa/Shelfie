using Azure;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using Microsoft.ML;
using Microsoft.ML.Data;
using Microsoft.ML.Trainers;
using Shelfie.Models.Requests;
using Shelfie.Models.Responses;
using Shelfie.Models.SearchObjects;
using Shelfie.Services.Database;
using Shelfie.Services.Interfaces;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Threading.Tasks;

namespace Shelfie.Services.Services
{
    public class BookService : BaseCRUDService<BookResponse, BookSearchObject, Book, BookInsertRequest, BookUpdateRequest>, IBookService
    {
        private readonly MLContext _mlContext;
        private ITransformer? _model;
        private PredictionEngine<BookEntry, BookPrediction>? _predictionEngine;
        private readonly string _modelFilePath = "model.zip";
        private Dictionary<uint, uint> _bookIdMap = new();

        public BookService(IB220155Context context, IMapper mapper) : base(context, mapper)
        {
            _mlContext = new MLContext();
        }

        public override async Task BeforeInsert(BookInsertRequest request, Book entity)
        {
            if (_db.Books.Any(b => b.Title == request.Title && b.AuthorId == request.AuthorId))
            {
                throw new ValidationException("A book with the same title and author already exists.");
            }
        }

        public override async Task<BookResponse> Insert(BookInsertRequest request)
        {
            var entity = Mapper.Map<Book>(request);

            await _db.AddAsync(entity);
            await BeforeInsert(request, entity);
            await _db.SaveChangesAsync();

            await _db.Entry(entity).Reference(b => b.Genre).LoadAsync();
            await _db.Entry(entity).Reference(b => b.Author).LoadAsync();
            await _db.Entry(entity).Reference(b => b.Publisher).LoadAsync();

            var response = Mapper.Map<BookResponse>(entity);

            return response;
        }

        public override IQueryable<Book> AddFilter(BookSearchObject search, IQueryable<Book> query)
        {
            query = query
                .Include(b => b.Genre)
                .Include(b => b.Author)
                .Include(b => b.Publisher);

            if (!string.IsNullOrWhiteSpace(search.FTS))
            {
                query = query.Where(b =>
                    b.Title.Contains(search.FTS) ||
                    b.Author.FirstName.Contains(search.FTS) ||
                    b.Author.LastName.Contains(search.FTS) ||
                    b.Genre.Name.Contains(search.FTS) ||
                    b.Publisher.Name.Contains(search.FTS));
            }

            if (!string.IsNullOrWhiteSpace(search.Title))
            {
                query = query.Where(b => b.Title.Contains(search.Title));
            }

            if (!string.IsNullOrWhiteSpace(search.GenreName))
            {
                query = query.Where(b => b.Genre.Name.Contains(search.GenreName));
            }

            if (!string.IsNullOrWhiteSpace(search.AuthorName))
            {
                query = query.Where(b =>
                    b.Author.FirstName.Contains(search.AuthorName) ||
                    b.Author.LastName.Contains(search.AuthorName));
            }

            if (!string.IsNullOrWhiteSpace(search.PublisherName))
            {
                query = query.Where(b => b.Publisher.Name.Contains(search.PublisherName));
            }

            return query;
        }

        public override async Task<PagedResult<BookResponse>> GetPaged(BookSearchObject search)
        {
            var query = _db.Books
                .Include(b => b.Author)
                .Include(b => b.Reviews)
                .AsQueryable();

            query = AddFilter(search, query);

            var totalCount = await query.CountAsync();

            if (search.Page.HasValue && search.PageSize.HasValue)
            {
                int skip = (search.Page.Value - 1) * search.PageSize.Value;
                query = query.Skip(skip).Take(search.PageSize.Value);
            }

            var list = await query.ToListAsync();

            var result = list.Select(b =>
            {
                var response = Mapper.Map<BookResponse>(b);
                response.AuthorName = $"{b.Author.FirstName} {b.Author.LastName}".Trim();
                response.AverageRating = b.Reviews.Any() ? b.Reviews.Average(r => r.Rating) : 0;
                response.ReviewCount = b.Reviews.Count;
                return response;
            }).ToList();

            return new PagedResult<BookResponse>
            {
                Items = result,
                TotalCount = totalCount
            };
        }

        public async Task<PagedResult<BookResponse>> GetPagedForUser(BookSearchObject search, int userId)
        {
            var baseQuery = _db.ShelfBooks
                .Include(sb => sb.Shelf)
                .Include(sb => sb.Book)
                .Include(x=>x.Book.Reviews)
                .Include(x=>x.Book.Author)
                .Include(x=>x.Book.Genre)
                .Where(sb => sb.Shelf.UserId == userId)
                .Select(sb => sb.Book)
                .AsQueryable();

            int totalCount = await baseQuery.CountAsync();

            if (totalCount == 0)
            {
                return new PagedResult<BookResponse> { Items = new List<BookResponse>(), TotalCount = 0 };
            }

            if (search?.Page.HasValue == true && search?.PageSize.HasValue == true)
            {
                baseQuery = baseQuery.Skip((search.Page.Value - 1) * search.PageSize.Value).Take(search.PageSize.Value);
            }

            var list = await baseQuery.ToListAsync();

            var result = list.Select(b => {
                var response = Mapper.Map<BookResponse>(b);
                response.AuthorName = $"{b.Author.FirstName} {b.Author.LastName}".Trim();
                response.AverageRating = b.Reviews.Any() ? b.Reviews.Average(r => r.Rating) : 0;
                response.ReviewCount = b.Reviews.Count;
                return response;
            }).ToList();

            return new PagedResult<BookResponse>
            {
                Items = result,
                TotalCount = totalCount
            };
        }

        public async Task<BookResponse> GetById(int id)
        {
            var book = await _db.Books
                .Include(b => b.Genre)
                .Include(b=>b.Reviews)
                .Include(b => b.Author)
                .Include(b => b.Publisher)
                .FirstOrDefaultAsync(b => b.Id == id);

            if (book == null)
            {
                throw new KeyNotFoundException($"Book with ID {id} not found.");
            }

            var response = Mapper.Map<BookResponse>(book);
            response.AuthorName = $"{book.Author.FirstName} {book.Author.LastName}".Trim();
            response.AverageRating = book.Reviews.Any() ? book.Reviews.Average(r => r.Rating) : 0;
            response.ReviewCount = book.Reviews.Count;

            return response;
        }

        public async Task<PagedResult<BookResponse>> GetRecommendedBooksAsync(BookSearchObject search, int userId)
        {
            if (_model == null || _predictionEngine == null)
            {
                await LoadOrTrainModelAsync();
            }

            var baseQuery = _db.ShelfBooks
                .Include(sb => sb.Shelf)
                .Include(sb => sb.Book)
                .Include(x=>x.Book.Reviews)
                .Include(x => x.Book.Author)
                .Include(x => x.Book.Genre)
                .Where(sb => sb.Shelf.UserId == userId)
                .Select(sb => sb.Book)
                .AsQueryable();

            baseQuery = AddFilter(search, baseQuery);

            int totalCount = await baseQuery.CountAsync();

            var readBooks = await _db.ShelfBooks
                .Where(sb => sb.Shelf.UserId == userId && sb.Shelf.Name == Models.Enums.ShelfTypeEnum.Read)
                .Select(sb => sb.BookId)
                .Distinct()
                .ToListAsync();

            if (readBooks.Count < 3)
            {
                var result1Query = _db.Books
                    .OrderByDescending(b => b.ShelfBooks.Count)
                    .AsQueryable();

                result1Query = AddFilter(search, result1Query);

                totalCount = await result1Query.CountAsync();

                if (search.Page.HasValue && search.PageSize.HasValue)
                {
                    int skip = (search.Page.Value - 1) * search.PageSize.Value;
                    result1Query = result1Query.Skip(skip).Take(search.PageSize.Value);
                }

                var result1 = await result1Query
                    .Select(b => new BookResponse
                    {
                        Id = b.Id,
                        Title = b.Title,
                        AuthorName = b.Author.FirstName + " " + b.Author.LastName,
                        CoverImage = b.CoverImage,
                        AverageRating = b.Reviews.Any() ? b.Reviews.Average(r => r.Rating) : 0,
                        ReviewCount = b.Reviews.Count,
                    })
                    .ToListAsync();

                return new PagedResult<BookResponse>
                {
                    Items = result1,
                    TotalCount = totalCount
                };
            }

            var allBooks = await _db.Books.ToListAsync();

            var scores = new Dictionary<int, float>();

            foreach (var readBookId in readBooks)
            {
                if (!_bookIdMap.TryGetValue((uint)readBookId, out var mappedReadId))
                    continue;

                foreach (var book in allBooks)
                {
                    if (readBookId == book.Id || readBooks.Contains(book.Id))
                        continue;

                    if (!_bookIdMap.TryGetValue((uint)book.Id, out var mappedTargetId))
                        continue;

                    var prediction = _predictionEngine!.Predict(new BookEntry
                    {
                        BookId = mappedReadId,
                        CoReadBookId = mappedTargetId,
                        Label = 0
                    });

                    if (scores.ContainsKey(book.Id))
                        scores[book.Id] += prediction.Score;
                    else
                        scores[book.Id] = prediction.Score;
                }
            }

            if (!scores.Any())
            {
                var result2Query = _db.Books
                    .OrderByDescending(b => b.ShelfBooks.Count)
                    .AsQueryable();

                result2Query = AddFilter(search, result2Query);

                totalCount = await result2Query.CountAsync();

                if (search.Page.HasValue && search.PageSize.HasValue)
                {
                    int skip = (search.Page.Value - 1) * search.PageSize.Value;
                    result2Query = result2Query.Skip(skip).Take(search.PageSize.Value);
                }

                var result2 = await result2Query
                    .Select(b => new BookResponse
                    {
                        Id = b.Id,
                        Title = b.Title,
                        AuthorName = b.Author.FirstName + " " + b.Author.LastName,
                        CoverImage = b.CoverImage,
                        AverageRating = b.Reviews.Any() ? b.Reviews.Average(r => r.Rating) : 0,
                        ReviewCount = b.Reviews.Count,
                    })
                    .ToListAsync();

                return new PagedResult<BookResponse>
                {
                    Items = result2,
                    TotalCount = totalCount
                };
            }

            var recommendedBookIds = scores.OrderByDescending(x => x.Value).Take(10).Select(x => x.Key).ToList();

            var recommendedBooksQuery = _db.Books
                .Where(b => recommendedBookIds.Contains(b.Id))
                .Include(b => b.Author)
                .Include(b=>b.Reviews)
                .Include(b => b.Genre)
                .AsQueryable();

            recommendedBooksQuery = AddFilter(search, recommendedBooksQuery);

            totalCount = await recommendedBooksQuery.CountAsync();

            if (search.Page.HasValue && search.PageSize.HasValue)
            {
                int skip = (search.Page.Value - 1) * search.PageSize.Value;
                recommendedBooksQuery = recommendedBooksQuery.Skip(skip).Take(search.PageSize.Value);
            }

            var recommendedBooks = await recommendedBooksQuery.ToListAsync();

            var result = recommendedBooks.Select(b =>
            {
                var response = Mapper.Map<BookResponse>(b);
                response.AuthorName = $"{b.Author.FirstName} {b.Author.LastName}".Trim();
                response.AverageRating = b.Reviews.Any() ? b.Reviews.Average(r => r.Rating) : 0;
                response.ReviewCount = b.Reviews.Count;
                return response;
            }).ToList();

            return new PagedResult<BookResponse>
            {
                Items = result,
                TotalCount = totalCount
            };
        }


        private async Task LoadOrTrainModelAsync()
        {
            if (File.Exists(_modelFilePath))
            {
                using var stream = new FileStream(_modelFilePath, FileMode.Open, FileAccess.Read, FileShare.Read);
                _model = _mlContext.Model.Load(stream, out var schema);
                _predictionEngine = _mlContext.Model.CreatePredictionEngine<BookEntry, BookPrediction>(_model);
            }
            else
            {
                await TrainAndSaveModelAsync();
            }
        }

        private async Task TrainAndSaveModelAsync()
        {
            var readShelves = await _db.Shelves
                .Where(s => s.Name == Models.Enums.ShelfTypeEnum.Read)
                .Include(s => s.ShelfBooks)
                .ToListAsync();

            var data = new List<BookEntry>();

            foreach (var shelf in readShelves)
            {
                var bookIds = shelf.ShelfBooks.Select(sb => sb.BookId).Distinct().ToList();
                foreach (var b1 in bookIds)
                {
                    foreach (var b2 in bookIds)
                    {
                        if (b1 != b2)
                        {
                            data.Add(new BookEntry
                            {
                                BookId = (uint)b1,
                                CoReadBookId = (uint)b2,
                                Label = 1
                            });
                        }
                    }
                }
            }

            if (!data.Any())
                return;


            var uniqueBookIds = data
                .SelectMany(d => new[] { d.BookId, d.CoReadBookId })
                .Distinct()
                .ToList();

            var bookIdMap = uniqueBookIds
                .Select((id, index) => new { id, index })
                .ToDictionary(x => x.id, x => (uint)x.index);


            var mappedData = data.Select(d => new BookEntry
            {
                BookId = bookIdMap[d.BookId],
                CoReadBookId = bookIdMap[d.CoReadBookId],
                Label = d.Label
            }).ToList();

            _bookIdMap = bookIdMap;

            var trainData = _mlContext.Data.LoadFromEnumerable(mappedData);


            var options = new MatrixFactorizationTrainer.Options
            {
                MatrixColumnIndexColumnName = nameof(BookEntry.BookId),
                MatrixRowIndexColumnName = nameof(BookEntry.CoReadBookId),
                LabelColumnName = nameof(BookEntry.Label),
                NumberOfIterations = 100,
                ApproximationRank = 32,
                Alpha = 0.01,
                Lambda = 0.025,
                LossFunction = MatrixFactorizationTrainer.LossFunctionType.SquareLossOneClass,
                C = 0.00001
            };

            var estimator = _mlContext.Recommendation().Trainers.MatrixFactorization(options);
            _model = estimator.Fit(trainData);

            using var fs = new FileStream(_modelFilePath, FileMode.Create, FileAccess.Write, FileShare.Write);
            _mlContext.Model.Save(_model, trainData.Schema, fs);
            _predictionEngine = _mlContext.Model.CreatePredictionEngine<BookEntry, BookPrediction>(_model);
        }

        private class BookEntry
        {
            [KeyType(count: 40)]
            public uint BookId { get; set; }
            [KeyType(count: 40)]
            public uint CoReadBookId { get; set; }
            public float Label { get; set; }
        }

        private class BookPrediction
        {
            public float Score { get; set; }
        }
    }
}
