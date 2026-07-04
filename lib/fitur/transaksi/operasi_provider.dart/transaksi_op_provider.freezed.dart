// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'transaksi_op_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TransaksiNotifierState {

 List<TransaksiModel> get transaksi;
/// Create a copy of TransaksiNotifierState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TransaksiNotifierStateCopyWith<TransaksiNotifierState> get copyWith => _$TransaksiNotifierStateCopyWithImpl<TransaksiNotifierState>(this as TransaksiNotifierState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TransaksiNotifierState&&const DeepCollectionEquality().equals(other.transaksi, transaksi));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(transaksi));

@override
String toString() {
  return 'TransaksiNotifierState(transaksi: $transaksi)';
}


}

/// @nodoc
abstract mixin class $TransaksiNotifierStateCopyWith<$Res>  {
  factory $TransaksiNotifierStateCopyWith(TransaksiNotifierState value, $Res Function(TransaksiNotifierState) _then) = _$TransaksiNotifierStateCopyWithImpl;
@useResult
$Res call({
 List<TransaksiModel> transaksi
});




}
/// @nodoc
class _$TransaksiNotifierStateCopyWithImpl<$Res>
    implements $TransaksiNotifierStateCopyWith<$Res> {
  _$TransaksiNotifierStateCopyWithImpl(this._self, this._then);

  final TransaksiNotifierState _self;
  final $Res Function(TransaksiNotifierState) _then;

/// Create a copy of TransaksiNotifierState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? transaksi = null,}) {
  return _then(_self.copyWith(
transaksi: null == transaksi ? _self.transaksi : transaksi // ignore: cast_nullable_to_non_nullable
as List<TransaksiModel>,
  ));
}

}


/// Adds pattern-matching-related methods to [TransaksiNotifierState].
extension TransaksiNotifierStatePatterns on TransaksiNotifierState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TransaksiNotifierState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TransaksiNotifierState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TransaksiNotifierState value)  $default,){
final _that = this;
switch (_that) {
case _TransaksiNotifierState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TransaksiNotifierState value)?  $default,){
final _that = this;
switch (_that) {
case _TransaksiNotifierState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<TransaksiModel> transaksi)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TransaksiNotifierState() when $default != null:
return $default(_that.transaksi);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<TransaksiModel> transaksi)  $default,) {final _that = this;
switch (_that) {
case _TransaksiNotifierState():
return $default(_that.transaksi);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<TransaksiModel> transaksi)?  $default,) {final _that = this;
switch (_that) {
case _TransaksiNotifierState() when $default != null:
return $default(_that.transaksi);case _:
  return null;

}
}

}

/// @nodoc


class _TransaksiNotifierState implements TransaksiNotifierState {
  const _TransaksiNotifierState({final  List<TransaksiModel> transaksi = const []}): _transaksi = transaksi;
  

 final  List<TransaksiModel> _transaksi;
@override@JsonKey() List<TransaksiModel> get transaksi {
  if (_transaksi is EqualUnmodifiableListView) return _transaksi;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_transaksi);
}


/// Create a copy of TransaksiNotifierState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TransaksiNotifierStateCopyWith<_TransaksiNotifierState> get copyWith => __$TransaksiNotifierStateCopyWithImpl<_TransaksiNotifierState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TransaksiNotifierState&&const DeepCollectionEquality().equals(other._transaksi, _transaksi));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_transaksi));

@override
String toString() {
  return 'TransaksiNotifierState(transaksi: $transaksi)';
}


}

/// @nodoc
abstract mixin class _$TransaksiNotifierStateCopyWith<$Res> implements $TransaksiNotifierStateCopyWith<$Res> {
  factory _$TransaksiNotifierStateCopyWith(_TransaksiNotifierState value, $Res Function(_TransaksiNotifierState) _then) = __$TransaksiNotifierStateCopyWithImpl;
@override @useResult
$Res call({
 List<TransaksiModel> transaksi
});




}
/// @nodoc
class __$TransaksiNotifierStateCopyWithImpl<$Res>
    implements _$TransaksiNotifierStateCopyWith<$Res> {
  __$TransaksiNotifierStateCopyWithImpl(this._self, this._then);

  final _TransaksiNotifierState _self;
  final $Res Function(_TransaksiNotifierState) _then;

/// Create a copy of TransaksiNotifierState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? transaksi = null,}) {
  return _then(_TransaksiNotifierState(
transaksi: null == transaksi ? _self._transaksi : transaksi // ignore: cast_nullable_to_non_nullable
as List<TransaksiModel>,
  ));
}


}

// dart format on
