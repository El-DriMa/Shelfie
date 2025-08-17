// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Review _$ReviewFromJson(Map<String, dynamic> json) => Review(
  id: (json['id'] as num).toInt(),
  bookId: (json['bookId'] as num).toInt(),
  bookTitle: json['bookTitle'] as String,
  userId: (json['userId'] as num).toInt(),
  userFullName: json['userFullName'] as String?,
  username: json['username'] as String?,
  rating: (json['rating'] as num).toInt(),
  description: json['description'] as String,
);

Map<String, dynamic> _$ReviewToJson(Review instance) => <String, dynamic>{
  'id': instance.id,
  'bookId': instance.bookId,
  'bookTitle': instance.bookTitle,
  'userId': instance.userId,
  'userFullName': instance.userFullName,
  'username': instance.username,
  'rating': instance.rating,
  'description': instance.description,
};
