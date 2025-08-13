import 'package:json_annotation/json_annotation.dart';

part 'book.g.dart';

@JsonSerializable()
class Book {
  int id;
  String title;
  int totalPages;
  String? CoverImage;
  String genreName;
  String authorName;
  String publisherName;
  int yearPublished;
  String shortDescription;
  String language;
  double averageRating;
  int reviewCount;

  Book({
    required this.id,
    required this.title,
    required this.totalPages,
    this.CoverImage,
    required this.genreName,
    required this.authorName,
    required this.publisherName,
    required this.yearPublished,
    required this.shortDescription,
    required this.language,
    required this.averageRating,
    required this.reviewCount,
  });

  factory Book.fromJson(Map<String, dynamic> json) => _$BookFromJson(json);
  Map<String, dynamic> toJson() => _$BookToJson(this);
}

