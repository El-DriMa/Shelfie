import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';
@JsonSerializable()
class User {
  int id;
  String firstName;
  String lastName;
  String email;
  String username;
  DateTime? lastLoginAt;
  String? phoneNumber;
  String? photoUrl;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.username,
    this.lastLoginAt,
    this.phoneNumber
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}
