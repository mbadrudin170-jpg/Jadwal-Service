// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'lampiran.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Lampiran {

 String get id; String get url; String get tipe; String? get nama; int? get ukuran;
/// Create a copy of Lampiran
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LampiranCopyWith<Lampiran> get copyWith => _$LampiranCopyWithImpl<Lampiran>(this as Lampiran, _$identity);

  /// Serializes this Lampiran to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Lampiran&&(identical(other.id, id) || other.id == id)&&(identical(other.url, url) || other.url == url)&&(identical(other.tipe, tipe) || other.tipe == tipe)&&(identical(other.nama, nama) || other.nama == nama)&&(identical(other.ukuran, ukuran) || other.ukuran == ukuran));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,url,tipe,nama,ukuran);

@override
String toString() {
  return 'Lampiran(id: $id, url: $url, tipe: $tipe, nama: $nama, ukuran: $ukuran)';
}


}

/// @nodoc
abstract mixin class $LampiranCopyWith<$Res>  {
  factory $LampiranCopyWith(Lampiran value, $Res Function(Lampiran) _then) = _$LampiranCopyWithImpl;
@useResult
$Res call({
 String id, String url, String tipe, String? nama, int? ukuran
});




}
/// @nodoc
class _$LampiranCopyWithImpl<$Res>
    implements $LampiranCopyWith<$Res> {
  _$LampiranCopyWithImpl(this._self, this._then);

  final Lampiran _self;
  final $Res Function(Lampiran) _then;

/// Create a copy of Lampiran
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? url = null,Object? tipe = null,Object? nama = freezed,Object? ukuran = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,tipe: null == tipe ? _self.tipe : tipe // ignore: cast_nullable_to_non_nullable
as String,nama: freezed == nama ? _self.nama : nama // ignore: cast_nullable_to_non_nullable
as String?,ukuran: freezed == ukuran ? _self.ukuran : ukuran // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [Lampiran].
extension LampiranPatterns on Lampiran {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Lampiran value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Lampiran() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Lampiran value)  $default,){
final _that = this;
switch (_that) {
case _Lampiran():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Lampiran value)?  $default,){
final _that = this;
switch (_that) {
case _Lampiran() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String url,  String tipe,  String? nama,  int? ukuran)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Lampiran() when $default != null:
return $default(_that.id,_that.url,_that.tipe,_that.nama,_that.ukuran);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String url,  String tipe,  String? nama,  int? ukuran)  $default,) {final _that = this;
switch (_that) {
case _Lampiran():
return $default(_that.id,_that.url,_that.tipe,_that.nama,_that.ukuran);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String url,  String tipe,  String? nama,  int? ukuran)?  $default,) {final _that = this;
switch (_that) {
case _Lampiran() when $default != null:
return $default(_that.id,_that.url,_that.tipe,_that.nama,_that.ukuran);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Lampiran implements Lampiran {
  const _Lampiran({required this.id, required this.url, required this.tipe, this.nama, this.ukuran});
  factory _Lampiran.fromJson(Map<String, dynamic> json) => _$LampiranFromJson(json);

@override final  String id;
@override final  String url;
@override final  String tipe;
@override final  String? nama;
@override final  int? ukuran;

/// Create a copy of Lampiran
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LampiranCopyWith<_Lampiran> get copyWith => __$LampiranCopyWithImpl<_Lampiran>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LampiranToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Lampiran&&(identical(other.id, id) || other.id == id)&&(identical(other.url, url) || other.url == url)&&(identical(other.tipe, tipe) || other.tipe == tipe)&&(identical(other.nama, nama) || other.nama == nama)&&(identical(other.ukuran, ukuran) || other.ukuran == ukuran));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,url,tipe,nama,ukuran);

@override
String toString() {
  return 'Lampiran(id: $id, url: $url, tipe: $tipe, nama: $nama, ukuran: $ukuran)';
}


}

/// @nodoc
abstract mixin class _$LampiranCopyWith<$Res> implements $LampiranCopyWith<$Res> {
  factory _$LampiranCopyWith(_Lampiran value, $Res Function(_Lampiran) _then) = __$LampiranCopyWithImpl;
@override @useResult
$Res call({
 String id, String url, String tipe, String? nama, int? ukuran
});




}
/// @nodoc
class __$LampiranCopyWithImpl<$Res>
    implements _$LampiranCopyWith<$Res> {
  __$LampiranCopyWithImpl(this._self, this._then);

  final _Lampiran _self;
  final $Res Function(_Lampiran) _then;

/// Create a copy of Lampiran
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? url = null,Object? tipe = null,Object? nama = freezed,Object? ukuran = freezed,}) {
  return _then(_Lampiran(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,tipe: null == tipe ? _self.tipe : tipe // ignore: cast_nullable_to_non_nullable
as String,nama: freezed == nama ? _self.nama : nama // ignore: cast_nullable_to_non_nullable
as String?,ukuran: freezed == ukuran ? _self.ukuran : ukuran // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
