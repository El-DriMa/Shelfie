// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'readingChallenge.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReadingChallenge _$ReadingChallengeFromJson(Map<String, dynamic> json) =>
    ReadingChallenge(
      id: (json['id'] as num).toInt(),
      challengeName: json['challengeName'] as String,
      description: json['description'] as String,
      goalType: json['goalType'] as String,
      goalAmount: (json['goalAmount'] as num).toInt(),
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      progress: (json['progress'] as num).toInt(),
      isCompleted: json['isCompleted'] as bool,
      userId: (json['userId'] as num).toInt(),
      username: json['username'] as String?,
    );

Map<String, dynamic> _$ReadingChallengeToJson(ReadingChallenge instance) =>
    <String, dynamic>{
      'id': instance.id,
      'challengeName': instance.challengeName,
      'description': instance.description,
      'goalType': instance.goalType,
      'goalAmount': instance.goalAmount,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate.toIso8601String(),
      'progress': instance.progress,
      'isCompleted': instance.isCompleted,
      'userId': instance.userId,
      'username': instance.username,
    };
