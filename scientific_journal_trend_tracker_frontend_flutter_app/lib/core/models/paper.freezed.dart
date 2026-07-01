// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'paper.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PaperAuthor {

@JsonKey(name: '_id') String? get id; String get fullName; String? get externalAuthorId; String? get affiliation;
/// Create a copy of PaperAuthor
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PaperAuthorCopyWith<PaperAuthor> get copyWith => _$PaperAuthorCopyWithImpl<PaperAuthor>(this as PaperAuthor, _$identity);

  /// Serializes this PaperAuthor to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PaperAuthor&&(identical(other.id, id) || other.id == id)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.externalAuthorId, externalAuthorId) || other.externalAuthorId == externalAuthorId)&&(identical(other.affiliation, affiliation) || other.affiliation == affiliation));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,fullName,externalAuthorId,affiliation);

@override
String toString() {
  return 'PaperAuthor(id: $id, fullName: $fullName, externalAuthorId: $externalAuthorId, affiliation: $affiliation)';
}


}

/// @nodoc
abstract mixin class $PaperAuthorCopyWith<$Res>  {
  factory $PaperAuthorCopyWith(PaperAuthor value, $Res Function(PaperAuthor) _then) = _$PaperAuthorCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: '_id') String? id, String fullName, String? externalAuthorId, String? affiliation
});




}
/// @nodoc
class _$PaperAuthorCopyWithImpl<$Res>
    implements $PaperAuthorCopyWith<$Res> {
  _$PaperAuthorCopyWithImpl(this._self, this._then);

  final PaperAuthor _self;
  final $Res Function(PaperAuthor) _then;

/// Create a copy of PaperAuthor
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? fullName = null,Object? externalAuthorId = freezed,Object? affiliation = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,externalAuthorId: freezed == externalAuthorId ? _self.externalAuthorId : externalAuthorId // ignore: cast_nullable_to_non_nullable
as String?,affiliation: freezed == affiliation ? _self.affiliation : affiliation // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PaperAuthor].
extension PaperAuthorPatterns on PaperAuthor {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PaperAuthor value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PaperAuthor() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PaperAuthor value)  $default,){
final _that = this;
switch (_that) {
case _PaperAuthor():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PaperAuthor value)?  $default,){
final _that = this;
switch (_that) {
case _PaperAuthor() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: '_id')  String? id,  String fullName,  String? externalAuthorId,  String? affiliation)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PaperAuthor() when $default != null:
return $default(_that.id,_that.fullName,_that.externalAuthorId,_that.affiliation);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: '_id')  String? id,  String fullName,  String? externalAuthorId,  String? affiliation)  $default,) {final _that = this;
switch (_that) {
case _PaperAuthor():
return $default(_that.id,_that.fullName,_that.externalAuthorId,_that.affiliation);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: '_id')  String? id,  String fullName,  String? externalAuthorId,  String? affiliation)?  $default,) {final _that = this;
switch (_that) {
case _PaperAuthor() when $default != null:
return $default(_that.id,_that.fullName,_that.externalAuthorId,_that.affiliation);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PaperAuthor implements PaperAuthor {
  const _PaperAuthor({@JsonKey(name: '_id') this.id, required this.fullName, this.externalAuthorId, this.affiliation});
  factory _PaperAuthor.fromJson(Map<String, dynamic> json) => _$PaperAuthorFromJson(json);

@override@JsonKey(name: '_id') final  String? id;
@override final  String fullName;
@override final  String? externalAuthorId;
@override final  String? affiliation;

/// Create a copy of PaperAuthor
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PaperAuthorCopyWith<_PaperAuthor> get copyWith => __$PaperAuthorCopyWithImpl<_PaperAuthor>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PaperAuthorToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PaperAuthor&&(identical(other.id, id) || other.id == id)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.externalAuthorId, externalAuthorId) || other.externalAuthorId == externalAuthorId)&&(identical(other.affiliation, affiliation) || other.affiliation == affiliation));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,fullName,externalAuthorId,affiliation);

@override
String toString() {
  return 'PaperAuthor(id: $id, fullName: $fullName, externalAuthorId: $externalAuthorId, affiliation: $affiliation)';
}


}

