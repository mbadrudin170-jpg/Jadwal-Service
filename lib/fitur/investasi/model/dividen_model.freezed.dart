// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dividen_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DividenModel {

 String get id; String get idInvestasi; String get idInvestor; double get jumlahDividen; DateTime get tanggalPembagian; bool get sudahDibayar; bool get diHapus; DateTime? get diarsipkanPada; DateTime? get diperbaruiPada;
/// Create a copy of DividenModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DividenModelCopyWith<DividenModel> get copyWith => _$DividenModelCopyWithImpl<DividenModel>(this as DividenModel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DividenModel&&(identical(other.id, id) || other.id == id)&&(identical(other.idInvestasi, idInvestasi) || other.idInvestasi == idInvestasi)&&(identical(other.idInvestor, idInvestor) || other.idInvestor == idInvestor)&&(identical(other.jumlahDividen, jumlahDividen) || other.jumlahDividen == jumlahDividen)&&(identical(other.tanggalPembagian, tanggalPembagian) || other.tanggalPembagian == tanggalPembagian)&&(identical(other.sudahDibayar, sudahDibayar) || other.sudahDibayar == sudahDibayar)&&(identical(other.diHapus, diHapus) || other.diHapus == diHapus)&&(identical(other.diarsipkanPada, diarsipkanPada) || other.diarsipkanPada == diarsipkanPada)&&(identical(other.diperbaruiPada, diperbaruiPada) || other.diperbaruiPada == diperbaruiPada));
}


@override
int get hashCode => Object.hash(runtimeType,id,idInvestasi,idInvestor,jumlahDividen,tanggalPembagian,sudahDibayar,diHapus,diarsipkanPada,diperbaruiPada);

@override
String toString() {
  return 'DividenModel(id: $id, idInvestasi: $idInvestasi, idInvestor: $idInvestor, jumlahDividen: $jumlahDividen, tanggalPembagian: $tanggalPembagian, sudahDibayar: $sudahDibayar, diHapus: $diHapus, diarsipkanPada: $diarsipkanPada, diperbaruiPada: $diperbaruiPada)';
}


}

/// @nodoc
abstract mixin class $DividenModelCopyWith<$Res>  {
  factory $DividenModelCopyWith(DividenModel value, $Res Function(DividenModel) _then) = _$DividenModelCopyWithImpl;
@useResult
$Res call({
 String id, String idInvestasi, String idInvestor, double jumlahDividen, DateTime tanggalPembagian, bool sudahDibayar, bool diHapus, DateTime? diarsipkanPada, DateTime? diperbaruiPada
});




}
/// @nodoc
class _$DividenModelCopyWithImpl<$Res>
    implements $DividenModelCopyWith<$Res> {
  _$DividenModelCopyWithImpl(this._self, this._then);

  final DividenModel _self;
  final $Res Function(DividenModel) _then;

/// Create a copy of DividenModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? idInvestasi = null,Object? idInvestor = null,Object? jumlahDividen = null,Object? tanggalPembagian = null,Object? sudahDibayar = null,Object? diHapus = null,Object? diarsipkanPada = freezed,Object? diperbaruiPada = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,idInvestasi: null == idInvestasi ? _self.idInvestasi : idInvestasi // ignore: cast_nullable_to_non_nullable
as String,idInvestor: null == idInvestor ? _self.idInvestor : idInvestor // ignore: cast_nullable_to_non_nullable
as String,jumlahDividen: null == jumlahDividen ? _self.jumlahDividen : jumlahDividen // ignore: cast_nullable_to_non_nullable
as double,tanggalPembagian: null == tanggalPembagian ? _self.tanggalPembagian : tanggalPembagian // ignore: cast_nullable_to_non_nullable
as DateTime,sudahDibayar: null == sudahDibayar ? _self.sudahDibayar : sudahDibayar // ignore: cast_nullable_to_non_nullable
as bool,diHapus: null == diHapus ? _self.diHapus : diHapus // ignore: cast_nullable_to_non_nullable
as bool,diarsipkanPada: freezed == diarsipkanPada ? _self.diarsipkanPada : diarsipkanPada // ignore: cast_nullable_to_non_nullable
as DateTime?,diperbaruiPada: freezed == diperbaruiPada ? _self.diperbaruiPada : diperbaruiPada // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [DividenModel].
extension DividenModelPatterns on DividenModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DividenModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DividenModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DividenModel value)  $default,){
final _that = this;
switch (_that) {
case _DividenModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DividenModel value)?  $default,){
final _that = this;
switch (_that) {
case _DividenModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String idInvestasi,  String idInvestor,  double jumlahDividen,  DateTime tanggalPembagian,  bool sudahDibayar,  bool diHapus,  DateTime? diarsipkanPada,  DateTime? diperbaruiPada)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DividenModel() when $default != null:
return $default(_that.id,_that.idInvestasi,_that.idInvestor,_that.jumlahDividen,_that.tanggalPembagian,_that.sudahDibayar,_that.diHapus,_that.diarsipkanPada,_that.diperbaruiPada);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String idInvestasi,  String idInvestor,  double jumlahDividen,  DateTime tanggalPembagian,  bool sudahDibayar,  bool diHapus,  DateTime? diarsipkanPada,  DateTime? diperbaruiPada)  $default,) {final _that = this;
switch (_that) {
case _DividenModel():
return $default(_that.id,_that.idInvestasi,_that.idInvestor,_that.jumlahDividen,_that.tanggalPembagian,_that.sudahDibayar,_that.diHapus,_that.diarsipkanPada,_that.diperbaruiPada);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String idInvestasi,  String idInvestor,  double jumlahDividen,  DateTime tanggalPembagian,  bool sudahDibayar,  bool diHapus,  DateTime? diarsipkanPada,  DateTime? diperbaruiPada)?  $default,) {final _that = this;
switch (_that) {
case _DividenModel() when $default != null:
return $default(_that.id,_that.idInvestasi,_that.idInvestor,_that.jumlahDividen,_that.tanggalPembagian,_that.sudahDibayar,_that.diHapus,_that.diarsipkanPada,_that.diperbaruiPada);case _:
  return null;

}
}

}

