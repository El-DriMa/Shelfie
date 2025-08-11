// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'myNotifications.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MyNotifications _$MyNotificationsFromJson(Map<String, dynamic> json) =>
    MyNotifications(
      id: (json['id'] as num).toInt(),
      postId: (json['postId'] as num).toInt(),
      commentId: (json['commentId'] as num).toInt(),
      commentText: json['commentText'] as String,
      fromUserId: (json['fromUserId'] as num).toInt(),
      fromUserName: json['fromUserName'] as String,
      toUserId: (json['toUserId'] as num).toInt(),
      isRead: json['isRead'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$MyNotificationsToJson(MyNotifications instance) =>
    <String, dynamic>{
      'id': instance.id,
      'postId': instance.postId,
      'commentId': instance.commentId,
      'commentText': instance.commentText,
      'fromUserId': instance.fromUserId,
      'fromUserName': instance.fromUserName,
      'toUserId': instance.toUserId,
      'isRead': instance.isRead,
      'createdAt': instance.createdAt.toIso8601String(),
    };
