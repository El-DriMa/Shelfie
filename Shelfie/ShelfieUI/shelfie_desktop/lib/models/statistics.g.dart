// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'statistics.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Statistics _$StatisticsFromJson(Map<String, dynamic> json) => Statistics(
  userId: (json['userId'] as num).toInt(),
  totalReadBooks: (json['totalReadBooks'] as num).toInt(),
  totalBooksInShelf: (json['totalBooksInShelf'] as num).toInt(),
  totalPagesRead: (json['totalPagesRead'] as num).toInt(),
  mostReadGenreName: json['mostReadGenreName'] as String,
  bookWithLeastPagesTitle: json['bookWithLeastPagesTitle'] as String,
  bookWithLeastPagesCount: (json['bookWithLeastPagesCount'] as num).toInt(),
  bookWithMostPagesTitle: json['bookWithMostPagesTitle'] as String,
  bookWithMostPagesCount: (json['bookWithMostPagesCount'] as num).toInt(),
  firstBookReadDate:
      json['firstBookReadDate'] == null
          ? null
          : DateTime.parse(json['firstBookReadDate'] as String),
  lastBookReadDate:
      json['lastBookReadDate'] == null
          ? null
          : DateTime.parse(json['lastBookReadDate'] as String),
  uniqueGenresCount: (json['uniqueGenresCount'] as num).toInt(),
  uniqueGenresNames:
      (json['uniqueGenresNames'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
  topAuthorId: (json['topAuthorId'] as num).toInt(),
  topAuthor: json['topAuthor'] as String,
  totalUsers: (json['totalUsers'] as num).toInt(),
  totalBooks: (json['totalBooks'] as num).toInt(),
  totalAuthors: (json['totalAuthors'] as num).toInt(),
  totalReviews: (json['totalReviews'] as num).toInt(),
  mostReadGenres:
      (json['mostReadGenres'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
  mostReadGenresCounts:
      (json['mostReadGenresCounts'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
  topUsers:
      (json['topUsers'] as List<dynamic>).map((e) => e as String).toList(),
  topUsersCounts:
      (json['topUsersCounts'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
  averageRating: (json['averageRating'] as num).toDouble(),
);

Map<String, dynamic> _$StatisticsToJson(Statistics instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'totalReadBooks': instance.totalReadBooks,
      'totalBooksInShelf': instance.totalBooksInShelf,
      'totalPagesRead': instance.totalPagesRead,
      'mostReadGenreName': instance.mostReadGenreName,
      'bookWithLeastPagesTitle': instance.bookWithLeastPagesTitle,
      'bookWithLeastPagesCount': instance.bookWithLeastPagesCount,
      'bookWithMostPagesTitle': instance.bookWithMostPagesTitle,
      'bookWithMostPagesCount': instance.bookWithMostPagesCount,
      'firstBookReadDate': instance.firstBookReadDate?.toIso8601String(),
      'lastBookReadDate': instance.lastBookReadDate?.toIso8601String(),
      'uniqueGenresCount': instance.uniqueGenresCount,
      'uniqueGenresNames': instance.uniqueGenresNames,
      'topAuthorId': instance.topAuthorId,
      'topAuthor': instance.topAuthor,
      'totalUsers': instance.totalUsers,
      'totalBooks': instance.totalBooks,
      'totalAuthors': instance.totalAuthors,
      'totalReviews': instance.totalReviews,
      'mostReadGenres': instance.mostReadGenres,
      'mostReadGenresCounts': instance.mostReadGenresCounts,
      'topUsers': instance.topUsers,
      'topUsersCounts': instance.topUsersCounts,
      'averageRating': instance.averageRating,
    };
