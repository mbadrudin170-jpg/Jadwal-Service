// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'voucher_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$VoucherModel {

 String get id; String get voucher; String get idPaket; String get tipeVoucher; bool get terpakai; bool get dihapus; DateTime? get diperbaruiPada; DateTime? get diarsipkanPada;
/// Create a copy of VoucherModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VoucherModelCopyWith<VoucherModel> get copyWith => _$VoucherModelCopyWithImpl<VoucherModel>(this as VoucherModel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VoucherModel&&(identical(other.id, id) || other.id == id)&&(identical(other.voucher, voucher) || other.voucher == voucher)&&(identical(other.idPaket, idPaket) || other.idPaket == idPaket)&&(identical(other.tipeVoucher, tipeVoucher) || other.tipeVoucher == tipeVoucher)&&(identical(other.terpakai, terpakai) || other.terpakai == terpakai)&&(identical(other.dihapus, dihapus) || other.dihapus == dihapus)&&(identical(other.diperbaruiPada, diperbaruiPada) || other.diperbaruiPada == diperbaruiPada)&&(identical(other.diarsipkanPada, diarsipkanPada) || other.diarsipkanPada == diarsipkanPada));
}


@override
int get hashCode => Object.hash(runtimeType,id,voucher,idPaket,tipeVoucher,terpakai,dihapus,diperbaruiPada,diarsipkanPada);

@override
String toString() {
  return 'VoucherModel(id: $id, voucher: $voucher, idPaket: $idPaket, tipeVoucher: $tipeVoucher, terpakai: $terpakai, dihapus: $dihapus, diperbaruiPada: $diperbaruiPada, diarsipkanPada: $diarsipkanPada)';
}


}

/// @nodoc
abstract mixin class $VoucherModelCopyWith<$Res>  {
  factory $VoucherModelCopyWith(VoucherModel value, $Res Function(VoucherModel) _then) = _$VoucherModelCopyWithImpl;
@useResult
$Res call({
 String id, String voucher, String idPaket, String tipeVoucher, bool terpakai, bool dihapus, DateTime? diperbaruiPada, DateTime? diarsipkanPada
});




}
/// @nodoc
class _$VoucherModelCopyWithImpl<$Res>
    implements $VoucherModelCopyWith<$Res> {
  _$VoucherModelCopyWithImpl(this._self, this._then);

  final VoucherModel _self;
  final $Res Function(VoucherModel) _then;

/// Create a copy of VoucherModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? voucher = null,Object? idPaket = null,Object? tipeVoucher = null,Object? terpakai = null,Object? dihapus = null,Object? diperbaruiPada = freezed,Object? diarsipkanPada = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,voucher: null == voucher ? _self.voucher : voucher // ignore: cast_nullable_to_non_nullable
as String,idPaket: null == idPaket ? _self.idPaket : idPaket // ignore: cast_nullable_to_non_nullable
as String,tipeVoucher: null == tipeVoucher ? _self.tipeVoucher : tipeVoucher // ignore: cast_nullable_to_non_nullable
as String,terpakai: null == terpakai ? _self.terpakai : terpakai // ignore: cast_nullable_to_non_nullable
as bool,dihapus: null == dihapus ? _self.dihapus : dihapus // ignore: cast_nullable_to_non_nullable
as bool,diperbaruiPada: freezed == diperbaruiPada ? _self.diperbaruiPada : diperbaruiPada // ignore: cast_nullable_to_non_nullable
as DateTime?,diarsipkanPada: freezed == diarsipkanPada ? _self.diarsipkanPada : diarsipkanPada // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [VoucherModel].
extension VoucherModelPatterns on VoucherModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VoucherModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VoucherModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VoucherModel value)  $default,){
final _that = this;
switch (_that) {
case _VoucherModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VoucherModel value)?  $default,){
final _that = this;
switch (_that) {
case _VoucherModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String voucher,  String idPaket,  String tipeVoucher,  bool terpakai,  bool dihapus,  DateTime? diperbaruiPada,  DateTime? diarsipkanPada)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VoucherModel() when $default != null:
return $default(_that.id,_that.voucher,_that.idPaket,_that.tipeVoucher,_that.terpakai,_that.dihapus,_that.diperbaruiPada,_that.diarsipkanPada);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String voucher,  String idPaket,  String tipeVoucher,  bool terpakai,  bool dihapus,  DateTime? diperbaruiPada,  DateTime? diarsipkanPada)  $default,) {final _that = this;
switch (_that) {
case _VoucherModel():
return $default(_that.id,_that.voucher,_that.idPaket,_that.tipeVoucher,_that.terpakai,_that.dihapus,_that.diperbaruiPada,_that.diarsipkanPada);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String voucher,  String idPaket,  String tipeVoucher,  bool terpakai,  bool dihapus,  DateTime? diperbaruiPada,  DateTime? diarsipkanPada)?  $default,) {final _that = this;
switch (_that) {
case _VoucherModel() when $default != null:
return $default(_that.id,_that.voucher,_that.idPaket,_that.tipeVoucher,_that.terpakai,_that.dihapus,_that.diperbaruiPada,_that.diarsipkanPada);case _:
  return null;

}
}

}

