// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
  id: (json['id'] as num).toInt(),
  firstName: json['firstName'] as String,
  lastName: json['lastName'] as String,
  email: json['email'] as String,
  username: json['username'] as String,
  lastLoginAt:
      json['lastLoginAt'] == null
          ? null
          : DateTime.parse(json['lastLoginAt'] as String),
  phoneNumber: json['phoneNumber'] as String?,
  isActive: json['isActive'] as bool?,
  photoUrl: json['photoUrl'] as String?,
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'id': instance.id,
  'firstName': instance.firstName,
  'lastName': instance.lastName,
  'email': instance.email,
  'username': instance.username,
  'lastLoginAt': instance.lastLoginAt?.toIso8601String(),
  'phoneNumber': instance.phoneNumber,
  'isActive': instance.isActive,
  'photoUrl': instance.photoUrl,
};
