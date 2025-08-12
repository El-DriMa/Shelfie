import 'package:json_annotation/json_annotation.dart';

part 'readingChallenge.g.dart';

@JsonSerializable()
class ReadingChallenge {
  int id;
  String challengeName;
  String description;
  String goalType;
  int goalAmount;
  DateTime startDate;
  DateTime endDate;
  int progress;
  bool isCompleted;
  int userId;
  String? username;

  ReadingChallenge({
    required this.id,
    required this.challengeName,
    required this.description,
    required this.goalType,
    required this.goalAmount,
    required this.startDate,
    required this.endDate,
    required this.progress,
    required this.isCompleted,
    required this.userId,
    this.username,
  });

  factory ReadingChallenge.fromJson(Map<String, dynamic> json) => _$ReadingChallengeFromJson(json);
  Map<String, dynamic> toJson() => _$ReadingChallengeToJson(this);
}

