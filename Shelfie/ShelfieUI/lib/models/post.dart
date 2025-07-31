import 'package:json_annotation/json_annotation.dart';

part 'post.g.dart';

@JsonSerializable()
class Post {
  int id;
  String content;
  int userId;
  String? username;
  int genreId;
  String? genreName;
  DateTime createdAt;
  DateTime? modifiedAt;

  Post({
    required this.id,
    required this.content,
    required this.userId,
    this.username,
    required this.genreId,
    this.genreName,
    required this.createdAt,
    this.modifiedAt,
  });

  factory Post.fromJson(Map<String, dynamic> json) => _$PostFromJson(json);
  Map<String, dynamic> toJson() => _$PostToJson(this);
}

