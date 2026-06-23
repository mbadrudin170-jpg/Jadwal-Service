// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notifikasi_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$NotifikasiModel {

 String get id; DateTime get tanggalMulai; DateTime get tanggalBerakhir; DateTime get tanggalTampil; String get judul; String get deskripsi; bool get setatusDibaca; TipeNotifikasiEnum get tipe; DateTime? get diperbaruiPada; String get idTujuan; String get userId; bool get dihapus; DateTime? get diarsipkanPada; AppRole get targetRole;
/// Create a copy of NotifikasiModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NotifikasiModelCopyWith<NotifikasiModel> get copyWith => _$NotifikasiModelCopyWithImpl<NotifikasiModel>(this as NotifikasiModel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotifikasiModel&&(identical(other.id, id) || other.id == id)&&(identical(other.tanggalMulai, tanggalMulai) || other.tanggalMulai == tanggalMulai)&&(identical(other.tanggalBerakhir, tanggalBerakhir) || other.tanggalBerakhir == tanggalBerakhir)&&(identical(other.tanggalTampil, tanggalTampil) || other.tanggalTampil == tanggalTampil)&&(identical(other.judul, judul) || other.judul == judul)&&(identical(other.deskripsi, deskripsi) || other.deskripsi == deskripsi)&&(identical(other.setatusDibaca, setatusDibaca) || other.setatusDibaca == setatusDibaca)&&(identical(other.tipe, tipe) || other.tipe == tipe)&&(identical(other.diperbaruiPada, diperbaruiPada) || other.diperbaruiPada == diperbaruiPada)&&(identical(other.idTujuan, idTujuan) || other.idTujuan == idTujuan)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.dihapus, dihapus) || other.dihapus == dihapus)&&(identical(other.diarsipkanPada, diarsipkanPada) || other.diarsipkanPada == diarsipkanPada)&&(identical(other.targetRole, targetRole) || other.targetRole == targetRole));
}


@override
int get hashCode => Object.hash(runtimeType,id,tanggalMulai,tanggalBerakhir,tanggalTampil,judul,deskripsi,setatusDibaca,tipe,diperbaruiPada,idTujuan,userId,dihapus,diarsipkanPada,targetRole);

@override
String toString() {
  return 'NotifikasiModel(id: $id, tanggalMulai: $tanggalMulai, tanggalBerakhir: $tanggalBerakhir, tanggalTampil: $tanggalTampil, judul: $judul, deskripsi: $deskripsi, setatusDibaca: $setatusDibaca, tipe: $tipe, diperbaruiPada: $diperbaruiPada, idTujuan: $idTujuan, userId: $userId, dihapus: $dihapus, diarsipkanPada: $diarsipkanPada, targetRole: $targetRole)';
}


}

/// @nodoc
abstract mixin class $NotifikasiModelCopyWith<$Res>  {
  factory $NotifikasiModelCopyWith(NotifikasiModel value, $Res Function(NotifikasiModel) _then) = _$NotifikasiModelCopyWithImpl;
@useResult
$Res call({
 String id, DateTime tanggalMulai, DateTime tanggalBerakhir, DateTime tanggalTampil, String judul, String deskripsi, bool setatusDibaca, TipeNotifikasiEnum tipe, DateTime? diperbaruiPada, String idTujuan, String userId, bool dihapus, DateTime? diarsipkanPada, AppRole targetRole
});




}
/// @nodoc
class _$NotifikasiModelCopyWithImpl<$Res>
    implements $NotifikasiModelCopyWith<$Res> {
  _$NotifikasiModelCopyWithImpl(this._self, this._then);

  final NotifikasiModel _self;
  final $Res Function(NotifikasiModel) _then;

/// Create a copy of NotifikasiModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? tanggalMulai = null,Object? tanggalBerakhir = null,Object? tanggalTampil = null,Object? judul = null,Object? deskripsi = null,Object? setatusDibaca = null,Object? tipe = null,Object? diperbaruiPada = freezed,Object? idTujuan = null,Object? userId = null,Object? dihapus = null,Object? diarsipkanPada = freezed,Object? targetRole = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,tanggalMulai: null == tanggalMulai ? _self.tanggalMulai : tanggalMulai // ignore: cast_nullable_to_non_nullable
as DateTime,tanggalBerakhir: null == tanggalBerakhir ? _self.tanggalBerakhir : tanggalBerakhir // ignore: cast_nullable_to_non_nullable
as DateTime,tanggalTampil: null == tanggalTampil ? _self.tanggalTampil : tanggalTampil // ignore: cast_nullable_to_non_nullable
as DateTime,judul: null == judul ? _self.judul : judul // ignore: cast_nullable_to_non_nullable
as String,deskripsi: null == deskripsi ? _self.deskripsi : deskripsi // ignore: cast_nullable_to_non_nullable
as String,setatusDibaca: null == setatusDibaca ? _self.setatusDibaca : setatusDibaca // ignore: cast_nullable_to_non_nullable
as bool,tipe: null == tipe ? _self.tipe : tipe // ignore: cast_nullable_to_non_nullable
as TipeNotifikasiEnum,diperbaruiPada: freezed == diperbaruiPada ? _self.diperbaruiPada : diperbaruiPada // ignore: cast_nullable_to_non_nullable
as DateTime?,idTujuan: null == idTujuan ? _self.idTujuan : idTujuan // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,dihapus: null == dihapus ? _self.dihapus : dihapus // ignore: cast_nullable_to_non_nullable
as bool,diarsipkanPada: freezed == diarsipkanPada ? _self.diarsipkanPada : diarsipkanPada // ignore: cast_nullable_to_non_nullable
as DateTime?,targetRole: null == targetRole ? _self.targetRole : targetRole // ignore: cast_nullable_to_non_nullable
as AppRole,
  ));
}

}


