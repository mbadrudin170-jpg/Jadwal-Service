// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'investasi_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$InvestasiState {

 List<InvestasiModel> get daftarInvestasi; List<DividenModel> get daftarDividen; int get jumlahInvestasi; int get jumlahDividen; double get totalModal; double get totalDividenDiterima; double get totalDividenBelumDibayar;
/// Create a copy of InvestasiState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InvestasiStateCopyWith<InvestasiState> get copyWith => _$InvestasiStateCopyWithImpl<InvestasiState>(this as InvestasiState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InvestasiState&&const DeepCollectionEquality().equals(other.daftarInvestasi, daftarInvestasi)&&const DeepCollectionEquality().equals(other.daftarDividen, daftarDividen)&&(identical(other.jumlahInvestasi, jumlahInvestasi) || other.jumlahInvestasi == jumlahInvestasi)&&(identical(other.jumlahDividen, jumlahDividen) || other.jumlahDividen == jumlahDividen)&&(identical(other.totalModal, totalModal) || other.totalModal == totalModal)&&(identical(other.totalDividenDiterima, totalDividenDiterima) || other.totalDividenDiterima == totalDividenDiterima)&&(identical(other.totalDividenBelumDibayar, totalDividenBelumDibayar) || other.totalDividenBelumDibayar == totalDividenBelumDibayar));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(daftarInvestasi),const DeepCollectionEquality().hash(daftarDividen),jumlahInvestasi,jumlahDividen,totalModal,totalDividenDiterima,totalDividenBelumDibayar);

@override
String toString() {
  return 'InvestasiState(daftarInvestasi: $daftarInvestasi, daftarDividen: $daftarDividen, jumlahInvestasi: $jumlahInvestasi, jumlahDividen: $jumlahDividen, totalModal: $totalModal, totalDividenDiterima: $totalDividenDiterima, totalDividenBelumDibayar: $totalDividenBelumDibayar)';
}


}

/// @nodoc
abstract mixin class $InvestasiStateCopyWith<$Res>  {
  factory $InvestasiStateCopyWith(InvestasiState value, $Res Function(InvestasiState) _then) = _$InvestasiStateCopyWithImpl;
@useResult
$Res call({
 List<InvestasiModel> daftarInvestasi, List<DividenModel> daftarDividen, int jumlahInvestasi, int jumlahDividen, double totalModal, double totalDividenDiterima, double totalDividenBelumDibayar
});




}
/// @nodoc
class _$InvestasiStateCopyWithImpl<$Res>
    implements $InvestasiStateCopyWith<$Res> {
  _$InvestasiStateCopyWithImpl(this._self, this._then);

  final InvestasiState _self;
  final $Res Function(InvestasiState) _then;

/// Create a copy of InvestasiState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? daftarInvestasi = null,Object? daftarDividen = null,Object? jumlahInvestasi = null,Object? jumlahDividen = null,Object? totalModal = null,Object? totalDividenDiterima = null,Object? totalDividenBelumDibayar = null,}) {
  return _then(_self.copyWith(
daftarInvestasi: null == daftarInvestasi ? _self.daftarInvestasi : daftarInvestasi // ignore: cast_nullable_to_non_nullable
as List<InvestasiModel>,daftarDividen: null == daftarDividen ? _self.daftarDividen : daftarDividen // ignore: cast_nullable_to_non_nullable
as List<DividenModel>,jumlahInvestasi: null == jumlahInvestasi ? _self.jumlahInvestasi : jumlahInvestasi // ignore: cast_nullable_to_non_nullable
as int,jumlahDividen: null == jumlahDividen ? _self.jumlahDividen : jumlahDividen // ignore: cast_nullable_to_non_nullable
as int,totalModal: null == totalModal ? _self.totalModal : totalModal // ignore: cast_nullable_to_non_nullable
as double,totalDividenDiterima: null == totalDividenDiterima ? _self.totalDividenDiterima : totalDividenDiterima // ignore: cast_nullable_to_non_nullable
as double,totalDividenBelumDibayar: null == totalDividenBelumDibayar ? _self.totalDividenBelumDibayar : totalDividenBelumDibayar // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [InvestasiState].
extension InvestasiStatePatterns on InvestasiState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InvestasiState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InvestasiState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InvestasiState value)  $default,){
final _that = this;
switch (_that) {
case _InvestasiState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InvestasiState value)?  $default,){
final _that = this;
switch (_that) {
case _InvestasiState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<InvestasiModel> daftarInvestasi,  List<DividenModel> daftarDividen,  int jumlahInvestasi,  int jumlahDividen,  double totalModal,  double totalDividenDiterima,  double totalDividenBelumDibayar)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InvestasiState() when $default != null:
return $default(_that.daftarInvestasi,_that.daftarDividen,_that.jumlahInvestasi,_that.jumlahDividen,_that.totalModal,_that.totalDividenDiterima,_that.totalDividenBelumDibayar);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<InvestasiModel> daftarInvestasi,  List<DividenModel> daftarDividen,  int jumlahInvestasi,  int jumlahDividen,  double totalModal,  double totalDividenDiterima,  double totalDividenBelumDibayar)  $default,) {final _that = this;
switch (_that) {
case _InvestasiState():
return $default(_that.daftarInvestasi,_that.daftarDividen,_that.jumlahInvestasi,_that.jumlahDividen,_that.totalModal,_that.totalDividenDiterima,_that.totalDividenBelumDibayar);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<InvestasiModel> daftarInvestasi,  List<DividenModel> daftarDividen,  int jumlahInvestasi,  int jumlahDividen,  double totalModal,  double totalDividenDiterima,  double totalDividenBelumDibayar)?  $default,) {final _that = this;
switch (_that) {
case _InvestasiState() when $default != null:
return $default(_that.daftarInvestasi,_that.daftarDividen,_that.jumlahInvestasi,_that.jumlahDividen,_that.totalModal,_that.totalDividenDiterima,_that.totalDividenBelumDibayar);case _:
  return null;

}
}

}

