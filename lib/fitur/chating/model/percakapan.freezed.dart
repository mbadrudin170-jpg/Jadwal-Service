// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'percakapan.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Percakapan {

 String get id; List<String> get idPartisipan; String? get judul; Pesan? get pesanTerakhir; String? get pratinjauPesanTerakhir; DateTime? get waktuPesanTerakhir; int get jumlahBelumDibaca;
/// Create a copy of Percakapan
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PercakapanCopyWith<Percakapan> get copyWith => _$PercakapanCopyWithImpl<Percakapan>(this as Percakapan, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Percakapan&&(identical(other.id, id) || other.id == id)&&const DeepCollectionEquality().equals(other.idPartisipan, idPartisipan)&&(identical(other.judul, judul) || other.judul == judul)&&(identical(other.pesanTerakhir, pesanTerakhir) || other.pesanTerakhir == pesanTerakhir)&&(identical(other.pratinjauPesanTerakhir, pratinjauPesanTerakhir) || other.pratinjauPesanTerakhir == pratinjauPesanTerakhir)&&(identical(other.waktuPesanTerakhir, waktuPesanTerakhir) || other.waktuPesanTerakhir == waktuPesanTerakhir)&&(identical(other.jumlahBelumDibaca, jumlahBelumDibaca) || other.jumlahBelumDibaca == jumlahBelumDibaca));
}


@override
int get hashCode => Object.hash(runtimeType,id,const DeepCollectionEquality().hash(idPartisipan),judul,pesanTerakhir,pratinjauPesanTerakhir,waktuPesanTerakhir,jumlahBelumDibaca);

@override
String toString() {
  return 'Percakapan(id: $id, idPartisipan: $idPartisipan, judul: $judul, pesanTerakhir: $pesanTerakhir, pratinjauPesanTerakhir: $pratinjauPesanTerakhir, waktuPesanTerakhir: $waktuPesanTerakhir, jumlahBelumDibaca: $jumlahBelumDibaca)';
}


}

/// @nodoc
abstract mixin class $PercakapanCopyWith<$Res>  {
  factory $PercakapanCopyWith(Percakapan value, $Res Function(Percakapan) _then) = _$PercakapanCopyWithImpl;
@useResult
$Res call({
 String id, List<String> idPartisipan, String? judul, Pesan? pesanTerakhir, String? pratinjauPesanTerakhir, DateTime? waktuPesanTerakhir, int jumlahBelumDibaca
});


$PesanCopyWith<$Res>? get pesanTerakhir;

}
/// @nodoc
class _$PercakapanCopyWithImpl<$Res>
    implements $PercakapanCopyWith<$Res> {
  _$PercakapanCopyWithImpl(this._self, this._then);

  final Percakapan _self;
  final $Res Function(Percakapan) _then;

/// Create a copy of Percakapan
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? idPartisipan = null,Object? judul = freezed,Object? pesanTerakhir = freezed,Object? pratinjauPesanTerakhir = freezed,Object? waktuPesanTerakhir = freezed,Object? jumlahBelumDibaca = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,idPartisipan: null == idPartisipan ? _self.idPartisipan : idPartisipan // ignore: cast_nullable_to_non_nullable
as List<String>,judul: freezed == judul ? _self.judul : judul // ignore: cast_nullable_to_non_nullable
as String?,pesanTerakhir: freezed == pesanTerakhir ? _self.pesanTerakhir : pesanTerakhir // ignore: cast_nullable_to_non_nullable
as Pesan?,pratinjauPesanTerakhir: freezed == pratinjauPesanTerakhir ? _self.pratinjauPesanTerakhir : pratinjauPesanTerakhir // ignore: cast_nullable_to_non_nullable
as String?,waktuPesanTerakhir: freezed == waktuPesanTerakhir ? _self.waktuPesanTerakhir : waktuPesanTerakhir // ignore: cast_nullable_to_non_nullable
as DateTime?,jumlahBelumDibaca: null == jumlahBelumDibaca ? _self.jumlahBelumDibaca : jumlahBelumDibaca // ignore: cast_nullable_to_non_nullable
as int,
  ));
}
/// Create a copy of Percakapan
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PesanCopyWith<$Res>? get pesanTerakhir {
    if (_self.pesanTerakhir == null) {
    return null;
  }

  return $PesanCopyWith<$Res>(_self.pesanTerakhir!, (value) {
    return _then(_self.copyWith(pesanTerakhir: value));
  });
}
}


/// Adds pattern-matching-related methods to [Percakapan].
extension PercakapanPatterns on Percakapan {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Percakapan value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Percakapan() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Percakapan value)  $default,){
final _that = this;
switch (_that) {
case _Percakapan():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Percakapan value)?  $default,){
final _that = this;
switch (_that) {
case _Percakapan() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  List<String> idPartisipan,  String? judul,  Pesan? pesanTerakhir,  String? pratinjauPesanTerakhir,  DateTime? waktuPesanTerakhir,  int jumlahBelumDibaca)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Percakapan() when $default != null:
return $default(_that.id,_that.idPartisipan,_that.judul,_that.pesanTerakhir,_that.pratinjauPesanTerakhir,_that.waktuPesanTerakhir,_that.jumlahBelumDibaca);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  List<String> idPartisipan,  String? judul,  Pesan? pesanTerakhir,  String? pratinjauPesanTerakhir,  DateTime? waktuPesanTerakhir,  int jumlahBelumDibaca)  $default,) {final _that = this;
switch (_that) {
case _Percakapan():
return $default(_that.id,_that.idPartisipan,_that.judul,_that.pesanTerakhir,_that.pratinjauPesanTerakhir,_that.waktuPesanTerakhir,_that.jumlahBelumDibaca);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  List<String> idPartisipan,  String? judul,  Pesan? pesanTerakhir,  String? pratinjauPesanTerakhir,  DateTime? waktuPesanTerakhir,  int jumlahBelumDibaca)?  $default,) {final _that = this;
switch (_that) {
case _Percakapan() when $default != null:
return $default(_that.id,_that.idPartisipan,_that.judul,_that.pesanTerakhir,_that.pratinjauPesanTerakhir,_that.waktuPesanTerakhir,_that.jumlahBelumDibaca);case _:
  return null;

}
}

}