/// @nodoc
abstract mixin class _$PaperAuthorCopyWith<$Res> implements $PaperAuthorCopyWith<$Res> {
  factory _$PaperAuthorCopyWith(_PaperAuthor value, $Res Function(_PaperAuthor) _then) = __$PaperAuthorCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: '_id') String? id, String fullName, String? externalAuthorId, String? affiliation
});




}
/// @nodoc
class __$PaperAuthorCopyWithImpl<$Res>
    implements _$PaperAuthorCopyWith<$Res> {
  __$PaperAuthorCopyWithImpl(this._self, this._then);

  final _PaperAuthor _self;
  final $Res Function(_PaperAuthor) _then;

/// Create a copy of PaperAuthor
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? fullName = null,Object? externalAuthorId = freezed,Object? affiliation = freezed,}) {
  return _then(_PaperAuthor(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,externalAuthorId: freezed == externalAuthorId ? _self.externalAuthorId : externalAuthorId // ignore: cast_nullable_to_non_nullable
as String?,affiliation: freezed == affiliation ? _self.affiliation : affiliation // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$Paper {

@JsonKey(name: '_id') String get id; String get title; String? get abstract; String? get doi; String? get url; int? get publicationYear;@JsonKey(name: 'citationCount') int get citationCount;@JsonKey(name: 'externalId_openalexId') String? get externalIdOpenalexId;@JsonKey(name: 'externalId_semanticScholarId') String? get externalIdSemanticScholarId;@JsonKey(name: 'externalId_crossref') String? get externalIdCrossref; List<PaperAuthor>? get authors; dynamic get journalId; List<dynamic>? get keywords; List<dynamic>? get topics; String? get pdfUrl; String? get source; DateTime? get createdAt; DateTime? get updatedAt;
/// Create a copy of Paper
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PaperCopyWith<Paper> get copyWith => _$PaperCopyWithImpl<Paper>(this as Paper, _$identity);

  /// Serializes this Paper to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Paper&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.abstract, abstract) || other.abstract == abstract)&&(identical(other.doi, doi) || other.doi == doi)&&(identical(other.url, url) || other.url == url)&&(identical(other.publicationYear, publicationYear) || other.publicationYear == publicationYear)&&(identical(other.citationCount, citationCount) || other.citationCount == citationCount)&&(identical(other.externalIdOpenalexId, externalIdOpenalexId) || other.externalIdOpenalexId == externalIdOpenalexId)&&(identical(other.externalIdSemanticScholarId, externalIdSemanticScholarId) || other.externalIdSemanticScholarId == externalIdSemanticScholarId)&&(identical(other.externalIdCrossref, externalIdCrossref) || other.externalIdCrossref == externalIdCrossref)&&const DeepCollectionEquality().equals(other.authors, authors)&&const DeepCollectionEquality().equals(other.journalId, journalId)&&const DeepCollectionEquality().equals(other.keywords, keywords)&&const DeepCollectionEquality().equals(other.topics, topics)&&(identical(other.pdfUrl, pdfUrl) || other.pdfUrl == pdfUrl)&&(identical(other.source, source) || other.source == source)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,abstract,doi,url,publicationYear,citationCount,externalIdOpenalexId,externalIdSemanticScholarId,externalIdCrossref,const DeepCollectionEquality().hash(authors),const DeepCollectionEquality().hash(journalId),const DeepCollectionEquality().hash(keywords),const DeepCollectionEquality().hash(topics),pdfUrl,source,createdAt,updatedAt);

@override
String toString() {
  return 'Paper(id: $id, title: $title, abstract: $abstract, doi: $doi, url: $url, publicationYear: $publicationYear, citationCount: $citationCount, externalIdOpenalexId: $externalIdOpenalexId, externalIdSemanticScholarId: $externalIdSemanticScholarId, externalIdCrossref: $externalIdCrossref, authors: $authors, journalId: $journalId, keywords: $keywords, topics: $topics, pdfUrl: $pdfUrl, source: $source, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $PaperCopyWith<$Res>  {
  factory $PaperCopyWith(Paper value, $Res Function(Paper) _then) = _$PaperCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: '_id') String id, String title, String? abstract, String? doi, String? url, int? publicationYear,@JsonKey(name: 'citationCount') int citationCount,@JsonKey(name: 'externalId_openalexId') String? externalIdOpenalexId,@JsonKey(name: 'externalId_semanticScholarId') String? externalIdSemanticScholarId,@JsonKey(name: 'externalId_crossref') String? externalIdCrossref, List<PaperAuthor>? authors, dynamic journalId, List<dynamic>? keywords, List<dynamic>? topics, String? pdfUrl, String? source, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class _$PaperCopyWithImpl<$Res>
    implements $PaperCopyWith<$Res> {
  _$PaperCopyWithImpl(this._self, this._then);

  final Paper _self;
  final $Res Function(Paper) _then;

/// Create a copy of Paper
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? abstract = freezed,Object? doi = freezed,Object? url = freezed,Object? publicationYear = freezed,Object? citationCount = null,Object? externalIdOpenalexId = freezed,Object? externalIdSemanticScholarId = freezed,Object? externalIdCrossref = freezed,Object? authors = freezed,Object? journalId = freezed,Object? keywords = freezed,Object? topics = freezed,Object? pdfUrl = freezed,Object? source = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,abstract: freezed == abstract ? _self.abstract : abstract // ignore: cast_nullable_to_non_nullable
as String?,doi: freezed == doi ? _self.doi : doi // ignore: cast_nullable_to_non_nullable
as String?,url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,publicationYear: freezed == publicationYear ? _self.publicationYear : publicationYear // ignore: cast_nullable_to_non_nullable
as int?,citationCount: null == citationCount ? _self.citationCount : citationCount // ignore: cast_nullable_to_non_nullable
as int,externalIdOpenalexId: freezed == externalIdOpenalexId ? _self.externalIdOpenalexId : externalIdOpenalexId // ignore: cast_nullable_to_non_nullable
as String?,externalIdSemanticScholarId: freezed == externalIdSemanticScholarId ? _self.externalIdSemanticScholarId : externalIdSemanticScholarId // ignore: cast_nullable_to_non_nullable
as String?,externalIdCrossref: freezed == externalIdCrossref ? _self.externalIdCrossref : externalIdCrossref // ignore: cast_nullable_to_non_nullable
as String?,authors: freezed == authors ? _self.authors : authors // ignore: cast_nullable_to_non_nullable
as List<PaperAuthor>?,journalId: freezed == journalId ? _self.journalId : journalId // ignore: cast_nullable_to_non_nullable
as dynamic,keywords: freezed == keywords ? _self.keywords : keywords // ignore: cast_nullable_to_non_nullable
as List<dynamic>?,topics: freezed == topics ? _self.topics : topics // ignore: cast_nullable_to_non_nullable
as List<dynamic>?,pdfUrl: freezed == pdfUrl ? _self.pdfUrl : pdfUrl // ignore: cast_nullable_to_non_nullable
as String?,source: freezed == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Paper].
extension PaperPatterns on Paper {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Paper value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Paper() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Paper value)  $default,){
final _that = this;
switch (_that) {
case _Paper():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Paper value)?  $default,){
final _that = this;
switch (_that) {
case _Paper() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: '_id')  String id,  String title,  String? abstract,  String? doi,  String? url,  int? publicationYear, @JsonKey(name: 'citationCount')  int citationCount, @JsonKey(name: 'externalId_openalexId')  String? externalIdOpenalexId, @JsonKey(name: 'externalId_semanticScholarId')  String? externalIdSemanticScholarId, @JsonKey(name: 'externalId_crossref')  String? externalIdCrossref,  List<PaperAuthor>? authors,  dynamic journalId,  List<dynamic>? keywords,  List<dynamic>? topics,  String? pdfUrl,  String? source,  DateTime? createdAt,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Paper() when $default != null:
return $default(_that.id,_that.title,_that.abstract,_that.doi,_that.url,_that.publicationYear,_that.citationCount,_that.externalIdOpenalexId,_that.externalIdSemanticScholarId,_that.externalIdCrossref,_that.authors,_that.journalId,_that.keywords,_that.topics,_that.pdfUrl,_that.source,_that.createdAt,_that.updatedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: '_id')  String id,  String title,  String? abstract,  String? doi,  String? url,  int? publicationYear, @JsonKey(name: 'citationCount')  int citationCount, @JsonKey(name: 'externalId_openalexId')  String? externalIdOpenalexId, @JsonKey(name: 'externalId_semanticScholarId')  String? externalIdSemanticScholarId, @JsonKey(name: 'externalId_crossref')  String? externalIdCrossref,  List<PaperAuthor>? authors,  dynamic journalId,  List<dynamic>? keywords,  List<dynamic>? topics,  String? pdfUrl,  String? source,  DateTime? createdAt,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _Paper():
return $default(_that.id,_that.title,_that.abstract,_that.doi,_that.url,_that.publicationYear,_that.citationCount,_that.externalIdOpenalexId,_that.externalIdSemanticScholarId,_that.externalIdCrossref,_that.authors,_that.journalId,_that.keywords,_that.topics,_that.pdfUrl,_that.source,_that.createdAt,_that.updatedAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: '_id')  String id,  String title,  String? abstract,  String? doi,  String? url,  int? publicationYear, @JsonKey(name: 'citationCount')  int citationCount, @JsonKey(name: 'externalId_openalexId')  String? externalIdOpenalexId, @JsonKey(name: 'externalId_semanticScholarId')  String? externalIdSemanticScholarId, @JsonKey(name: 'externalId_crossref')  String? externalIdCrossref,  List<PaperAuthor>? authors,  dynamic journalId,  List<dynamic>? keywords,  List<dynamic>? topics,  String? pdfUrl,  String? source,  DateTime? createdAt,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Paper() when $default != null:
return $default(_that.id,_that.title,_that.abstract,_that.doi,_that.url,_that.publicationYear,_that.citationCount,_that.externalIdOpenalexId,_that.externalIdSemanticScholarId,_that.externalIdCrossref,_that.authors,_that.journalId,_that.keywords,_that.topics,_that.pdfUrl,_that.source,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Paper implements Paper {
  const _Paper({@JsonKey(name: '_id') required this.id, required this.title, this.abstract, this.doi, this.url, this.publicationYear, @JsonKey(name: 'citationCount') this.citationCount = 0, @JsonKey(name: 'externalId_openalexId') this.externalIdOpenalexId, @JsonKey(name: 'externalId_semanticScholarId') this.externalIdSemanticScholarId, @JsonKey(name: 'externalId_crossref') this.externalIdCrossref, this.authors, this.journalId, this.keywords, this.topics, this.pdfUrl, this.source, this.createdAt, this.updatedAt});
  factory _Paper.fromJson(Map<String, dynamic> json) => _$PaperFromJson(json);

@override@JsonKey(name: '_id') final  String id;
@override final  String title;
@override final  String? abstract;
@override final  String? doi;
@override final  String? url;
@override final  int? publicationYear;
@override@JsonKey(name: 'citationCount') final  int citationCount;
@override@JsonKey(name: 'externalId_openalexId') final  String? externalIdOpenalexId;
@override@JsonKey(name: 'externalId_semanticScholarId') final  String? externalIdSemanticScholarId;
@override@JsonKey(name: 'externalId_crossref') final  String? externalIdCrossref;
@override final  List<PaperAuthor>? authors;
@override final  dynamic journalId;
@override final  List<dynamic>? keywords;
@override final  List<dynamic>? topics;
@override final  String? pdfUrl;
@override final  String? source;
@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;

/// Create a copy of Paper
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PaperCopyWith<_Paper> get copyWith => __$PaperCopyWithImpl<_Paper>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PaperToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Paper&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.abstract, abstract) || other.abstract == abstract)&&(identical(other.doi, doi) || other.doi == doi)&&(identical(other.url, url) || other.url == url)&&(identical(other.publicationYear, publicationYear) || other.publicationYear == publicationYear)&&(identical(other.citationCount, citationCount) || other.citationCount == citationCount)&&(identical(other.externalIdOpenalexId, externalIdOpenalexId) || other.externalIdOpenalexId == externalIdOpenalexId)&&(identical(other.externalIdSemanticScholarId, externalIdSemanticScholarId) || other.externalIdSemanticScholarId == externalIdSemanticScholarId)&&(identical(other.externalIdCrossref, externalIdCrossref) || other.externalIdCrossref == externalIdCrossref)&&const DeepCollectionEquality().equals(other.authors, authors)&&const DeepCollectionEquality().equals(other.journalId, journalId)&&const DeepCollectionEquality().equals(other.keywords, keywords)&&const DeepCollectionEquality().equals(other.topics, topics)&&(identical(other.pdfUrl, pdfUrl) || other.pdfUrl == pdfUrl)&&(identical(other.source, source) || other.source == source)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,abstract,doi,url,publicationYear,citationCount,externalIdOpenalexId,externalIdSemanticScholarId,externalIdCrossref,const DeepCollectionEquality().hash(authors),const DeepCollectionEquality().hash(journalId),const DeepCollectionEquality().hash(keywords),const DeepCollectionEquality().hash(topics),pdfUrl,source,createdAt,updatedAt);

@override
String toString() {
  return 'Paper(id: $id, title: $title, abstract: $abstract, doi: $doi, url: $url, publicationYear: $publicationYear, citationCount: $citationCount, externalIdOpenalexId: $externalIdOpenalexId, externalIdSemanticScholarId: $externalIdSemanticScholarId, externalIdCrossref: $externalIdCrossref, authors: $authors, journalId: $journalId, keywords: $keywords, topics: $topics, pdfUrl: $pdfUrl, source: $source, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$PaperCopyWith<$Res> implements $PaperCopyWith<$Res> {
  factory _$PaperCopyWith(_Paper value, $Res Function(_Paper) _then) = __$PaperCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: '_id') String id, String title, String? abstract, String? doi, String? url, int? publicationYear,@JsonKey(name: 'citationCount') int citationCount,@JsonKey(name: 'externalId_openalexId') String? externalIdOpenalexId,@JsonKey(name: 'externalId_semanticScholarId') String? externalIdSemanticScholarId,@JsonKey(name: 'externalId_crossref') String? externalIdCrossref, List<PaperAuthor>? authors, dynamic journalId, List<dynamic>? keywords, List<dynamic>? topics, String? pdfUrl, String? source, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class __$PaperCopyWithImpl<$Res>
    implements _$PaperCopyWith<$Res> {
  __$PaperCopyWithImpl(this._self, this._then);

  final _Paper _self;
  final $Res Function(_Paper) _then;

/// Create a copy of Paper
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? abstract = freezed,Object? doi = freezed,Object? url = freezed,Object? publicationYear = freezed,Object? citationCount = null,Object? externalIdOpenalexId = freezed,Object? externalIdSemanticScholarId = freezed,Object? externalIdCrossref = freezed,Object? authors = freezed,Object? journalId = freezed,Object? keywords = freezed,Object? topics = freezed,Object? pdfUrl = freezed,Object? source = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_Paper(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,abstract: freezed == abstract ? _self.abstract : abstract // ignore: cast_nullable_to_non_nullable
as String?,doi: freezed == doi ? _self.doi : doi // ignore: cast_nullable_to_non_nullable
as String?,url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,publicationYear: freezed == publicationYear ? _self.publicationYear : publicationYear // ignore: cast_nullable_to_non_nullable
as int?,citationCount: null == citationCount ? _self.citationCount : citationCount // ignore: cast_nullable_to_non_nullable
as int,externalIdOpenalexId: freezed == externalIdOpenalexId ? _self.externalIdOpenalexId : externalIdOpenalexId // ignore: cast_nullable_to_non_nullable
as String?,externalIdSemanticScholarId: freezed == externalIdSemanticScholarId ? _self.externalIdSemanticScholarId : externalIdSemanticScholarId // ignore: cast_nullable_to_non_nullable
as String?,externalIdCrossref: freezed == externalIdCrossref ? _self.externalIdCrossref : externalIdCrossref // ignore: cast_nullable_to_non_nullable
as String?,authors: freezed == authors ? _self.authors : authors // ignore: cast_nullable_to_non_nullable
as List<PaperAuthor>?,journalId: freezed == journalId ? _self.journalId : journalId // ignore: cast_nullable_to_non_nullable
as dynamic,keywords: freezed == keywords ? _self.keywords : keywords // ignore: cast_nullable_to_non_nullable
as List<dynamic>?,topics: freezed == topics ? _self.topics : topics // ignore: cast_nullable_to_non_nullable
as List<dynamic>?,pdfUrl: freezed == pdfUrl ? _self.pdfUrl : pdfUrl // ignore: cast_nullable_to_non_nullable
as String?,source: freezed == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
