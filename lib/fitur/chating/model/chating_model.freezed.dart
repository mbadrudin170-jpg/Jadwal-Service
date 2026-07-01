// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chating_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Pesan {

 String get id;@JsonKey(name: 'id_percakapan') String get idPercakapan;@JsonKey(name: 'id_pengirim') String get idPengirim; String? get teks;@JsonKey(name: 'dibuat_pada') DateTime get dibuatPada;@JsonKey(name: 'diedit_pada') DateTime? get dieditPada;@JsonKey(name: 'status', fromJson: _statusFromJson, toJson: _statusToJson) StatusPesan get status; List<Lampiran> get lampiran;@JsonKey(name: 'balasan_untuk') String? get balasanUntuk; Map<String, int> get reaksi; Map<String, dynamic>? get metadata;@JsonKey(name: 'dihapus', fromJson: _boolFromDynamic, toJson: _boolToDynamic) bool get dihapus;@JsonKey(name: 'diarsipkan_pada') DateTime? get diarsipkanPada;
/// Create a copy of Pesan
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PesanCopyWith<Pesan> get copyWith => _$PesanCopyWithImpl<Pesan>(this as Pesan, _$identity);

  /// Serializes this Pesan to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Pesan&&(identical(other.id, id) || other.id == id)&&(identical(other.idPercakapan, idPercakapan) || other.idPercakapan == idPercakapan)&&(identical(other.idPengirim, idPengirim) || other.idPengirim == idPengirim)&&(identical(other.teks, teks) || other.teks == teks)&&(identical(other.dibuatPada, dibuatPada) || other.dibuatPada == dibuatPada)&&(identical(other.dieditPada, dieditPada) || other.dieditPada == dieditPada)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.lampiran, lampiran)&&(identical(other.balasanUntuk, balasanUntuk) || other.balasanUntuk == balasanUntuk)&&const DeepCollectionEquality().equals(other.reaksi, reaksi)&&const DeepCollectionEquality().equals(other.metadata, metadata)&&(identical(other.dihapus, dihapus) || other.dihapus == dihapus)&&(identical(other.diarsipkanPada, diarsipkanPada) || other.diarsipkanPada == diarsipkanPada));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,idPercakapan,idPengirim,teks,dibuatPada,dieditPada,status,const DeepCollectionEquality().hash(lampiran),balasanUntuk,const DeepCollectionEquality().hash(reaksi),const DeepCollectionEquality().hash(metadata),dihapus,diarsipkanPada);

@override
String toString() {
  return 'Pesan(id: $id, idPercakapan: $idPercakapan, idPengirim: $idPengirim, teks: $teks, dibuatPada: $dibuatPada, dieditPada: $dieditPada, status: $status, lampiran: $lampiran, balasanUntuk: $balasanUntuk, reaksi: $reaksi, metadata: $metadata, dihapus: $dihapus, diarsipkanPada: $diarsipkanPada)';
}


}