/// @nodoc


class _DividenModel extends DividenModel {
  const _DividenModel({required this.id, required this.idInvestasi, required this.idInvestor, required this.jumlahDividen, required this.tanggalPembagian, required this.sudahDibayar, this.diHapus = false, this.diarsipkanPada, this.diperbaruiPada}): super._();
  

@override final  String id;
@override final  String idInvestasi;
@override final  String idInvestor;
@override final  double jumlahDividen;
@override final  DateTime tanggalPembagian;
@override final  bool sudahDibayar;
@override@JsonKey() final  bool diHapus;
@override final  DateTime? diarsipkanPada;
@override final  DateTime? diperbaruiPada;

/// Create a copy of DividenModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DividenModelCopyWith<_DividenModel> get copyWith => __$DividenModelCopyWithImpl<_DividenModel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DividenModel&&(identical(other.id, id) || other.id == id)&&(identical(other.idInvestasi, idInvestasi) || other.idInvestasi == idInvestasi)&&(identical(other.idInvestor, idInvestor) || other.idInvestor == idInvestor)&&(identical(other.jumlahDividen, jumlahDividen) || other.jumlahDividen == jumlahDividen)&&(identical(other.tanggalPembagian, tanggalPembagian) || other.tanggalPembagian == tanggalPembagian)&&(identical(other.sudahDibayar, sudahDibayar) || other.sudahDibayar == sudahDibayar)&&(identical(other.diHapus, diHapus) || other.diHapus == diHapus)&&(identical(other.diarsipkanPada, diarsipkanPada) || other.diarsipkanPada == diarsipkanPada)&&(identical(other.diperbaruiPada, diperbaruiPada) || other.diperbaruiPada == diperbaruiPada));
}


@override
int get hashCode => Object.hash(runtimeType,id,idInvestasi,idInvestor,jumlahDividen,tanggalPembagian,sudahDibayar,diHapus,diarsipkanPada,diperbaruiPada);

@override
String toString() {
  return 'DividenModel(id: $id, idInvestasi: $idInvestasi, idInvestor: $idInvestor, jumlahDividen: $jumlahDividen, tanggalPembagian: $tanggalPembagian, sudahDibayar: $sudahDibayar, diHapus: $diHapus, diarsipkanPada: $diarsipkanPada, diperbaruiPada: $diperbaruiPada)';
}


}

/// @nodoc
abstract mixin class _$DividenModelCopyWith<$Res> implements $DividenModelCopyWith<$Res> {
  factory _$DividenModelCopyWith(_DividenModel value, $Res Function(_DividenModel) _then) = __$DividenModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String idInvestasi, String idInvestor, double jumlahDividen, DateTime tanggalPembagian, bool sudahDibayar, bool diHapus, DateTime? diarsipkanPada, DateTime? diperbaruiPada
});




}
/// @nodoc
class __$DividenModelCopyWithImpl<$Res>
    implements _$DividenModelCopyWith<$Res> {
  __$DividenModelCopyWithImpl(this._self, this._then);

  final _DividenModel _self;
  final $Res Function(_DividenModel) _then;

/// Create a copy of DividenModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? idInvestasi = null,Object? idInvestor = null,Object? jumlahDividen = null,Object? tanggalPembagian = null,Object? sudahDibayar = null,Object? diHapus = null,Object? diarsipkanPada = freezed,Object? diperbaruiPada = freezed,}) {
  return _then(_DividenModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,idInvestasi: null == idInvestasi ? _self.idInvestasi : idInvestasi // ignore: cast_nullable_to_non_nullable
as String,idInvestor: null == idInvestor ? _self.idInvestor : idInvestor // ignore: cast_nullable_to_non_nullable
as String,jumlahDividen: null == jumlahDividen ? _self.jumlahDividen : jumlahDividen // ignore: cast_nullable_to_non_nullable
as double,tanggalPembagian: null == tanggalPembagian ? _self.tanggalPembagian : tanggalPembagian // ignore: cast_nullable_to_non_nullable
as DateTime,sudahDibayar: null == sudahDibayar ? _self.sudahDibayar : sudahDibayar // ignore: cast_nullable_to_non_nullable
as bool,diHapus: null == diHapus ? _self.diHapus : diHapus // ignore: cast_nullable_to_non_nullable
as bool,diarsipkanPada: freezed == diarsipkanPada ? _self.diarsipkanPada : diarsipkanPada // ignore: cast_nullable_to_non_nullable
as DateTime?,diperbaruiPada: freezed == diperbaruiPada ? _self.diperbaruiPada : diperbaruiPada // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
