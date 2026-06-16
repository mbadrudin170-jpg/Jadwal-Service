// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dompet_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DompetModel {

 String get id; String get nama; double get saldo; DateTime? get diperbaruiPada; bool get dihapus; DateTime? get diarsipkanPada;
/// Create a copy of DompetModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DompetModelCopyWith<DompetModel> get copyWith => _$DompetModelCopyWithImpl<DompetModel>(this as DompetModel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DompetModel&&(identical(other.id, id) || other.id == id)&&(identical(other.nama, nama) || other.nama == nama)&&(identical(other.saldo, saldo) || other.saldo == saldo)&&(identical(other.diperbaruiPada, diperbaruiPada) || other.diperbaruiPada == diperbaruiPada)&&(identical(other.dihapus, dihapus) || other.dihapus == dihapus)&&(identical(other.diarsipkanPada, diarsipkanPada) || other.diarsipkanPada == diarsipkanPada));
}


@override
int get hashCode => Object.hash(runtimeType,id,nama,saldo,diperbaruiPada,dihapus,diarsipkanPada);

@override
String toString() {
  return 'DompetModel(id: $id, nama: $nama, saldo: $saldo, diperbaruiPada: $diperbaruiPada, dihapus: $dihapus, diarsipkanPada: $diarsipkanPada)';
}


}

/// @nodoc
abstract mixin class $DompetModelCopyWith<$Res>  {
  factory $DompetModelCopyWith(DompetModel value, $Res Function(DompetModel) _then) = _$DompetModelCopyWithImpl;
@useResult
$Res call({
 String id, String nama, double saldo, DateTime? diperbaruiPada, bool dihapus, DateTime? diarsipkanPada
});




}
/// @nodoc
class _$DompetModelCopyWithImpl<$Res>
    implements $DompetModelCopyWith<$Res> {
  _$DompetModelCopyWithImpl(this._self, this._then);

  final DompetModel _self;
  final $Res Function(DompetModel) _then;

/// Create a copy of DompetModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? nama = null,Object? saldo = null,Object? diperbaruiPada = freezed,Object? dihapus = null,Object? diarsipkanPada = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,nama: null == nama ? _self.nama : nama // ignore: cast_nullable_to_non_nullable
as String,saldo: null == saldo ? _self.saldo : saldo // ignore: cast_nullable_to_non_nullable
as double,diperbaruiPada: freezed == diperbaruiPada ? _self.diperbaruiPada : diperbaruiPada // ignore: cast_nullable_to_non_nullable
as DateTime?,dihapus: null == dihapus ? _self.dihapus : dihapus // ignore: cast_nullable_to_non_nullable
as bool,diarsipkanPada: freezed == diarsipkanPada ? _self.diarsipkanPada : diarsipkanPada // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [DompetModel].
extension DompetModelPatterns on DompetModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DompetModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DompetModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DompetModel value)  $default,){
final _that = this;
switch (_that) {
case _DompetModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DompetModel value)?  $default,){
final _that = this;
switch (_that) {
case _DompetModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String nama,  double saldo,  DateTime? diperbaruiPada,  bool dihapus,  DateTime? diarsipkanPada)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DompetModel() when $default != null:
return $default(_that.id,_that.nama,_that.saldo,_that.diperbaruiPada,_that.dihapus,_that.diarsipkanPada);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String nama,  double saldo,  DateTime? diperbaruiPada,  bool dihapus,  DateTime? diarsipkanPada)  $default,) {final _that = this;
switch (_that) {
case _DompetModel():
return $default(_that.id,_that.nama,_that.saldo,_that.diperbaruiPada,_that.dihapus,_that.diarsipkanPada);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String nama,  double saldo,  DateTime? diperbaruiPada,  bool dihapus,  DateTime? diarsipkanPada)?  $default,) {final _that = this;
switch (_that) {
case _DompetModel() when $default != null:
return $default(_that.id,_that.nama,_that.saldo,_that.diperbaruiPada,_that.dihapus,_that.diarsipkanPada);case _:
  return null;

}
}

}

/// @nodoc


class _DompetModel extends DompetModel {
  const _DompetModel({required this.id, required this.nama, this.saldo = 0.0, this.diperbaruiPada, this.dihapus = false, this.diarsipkanPada}): super._();
  

@override final  String id;
@override final  String nama;
@override@JsonKey() final  double saldo;
@override final  DateTime? diperbaruiPada;
@override@JsonKey() final  bool dihapus;
@override final  DateTime? diarsipkanPada;

/// Create a copy of DompetModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DompetModelCopyWith<_DompetModel> get copyWith => __$DompetModelCopyWithImpl<_DompetModel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DompetModel&&(identical(other.id, id) || other.id == id)&&(identical(other.nama, nama) || other.nama == nama)&&(identical(other.saldo, saldo) || other.saldo == saldo)&&(identical(other.diperbaruiPada, diperbaruiPada) || other.diperbaruiPada == diperbaruiPada)&&(identical(other.dihapus, dihapus) || other.dihapus == dihapus)&&(identical(other.diarsipkanPada, diarsipkanPada) || other.diarsipkanPada == diarsipkanPada));
}


@override
int get hashCode => Object.hash(runtimeType,id,nama,saldo,diperbaruiPada,dihapus,diarsipkanPada);

@override
String toString() {
  return 'DompetModel(id: $id, nama: $nama, saldo: $saldo, diperbaruiPada: $diperbaruiPada, dihapus: $dihapus, diarsipkanPada: $diarsipkanPada)';
}


}

/// @nodoc
abstract mixin class _$DompetModelCopyWith<$Res> implements $DompetModelCopyWith<$Res> {
  factory _$DompetModelCopyWith(_DompetModel value, $Res Function(_DompetModel) _then) = __$DompetModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String nama, double saldo, DateTime? diperbaruiPada, bool dihapus, DateTime? diarsipkanPada
});




}
/// @nodoc
class __$DompetModelCopyWithImpl<$Res>
    implements _$DompetModelCopyWith<$Res> {
  __$DompetModelCopyWithImpl(this._self, this._then);

  final _DompetModel _self;
  final $Res Function(_DompetModel) _then;

/// Create a copy of DompetModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? nama = null,Object? saldo = null,Object? diperbaruiPada = freezed,Object? dihapus = null,Object? diarsipkanPada = freezed,}) {
  return _then(_DompetModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,nama: null == nama ? _self.nama : nama // ignore: cast_nullable_to_non_nullable
as String,saldo: null == saldo ? _self.saldo : saldo // ignore: cast_nullable_to_non_nullable
as double,diperbaruiPada: freezed == diperbaruiPada ? _self.diperbaruiPada : diperbaruiPada // ignore: cast_nullable_to_non_nullable
as DateTime?,dihapus: null == dihapus ? _self.dihapus : dihapus // ignore: cast_nullable_to_non_nullable
as bool,diarsipkanPada: freezed == diarsipkanPada ? _self.diarsipkanPada : diarsipkanPada // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
