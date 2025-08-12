import 'package:json_annotation/json_annotation.dart';

part 'author.g.dart';

@JsonSerializable()
class Author {
  int id;
  String firstName;
  String lastName;
  String birthCountry;
  DateTime birthDate;
  DateTime? deathDate;
  String shortBio;

  Author({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.birthCountry,
    required this.birthDate,
    this.deathDate,
    required this.shortBio,
  });

  factory Author.fromJson(Map<String, dynamic> json) => _$AuthorFromJson(json);
  Map<String, dynamic> toJson() => _$AuthorToJson(this);

  
  String get fullName => '$firstName $lastName';

 
}
