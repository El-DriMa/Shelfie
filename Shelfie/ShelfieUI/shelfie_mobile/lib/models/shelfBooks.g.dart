// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shelfBooks.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ShelfBooks _$ShelfBooksFromJson(Map<String, dynamic> json) => ShelfBooks(
  id: (json['id'] as num).toInt(),
  shelfId: (json['shelfId'] as num).toInt(),
  shelfName: json['shelfName'] as String?,
  bookId: (json['bookId'] as num).toInt(),
  bookTitle: json['bookTitle'] as String?,
  pagesRead: (json['pagesRead'] as num?)?.toInt(),
  totalPages: (json['totalPages'] as num?)?.toInt(),
  authorName: json['authorName'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt:
      json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
  averageRating: (json['averageRating'] as num).toDouble(),
  reviewCount: (json['reviewCount'] as num).toInt(),
  photoUrl: json['photoUrl'] as String?,
);

Map<String, dynamic> _$ShelfBooksToJson(ShelfBooks instance) =>
    <String, dynamic>{
      'id': instance.id,
      'shelfId': instance.shelfId,
      'shelfName': instance.shelfName,
      'bookId': instance.bookId,
      'bookTitle': instance.bookTitle,
      'pagesRead': instance.pagesRead,
      'totalPages': instance.totalPages,
      'authorName': instance.authorName,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'averageRating': instance.averageRating,
      'reviewCount': instance.reviewCount,
      'photoUrl': instance.photoUrl,
    };
