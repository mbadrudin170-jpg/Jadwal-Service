// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pelanggan_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PelangganModel {

 String get id; String get nama; String get telepon; String get alamat; String get kataSandi; String get macAddress; AppRole get role; DateTime? get diperbaruiPada; bool get diHapus; DateTime? get diarsipkanPada; DateTime? get terkahirAktif;
/// Create a copy of PelangganModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PelangganModelCopyWith<PelangganModel> get copyWith => _$PelangganModelCopyWithImpl<PelangganModel>(this as PelangganModel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PelangganModel&&(identical(other.id, id) || other.id == id)&&(identical(other.nama, nama) || other.nama == nama)&&(identical(other.telepon, telepon) || other.telepon == telepon)&&(identical(other.alamat, alamat) || other.alamat == alamat)&&(identical(other.kataSandi, kataSandi) || other.kataSandi == kataSandi)&&(identical(other.macAddress, macAddress) || other.macAddress == macAddress)&&(identical(other.role, role) || other.role == role)&&(identical(other.diperbaruiPada, diperbaruiPada) || other.diperbaruiPada == diperbaruiPada)&&(identical(other.diHapus, diHapus) || other.diHapus == diHapus)&&(identical(other.diarsipkanPada, diarsipkanPada) || other.diarsipkanPada == diarsipkanPada)&&(identical(other.terkahirAktif, terkahirAktif) || other.terkahirAktif == terkahirAktif));
}


@override
int get hashCode => Object.hash(runtimeType,id,nama,telepon,alamat,kataSandi,macAddress,role,diperbaruiPada,diHapus,diarsipkanPada,terkahirAktif);

@override
String toString() {
  return 'PelangganModel(id: $id, nama: $nama, telepon: $telepon, alamat: $alamat, kataSandi: $kataSandi, macAddress: $macAddress, role: $role, diperbaruiPada: $diperbaruiPada, diHapus: $diHapus, diarsipkanPada: $diarsipkanPada, terkahirAktif: $terkahirAktif)';
}


}

/// @nodoc
abstract mixin class $PelangganModelCopyWith<$Res>  {
  factory $PelangganModelCopyWith(PelangganModel value, $Res Function(PelangganModel) _then) = _$PelangganModelCopyWithImpl;
@useResult
$Res call({
 String id, String nama, String telepon, String alamat, String kataSandi, String macAddress, AppRole role, DateTime? diperbaruiPada, bool diHapus, DateTime? diarsipkanPada, DateTime? terkahirAktif
});




}
/// @nodoc
class _$PelangganModelCopyWithImpl<$Res>
    implements $PelangganModelCopyWith<$Res> {
  _$PelangganModelCopyWithImpl(this._self, this._then);

  final PelangganModel _self;
  final $Res Function(PelangganModel) _then;

/// Create a copy of PelangganModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? nama = null,Object? telepon = null,Object? alamat = null,Object? kataSandi = null,Object? macAddress = null,Object? role = null,Object? diperbaruiPada = freezed,Object? diHapus = null,Object? diarsipkanPada = freezed,Object? terkahirAktif = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,nama: null == nama ? _self.nama : nama // ignore: cast_nullable_to_non_nullable
as String,telepon: null == telepon ? _self.telepon : telepon // ignore: cast_nullable_to_non_nullable
as String,alamat: null == alamat ? _self.alamat : alamat // ignore: cast_nullable_to_non_nullable
as String,kataSandi: null == kataSandi ? _self.kataSandi : kataSandi // ignore: cast_nullable_to_non_nullable
as String,macAddress: null == macAddress ? _self.macAddress : macAddress // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as AppRole,diperbaruiPada: freezed == diperbaruiPada ? _self.diperbaruiPada : diperbaruiPada // ignore: cast_nullable_to_non_nullable
as DateTime?,diHapus: null == diHapus ? _self.diHapus : diHapus // ignore: cast_nullable_to_non_nullable
as bool,diarsipkanPada: freezed == diarsipkanPada ? _self.diarsipkanPada : diarsipkanPada // ignore: cast_nullable_to_non_nullable
as DateTime?,terkahirAktif: freezed == terkahirAktif ? _self.terkahirAktif : terkahirAktif // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [PelangganModel].
extension PelangganModelPatterns on PelangganModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PelangganModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PelangganModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PelangganModel value)  $default,){
final _that = this;
switch (_that) {
case _PelangganModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PelangganModel value)?  $default,){
final _that = this;
switch (_that) {
case _PelangganModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String nama,  String telepon,  String alamat,  String kataSandi,  String macAddress,  AppRole role,  DateTime? diperbaruiPada,  bool diHapus,  DateTime? diarsipkanPada,  DateTime? terkahirAktif)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PelangganModel() when $default != null:
return $default(_that.id,_that.nama,_that.telepon,_that.alamat,_that.kataSandi,_that.macAddress,_that.role,_that.diperbaruiPada,_that.diHapus,_that.diarsipkanPada,_that.terkahirAktif);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String nama,  String telepon,  String alamat,  String kataSandi,  String macAddress,  AppRole role,  DateTime? diperbaruiPada,  bool diHapus,  DateTime? diarsipkanPada,  DateTime? terkahirAktif)  $default,) {final _that = this;
switch (_that) {
case _PelangganModel():
return $default(_that.id,_that.nama,_that.telepon,_that.alamat,_that.kataSandi,_that.macAddress,_that.role,_that.diperbaruiPada,_that.diHapus,_that.diarsipkanPada,_that.terkahirAktif);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String nama,  String telepon,  String alamat,  String kataSandi,  String macAddress,  AppRole role,  DateTime? diperbaruiPada,  bool diHapus,  DateTime? diarsipkanPada,  DateTime? terkahirAktif)?  $default,) {final _that = this;
switch (_that) {
case _PelangganModel() when $default != null:
return $default(_that.id,_that.nama,_that.telepon,_that.alamat,_that.kataSandi,_that.macAddress,_that.role,_that.diperbaruiPada,_that.diHapus,_that.diarsipkanPada,_that.terkahirAktif);case _:
  return null;

}
}

}

