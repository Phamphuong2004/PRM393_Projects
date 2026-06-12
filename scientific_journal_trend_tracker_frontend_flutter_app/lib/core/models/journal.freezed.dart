// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'journal.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Journal {

@JsonKey(name: '_id') String get id; String get name; String? get issn; String? get publisher; double? get impactFactor; int? get hIndex; int get paperCount; String? get fieldDomain; bool get isTracked; DateTime? get createdAt; DateTime? get updatedAt;
/// Create a copy of Journal
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$JournalCopyWith<Journal> get copyWith => _$JournalCopyWithImpl<Journal>(this as Journal, _$identity);

  /// Serializes this Journal to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Journal&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.issn, issn) || other.issn == issn)&&(identical(other.publisher, publisher) || other.publisher == publisher)&&(identical(other.impactFactor, impactFactor) || other.impactFactor == impactFactor)&&(identical(other.hIndex, hIndex) || other.hIndex == hIndex)&&(identical(other.paperCount, paperCount) || other.paperCount == paperCount)&&(identical(other.fieldDomain, fieldDomain) || other.fieldDomain == fieldDomain)&&(identical(other.isTracked, isTracked) || other.isTracked == isTracked)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,issn,publisher,impactFactor,hIndex,paperCount,fieldDomain,isTracked,createdAt,updatedAt);

@override
String toString() {
  return 'Journal(id: $id, name: $name, issn: $issn, publisher: $publisher, impactFactor: $impactFactor, hIndex: $hIndex, paperCount: $paperCount, fieldDomain: $fieldDomain, isTracked: $isTracked, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $JournalCopyWith<$Res>  {
  factory $JournalCopyWith(Journal value, $Res Function(Journal) _then) = _$JournalCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: '_id') String id, String name, String? issn, String? publisher, double? impactFactor, int? hIndex, int paperCount, String? fieldDomain, bool isTracked, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class _$JournalCopyWithImpl<$Res>
    implements $JournalCopyWith<$Res> {
  _$JournalCopyWithImpl(this._self, this._then);

  final Journal _self;
  final $Res Function(Journal) _then;

/// Create a copy of Journal
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? issn = freezed,Object? publisher = freezed,Object? impactFactor = freezed,Object? hIndex = freezed,Object? paperCount = null,Object? fieldDomain = freezed,Object? isTracked = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,issn: freezed == issn ? _self.issn : issn // ignore: cast_nullable_to_non_nullable
as String?,publisher: freezed == publisher ? _self.publisher : publisher // ignore: cast_nullable_to_non_nullable
as String?,impactFactor: freezed == impactFactor ? _self.impactFactor : impactFactor // ignore: cast_nullable_to_non_nullable
as double?,hIndex: freezed == hIndex ? _self.hIndex : hIndex // ignore: cast_nullable_to_non_nullable
as int?,paperCount: null == paperCount ? _self.paperCount : paperCount // ignore: cast_nullable_to_non_nullable
as int,fieldDomain: freezed == fieldDomain ? _self.fieldDomain : fieldDomain // ignore: cast_nullable_to_non_nullable
as String?,isTracked: null == isTracked ? _self.isTracked : isTracked // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Journal].
extension JournalPatterns on Journal {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Journal value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Journal() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Journal value)  $default,){
final _that = this;
switch (_that) {
case _Journal():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Journal value)?  $default,){
final _that = this;
switch (_that) {
case _Journal() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: '_id')  String id,  String name,  String? issn,  String? publisher,  double? impactFactor,  int? hIndex,  int paperCount,  String? fieldDomain,  bool isTracked,  DateTime? createdAt,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Journal() when $default != null:
return $default(_that.id,_that.name,_that.issn,_that.publisher,_that.impactFactor,_that.hIndex,_that.paperCount,_that.fieldDomain,_that.isTracked,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: '_id')  String id,  String name,  String? issn,  String? publisher,  double? impactFactor,  int? hIndex,  int paperCount,  String? fieldDomain,  bool isTracked,  DateTime? createdAt,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _Journal():
return $default(_that.id,_that.name,_that.issn,_that.publisher,_that.impactFactor,_that.hIndex,_that.paperCount,_that.fieldDomain,_that.isTracked,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: '_id')  String id,  String name,  String? issn,  String? publisher,  double? impactFactor,  int? hIndex,  int paperCount,  String? fieldDomain,  bool isTracked,  DateTime? createdAt,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Journal() when $default != null:
return $default(_that.id,_that.name,_that.issn,_that.publisher,_that.impactFactor,_that.hIndex,_that.paperCount,_that.fieldDomain,_that.isTracked,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Journal implements Journal {
  const _Journal({@JsonKey(name: '_id') required this.id, required this.name, this.issn, this.publisher, this.impactFactor, this.hIndex, this.paperCount = 0, this.fieldDomain, this.isTracked = false, this.createdAt, this.updatedAt});
  factory _Journal.fromJson(Map<String, dynamic> json) => _$JournalFromJson(json);

@override@JsonKey(name: '_id') final  String id;
@override final  String name;
@override final  String? issn;
@override final  String? publisher;
@override final  double? impactFactor;
@override final  int? hIndex;
@override@JsonKey() final  int paperCount;
@override final  String? fieldDomain;
@override@JsonKey() final  bool isTracked;
@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;

/// Create a copy of Journal
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$JournalCopyWith<_Journal> get copyWith => __$JournalCopyWithImpl<_Journal>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$JournalToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Journal&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.issn, issn) || other.issn == issn)&&(identical(other.publisher, publisher) || other.publisher == publisher)&&(identical(other.impactFactor, impactFactor) || other.impactFactor == impactFactor)&&(identical(other.hIndex, hIndex) || other.hIndex == hIndex)&&(identical(other.paperCount, paperCount) || other.paperCount == paperCount)&&(identical(other.fieldDomain, fieldDomain) || other.fieldDomain == fieldDomain)&&(identical(other.isTracked, isTracked) || other.isTracked == isTracked)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,issn,publisher,impactFactor,hIndex,paperCount,fieldDomain,isTracked,createdAt,updatedAt);

