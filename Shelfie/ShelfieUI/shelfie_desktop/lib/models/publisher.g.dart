// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'publisher.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Publisher _$PublisherFromJson(Map<String, dynamic> json) => Publisher(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  headquartersLocation: json['headquartersLocation'] as String,
  contactEmail: json['contactEmail'] as String,
  contactPhone: json['contactPhone'] as String?,
  yearFounded: (json['yearFounded'] as num).toInt(),
  country: json['country'] as String,
);

Map<String, dynamic> _$PublisherToJson(Publisher instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'headquartersLocation': instance.headquartersLocation,
  'contactEmail': instance.contactEmail,
  'contactPhone': instance.contactPhone,
  'yearFounded': instance.yearFounded,
  'country': instance.country,
};
