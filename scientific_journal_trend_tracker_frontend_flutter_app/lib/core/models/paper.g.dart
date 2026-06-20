// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'paper.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PaperAuthor _$PaperAuthorFromJson(Map<String, dynamic> json) => _PaperAuthor(
  id: json['_id'] as String?,
  fullName: json['fullName'] as String,
  externalAuthorId: json['externalAuthorId'] as String?,
  affiliation: json['affiliation'] as String?,
);

Map<String, dynamic> _$PaperAuthorToJson(_PaperAuthor instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'fullName': instance.fullName,
      'externalAuthorId': instance.externalAuthorId,
      'affiliation': instance.affiliation,
    };

_Paper _$PaperFromJson(Map<String, dynamic> json) => _Paper(
  id: json['_id'] as String,
  title: json['title'] as String,
  abstract: json['abstract'] as String?,
  doi: json['doi'] as String?,
  url: json['url'] as String?,
  publicationYear: (json['publicationYear'] as num?)?.toInt(),
  citationCount: (json['citationCount'] as num?)?.toInt() ?? 0,
  externalIdOpenalexId: json['externalId_openalexId'] as String?,
  authors: (json['authors'] as List<dynamic>?)
      ?.map((e) => PaperAuthor.fromJson(e as Map<String, dynamic>))
      .toList(),
  journalId: json['journalId'],
  keywords: json['keywords'] as List<dynamic>?,
  topics: json['topics'] as List<dynamic>?,
  source: json['source'] as String?,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$PaperToJson(_Paper instance) => <String, dynamic>{
  '_id': instance.id,
  'title': instance.title,
  'abstract': instance.abstract,
  'doi': instance.doi,
  'url': instance.url,
  'publicationYear': instance.publicationYear,
  'citationCount': instance.citationCount,
  'externalId_openalexId': instance.externalIdOpenalexId,
  'authors': instance.authors,
  'journalId': instance.journalId,
  'keywords': instance.keywords,
  'topics': instance.topics,
  'source': instance.source,
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
};
