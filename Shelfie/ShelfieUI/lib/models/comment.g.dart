// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Comment _$CommentFromJson(Map<String, dynamic> json) => Comment(
  id: (json['id'] as num).toInt(),
  content: json['content'] as String,
  postId: (json['postId'] as num).toInt(),
  userId: (json['userId'] as num).toInt(),
  username: json['username'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  parentCommentId: (json['parentCommentId'] as num?)?.toInt(),
);

Map<String, dynamic> _$CommentToJson(Comment instance) => <String, dynamic>{
  'id': instance.id,
  'content': instance.content,
  'postId': instance.postId,
  'userId': instance.userId,
  'username': instance.username,
  'createdAt': instance.createdAt.toIso8601String(),
  'parentCommentId': instance.parentCommentId,
};