/// @nodoc


class _Percakapan extends Percakapan {
  const _Percakapan({required this.id, final  List<String> idPartisipan = const [], this.judul, this.pesanTerakhir, this.pratinjauPesanTerakhir, this.waktuPesanTerakhir, this.jumlahBelumDibaca = 0}): _idPartisipan = idPartisipan,super._();
  

@override final  String id;
 final  List<String> _idPartisipan;
@override@JsonKey() List<String> get idPartisipan {
  if (_idPartisipan is EqualUnmodifiableListView) return _idPartisipan;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_idPartisipan);
}

@override final  String? judul;
@override final  Pesan? pesanTerakhir;
@override final  String? pratinjauPesanTerakhir;
@override final  DateTime? waktuPesanTerakhir;
@override@JsonKey() final  int jumlahBelumDibaca;

/// Create a copy of Percakapan
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PercakapanCopyWith<_Percakapan> get copyWith => __$PercakapanCopyWithImpl<_Percakapan>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Percakapan&&(identical(other.id, id) || other.id == id)&&const DeepCollectionEquality().equals(other._idPartisipan, _idPartisipan)&&(identical(other.judul, judul) || other.judul == judul)&&(identical(other.pesanTerakhir, pesanTerakhir) || other.pesanTerakhir == pesanTerakhir)&&(identical(other.pratinjauPesanTerakhir, pratinjauPesanTerakhir) || other.pratinjauPesanTerakhir == pratinjauPesanTerakhir)&&(identical(other.waktuPesanTerakhir, waktuPesanTerakhir) || other.waktuPesanTerakhir == waktuPesanTerakhir)&&(identical(other.jumlahBelumDibaca, jumlahBelumDibaca) || other.jumlahBelumDibaca == jumlahBelumDibaca));
}


@override
int get hashCode => Object.hash(runtimeType,id,const DeepCollectionEquality().hash(_idPartisipan),judul,pesanTerakhir,pratinjauPesanTerakhir,waktuPesanTerakhir,jumlahBelumDibaca);

@override
String toString() {
  return 'Percakapan(id: $id, idPartisipan: $idPartisipan, judul: $judul, pesanTerakhir: $pesanTerakhir, pratinjauPesanTerakhir: $pratinjauPesanTerakhir, waktuPesanTerakhir: $waktuPesanTerakhir, jumlahBelumDibaca: $jumlahBelumDibaca)';
}


}

/// @nodoc
abstract mixin class _$PercakapanCopyWith<$Res> implements $PercakapanCopyWith<$Res> {
  factory _$PercakapanCopyWith(_Percakapan value, $Res Function(_Percakapan) _then) = __$PercakapanCopyWithImpl;
@override @useResult
$Res call({
 String id, List<String> idPartisipan, String? judul, Pesan? pesanTerakhir, String? pratinjauPesanTerakhir, DateTime? waktuPesanTerakhir, int jumlahBelumDibaca
});


@override $PesanCopyWith<$Res>? get pesanTerakhir;

}
/// @nodoc
class __$PercakapanCopyWithImpl<$Res>
    implements _$PercakapanCopyWith<$Res> {
  __$PercakapanCopyWithImpl(this._self, this._then);

  final _Percakapan _self;
  final $Res Function(_Percakapan) _then;

/// Create a copy of Percakapan
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? idPartisipan = null,Object? judul = freezed,Object? pesanTerakhir = freezed,Object? pratinjauPesanTerakhir = freezed,Object? waktuPesanTerakhir = freezed,Object? jumlahBelumDibaca = null,}) {
  return _then(_Percakapan(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,idPartisipan: null == idPartisipan ? _self._idPartisipan : idPartisipan // ignore: cast_nullable_to_non_nullable
as List<String>,judul: freezed == judul ? _self.judul : judul // ignore: cast_nullable_to_non_nullable
as String?,pesanTerakhir: freezed == pesanTerakhir ? _self.pesanTerakhir : pesanTerakhir // ignore: cast_nullable_to_non_nullable
as Pesan?,pratinjauPesanTerakhir: freezed == pratinjauPesanTerakhir ? _self.pratinjauPesanTerakhir : pratinjauPesanTerakhir // ignore: cast_nullable_to_non_nullable
as String?,waktuPesanTerakhir: freezed == waktuPesanTerakhir ? _self.waktuPesanTerakhir : waktuPesanTerakhir // ignore: cast_nullable_to_non_nullable
as DateTime?,jumlahBelumDibaca: null == jumlahBelumDibaca ? _self.jumlahBelumDibaca : jumlahBelumDibaca // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of Percakapan
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PesanCopyWith<$Res>? get pesanTerakhir {
    if (_self.pesanTerakhir == null) {
    return null;
  }

  return $PesanCopyWith<$Res>(_self.pesanTerakhir!, (value) {
    return _then(_self.copyWith(pesanTerakhir: value));
  });
}
}

// dart format on