/// @nodoc


class _InvestasiState extends InvestasiState {
  const _InvestasiState({final  List<InvestasiModel> daftarInvestasi = const [], final  List<DividenModel> daftarDividen = const [], this.jumlahInvestasi = 0, this.jumlahDividen = 0, this.totalModal = 0.0, this.totalDividenDiterima = 0.0, this.totalDividenBelumDibayar = 0.0}): _daftarInvestasi = daftarInvestasi,_daftarDividen = daftarDividen,super._();
  

 final  List<InvestasiModel> _daftarInvestasi;
@override@JsonKey() List<InvestasiModel> get daftarInvestasi {
  if (_daftarInvestasi is EqualUnmodifiableListView) return _daftarInvestasi;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_daftarInvestasi);
}

 final  List<DividenModel> _daftarDividen;
@override@JsonKey() List<DividenModel> get daftarDividen {
  if (_daftarDividen is EqualUnmodifiableListView) return _daftarDividen;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_daftarDividen);
}

@override@JsonKey() final  int jumlahInvestasi;
@override@JsonKey() final  int jumlahDividen;
@override@JsonKey() final  double totalModal;
@override@JsonKey() final  double totalDividenDiterima;
@override@JsonKey() final  double totalDividenBelumDibayar;

/// Create a copy of InvestasiState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InvestasiStateCopyWith<_InvestasiState> get copyWith => __$InvestasiStateCopyWithImpl<_InvestasiState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InvestasiState&&const DeepCollectionEquality().equals(other._daftarInvestasi, _daftarInvestasi)&&const DeepCollectionEquality().equals(other._daftarDividen, _daftarDividen)&&(identical(other.jumlahInvestasi, jumlahInvestasi) || other.jumlahInvestasi == jumlahInvestasi)&&(identical(other.jumlahDividen, jumlahDividen) || other.jumlahDividen == jumlahDividen)&&(identical(other.totalModal, totalModal) || other.totalModal == totalModal)&&(identical(other.totalDividenDiterima, totalDividenDiterima) || other.totalDividenDiterima == totalDividenDiterima)&&(identical(other.totalDividenBelumDibayar, totalDividenBelumDibayar) || other.totalDividenBelumDibayar == totalDividenBelumDibayar));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_daftarInvestasi),const DeepCollectionEquality().hash(_daftarDividen),jumlahInvestasi,jumlahDividen,totalModal,totalDividenDiterima,totalDividenBelumDibayar);

@override
String toString() {
  return 'InvestasiState(daftarInvestasi: $daftarInvestasi, daftarDividen: $daftarDividen, jumlahInvestasi: $jumlahInvestasi, jumlahDividen: $jumlahDividen, totalModal: $totalModal, totalDividenDiterima: $totalDividenDiterima, totalDividenBelumDibayar: $totalDividenBelumDibayar)';
}


}

/// @nodoc
abstract mixin class _$InvestasiStateCopyWith<$Res> implements $InvestasiStateCopyWith<$Res> {
  factory _$InvestasiStateCopyWith(_InvestasiState value, $Res Function(_InvestasiState) _then) = __$InvestasiStateCopyWithImpl;
@override @useResult
$Res call({
 List<InvestasiModel> daftarInvestasi, List<DividenModel> daftarDividen, int jumlahInvestasi, int jumlahDividen, double totalModal, double totalDividenDiterima, double totalDividenBelumDibayar
});




}
/// @nodoc
class __$InvestasiStateCopyWithImpl<$Res>
    implements _$InvestasiStateCopyWith<$Res> {
  __$InvestasiStateCopyWithImpl(this._self, this._then);

  final _InvestasiState _self;
  final $Res Function(_InvestasiState) _then;

/// Create a copy of InvestasiState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? daftarInvestasi = null,Object? daftarDividen = null,Object? jumlahInvestasi = null,Object? jumlahDividen = null,Object? totalModal = null,Object? totalDividenDiterima = null,Object? totalDividenBelumDibayar = null,}) {
  return _then(_InvestasiState(
daftarInvestasi: null == daftarInvestasi ? _self._daftarInvestasi : daftarInvestasi // ignore: cast_nullable_to_non_nullable
as List<InvestasiModel>,daftarDividen: null == daftarDividen ? _self._daftarDividen : daftarDividen // ignore: cast_nullable_to_non_nullable
as List<DividenModel>,jumlahInvestasi: null == jumlahInvestasi ? _self.jumlahInvestasi : jumlahInvestasi // ignore: cast_nullable_to_non_nullable
as int,jumlahDividen: null == jumlahDividen ? _self.jumlahDividen : jumlahDividen // ignore: cast_nullable_to_non_nullable
as int,totalModal: null == totalModal ? _self.totalModal : totalModal // ignore: cast_nullable_to_non_nullable
as double,totalDividenDiterima: null == totalDividenDiterima ? _self.totalDividenDiterima : totalDividenDiterima // ignore: cast_nullable_to_non_nullable
as double,totalDividenBelumDibayar: null == totalDividenBelumDibayar ? _self.totalDividenBelumDibayar : totalDividenBelumDibayar // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
