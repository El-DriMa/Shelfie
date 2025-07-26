// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shelf.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Shelf _$ShelfFromJson(Map<String, dynamic> json) => Shelf(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  booksCount: (json['booksCount'] as num).toInt(),
  userId: (json['userId'] as num).toInt(),
);

Map<String, dynamic> _$ShelfToJson(Shelf instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'booksCount': instance.booksCount,
  'userId': instance.userId,
};
