// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Post _$PostFromJson(Map<String, dynamic> json) => Post(
  id: (json['id'] as num).toInt(),
  content: json['content'] as String,
  userId: (json['userId'] as num).toInt(),
  username: json['username'] as String?,
  genreId: (json['genreId'] as num).toInt(),
  genreName: json['genreName'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  modifiedAt:
      json['modifiedAt'] == null
          ? null
          : DateTime.parse(json['modifiedAt'] as String),
);

Map<String, dynamic> _$PostToJson(Post instance) => <String, dynamic>{
  'id': instance.id,
  'content': instance.content,
  'userId': instance.userId,
  'username': instance.username,
  'genreId': instance.genreId,
  'genreName': instance.genreName,
  'createdAt': instance.createdAt.toIso8601String(),
  'modifiedAt': instance.modifiedAt?.toIso8601String(),
};
