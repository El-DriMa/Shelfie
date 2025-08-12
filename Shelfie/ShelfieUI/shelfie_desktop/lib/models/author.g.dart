// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'author.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Author _$AuthorFromJson(Map<String, dynamic> json) => Author(
  id: (json['id'] as num).toInt(),
  firstName: json['firstName'] as String,
  lastName: json['lastName'] as String,
  birthCountry: json['birthCountry'] as String,
  birthDate: DateTime.parse(json['birthDate'] as String),
  deathDate:
      json['deathDate'] == null
          ? null
          : DateTime.parse(json['deathDate'] as String),
  shortBio: json['shortBio'] as String,
);

Map<String, dynamic> _$AuthorToJson(Author instance) => <String, dynamic>{
  'id': instance.id,
  'firstName': instance.firstName,
  'lastName': instance.lastName,
  'birthCountry': instance.birthCountry,
  'birthDate': instance.birthDate.toIso8601String(),
  'deathDate': instance.deathDate?.toIso8601String(),
  'shortBio': instance.shortBio,
};
