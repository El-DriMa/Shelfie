import 'package:json_annotation/json_annotation.dart';

part 'userRole.g.dart';
@JsonSerializable()
class UserRole {
  int id;
  String? username;
  String roleName;

  UserRole({
    required this.id,
    this.username,
    required this.roleName
  });

  factory UserRole.fromJson(Map<String, dynamic> json) => _$UserRoleFromJson(json);
  Map<String, dynamic> toJson() => _$UserRoleToJson(this);
}
