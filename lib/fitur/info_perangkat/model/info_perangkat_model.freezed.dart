// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'info_perangkat_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$InfoPerangkatModel {

 String get namaApk; String get namaPaket; String get versi; String get nomorBuild;
/// Create a copy of InfoPerangkatModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InfoPerangkatModelCopyWith<InfoPerangkatModel> get copyWith => _$InfoPerangkatModelCopyWithImpl<InfoPerangkatModel>(this as InfoPerangkatModel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InfoPerangkatModel&&(identical(other.namaApk, namaApk) || other.namaApk == namaApk)&&(identical(other.namaPaket, namaPaket) || other.namaPaket == namaPaket)&&(identical(other.versi, versi) || other.versi == versi)&&(identical(other.nomorBuild, nomorBuild) || other.nomorBuild == nomorBuild));
}


@override
int get hashCode => Object.hash(runtimeType,namaApk,namaPaket,versi,nomorBuild);

@override
String toString() {
  return 'InfoPerangkatModel(namaApk: $namaApk, namaPaket: $namaPaket, versi: $versi, nomorBuild: $nomorBuild)';
}


}

/// @nodoc
abstract mixin class $InfoPerangkatModelCopyWith<$Res>  {
  factory $InfoPerangkatModelCopyWith(InfoPerangkatModel value, $Res Function(InfoPerangkatModel) _then) = _$InfoPerangkatModelCopyWithImpl;
@useResult
$Res call({
 String namaApk, String namaPaket, String versi, String nomorBuild
});




}
/// @nodoc
class _$InfoPerangkatModelCopyWithImpl<$Res>
    implements $InfoPerangkatModelCopyWith<$Res> {
  _$InfoPerangkatModelCopyWithImpl(this._self, this._then);

  final InfoPerangkatModel _self;
  final $Res Function(InfoPerangkatModel) _then;

/// Create a copy of InfoPerangkatModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? namaApk = null,Object? namaPaket = null,Object? versi = null,Object? nomorBuild = null,}) {
  return _then(_self.copyWith(
namaApk: null == namaApk ? _self.namaApk : namaApk // ignore: cast_nullable_to_non_nullable
as String,namaPaket: null == namaPaket ? _self.namaPaket : namaPaket // ignore: cast_nullable_to_non_nullable
as String,versi: null == versi ? _self.versi : versi // ignore: cast_nullable_to_non_nullable
as String,nomorBuild: null == nomorBuild ? _self.nomorBuild : nomorBuild // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [InfoPerangkatModel].
extension InfoPerangkatModelPatterns on InfoPerangkatModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InfoPerangkatModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InfoPerangkatModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InfoPerangkatModel value)  $default,){
final _that = this;
switch (_that) {
case _InfoPerangkatModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InfoPerangkatModel value)?  $default,){
final _that = this;
switch (_that) {
case _InfoPerangkatModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String namaApk,  String namaPaket,  String versi,  String nomorBuild)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InfoPerangkatModel() when $default != null:
return $default(_that.namaApk,_that.namaPaket,_that.versi,_that.nomorBuild);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String namaApk,  String namaPaket,  String versi,  String nomorBuild)  $default,) {final _that = this;
switch (_that) {
case _InfoPerangkatModel():
return $default(_that.namaApk,_that.namaPaket,_that.versi,_that.nomorBuild);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String namaApk,  String namaPaket,  String versi,  String nomorBuild)?  $default,) {final _that = this;
switch (_that) {
case _InfoPerangkatModel() when $default != null:
return $default(_that.namaApk,_that.namaPaket,_that.versi,_that.nomorBuild);case _:
  return null;

}
}

}

/// @nodoc


class _InfoPerangkatModel extends InfoPerangkatModel {
  const _InfoPerangkatModel({required this.namaApk, required this.namaPaket, required this.versi, required this.nomorBuild}): super._();
  

@override final  String namaApk;
@override final  String namaPaket;
@override final  String versi;
@override final  String nomorBuild;

/// Create a copy of InfoPerangkatModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InfoPerangkatModelCopyWith<_InfoPerangkatModel> get copyWith => __$InfoPerangkatModelCopyWithImpl<_InfoPerangkatModel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InfoPerangkatModel&&(identical(other.namaApk, namaApk) || other.namaApk == namaApk)&&(identical(other.namaPaket, namaPaket) || other.namaPaket == namaPaket)&&(identical(other.versi, versi) || other.versi == versi)&&(identical(other.nomorBuild, nomorBuild) || other.nomorBuild == nomorBuild));
}


@override
int get hashCode => Object.hash(runtimeType,namaApk,namaPaket,versi,nomorBuild);

@override
String toString() {
  return 'InfoPerangkatModel(namaApk: $namaApk, namaPaket: $namaPaket, versi: $versi, nomorBuild: $nomorBuild)';
}


}

/// @nodoc
abstract mixin class _$InfoPerangkatModelCopyWith<$Res> implements $InfoPerangkatModelCopyWith<$Res> {
  factory _$InfoPerangkatModelCopyWith(_InfoPerangkatModel value, $Res Function(_InfoPerangkatModel) _then) = __$InfoPerangkatModelCopyWithImpl;
@override @useResult
$Res call({
 String namaApk, String namaPaket, String versi, String nomorBuild
});




}
/// @nodoc
class __$InfoPerangkatModelCopyWithImpl<$Res>
    implements _$InfoPerangkatModelCopyWith<$Res> {
  __$InfoPerangkatModelCopyWithImpl(this._self, this._then);

  final _InfoPerangkatModel _self;
  final $Res Function(_InfoPerangkatModel) _then;

/// Create a copy of InfoPerangkatModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? namaApk = null,Object? namaPaket = null,Object? versi = null,Object? nomorBuild = null,}) {
  return _then(_InfoPerangkatModel(
namaApk: null == namaApk ? _self.namaApk : namaApk // ignore: cast_nullable_to_non_nullable
as String,namaPaket: null == namaPaket ? _self.namaPaket : namaPaket // ignore: cast_nullable_to_non_nullable
as String,versi: null == versi ? _self.versi : versi // ignore: cast_nullable_to_non_nullable
as String,nomorBuild: null == nomorBuild ? _self.nomorBuild : nomorBuild // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
