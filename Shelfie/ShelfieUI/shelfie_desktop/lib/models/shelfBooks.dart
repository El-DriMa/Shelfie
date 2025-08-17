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
  int? userId;
  String? username;

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
  });

  factory ShelfBooks.fromJson(Map<String, dynamic> json) => _$ShelfBooksFromJson(json);
  Map<String, dynamic> toJson() => _$ShelfBooksToJson(this);
}

