// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'userRole.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserRole _$UserRoleFromJson(Map<String, dynamic> json) => UserRole(
  id: (json['id'] as num).toInt(),
  username: json['username'] as String?,
  roleName: json['roleName'] as String,
);

Map<String, dynamic> _$UserRoleToJson(UserRole instance) => <String, dynamic>{
  'id': instance.id,
  'username': instance.username,
  'roleName': instance.roleName,
};