/// @nodoc
abstract mixin class $PesanCopyWith<$Res>  {
  factory $PesanCopyWith(Pesan value, $Res Function(Pesan) _then) = _$PesanCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'id_percakapan') String idPercakapan,@JsonKey(name: 'id_pengirim') String idPengirim, String? teks,@JsonKey(name: 'dibuat_pada') DateTime dibuatPada,@JsonKey(name: 'diedit_pada') DateTime? dieditPada,@JsonKey(name: 'status', fromJson: _statusFromJson, toJson: _statusToJson) StatusPesan status, List<Lampiran> lampiran,@JsonKey(name: 'balasan_untuk') String? balasanUntuk, Map<String, int> reaksi, Map<String, dynamic>? metadata,@JsonKey(name: 'dihapus', fromJson: _boolFromDynamic, toJson: _boolToDynamic) bool dihapus,@JsonKey(name: 'diarsipkan_pada') DateTime? diarsipkanPada
});




}
/// @nodoc
class _$PesanCopyWithImpl<$Res>
    implements $PesanCopyWith<$Res> {
  _$PesanCopyWithImpl(this._self, this._then);

  final Pesan _self;
  final $Res Function(Pesan) _then;

/// Create a copy of Pesan
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? idPercakapan = null,Object? idPengirim = null,Object? teks = freezed,Object? dibuatPada = null,Object? dieditPada = freezed,Object? status = null,Object? lampiran = null,Object? balasanUntuk = freezed,Object? reaksi = null,Object? metadata = freezed,Object? dihapus = null,Object? diarsipkanPada = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,idPercakapan: null == idPercakapan ? _self.idPercakapan : idPercakapan // ignore: cast_nullable_to_non_nullable
as String,idPengirim: null == idPengirim ? _self.idPengirim : idPengirim // ignore: cast_nullable_to_non_nullable
as String,teks: freezed == teks ? _self.teks : teks // ignore: cast_nullable_to_non_nullable
as String?,dibuatPada: null == dibuatPada ? _self.dibuatPada : dibuatPada // ignore: cast_nullable_to_non_nullable
as DateTime,dieditPada: freezed == dieditPada ? _self.dieditPada : dieditPada // ignore: cast_nullable_to_non_nullable
as DateTime?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as StatusPesan,lampiran: null == lampiran ? _self.lampiran : lampiran // ignore: cast_nullable_to_non_nullable
as List<Lampiran>,balasanUntuk: freezed == balasanUntuk ? _self.balasanUntuk : balasanUntuk // ignore: cast_nullable_to_non_nullable
as String?,reaksi: null == reaksi ? _self.reaksi : reaksi // ignore: cast_nullable_to_non_nullable
as Map<String, int>,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,dihapus: null == dihapus ? _self.dihapus : dihapus // ignore: cast_nullable_to_non_nullable
as bool,diarsipkanPada: freezed == diarsipkanPada ? _self.diarsipkanPada : diarsipkanPada // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Pesan].
extension PesanPatterns on Pesan {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Pesan value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Pesan() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Pesan value)  $default,){
final _that = this;
switch (_that) {
case _Pesan():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Pesan value)?  $default,){
final _that = this;
switch (_that) {
case _Pesan() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'id_percakapan')  String idPercakapan, @JsonKey(name: 'id_pengirim')  String idPengirim,  String? teks, @JsonKey(name: 'dibuat_pada')  DateTime dibuatPada, @JsonKey(name: 'diedit_pada')  DateTime? dieditPada, @JsonKey(name: 'status', fromJson: _statusFromJson, toJson: _statusToJson)  StatusPesan status,  List<Lampiran> lampiran, @JsonKey(name: 'balasan_untuk')  String? balasanUntuk,  Map<String, int> reaksi,  Map<String, dynamic>? metadata, @JsonKey(name: 'dihapus', fromJson: _boolFromDynamic, toJson: _boolToDynamic)  bool dihapus, @JsonKey(name: 'diarsipkan_pada')  DateTime? diarsipkanPada)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Pesan() when $default != null:
return $default(_that.id,_that.idPercakapan,_that.idPengirim,_that.teks,_that.dibuatPada,_that.dieditPada,_that.status,_that.lampiran,_that.balasanUntuk,_that.reaksi,_that.metadata,_that.dihapus,_that.diarsipkanPada);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'id_percakapan')  String idPercakapan, @JsonKey(name: 'id_pengirim')  String idPengirim,  String? teks, @JsonKey(name: 'dibuat_pada')  DateTime dibuatPada, @JsonKey(name: 'diedit_pada')  DateTime? dieditPada, @JsonKey(name: 'status', fromJson: _statusFromJson, toJson: _statusToJson)  StatusPesan status,  List<Lampiran> lampiran, @JsonKey(name: 'balasan_untuk')  String? balasanUntuk,  Map<String, int> reaksi,  Map<String, dynamic>? metadata, @JsonKey(name: 'dihapus', fromJson: _boolFromDynamic, toJson: _boolToDynamic)  bool dihapus, @JsonKey(name: 'diarsipkan_pada')  DateTime? diarsipkanPada)  $default,) {final _that = this;
switch (_that) {
case _Pesan():
return $default(_that.id,_that.idPercakapan,_that.idPengirim,_that.teks,_that.dibuatPada,_that.dieditPada,_that.status,_that.lampiran,_that.balasanUntuk,_that.reaksi,_that.metadata,_that.dihapus,_that.diarsipkanPada);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'id_percakapan')  String idPercakapan, @JsonKey(name: 'id_pengirim')  String idPengirim,  String? teks, @JsonKey(name: 'dibuat_pada')  DateTime dibuatPada, @JsonKey(name: 'diedit_pada')  DateTime? dieditPada, @JsonKey(name: 'status', fromJson: _statusFromJson, toJson: _statusToJson)  StatusPesan status,  List<Lampiran> lampiran, @JsonKey(name: 'balasan_untuk')  String? balasanUntuk,  Map<String, int> reaksi,  Map<String, dynamic>? metadata, @JsonKey(name: 'dihapus', fromJson: _boolFromDynamic, toJson: _boolToDynamic)  bool dihapus, @JsonKey(name: 'diarsipkan_pada')  DateTime? diarsipkanPada)?  $default,) {final _that = this;
switch (_that) {
case _Pesan() when $default != null:
return $default(_that.id,_that.idPercakapan,_that.idPengirim,_that.teks,_that.dibuatPada,_that.dieditPada,_that.status,_that.lampiran,_that.balasanUntuk,_that.reaksi,_that.metadata,_that.dihapus,_that.diarsipkanPada);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Pesan implements Pesan {
  const _Pesan({required this.id, @JsonKey(name: 'id_percakapan') required this.idPercakapan, @JsonKey(name: 'id_pengirim') required this.idPengirim, this.teks, @JsonKey(name: 'dibuat_pada') required this.dibuatPada, @JsonKey(name: 'diedit_pada') this.dieditPada, @JsonKey(name: 'status', fromJson: _statusFromJson, toJson: _statusToJson) this.status = StatusPesan.terkirim, final  List<Lampiran> lampiran = const [], @JsonKey(name: 'balasan_untuk') this.balasanUntuk, final  Map<String, int> reaksi = const {}, final  Map<String, dynamic>? metadata, @JsonKey(name: 'dihapus', fromJson: _boolFromDynamic, toJson: _boolToDynamic) this.dihapus = false, @JsonKey(name: 'diarsipkan_pada') this.diarsipkanPada}): _lampiran = lampiran,_reaksi = reaksi,_metadata = metadata;
  factory _Pesan.fromJson(Map<String, dynamic> json) => _$PesanFromJson(json);

@override final  String id;
@override@JsonKey(name: 'id_percakapan') final  String idPercakapan;
@override@JsonKey(name: 'id_pengirim') final  String idPengirim;
@override final  String? teks;
@override@JsonKey(name: 'dibuat_pada') final  DateTime dibuatPada;
@override@JsonKey(name: 'diedit_pada') final  DateTime? dieditPada;
@override@JsonKey(name: 'status', fromJson: _statusFromJson, toJson: _statusToJson) final  StatusPesan status;
 final  List<Lampiran> _lampiran;
@override@JsonKey() List<Lampiran> get lampiran {
  if (_lampiran is EqualUnmodifiableListView) return _lampiran;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_lampiran);
}

@override@JsonKey(name: 'balasan_untuk') final  String? balasanUntuk;
 final  Map<String, int> _reaksi;
@override@JsonKey() Map<String, int> get reaksi {
  if (_reaksi is EqualUnmodifiableMapView) return _reaksi;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_reaksi);
}

 final  Map<String, dynamic>? _metadata;
@override Map<String, dynamic>? get metadata {
  final value = _metadata;
  if (value == null) return null;
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override@JsonKey(name: 'dihapus', fromJson: _boolFromDynamic, toJson: _boolToDynamic) final  bool dihapus;
@override@JsonKey(name: 'diarsipkan_pada') final  DateTime? diarsipkanPada;

/// Create a copy of Pesan
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PesanCopyWith<_Pesan> get copyWith => __$PesanCopyWithImpl<_Pesan>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PesanToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Pesan&&(identical(other.id, id) || other.id == id)&&(identical(other.idPercakapan, idPercakapan) || other.idPercakapan == idPercakapan)&&(identical(other.idPengirim, idPengirim) || other.idPengirim == idPengirim)&&(identical(other.teks, teks) || other.teks == teks)&&(identical(other.dibuatPada, dibuatPada) || other.dibuatPada == dibuatPada)&&(identical(other.dieditPada, dieditPada) || other.dieditPada == dieditPada)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other._lampiran, _lampiran)&&(identical(other.balasanUntuk, balasanUntuk) || other.balasanUntuk == balasanUntuk)&&const DeepCollectionEquality().equals(other._reaksi, _reaksi)&&const DeepCollectionEquality().equals(other._metadata, _metadata)&&(identical(other.dihapus, dihapus) || other.dihapus == dihapus)&&(identical(other.diarsipkanPada, diarsipkanPada) || other.diarsipkanPada == diarsipkanPada));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,idPercakapan,idPengirim,teks,dibuatPada,dieditPada,status,const DeepCollectionEquality().hash(_lampiran),balasanUntuk,const DeepCollectionEquality().hash(_reaksi),const DeepCollectionEquality().hash(_metadata),dihapus,diarsipkanPada);

