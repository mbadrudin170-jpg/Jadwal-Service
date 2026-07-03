// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'voucher_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$VoucherState {

 List<VoucherModel> get voucher;
/// Create a copy of VoucherState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VoucherStateCopyWith<VoucherState> get copyWith => _$VoucherStateCopyWithImpl<VoucherState>(this as VoucherState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VoucherState&&const DeepCollectionEquality().equals(other.voucher, voucher));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(voucher));

@override
String toString() {
  return 'VoucherState(voucher: $voucher)';
}


}

/// @nodoc
abstract mixin class $VoucherStateCopyWith<$Res>  {
  factory $VoucherStateCopyWith(VoucherState value, $Res Function(VoucherState) _then) = _$VoucherStateCopyWithImpl;
@useResult
$Res call({
 List<VoucherModel> voucher
});




}
/// @nodoc
class _$VoucherStateCopyWithImpl<$Res>
    implements $VoucherStateCopyWith<$Res> {
  _$VoucherStateCopyWithImpl(this._self, this._then);

  final VoucherState _self;
  final $Res Function(VoucherState) _then;

/// Create a copy of VoucherState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? voucher = null,}) {
  return _then(_self.copyWith(
voucher: null == voucher ? _self.voucher : voucher // ignore: cast_nullable_to_non_nullable
as List<VoucherModel>,
  ));
}

}


/// Adds pattern-matching-related methods to [VoucherState].
extension VoucherStatePatterns on VoucherState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VoucherState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VoucherState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VoucherState value)  $default,){
final _that = this;
switch (_that) {
case _VoucherState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VoucherState value)?  $default,){
final _that = this;
switch (_that) {
case _VoucherState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<VoucherModel> voucher)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VoucherState() when $default != null:
return $default(_that.voucher);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<VoucherModel> voucher)  $default,) {final _that = this;
switch (_that) {
case _VoucherState():
return $default(_that.voucher);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<VoucherModel> voucher)?  $default,) {final _that = this;
switch (_that) {
case _VoucherState() when $default != null:
return $default(_that.voucher);case _:
  return null;

}
}

}

/// @nodoc


class _VoucherState implements VoucherState {
  const _VoucherState({required final  List<VoucherModel> voucher}): _voucher = voucher;
  

 final  List<VoucherModel> _voucher;
@override List<VoucherModel> get voucher {
  if (_voucher is EqualUnmodifiableListView) return _voucher;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_voucher);
}


/// Create a copy of VoucherState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VoucherStateCopyWith<_VoucherState> get copyWith => __$VoucherStateCopyWithImpl<_VoucherState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VoucherState&&const DeepCollectionEquality().equals(other._voucher, _voucher));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_voucher));

@override
String toString() {
  return 'VoucherState(voucher: $voucher)';
}


}

/// @nodoc
abstract mixin class _$VoucherStateCopyWith<$Res> implements $VoucherStateCopyWith<$Res> {
  factory _$VoucherStateCopyWith(_VoucherState value, $Res Function(_VoucherState) _then) = __$VoucherStateCopyWithImpl;
@override @useResult
$Res call({
 List<VoucherModel> voucher
});




}
/// @nodoc
class __$VoucherStateCopyWithImpl<$Res>
    implements _$VoucherStateCopyWith<$Res> {
  __$VoucherStateCopyWithImpl(this._self, this._then);

  final _VoucherState _self;
  final $Res Function(_VoucherState) _then;

/// Create a copy of VoucherState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? voucher = null,}) {
  return _then(_VoucherState(
voucher: null == voucher ? _self._voucher : voucher // ignore: cast_nullable_to_non_nullable
as List<VoucherModel>,
  ));
}


}

// dart format on