@override
String toString() {
  return 'Journal(id: $id, name: $name, issn: $issn, publisher: $publisher, impactFactor: $impactFactor, hIndex: $hIndex, paperCount: $paperCount, fieldDomain: $fieldDomain, isTracked: $isTracked, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$JournalCopyWith<$Res> implements $JournalCopyWith<$Res> {
  factory _$JournalCopyWith(_Journal value, $Res Function(_Journal) _then) = __$JournalCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: '_id') String id, String name, String? issn, String? publisher, double? impactFactor, int? hIndex, int paperCount, String? fieldDomain, bool isTracked, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class __$JournalCopyWithImpl<$Res>
    implements _$JournalCopyWith<$Res> {
  __$JournalCopyWithImpl(this._self, this._then);

  final _Journal _self;
  final $Res Function(_Journal) _then;

/// Create a copy of Journal
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? issn = freezed,Object? publisher = freezed,Object? impactFactor = freezed,Object? hIndex = freezed,Object? paperCount = null,Object? fieldDomain = freezed,Object? isTracked = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_Journal(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,issn: freezed == issn ? _self.issn : issn // ignore: cast_nullable_to_non_nullable
as String?,publisher: freezed == publisher ? _self.publisher : publisher // ignore: cast_nullable_to_non_nullable
as String?,impactFactor: freezed == impactFactor ? _self.impactFactor : impactFactor // ignore: cast_nullable_to_non_nullable
as double?,hIndex: freezed == hIndex ? _self.hIndex : hIndex // ignore: cast_nullable_to_non_nullable
as int?,paperCount: null == paperCount ? _self.paperCount : paperCount // ignore: cast_nullable_to_non_nullable
as int,fieldDomain: freezed == fieldDomain ? _self.fieldDomain : fieldDomain // ignore: cast_nullable_to_non_nullable
as String?,isTracked: null == isTracked ? _self.isTracked : isTracked // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
