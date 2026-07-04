// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'operasi_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TransaksiTesState {

 List<TransaksiModel> get transaksi;
/// Create a copy of TransaksiTesState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TransaksiTesStateCopyWith<TransaksiTesState> get copyWith => _$TransaksiTesStateCopyWithImpl<TransaksiTesState>(this as TransaksiTesState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TransaksiTesState&&const DeepCollectionEquality().equals(other.transaksi, transaksi));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(transaksi));

@override
String toString() {
  return 'TransaksiTesState(transaksi: $transaksi)';
}


}

/// @nodoc
abstract mixin class $TransaksiTesStateCopyWith<$Res>  {
  factory $TransaksiTesStateCopyWith(TransaksiTesState value, $Res Function(TransaksiTesState) _then) = _$TransaksiTesStateCopyWithImpl;
@useResult
$Res call({
 List<TransaksiModel> transaksi
});




}
/// @nodoc
class _$TransaksiTesStateCopyWithImpl<$Res>
    implements $TransaksiTesStateCopyWith<$Res> {
  _$TransaksiTesStateCopyWithImpl(this._self, this._then);

  final TransaksiTesState _self;
  final $Res Function(TransaksiTesState) _then;

/// Create a copy of TransaksiTesState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? transaksi = null,}) {
  return _then(_self.copyWith(
transaksi: null == transaksi ? _self.transaksi : transaksi // ignore: cast_nullable_to_non_nullable
as List<TransaksiModel>,
  ));
}

}


/// Adds pattern-matching-related methods to [TransaksiTesState].
extension TransaksiTesStatePatterns on TransaksiTesState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TransaksiTesState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TransaksiTesState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TransaksiTesState value)  $default,){
final _that = this;
switch (_that) {
case _TransaksiTesState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TransaksiTesState value)?  $default,){
final _that = this;
switch (_that) {
case _TransaksiTesState() when $default != null:
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
case _TransaksiTesState() when $default != null:
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
case _TransaksiTesState():
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
case _TransaksiTesState() when $default != null:
return $default(_that.transaksi);case _:
  return null;

}
}

}

/// @nodoc


class _TransaksiTesState implements TransaksiTesState {
  const _TransaksiTesState({final  List<TransaksiModel> transaksi = const []}): _transaksi = transaksi;
  

 final  List<TransaksiModel> _transaksi;
@override@JsonKey() List<TransaksiModel> get transaksi {
  if (_transaksi is EqualUnmodifiableListView) return _transaksi;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_transaksi);
}


/// Create a copy of TransaksiTesState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TransaksiTesStateCopyWith<_TransaksiTesState> get copyWith => __$TransaksiTesStateCopyWithImpl<_TransaksiTesState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TransaksiTesState&&const DeepCollectionEquality().equals(other._transaksi, _transaksi));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_transaksi));

@override
String toString() {
  return 'TransaksiTesState(transaksi: $transaksi)';
}


}

/// @nodoc
abstract mixin class _$TransaksiTesStateCopyWith<$Res> implements $TransaksiTesStateCopyWith<$Res> {
  factory _$TransaksiTesStateCopyWith(_TransaksiTesState value, $Res Function(_TransaksiTesState) _then) = __$TransaksiTesStateCopyWithImpl;
@override @useResult
$Res call({
 List<TransaksiModel> transaksi
});




}
/// @nodoc
class __$TransaksiTesStateCopyWithImpl<$Res>
    implements _$TransaksiTesStateCopyWith<$Res> {
  __$TransaksiTesStateCopyWithImpl(this._self, this._then);

  final _TransaksiTesState _self;
  final $Res Function(_TransaksiTesState) _then;

/// Create a copy of TransaksiTesState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? transaksi = null,}) {
  return _then(_TransaksiTesState(
transaksi: null == transaksi ? _self._transaksi : transaksi // ignore: cast_nullable_to_non_nullable
as List<TransaksiModel>,
  ));
}


}

// dart format on
