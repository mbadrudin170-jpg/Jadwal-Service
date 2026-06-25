// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'feedback_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$FeedbackState {

 List<FeedbackModel> get daftarFeedback; int get jumlahFeedback;
/// Create a copy of FeedbackState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FeedbackStateCopyWith<FeedbackState> get copyWith => _$FeedbackStateCopyWithImpl<FeedbackState>(this as FeedbackState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FeedbackState&&const DeepCollectionEquality().equals(other.daftarFeedback, daftarFeedback)&&(identical(other.jumlahFeedback, jumlahFeedback) || other.jumlahFeedback == jumlahFeedback));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(daftarFeedback),jumlahFeedback);

@override
String toString() {
  return 'FeedbackState(daftarFeedback: $daftarFeedback, jumlahFeedback: $jumlahFeedback)';
}


}

/// @nodoc
abstract mixin class $FeedbackStateCopyWith<$Res>  {
  factory $FeedbackStateCopyWith(FeedbackState value, $Res Function(FeedbackState) _then) = _$FeedbackStateCopyWithImpl;
@useResult
$Res call({
 List<FeedbackModel> daftarFeedback, int jumlahFeedback
});




}
/// @nodoc
class _$FeedbackStateCopyWithImpl<$Res>
    implements $FeedbackStateCopyWith<$Res> {
  _$FeedbackStateCopyWithImpl(this._self, this._then);

  final FeedbackState _self;
  final $Res Function(FeedbackState) _then;

/// Create a copy of FeedbackState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? daftarFeedback = null,Object? jumlahFeedback = null,}) {
  return _then(_self.copyWith(
daftarFeedback: null == daftarFeedback ? _self.daftarFeedback : daftarFeedback // ignore: cast_nullable_to_non_nullable
as List<FeedbackModel>,jumlahFeedback: null == jumlahFeedback ? _self.jumlahFeedback : jumlahFeedback // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [FeedbackState].
extension FeedbackStatePatterns on FeedbackState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FeedbackState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FeedbackState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FeedbackState value)  $default,){
final _that = this;
switch (_that) {
case _FeedbackState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FeedbackState value)?  $default,){
final _that = this;
switch (_that) {
case _FeedbackState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<FeedbackModel> daftarFeedback,  int jumlahFeedback)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FeedbackState() when $default != null:
return $default(_that.daftarFeedback,_that.jumlahFeedback);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<FeedbackModel> daftarFeedback,  int jumlahFeedback)  $default,) {final _that = this;
switch (_that) {
case _FeedbackState():
return $default(_that.daftarFeedback,_that.jumlahFeedback);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<FeedbackModel> daftarFeedback,  int jumlahFeedback)?  $default,) {final _that = this;
switch (_that) {
case _FeedbackState() when $default != null:
return $default(_that.daftarFeedback,_that.jumlahFeedback);case _:
  return null;

}
}

}

/// @nodoc


class _FeedbackState implements FeedbackState {
  const _FeedbackState({final  List<FeedbackModel> daftarFeedback = const [], this.jumlahFeedback = 0}): _daftarFeedback = daftarFeedback;
  

 final  List<FeedbackModel> _daftarFeedback;
@override@JsonKey() List<FeedbackModel> get daftarFeedback {
  if (_daftarFeedback is EqualUnmodifiableListView) return _daftarFeedback;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_daftarFeedback);
}

@override@JsonKey() final  int jumlahFeedback;

/// Create a copy of FeedbackState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FeedbackStateCopyWith<_FeedbackState> get copyWith => __$FeedbackStateCopyWithImpl<_FeedbackState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FeedbackState&&const DeepCollectionEquality().equals(other._daftarFeedback, _daftarFeedback)&&(identical(other.jumlahFeedback, jumlahFeedback) || other.jumlahFeedback == jumlahFeedback));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_daftarFeedback),jumlahFeedback);

@override
String toString() {
  return 'FeedbackState(daftarFeedback: $daftarFeedback, jumlahFeedback: $jumlahFeedback)';
}


}

/// @nodoc
abstract mixin class _$FeedbackStateCopyWith<$Res> implements $FeedbackStateCopyWith<$Res> {
  factory _$FeedbackStateCopyWith(_FeedbackState value, $Res Function(_FeedbackState) _then) = __$FeedbackStateCopyWithImpl;
@override @useResult
$Res call({
 List<FeedbackModel> daftarFeedback, int jumlahFeedback
});




}
/// @nodoc
class __$FeedbackStateCopyWithImpl<$Res>
    implements _$FeedbackStateCopyWith<$Res> {
  __$FeedbackStateCopyWithImpl(this._self, this._then);

  final _FeedbackState _self;
  final $Res Function(_FeedbackState) _then;

/// Create a copy of FeedbackState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? daftarFeedback = null,Object? jumlahFeedback = null,}) {
  return _then(_FeedbackState(
daftarFeedback: null == daftarFeedback ? _self._daftarFeedback : daftarFeedback // ignore: cast_nullable_to_non_nullable
as List<FeedbackModel>,jumlahFeedback: null == jumlahFeedback ? _self.jumlahFeedback : jumlahFeedback // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
