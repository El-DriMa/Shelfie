import 'package:json_annotation/json_annotation.dart';

part 'review.g.dart';

@JsonSerializable()
class Review {
  int id;
  int bookId;
  String bookTitle;
  int userId;
  String? userFullName;
  String? username;
  int rating;
  String description;

  Review({
    required this.id,
    required this.bookId,
    required this.bookTitle,
    required this.userId,
    this.userFullName,
    this.username,
    required this.rating,
    required this.description,
  });

  factory Review.fromJson(Map<String, dynamic> json) => _$ReviewFromJson(json);
  Map<String, dynamic> toJson() => _$ReviewToJson(this);
}

