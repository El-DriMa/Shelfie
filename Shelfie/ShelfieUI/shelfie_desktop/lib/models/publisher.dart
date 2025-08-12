import 'package:json_annotation/json_annotation.dart';

part 'publisher.g.dart';

@JsonSerializable()
class Publisher {
  int id;
  String name;
  String headquartersLocation;
  String contactEmail;
  String? contactPhone;
  int yearFounded;
  String country;

  Publisher({
    required this.id,
    required this.name,
    required this.headquartersLocation,
    required this.contactEmail,
    this.contactPhone,
    required this.yearFounded,
    required this.country,
  });

  factory Publisher.fromJson(Map<String, dynamic> json) => _$PublisherFromJson(json);
  Map<String, dynamic> toJson() => _$PublisherToJson(this);

}
