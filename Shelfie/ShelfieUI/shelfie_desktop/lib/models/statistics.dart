import 'package:json_annotation/json_annotation.dart';

part 'statistics.g.dart';

@JsonSerializable()
class Statistics {
  int userId;
  int totalReadBooks;
  int totalBooksInShelf;
  int totalPagesRead;
  String mostReadGenreName;
  String bookWithLeastPagesTitle;
  int bookWithLeastPagesCount;
  String bookWithMostPagesTitle;
  int bookWithMostPagesCount;
  DateTime? firstBookReadDate;
  DateTime? lastBookReadDate;
  int uniqueGenresCount;
  List<String> uniqueGenresNames;
  int topAuthorId;
  String topAuthor;

  
  int totalUsers;
  int totalBooks;
  int totalAuthors;
  int totalReviews;
  List<String> mostReadGenres;
  List<int> mostReadGenresCounts;
  List<String> topUsers;
  List<int> topUsersCounts;
  double averageRating;


  Statistics({
    required this.userId,
    required this.totalReadBooks,
    required this.totalBooksInShelf,
    required this.totalPagesRead,
    required this.mostReadGenreName,
    required this.bookWithLeastPagesTitle,
    required this.bookWithLeastPagesCount,
    required this.bookWithMostPagesTitle,
    required this.bookWithMostPagesCount,
    this.firstBookReadDate,
    this.lastBookReadDate,
    required this.uniqueGenresCount,
    required this.uniqueGenresNames,
    required this.topAuthorId,
    required this.topAuthor,
    required this.totalUsers,
    required this.totalBooks,
    required this.totalAuthors,
    required this.totalReviews, 
    required this.mostReadGenres,
    required this.mostReadGenresCounts,
    required this.topUsers,
    required this.topUsersCounts,
    required this.averageRating,
  });

  factory Statistics.fromJson(Map<String, dynamic> json) => _$StatisticsFromJson(json);
  Map<String, dynamic> toJson() => _$StatisticsToJson(this);
}

