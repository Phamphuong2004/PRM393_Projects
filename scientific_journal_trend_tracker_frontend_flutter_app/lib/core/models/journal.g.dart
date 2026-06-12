// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'journal.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Journal _$JournalFromJson(Map<String, dynamic> json) => _Journal(
  id: json['_id'] as String,
  name: json['name'] as String,
  issn: json['issn'] as String?,
  publisher: json['publisher'] as String?,
  impactFactor: (json['impactFactor'] as num?)?.toDouble(),
  hIndex: (json['hIndex'] as num?)?.toInt(),
  paperCount: (json['paperCount'] as num?)?.toInt() ?? 0,
  fieldDomain: json['fieldDomain'] as String?,
  isTracked: json['isTracked'] as bool? ?? false,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$JournalToJson(_Journal instance) => <String, dynamic>{
  '_id': instance.id,
  'name': instance.name,
  'issn': instance.issn,
  'publisher': instance.publisher,
  'impactFactor': instance.impactFactor,
  'hIndex': instance.hIndex,
  'paperCount': instance.paperCount,
  'fieldDomain': instance.fieldDomain,
  'isTracked': instance.isTracked,
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
};
