import 'package:json_annotation/json_annotation.dart';

part 'myNotifications.g.dart';

@JsonSerializable()
class MyNotifications {
  int id;
  int postId;
  int commentId;
  String commentText;
  int fromUserId;
  String fromUserName;
  int toUserId;
  bool isRead;
  DateTime createdAt;

  MyNotifications({
    required this.id,
    required this.postId,
    required this.commentId,
    required this.commentText,
    required this.fromUserId,
    required this.fromUserName,
    required this.toUserId,
    required this.isRead,
    required this.createdAt,

  });

  factory MyNotifications.fromJson(Map<String, dynamic> json) => _$MyNotificationsFromJson(json);
  Map<String, dynamic> toJson() => _$MyNotificationsToJson(this);
}