/// Adds pattern-matching-related methods to [NotifikasiModel].
extension NotifikasiModelPatterns on NotifikasiModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NotifikasiModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NotifikasiModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NotifikasiModel value)  $default,){
final _that = this;
switch (_that) {
case _NotifikasiModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NotifikasiModel value)?  $default,){
final _that = this;
switch (_that) {
case _NotifikasiModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  DateTime tanggalMulai,  DateTime tanggalBerakhir,  DateTime tanggalTampil,  String judul,  String deskripsi,  bool setatusDibaca,  TipeNotifikasiEnum tipe,  DateTime? diperbaruiPada,  String idTujuan,  String userId,  bool dihapus,  DateTime? diarsipkanPada,  AppRole targetRole)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NotifikasiModel() when $default != null:
return $default(_that.id,_that.tanggalMulai,_that.tanggalBerakhir,_that.tanggalTampil,_that.judul,_that.deskripsi,_that.setatusDibaca,_that.tipe,_that.diperbaruiPada,_that.idTujuan,_that.userId,_that.dihapus,_that.diarsipkanPada,_that.targetRole);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  DateTime tanggalMulai,  DateTime tanggalBerakhir,  DateTime tanggalTampil,  String judul,  String deskripsi,  bool setatusDibaca,  TipeNotifikasiEnum tipe,  DateTime? diperbaruiPada,  String idTujuan,  String userId,  bool dihapus,  DateTime? diarsipkanPada,  AppRole targetRole)  $default,) {final _that = this;
switch (_that) {
case _NotifikasiModel():
return $default(_that.id,_that.tanggalMulai,_that.tanggalBerakhir,_that.tanggalTampil,_that.judul,_that.deskripsi,_that.setatusDibaca,_that.tipe,_that.diperbaruiPada,_that.idTujuan,_that.userId,_that.dihapus,_that.diarsipkanPada,_that.targetRole);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  DateTime tanggalMulai,  DateTime tanggalBerakhir,  DateTime tanggalTampil,  String judul,  String deskripsi,  bool setatusDibaca,  TipeNotifikasiEnum tipe,  DateTime? diperbaruiPada,  String idTujuan,  String userId,  bool dihapus,  DateTime? diarsipkanPada,  AppRole targetRole)?  $default,) {final _that = this;
switch (_that) {
case _NotifikasiModel() when $default != null:
return $default(_that.id,_that.tanggalMulai,_that.tanggalBerakhir,_that.tanggalTampil,_that.judul,_that.deskripsi,_that.setatusDibaca,_that.tipe,_that.diperbaruiPada,_that.idTujuan,_that.userId,_that.dihapus,_that.diarsipkanPada,_that.targetRole);case _:
  return null;

}
}

}

/// @nodoc


class _NotifikasiModel extends NotifikasiModel {
  const _NotifikasiModel({required this.id, required this.tanggalMulai, required this.tanggalBerakhir, required this.tanggalTampil, required this.judul, required this.deskripsi, this.setatusDibaca = false, required this.tipe, this.diperbaruiPada, required this.idTujuan, required this.userId, this.dihapus = false, this.diarsipkanPada, required this.targetRole}): super._();
  

@override final  String id;
@override final  DateTime tanggalMulai;
@override final  DateTime tanggalBerakhir;
@override final  DateTime tanggalTampil;
@override final  String judul;
@override final  String deskripsi;
@override@JsonKey() final  bool setatusDibaca;
@override final  TipeNotifikasiEnum tipe;
@override final  DateTime? diperbaruiPada;
@override final  String idTujuan;
@override final  String userId;
@override@JsonKey() final  bool dihapus;
@override final  DateTime? diarsipkanPada;
@override final  AppRole targetRole;

/// Create a copy of NotifikasiModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NotifikasiModelCopyWith<_NotifikasiModel> get copyWith => __$NotifikasiModelCopyWithImpl<_NotifikasiModel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NotifikasiModel&&(identical(other.id, id) || other.id == id)&&(identical(other.tanggalMulai, tanggalMulai) || other.tanggalMulai == tanggalMulai)&&(identical(other.tanggalBerakhir, tanggalBerakhir) || other.tanggalBerakhir == tanggalBerakhir)&&(identical(other.tanggalTampil, tanggalTampil) || other.tanggalTampil == tanggalTampil)&&(identical(other.judul, judul) || other.judul == judul)&&(identical(other.deskripsi, deskripsi) || other.deskripsi == deskripsi)&&(identical(other.setatusDibaca, setatusDibaca) || other.setatusDibaca == setatusDibaca)&&(identical(other.tipe, tipe) || other.tipe == tipe)&&(identical(other.diperbaruiPada, diperbaruiPada) || other.diperbaruiPada == diperbaruiPada)&&(identical(other.idTujuan, idTujuan) || other.idTujuan == idTujuan)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.dihapus, dihapus) || other.dihapus == dihapus)&&(identical(other.diarsipkanPada, diarsipkanPada) || other.diarsipkanPada == diarsipkanPada)&&(identical(other.targetRole, targetRole) || other.targetRole == targetRole));
}


