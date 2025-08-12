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
  });

  factory Statistics.fromJson(Map<String, dynamic> json) => _$StatisticsFromJson(json);
  Map<String, dynamic> toJson() => _$StatisticsToJson(this);
}