@override
String toString() {
  return 'Pesan(id: $id, idPercakapan: $idPercakapan, idPengirim: $idPengirim, teks: $teks, dibuatPada: $dibuatPada, dieditPada: $dieditPada, status: $status, lampiran: $lampiran, balasanUntuk: $balasanUntuk, reaksi: $reaksi, metadata: $metadata, dihapus: $dihapus, diarsipkanPada: $diarsipkanPada)';
}


}

/// @nodoc
abstract mixin class _$PesanCopyWith<$Res> implements $PesanCopyWith<$Res> {
  factory _$PesanCopyWith(_Pesan value, $Res Function(_Pesan) _then) = __$PesanCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'id_percakapan') String idPercakapan,@JsonKey(name: 'id_pengirim') String idPengirim, String? teks,@JsonKey(name: 'dibuat_pada') DateTime dibuatPada,@JsonKey(name: 'diedit_pada') DateTime? dieditPada,@JsonKey(name: 'status', fromJson: _statusFromJson, toJson: _statusToJson) StatusPesan status, List<Lampiran> lampiran,@JsonKey(name: 'balasan_untuk') String? balasanUntuk, Map<String, int> reaksi, Map<String, dynamic>? metadata,@JsonKey(name: 'dihapus', fromJson: _boolFromDynamic, toJson: _boolToDynamic) bool dihapus,@JsonKey(name: 'diarsipkan_pada') DateTime? diarsipkanPada
});




}
/// @nodoc
class __$PesanCopyWithImpl<$Res>
    implements _$PesanCopyWith<$Res> {
  __$PesanCopyWithImpl(this._self, this._then);

  final _Pesan _self;
  final $Res Function(_Pesan) _then;

/// Create a copy of Pesan
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? idPercakapan = null,Object? idPengirim = null,Object? teks = freezed,Object? dibuatPada = null,Object? dieditPada = freezed,Object? status = null,Object? lampiran = null,Object? balasanUntuk = freezed,Object? reaksi = null,Object? metadata = freezed,Object? dihapus = null,Object? diarsipkanPada = freezed,}) {
  return _then(_Pesan(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,idPercakapan: null == idPercakapan ? _self.idPercakapan : idPercakapan // ignore: cast_nullable_to_non_nullable
as String,idPengirim: null == idPengirim ? _self.idPengirim : idPengirim // ignore: cast_nullable_to_non_nullable
as String,teks: freezed == teks ? _self.teks : teks // ignore: cast_nullable_to_non_nullable
as String?,dibuatPada: null == dibuatPada ? _self.dibuatPada : dibuatPada // ignore: cast_nullable_to_non_nullable
as DateTime,dieditPada: freezed == dieditPada ? _self.dieditPada : dieditPada // ignore: cast_nullable_to_non_nullable
as DateTime?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as StatusPesan,lampiran: null == lampiran ? _self._lampiran : lampiran // ignore: cast_nullable_to_non_nullable
as List<Lampiran>,balasanUntuk: freezed == balasanUntuk ? _self.balasanUntuk : balasanUntuk // ignore: cast_nullable_to_non_nullable
as String?,reaksi: null == reaksi ? _self._reaksi : reaksi // ignore: cast_nullable_to_non_nullable
as Map<String, int>,metadata: freezed == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,dihapus: null == dihapus ? _self.dihapus : dihapus // ignore: cast_nullable_to_non_nullable
as bool,diarsipkanPada: freezed == diarsipkanPada ? _self.diarsipkanPada : diarsipkanPada // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
