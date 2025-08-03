import 'package:json_annotation/json_annotation.dart';

part 'comment.g.dart';

@JsonSerializable()
class Comment {
  int id;
  String content;
  int postId;
  int userId;
  String? username;
  DateTime createdAt;
  int? parentCommentId;

  Comment({
    required this.id,
    required this.content,
    required this.postId,
    required this.userId,
    this.username,
    required this.createdAt,
    this.parentCommentId,
  });

  factory Comment.fromJson(Map<String, dynamic> json) => _$CommentFromJson(json);
  Map<String, dynamic> toJson() => _$CommentToJson(this);
}