@override
int get hashCode => Object.hash(runtimeType,id,tanggalMulai,tanggalBerakhir,tanggalTampil,judul,deskripsi,setatusDibaca,tipe,diperbaruiPada,idTujuan,userId,dihapus,diarsipkanPada,targetRole);

@override
String toString() {
  return 'NotifikasiModel(id: $id, tanggalMulai: $tanggalMulai, tanggalBerakhir: $tanggalBerakhir, tanggalTampil: $tanggalTampil, judul: $judul, deskripsi: $deskripsi, setatusDibaca: $setatusDibaca, tipe: $tipe, diperbaruiPada: $diperbaruiPada, idTujuan: $idTujuan, userId: $userId, dihapus: $dihapus, diarsipkanPada: $diarsipkanPada, targetRole: $targetRole)';
}


}

/// @nodoc
abstract mixin class _$NotifikasiModelCopyWith<$Res> implements $NotifikasiModelCopyWith<$Res> {
  factory _$NotifikasiModelCopyWith(_NotifikasiModel value, $Res Function(_NotifikasiModel) _then) = __$NotifikasiModelCopyWithImpl;
@override @useResult
$Res call({
 String id, DateTime tanggalMulai, DateTime tanggalBerakhir, DateTime tanggalTampil, String judul, String deskripsi, bool setatusDibaca, TipeNotifikasiEnum tipe, DateTime? diperbaruiPada, String idTujuan, String userId, bool dihapus, DateTime? diarsipkanPada, AppRole targetRole
});




}
/// @nodoc
class __$NotifikasiModelCopyWithImpl<$Res>
    implements _$NotifikasiModelCopyWith<$Res> {
  __$NotifikasiModelCopyWithImpl(this._self, this._then);

  final _NotifikasiModel _self;
  final $Res Function(_NotifikasiModel) _then;

/// Create a copy of NotifikasiModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? tanggalMulai = null,Object? tanggalBerakhir = null,Object? tanggalTampil = null,Object? judul = null,Object? deskripsi = null,Object? setatusDibaca = null,Object? tipe = null,Object? diperbaruiPada = freezed,Object? idTujuan = null,Object? userId = null,Object? dihapus = null,Object? diarsipkanPada = freezed,Object? targetRole = null,}) {
  return _then(_NotifikasiModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,tanggalMulai: null == tanggalMulai ? _self.tanggalMulai : tanggalMulai // ignore: cast_nullable_to_non_nullable
as DateTime,tanggalBerakhir: null == tanggalBerakhir ? _self.tanggalBerakhir : tanggalBerakhir // ignore: cast_nullable_to_non_nullable
as DateTime,tanggalTampil: null == tanggalTampil ? _self.tanggalTampil : tanggalTampil // ignore: cast_nullable_to_non_nullable
as DateTime,judul: null == judul ? _self.judul : judul // ignore: cast_nullable_to_non_nullable
as String,deskripsi: null == deskripsi ? _self.deskripsi : deskripsi // ignore: cast_nullable_to_non_nullable
as String,setatusDibaca: null == setatusDibaca ? _self.setatusDibaca : setatusDibaca // ignore: cast_nullable_to_non_nullable
as bool,tipe: null == tipe ? _self.tipe : tipe // ignore: cast_nullable_to_non_nullable
as TipeNotifikasiEnum,diperbaruiPada: freezed == diperbaruiPada ? _self.diperbaruiPada : diperbaruiPada // ignore: cast_nullable_to_non_nullable
as DateTime?,idTujuan: null == idTujuan ? _self.idTujuan : idTujuan // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,dihapus: null == dihapus ? _self.dihapus : dihapus // ignore: cast_nullable_to_non_nullable
as bool,diarsipkanPada: freezed == diarsipkanPada ? _self.diarsipkanPada : diarsipkanPada // ignore: cast_nullable_to_non_nullable
as DateTime?,targetRole: null == targetRole ? _self.targetRole : targetRole // ignore: cast_nullable_to_non_nullable
as AppRole,
  ));
}


}

// dart format on
