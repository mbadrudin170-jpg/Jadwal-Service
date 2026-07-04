// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'operasi_baca_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$OperasiBacaState {

 double get totalPemasukan; double get totalPengeluaran; double get total;
/// Create a copy of OperasiBacaState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OperasiBacaStateCopyWith<OperasiBacaState> get copyWith => _$OperasiBacaStateCopyWithImpl<OperasiBacaState>(this as OperasiBacaState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OperasiBacaState&&(identical(other.totalPemasukan, totalPemasukan) || other.totalPemasukan == totalPemasukan)&&(identical(other.totalPengeluaran, totalPengeluaran) || other.totalPengeluaran == totalPengeluaran)&&(identical(other.total, total) || other.total == total));
}


@override
int get hashCode => Object.hash(runtimeType,totalPemasukan,totalPengeluaran,total);

@override
String toString() {
  return 'OperasiBacaState(totalPemasukan: $totalPemasukan, totalPengeluaran: $totalPengeluaran, total: $total)';
}


}

/// @nodoc
abstract mixin class $OperasiBacaStateCopyWith<$Res>  {
  factory $OperasiBacaStateCopyWith(OperasiBacaState value, $Res Function(OperasiBacaState) _then) = _$OperasiBacaStateCopyWithImpl;
@useResult
$Res call({
 double totalPemasukan, double totalPengeluaran, double total
});




}
/// @nodoc
class _$OperasiBacaStateCopyWithImpl<$Res>
    implements $OperasiBacaStateCopyWith<$Res> {
  _$OperasiBacaStateCopyWithImpl(this._self, this._then);

  final OperasiBacaState _self;
  final $Res Function(OperasiBacaState) _then;

/// Create a copy of OperasiBacaState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? totalPemasukan = null,Object? totalPengeluaran = null,Object? total = null,}) {
  return _then(_self.copyWith(
totalPemasukan: null == totalPemasukan ? _self.totalPemasukan : totalPemasukan // ignore: cast_nullable_to_non_nullable
as double,totalPengeluaran: null == totalPengeluaran ? _self.totalPengeluaran : totalPengeluaran // ignore: cast_nullable_to_non_nullable
as double,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [OperasiBacaState].
extension OperasiBacaStatePatterns on OperasiBacaState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OperasiBacaState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OperasiBacaState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OperasiBacaState value)  $default,){
final _that = this;
switch (_that) {
case _OperasiBacaState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OperasiBacaState value)?  $default,){
final _that = this;
switch (_that) {
case _OperasiBacaState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double totalPemasukan,  double totalPengeluaran,  double total)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OperasiBacaState() when $default != null:
return $default(_that.totalPemasukan,_that.totalPengeluaran,_that.total);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double totalPemasukan,  double totalPengeluaran,  double total)  $default,) {final _that = this;
switch (_that) {
case _OperasiBacaState():
return $default(_that.totalPemasukan,_that.totalPengeluaran,_that.total);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double totalPemasukan,  double totalPengeluaran,  double total)?  $default,) {final _that = this;
switch (_that) {
case _OperasiBacaState() when $default != null:
return $default(_that.totalPemasukan,_that.totalPengeluaran,_that.total);case _:
  return null;

}
}

}

/// @nodoc


class _OperasiBacaState implements OperasiBacaState {
  const _OperasiBacaState({this.totalPemasukan = 0.0, this.totalPengeluaran = 0.0, this.total = 0.0});
  

@override@JsonKey() final  double totalPemasukan;
@override@JsonKey() final  double totalPengeluaran;
@override@JsonKey() final  double total;

/// Create a copy of OperasiBacaState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OperasiBacaStateCopyWith<_OperasiBacaState> get copyWith => __$OperasiBacaStateCopyWithImpl<_OperasiBacaState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OperasiBacaState&&(identical(other.totalPemasukan, totalPemasukan) || other.totalPemasukan == totalPemasukan)&&(identical(other.totalPengeluaran, totalPengeluaran) || other.totalPengeluaran == totalPengeluaran)&&(identical(other.total, total) || other.total == total));
}


@override
int get hashCode => Object.hash(runtimeType,totalPemasukan,totalPengeluaran,total);

@override
String toString() {
  return 'OperasiBacaState(totalPemasukan: $totalPemasukan, totalPengeluaran: $totalPengeluaran, total: $total)';
}


}

/// @nodoc
abstract mixin class _$OperasiBacaStateCopyWith<$Res> implements $OperasiBacaStateCopyWith<$Res> {
  factory _$OperasiBacaStateCopyWith(_OperasiBacaState value, $Res Function(_OperasiBacaState) _then) = __$OperasiBacaStateCopyWithImpl;
@override @useResult
$Res call({
 double totalPemasukan, double totalPengeluaran, double total
});




}
/// @nodoc
class __$OperasiBacaStateCopyWithImpl<$Res>
    implements _$OperasiBacaStateCopyWith<$Res> {
  __$OperasiBacaStateCopyWithImpl(this._self, this._then);

  final _OperasiBacaState _self;
  final $Res Function(_OperasiBacaState) _then;

/// Create a copy of OperasiBacaState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totalPemasukan = null,Object? totalPengeluaran = null,Object? total = null,}) {
  return _then(_OperasiBacaState(
totalPemasukan: null == totalPemasukan ? _self.totalPemasukan : totalPemasukan // ignore: cast_nullable_to_non_nullable
as double,totalPengeluaran: null == totalPengeluaran ? _self.totalPengeluaran : totalPengeluaran // ignore: cast_nullable_to_non_nullable
as double,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