/// @nodoc


class _VoucherModel extends VoucherModel {
  const _VoucherModel({required this.id, required this.voucher, required this.idPaket, required this.tipeVoucher, this.terpakai = false, this.dihapus = false, this.diperbaruiPada, this.diarsipkanPada}): super._();
  

@override final  String id;
@override final  String voucher;
@override final  String idPaket;
@override final  String tipeVoucher;
@override@JsonKey() final  bool terpakai;
@override@JsonKey() final  bool dihapus;
@override final  DateTime? diperbaruiPada;
@override final  DateTime? diarsipkanPada;

/// Create a copy of VoucherModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VoucherModelCopyWith<_VoucherModel> get copyWith => __$VoucherModelCopyWithImpl<_VoucherModel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VoucherModel&&(identical(other.id, id) || other.id == id)&&(identical(other.voucher, voucher) || other.voucher == voucher)&&(identical(other.idPaket, idPaket) || other.idPaket == idPaket)&&(identical(other.tipeVoucher, tipeVoucher) || other.tipeVoucher == tipeVoucher)&&(identical(other.terpakai, terpakai) || other.terpakai == terpakai)&&(identical(other.dihapus, dihapus) || other.dihapus == dihapus)&&(identical(other.diperbaruiPada, diperbaruiPada) || other.diperbaruiPada == diperbaruiPada)&&(identical(other.diarsipkanPada, diarsipkanPada) || other.diarsipkanPada == diarsipkanPada));
}


@override
int get hashCode => Object.hash(runtimeType,id,voucher,idPaket,tipeVoucher,terpakai,dihapus,diperbaruiPada,diarsipkanPada);

@override
String toString() {
  return 'VoucherModel(id: $id, voucher: $voucher, idPaket: $idPaket, tipeVoucher: $tipeVoucher, terpakai: $terpakai, dihapus: $dihapus, diperbaruiPada: $diperbaruiPada, diarsipkanPada: $diarsipkanPada)';
}


}

/// @nodoc
abstract mixin class _$VoucherModelCopyWith<$Res> implements $VoucherModelCopyWith<$Res> {
  factory _$VoucherModelCopyWith(_VoucherModel value, $Res Function(_VoucherModel) _then) = __$VoucherModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String voucher, String idPaket, String tipeVoucher, bool terpakai, bool dihapus, DateTime? diperbaruiPada, DateTime? diarsipkanPada
});




}
/// @nodoc
class __$VoucherModelCopyWithImpl<$Res>
    implements _$VoucherModelCopyWith<$Res> {
  __$VoucherModelCopyWithImpl(this._self, this._then);

  final _VoucherModel _self;
  final $Res Function(_VoucherModel) _then;

/// Create a copy of VoucherModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? voucher = null,Object? idPaket = null,Object? tipeVoucher = null,Object? terpakai = null,Object? dihapus = null,Object? diperbaruiPada = freezed,Object? diarsipkanPada = freezed,}) {
  return _then(_VoucherModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,voucher: null == voucher ? _self.voucher : voucher // ignore: cast_nullable_to_non_nullable
as String,idPaket: null == idPaket ? _self.idPaket : idPaket // ignore: cast_nullable_to_non_nullable
as String,tipeVoucher: null == tipeVoucher ? _self.tipeVoucher : tipeVoucher // ignore: cast_nullable_to_non_nullable
as String,terpakai: null == terpakai ? _self.terpakai : terpakai // ignore: cast_nullable_to_non_nullable
as bool,dihapus: null == dihapus ? _self.dihapus : dihapus // ignore: cast_nullable_to_non_nullable
as bool,diperbaruiPada: freezed == diperbaruiPada ? _self.diperbaruiPada : diperbaruiPada // ignore: cast_nullable_to_non_nullable
as DateTime?,diarsipkanPada: freezed == diarsipkanPada ? _self.diarsipkanPada : diarsipkanPada // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
