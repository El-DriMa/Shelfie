// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Book _$BookFromJson(Map<String, dynamic> json) => Book(
  id: (json['id'] as num).toInt(),
  title: json['title'] as String,
  totalPages: (json['totalPages'] as num).toInt(),
  CoverImage: json['CoverImage'] as String?,
  genreName: json['genreName'] as String,
  authorName: json['authorName'] as String,
  publisherName: json['publisherName'] as String,
  yearPublished: (json['yearPublished'] as num).toInt(),
  shortDescription: json['shortDescription'] as String,
  language: json['language'] as String,
);

Map<String, dynamic> _$BookToJson(Book instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'totalPages': instance.totalPages,
  'CoverImage': instance.CoverImage,
  'genreName': instance.genreName,
  'authorName': instance.authorName,
  'publisherName': instance.publisherName,
  'yearPublished': instance.yearPublished,
  'shortDescription': instance.shortDescription,
  'language': instance.language,
};
