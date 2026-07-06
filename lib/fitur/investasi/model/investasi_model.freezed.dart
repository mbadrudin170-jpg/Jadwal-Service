// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'investasi_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$InvestasiModel {

 String get id; String get idInvestor; String get idTransaksi; double get jumlahModal; int get jumlahLembar; DateTime? get tanggalInvestasi; bool get diHapus; DateTime? get diarsipkanPada; DateTime? get diperbaruiPada;
/// Create a copy of InvestasiModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InvestasiModelCopyWith<InvestasiModel> get copyWith => _$InvestasiModelCopyWithImpl<InvestasiModel>(this as InvestasiModel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InvestasiModel&&(identical(other.id, id) || other.id == id)&&(identical(other.idInvestor, idInvestor) || other.idInvestor == idInvestor)&&(identical(other.idTransaksi, idTransaksi) || other.idTransaksi == idTransaksi)&&(identical(other.jumlahModal, jumlahModal) || other.jumlahModal == jumlahModal)&&(identical(other.jumlahLembar, jumlahLembar) || other.jumlahLembar == jumlahLembar)&&(identical(other.tanggalInvestasi, tanggalInvestasi) || other.tanggalInvestasi == tanggalInvestasi)&&(identical(other.diHapus, diHapus) || other.diHapus == diHapus)&&(identical(other.diarsipkanPada, diarsipkanPada) || other.diarsipkanPada == diarsipkanPada)&&(identical(other.diperbaruiPada, diperbaruiPada) || other.diperbaruiPada == diperbaruiPada));
}


@override
int get hashCode => Object.hash(runtimeType,id,idInvestor,idTransaksi,jumlahModal,jumlahLembar,tanggalInvestasi,diHapus,diarsipkanPada,diperbaruiPada);

@override
String toString() {
  return 'InvestasiModel(id: $id, idInvestor: $idInvestor, idTransaksi: $idTransaksi, jumlahModal: $jumlahModal, jumlahLembar: $jumlahLembar, tanggalInvestasi: $tanggalInvestasi, diHapus: $diHapus, diarsipkanPada: $diarsipkanPada, diperbaruiPada: $diperbaruiPada)';
}


}

/// @nodoc
abstract mixin class $InvestasiModelCopyWith<$Res>  {
  factory $InvestasiModelCopyWith(InvestasiModel value, $Res Function(InvestasiModel) _then) = _$InvestasiModelCopyWithImpl;
@useResult
$Res call({
 String id, String idInvestor, String idTransaksi, double jumlahModal, int jumlahLembar, DateTime? tanggalInvestasi, bool diHapus, DateTime? diarsipkanPada, DateTime? diperbaruiPada
});




}
/// @nodoc
class _$InvestasiModelCopyWithImpl<$Res>
    implements $InvestasiModelCopyWith<$Res> {
  _$InvestasiModelCopyWithImpl(this._self, this._then);

  final InvestasiModel _self;
  final $Res Function(InvestasiModel) _then;

/// Create a copy of InvestasiModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? idInvestor = null,Object? idTransaksi = null,Object? jumlahModal = null,Object? jumlahLembar = null,Object? tanggalInvestasi = freezed,Object? diHapus = null,Object? diarsipkanPada = freezed,Object? diperbaruiPada = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,idInvestor: null == idInvestor ? _self.idInvestor : idInvestor // ignore: cast_nullable_to_non_nullable
as String,idTransaksi: null == idTransaksi ? _self.idTransaksi : idTransaksi // ignore: cast_nullable_to_non_nullable
as String,jumlahModal: null == jumlahModal ? _self.jumlahModal : jumlahModal // ignore: cast_nullable_to_non_nullable
as double,jumlahLembar: null == jumlahLembar ? _self.jumlahLembar : jumlahLembar // ignore: cast_nullable_to_non_nullable
as int,tanggalInvestasi: freezed == tanggalInvestasi ? _self.tanggalInvestasi : tanggalInvestasi // ignore: cast_nullable_to_non_nullable
as DateTime?,diHapus: null == diHapus ? _self.diHapus : diHapus // ignore: cast_nullable_to_non_nullable
as bool,diarsipkanPada: freezed == diarsipkanPada ? _self.diarsipkanPada : diarsipkanPada // ignore: cast_nullable_to_non_nullable
as DateTime?,diperbaruiPada: freezed == diperbaruiPada ? _self.diperbaruiPada : diperbaruiPada // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [InvestasiModel].
extension InvestasiModelPatterns on InvestasiModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InvestasiModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InvestasiModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InvestasiModel value)  $default,){
final _that = this;
switch (_that) {
case _InvestasiModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InvestasiModel value)?  $default,){
final _that = this;
switch (_that) {
case _InvestasiModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String idInvestor,  String idTransaksi,  double jumlahModal,  int jumlahLembar,  DateTime? tanggalInvestasi,  bool diHapus,  DateTime? diarsipkanPada,  DateTime? diperbaruiPada)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InvestasiModel() when $default != null:
return $default(_that.id,_that.idInvestor,_that.idTransaksi,_that.jumlahModal,_that.jumlahLembar,_that.tanggalInvestasi,_that.diHapus,_that.diarsipkanPada,_that.diperbaruiPada);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String idInvestor,  String idTransaksi,  double jumlahModal,  int jumlahLembar,  DateTime? tanggalInvestasi,  bool diHapus,  DateTime? diarsipkanPada,  DateTime? diperbaruiPada)  $default,) {final _that = this;
switch (_that) {
case _InvestasiModel():
return $default(_that.id,_that.idInvestor,_that.idTransaksi,_that.jumlahModal,_that.jumlahLembar,_that.tanggalInvestasi,_that.diHapus,_that.diarsipkanPada,_that.diperbaruiPada);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String idInvestor,  String idTransaksi,  double jumlahModal,  int jumlahLembar,  DateTime? tanggalInvestasi,  bool diHapus,  DateTime? diarsipkanPada,  DateTime? diperbaruiPada)?  $default,) {final _that = this;
switch (_that) {
case _InvestasiModel() when $default != null:
return $default(_that.id,_that.idInvestor,_that.idTransaksi,_that.jumlahModal,_that.jumlahLembar,_that.tanggalInvestasi,_that.diHapus,_that.diarsipkanPada,_that.diperbaruiPada);case _:
  return null;

}
}

}

