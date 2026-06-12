// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'keyword.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Keyword _$KeywordFromJson(Map<String, dynamic> json) => _Keyword(
  id: json['_id'] as String,
  name: json['name'] as String,
  normalizedText: json['normalizedText'] as String?,
  workCount: (json['workCount'] as num?)?.toInt() ?? 0,
  paperCount: (json['paperCount'] as num?)?.toInt() ?? 0,
  citationCount: (json['citationCount'] as num?)?.toInt() ?? 0,
  trendScore: (json['trendScore'] as num?)?.toDouble() ?? 0.0,
  growthRate: (json['growthRate'] as num?)?.toDouble() ?? 0.0,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$KeywordToJson(_Keyword instance) => <String, dynamic>{
  '_id': instance.id,
  'name': instance.name,
  'normalizedText': instance.normalizedText,
  'workCount': instance.workCount,
  'paperCount': instance.paperCount,
  'citationCount': instance.citationCount,
  'trendScore': instance.trendScore,
  'growthRate': instance.growthRate,
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
};
