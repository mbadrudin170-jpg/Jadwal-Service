// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dompet_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DompetState {

 List<DompetModel> get wallets; double get totalSaldoPositif; double get totalSaldoNegatif; double get totalSaldo;
/// Create a copy of DompetState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DompetStateCopyWith<DompetState> get copyWith => _$DompetStateCopyWithImpl<DompetState>(this as DompetState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DompetState&&const DeepCollectionEquality().equals(other.wallets, wallets)&&(identical(other.totalSaldoPositif, totalSaldoPositif) || other.totalSaldoPositif == totalSaldoPositif)&&(identical(other.totalSaldoNegatif, totalSaldoNegatif) || other.totalSaldoNegatif == totalSaldoNegatif)&&(identical(other.totalSaldo, totalSaldo) || other.totalSaldo == totalSaldo));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(wallets),totalSaldoPositif,totalSaldoNegatif,totalSaldo);

@override
String toString() {
  return 'DompetState(wallets: $wallets, totalSaldoPositif: $totalSaldoPositif, totalSaldoNegatif: $totalSaldoNegatif, totalSaldo: $totalSaldo)';
}


}

/// @nodoc
abstract mixin class $DompetStateCopyWith<$Res>  {
  factory $DompetStateCopyWith(DompetState value, $Res Function(DompetState) _then) = _$DompetStateCopyWithImpl;
@useResult
$Res call({
 List<DompetModel> wallets, double totalSaldoPositif, double totalSaldoNegatif, double totalSaldo
});




}
/// @nodoc
class _$DompetStateCopyWithImpl<$Res>
    implements $DompetStateCopyWith<$Res> {
  _$DompetStateCopyWithImpl(this._self, this._then);

  final DompetState _self;
  final $Res Function(DompetState) _then;

/// Create a copy of DompetState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? wallets = null,Object? totalSaldoPositif = null,Object? totalSaldoNegatif = null,Object? totalSaldo = null,}) {
  return _then(_self.copyWith(
wallets: null == wallets ? _self.wallets : wallets // ignore: cast_nullable_to_non_nullable
as List<DompetModel>,totalSaldoPositif: null == totalSaldoPositif ? _self.totalSaldoPositif : totalSaldoPositif // ignore: cast_nullable_to_non_nullable
as double,totalSaldoNegatif: null == totalSaldoNegatif ? _self.totalSaldoNegatif : totalSaldoNegatif // ignore: cast_nullable_to_non_nullable
as double,totalSaldo: null == totalSaldo ? _self.totalSaldo : totalSaldo // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [DompetState].
extension DompetStatePatterns on DompetState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DompetState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DompetState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DompetState value)  $default,){
final _that = this;
switch (_that) {
case _DompetState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DompetState value)?  $default,){
final _that = this;
switch (_that) {
case _DompetState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<DompetModel> wallets,  double totalSaldoPositif,  double totalSaldoNegatif,  double totalSaldo)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DompetState() when $default != null:
return $default(_that.wallets,_that.totalSaldoPositif,_that.totalSaldoNegatif,_that.totalSaldo);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<DompetModel> wallets,  double totalSaldoPositif,  double totalSaldoNegatif,  double totalSaldo)  $default,) {final _that = this;
switch (_that) {
case _DompetState():
return $default(_that.wallets,_that.totalSaldoPositif,_that.totalSaldoNegatif,_that.totalSaldo);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<DompetModel> wallets,  double totalSaldoPositif,  double totalSaldoNegatif,  double totalSaldo)?  $default,) {final _that = this;
switch (_that) {
case _DompetState() when $default != null:
return $default(_that.wallets,_that.totalSaldoPositif,_that.totalSaldoNegatif,_that.totalSaldo);case _:
  return null;

}
}

}

/// @nodoc


class _DompetState implements DompetState {
  const _DompetState({final  List<DompetModel> wallets = const [], this.totalSaldoPositif = 0.0, this.totalSaldoNegatif = 0.0, this.totalSaldo = 0.0}): _wallets = wallets;
  

 final  List<DompetModel> _wallets;
@override@JsonKey() List<DompetModel> get wallets {
  if (_wallets is EqualUnmodifiableListView) return _wallets;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_wallets);
}

@override@JsonKey() final  double totalSaldoPositif;
@override@JsonKey() final  double totalSaldoNegatif;
@override@JsonKey() final  double totalSaldo;

/// Create a copy of DompetState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DompetStateCopyWith<_DompetState> get copyWith => __$DompetStateCopyWithImpl<_DompetState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DompetState&&const DeepCollectionEquality().equals(other._wallets, _wallets)&&(identical(other.totalSaldoPositif, totalSaldoPositif) || other.totalSaldoPositif == totalSaldoPositif)&&(identical(other.totalSaldoNegatif, totalSaldoNegatif) || other.totalSaldoNegatif == totalSaldoNegatif)&&(identical(other.totalSaldo, totalSaldo) || other.totalSaldo == totalSaldo));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_wallets),totalSaldoPositif,totalSaldoNegatif,totalSaldo);

@override
String toString() {
  return 'DompetState(wallets: $wallets, totalSaldoPositif: $totalSaldoPositif, totalSaldoNegatif: $totalSaldoNegatif, totalSaldo: $totalSaldo)';
}


}

/// @nodoc
abstract mixin class _$DompetStateCopyWith<$Res> implements $DompetStateCopyWith<$Res> {
  factory _$DompetStateCopyWith(_DompetState value, $Res Function(_DompetState) _then) = __$DompetStateCopyWithImpl;
@override @useResult
$Res call({
 List<DompetModel> wallets, double totalSaldoPositif, double totalSaldoNegatif, double totalSaldo
});




}
/// @nodoc
class __$DompetStateCopyWithImpl<$Res>
    implements _$DompetStateCopyWith<$Res> {
  __$DompetStateCopyWithImpl(this._self, this._then);

  final _DompetState _self;
  final $Res Function(_DompetState) _then;

/// Create a copy of DompetState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? wallets = null,Object? totalSaldoPositif = null,Object? totalSaldoNegatif = null,Object? totalSaldo = null,}) {
  return _then(_DompetState(
wallets: null == wallets ? _self._wallets : wallets // ignore: cast_nullable_to_non_nullable
as List<DompetModel>,totalSaldoPositif: null == totalSaldoPositif ? _self.totalSaldoPositif : totalSaldoPositif // ignore: cast_nullable_to_non_nullable
as double,totalSaldoNegatif: null == totalSaldoNegatif ? _self.totalSaldoNegatif : totalSaldoNegatif // ignore: cast_nullable_to_non_nullable
as double,totalSaldo: null == totalSaldo ? _self.totalSaldo : totalSaldo // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