/// @nodoc


class _InvestasiModel extends InvestasiModel {
  const _InvestasiModel({required this.id, required this.idInvestor, required this.idTransaksi, required this.jumlahModal, required this.jumlahLembar, this.tanggalInvestasi, this.diHapus = false, this.diarsipkanPada, this.diperbaruiPada}): super._();
  

@override final  String id;
@override final  String idInvestor;
@override final  String idTransaksi;
@override final  double jumlahModal;
@override final  int jumlahLembar;
@override final  DateTime? tanggalInvestasi;
@override@JsonKey() final  bool diHapus;
@override final  DateTime? diarsipkanPada;
@override final  DateTime? diperbaruiPada;

/// Create a copy of InvestasiModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InvestasiModelCopyWith<_InvestasiModel> get copyWith => __$InvestasiModelCopyWithImpl<_InvestasiModel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InvestasiModel&&(identical(other.id, id) || other.id == id)&&(identical(other.idInvestor, idInvestor) || other.idInvestor == idInvestor)&&(identical(other.idTransaksi, idTransaksi) || other.idTransaksi == idTransaksi)&&(identical(other.jumlahModal, jumlahModal) || other.jumlahModal == jumlahModal)&&(identical(other.jumlahLembar, jumlahLembar) || other.jumlahLembar == jumlahLembar)&&(identical(other.tanggalInvestasi, tanggalInvestasi) || other.tanggalInvestasi == tanggalInvestasi)&&(identical(other.diHapus, diHapus) || other.diHapus == diHapus)&&(identical(other.diarsipkanPada, diarsipkanPada) || other.diarsipkanPada == diarsipkanPada)&&(identical(other.diperbaruiPada, diperbaruiPada) || other.diperbaruiPada == diperbaruiPada));
}


@override
int get hashCode => Object.hash(runtimeType,id,idInvestor,idTransaksi,jumlahModal,jumlahLembar,tanggalInvestasi,diHapus,diarsipkanPada,diperbaruiPada);

@override
String toString() {
  return 'InvestasiModel(id: $id, idInvestor: $idInvestor, idTransaksi: $idTransaksi, jumlahModal: $jumlahModal, jumlahLembar: $jumlahLembar, tanggalInvestasi: $tanggalInvestasi, diHapus: $diHapus, diarsipkanPada: $diarsipkanPada, diperbaruiPada: $diperbaruiPada)';
}


}

/// @nodoc
abstract mixin class _$InvestasiModelCopyWith<$Res> implements $InvestasiModelCopyWith<$Res> {
  factory _$InvestasiModelCopyWith(_InvestasiModel value, $Res Function(_InvestasiModel) _then) = __$InvestasiModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String idInvestor, String idTransaksi, double jumlahModal, int jumlahLembar, DateTime? tanggalInvestasi, bool diHapus, DateTime? diarsipkanPada, DateTime? diperbaruiPada
});




}
/// @nodoc
class __$InvestasiModelCopyWithImpl<$Res>
    implements _$InvestasiModelCopyWith<$Res> {
  __$InvestasiModelCopyWithImpl(this._self, this._then);

  final _InvestasiModel _self;
  final $Res Function(_InvestasiModel) _then;

/// Create a copy of InvestasiModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? idInvestor = null,Object? idTransaksi = null,Object? jumlahModal = null,Object? jumlahLembar = null,Object? tanggalInvestasi = freezed,Object? diHapus = null,Object? diarsipkanPada = freezed,Object? diperbaruiPada = freezed,}) {
  return _then(_InvestasiModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,idInvestor: null == idInvestor ? _self.idInvestor : idInvestor // ignore: cast_nullable_to_non_nullable
as String,idTransaksi: null == idTransaksi ? _self.idTransaksi : idTransaksi // ignore: cast_nullable_to_non_nullable
as String,jumlahModal: null == jumlahModal ? _self.jumlahModal : jumlahModal // ignore: cast_nullable_to_non_nullable
as double,jumlahLembar: null == jumlahLembar ? _self.jumlahLembar : jumlahLembar // ignore: cast_nullable_to_non_nullable
as int,tanggalInvestasi: freezed == tanggalInvestasi ? _self.tanggalInvestasi : tanggalInvestasi // ignore: cast_nullable_to_non_nullable
as DateTime?,diHapus: null == diHapus ? _self.diHapus : diHapus // ignore: cast_nullable_to_non_nullable
as bool,diarsipkanPada: freezed == diarsipkanPada ? _self.diarsipkanPada : diarsipkanPada // ignore: cast_nullable_to_non_nullable
as DateTime?,diperbaruiPada: freezed == diperbaruiPada ? _self.diperbaruiPada : diperbaruiPada // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
