import 'package:json_annotation/json_annotation.dart';

part 'shelf.g.dart';

@JsonSerializable()
class Shelf {
  int id;
  String name;
  int booksCount;

  Shelf({
    required this.id,
    required this.name,
    required this.booksCount,
  });

  factory Shelf.fromJson(Map<String, dynamic> json) => _$ShelfFromJson(json);
  Map<String, dynamic> toJson() => _$ShelfToJson(this);
}