/// @nodoc


class _PelangganModel extends PelangganModel {
  const _PelangganModel({required this.id, required this.nama, required this.telepon, required this.alamat, required this.kataSandi, required this.macAddress, this.role = AppRole.user, this.diperbaruiPada, this.diHapus = false, this.diarsipkanPada, this.terkahirAktif}): super._();
  

@override final  String id;
@override final  String nama;
@override final  String telepon;
@override final  String alamat;
@override final  String kataSandi;
@override final  String macAddress;
@override@JsonKey() final  AppRole role;
@override final  DateTime? diperbaruiPada;
@override@JsonKey() final  bool diHapus;
@override final  DateTime? diarsipkanPada;
@override final  DateTime? terkahirAktif;

/// Create a copy of PelangganModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PelangganModelCopyWith<_PelangganModel> get copyWith => __$PelangganModelCopyWithImpl<_PelangganModel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PelangganModel&&(identical(other.id, id) || other.id == id)&&(identical(other.nama, nama) || other.nama == nama)&&(identical(other.telepon, telepon) || other.telepon == telepon)&&(identical(other.alamat, alamat) || other.alamat == alamat)&&(identical(other.kataSandi, kataSandi) || other.kataSandi == kataSandi)&&(identical(other.macAddress, macAddress) || other.macAddress == macAddress)&&(identical(other.role, role) || other.role == role)&&(identical(other.diperbaruiPada, diperbaruiPada) || other.diperbaruiPada == diperbaruiPada)&&(identical(other.diHapus, diHapus) || other.diHapus == diHapus)&&(identical(other.diarsipkanPada, diarsipkanPada) || other.diarsipkanPada == diarsipkanPada)&&(identical(other.terkahirAktif, terkahirAktif) || other.terkahirAktif == terkahirAktif));
}


@override
int get hashCode => Object.hash(runtimeType,id,nama,telepon,alamat,kataSandi,macAddress,role,diperbaruiPada,diHapus,diarsipkanPada,terkahirAktif);

@override
String toString() {
  return 'PelangganModel(id: $id, nama: $nama, telepon: $telepon, alamat: $alamat, kataSandi: $kataSandi, macAddress: $macAddress, role: $role, diperbaruiPada: $diperbaruiPada, diHapus: $diHapus, diarsipkanPada: $diarsipkanPada, terkahirAktif: $terkahirAktif)';
}


}

/// @nodoc
abstract mixin class _$PelangganModelCopyWith<$Res> implements $PelangganModelCopyWith<$Res> {
  factory _$PelangganModelCopyWith(_PelangganModel value, $Res Function(_PelangganModel) _then) = __$PelangganModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String nama, String telepon, String alamat, String kataSandi, String macAddress, AppRole role, DateTime? diperbaruiPada, bool diHapus, DateTime? diarsipkanPada, DateTime? terkahirAktif
});




}
/// @nodoc
class __$PelangganModelCopyWithImpl<$Res>
    implements _$PelangganModelCopyWith<$Res> {
  __$PelangganModelCopyWithImpl(this._self, this._then);

  final _PelangganModel _self;
  final $Res Function(_PelangganModel) _then;

/// Create a copy of PelangganModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? nama = null,Object? telepon = null,Object? alamat = null,Object? kataSandi = null,Object? macAddress = null,Object? role = null,Object? diperbaruiPada = freezed,Object? diHapus = null,Object? diarsipkanPada = freezed,Object? terkahirAktif = freezed,}) {
  return _then(_PelangganModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,nama: null == nama ? _self.nama : nama // ignore: cast_nullable_to_non_nullable
as String,telepon: null == telepon ? _self.telepon : telepon // ignore: cast_nullable_to_non_nullable
as String,alamat: null == alamat ? _self.alamat : alamat // ignore: cast_nullable_to_non_nullable
as String,kataSandi: null == kataSandi ? _self.kataSandi : kataSandi // ignore: cast_nullable_to_non_nullable
as String,macAddress: null == macAddress ? _self.macAddress : macAddress // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as AppRole,diperbaruiPada: freezed == diperbaruiPada ? _self.diperbaruiPada : diperbaruiPada // ignore: cast_nullable_to_non_nullable
as DateTime?,diHapus: null == diHapus ? _self.diHapus : diHapus // ignore: cast_nullable_to_non_nullable
as bool,diarsipkanPada: freezed == diarsipkanPada ? _self.diarsipkanPada : diarsipkanPada // ignore: cast_nullable_to_non_nullable
as DateTime?,terkahirAktif: freezed == terkahirAktif ? _self.terkahirAktif : terkahirAktif // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
