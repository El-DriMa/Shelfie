import 'package:json_annotation/json_annotation.dart';

part 'shelfBooks.g.dart';

@JsonSerializable()
class ShelfBooks {
  int id;
  int shelfId;
  String? shelfName;
  int bookId;
  String? bookTitle;
  int? pagesRead;
  int? totalPages;
  String? authorName;
  DateTime createdAt;
  DateTime? updatedAt;
  double averageRating;
  int reviewCount;
  String? photoUrl;

  ShelfBooks({
    required this.id,
    required this.shelfId,
    this.shelfName,
    required this.bookId,
    this.bookTitle,
    this.pagesRead,
    this.totalPages,
    this.authorName,
    required this.createdAt,
    this.updatedAt,
    required this.averageRating,
    required this.reviewCount,
    this.photoUrl,
  });

  factory ShelfBooks.fromJson(Map<String, dynamic> json) => _$ShelfBooksFromJson(json);
  Map<String, dynamic> toJson() => _$ShelfBooksToJson(this);
}

