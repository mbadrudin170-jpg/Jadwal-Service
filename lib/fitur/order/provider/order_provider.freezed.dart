// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'order_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$OrderState implements DiagnosticableTreeMixin {

 List<OrderModel> get daftarOrder; int get totalDaftar;
/// Create a copy of OrderState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrderStateCopyWith<OrderState> get copyWith => _$OrderStateCopyWithImpl<OrderState>(this as OrderState, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'OrderState'))
    ..add(DiagnosticsProperty('daftarOrder', daftarOrder))..add(DiagnosticsProperty('totalDaftar', totalDaftar));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OrderState&&const DeepCollectionEquality().equals(other.daftarOrder, daftarOrder)&&(identical(other.totalDaftar, totalDaftar) || other.totalDaftar == totalDaftar));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(daftarOrder),totalDaftar);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'OrderState(daftarOrder: $daftarOrder, totalDaftar: $totalDaftar)';
}


}

/// @nodoc
abstract mixin class $OrderStateCopyWith<$Res>  {
  factory $OrderStateCopyWith(OrderState value, $Res Function(OrderState) _then) = _$OrderStateCopyWithImpl;
@useResult
$Res call({
 List<OrderModel> daftarOrder, int totalDaftar
});




}
/// @nodoc
class _$OrderStateCopyWithImpl<$Res>
    implements $OrderStateCopyWith<$Res> {
  _$OrderStateCopyWithImpl(this._self, this._then);

  final OrderState _self;
  final $Res Function(OrderState) _then;

/// Create a copy of OrderState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? daftarOrder = null,Object? totalDaftar = null,}) {
  return _then(_self.copyWith(
daftarOrder: null == daftarOrder ? _self.daftarOrder : daftarOrder // ignore: cast_nullable_to_non_nullable
as List<OrderModel>,totalDaftar: null == totalDaftar ? _self.totalDaftar : totalDaftar // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [OrderState].
extension OrderStatePatterns on OrderState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OrderState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OrderState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OrderState value)  $default,){
final _that = this;
switch (_that) {
case _OrderState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OrderState value)?  $default,){
final _that = this;
switch (_that) {
case _OrderState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<OrderModel> daftarOrder,  int totalDaftar)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OrderState() when $default != null:
return $default(_that.daftarOrder,_that.totalDaftar);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<OrderModel> daftarOrder,  int totalDaftar)  $default,) {final _that = this;
switch (_that) {
case _OrderState():
return $default(_that.daftarOrder,_that.totalDaftar);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<OrderModel> daftarOrder,  int totalDaftar)?  $default,) {final _that = this;
switch (_that) {
case _OrderState() when $default != null:
return $default(_that.daftarOrder,_that.totalDaftar);case _:
  return null;

}
}

}

/// @nodoc


class _OrderState extends OrderState with DiagnosticableTreeMixin {
  const _OrderState({final  List<OrderModel> daftarOrder = const [], this.totalDaftar = 0}): _daftarOrder = daftarOrder,super._();
  

 final  List<OrderModel> _daftarOrder;
@override@JsonKey() List<OrderModel> get daftarOrder {
  if (_daftarOrder is EqualUnmodifiableListView) return _daftarOrder;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_daftarOrder);
}

@override@JsonKey() final  int totalDaftar;

/// Create a copy of OrderState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrderStateCopyWith<_OrderState> get copyWith => __$OrderStateCopyWithImpl<_OrderState>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'OrderState'))
    ..add(DiagnosticsProperty('daftarOrder', daftarOrder))..add(DiagnosticsProperty('totalDaftar', totalDaftar));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OrderState&&const DeepCollectionEquality().equals(other._daftarOrder, _daftarOrder)&&(identical(other.totalDaftar, totalDaftar) || other.totalDaftar == totalDaftar));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_daftarOrder),totalDaftar);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'OrderState(daftarOrder: $daftarOrder, totalDaftar: $totalDaftar)';
}


}

/// @nodoc
abstract mixin class _$OrderStateCopyWith<$Res> implements $OrderStateCopyWith<$Res> {
  factory _$OrderStateCopyWith(_OrderState value, $Res Function(_OrderState) _then) = __$OrderStateCopyWithImpl;
@override @useResult
$Res call({
 List<OrderModel> daftarOrder, int totalDaftar
});




}
/// @nodoc
class __$OrderStateCopyWithImpl<$Res>
    implements _$OrderStateCopyWith<$Res> {
  __$OrderStateCopyWithImpl(this._self, this._then);

  final _OrderState _self;
  final $Res Function(_OrderState) _then;

/// Create a copy of OrderState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? daftarOrder = null,Object? totalDaftar = null,}) {
  return _then(_OrderState(
daftarOrder: null == daftarOrder ? _self._daftarOrder : daftarOrder // ignore: cast_nullable_to_non_nullable
as List<OrderModel>,totalDaftar: null == totalDaftar ? _self.totalDaftar : totalDaftar // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
