// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'paket_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PaketState {

 List<PaketModel?> get daftarPaket; List<PaketModel?> get daftarPaketPublik; int get jumlahPaket;
/// Create a copy of PaketState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PaketStateCopyWith<PaketState> get copyWith => _$PaketStateCopyWithImpl<PaketState>(this as PaketState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PaketState&&const DeepCollectionEquality().equals(other.daftarPaket, daftarPaket)&&const DeepCollectionEquality().equals(other.daftarPaketPublik, daftarPaketPublik)&&(identical(other.jumlahPaket, jumlahPaket) || other.jumlahPaket == jumlahPaket));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(daftarPaket),const DeepCollectionEquality().hash(daftarPaketPublik),jumlahPaket);

@override
String toString() {
  return 'PaketState(daftarPaket: $daftarPaket, daftarPaketPublik: $daftarPaketPublik, jumlahPaket: $jumlahPaket)';
}


}

/// @nodoc
abstract mixin class $PaketStateCopyWith<$Res>  {
  factory $PaketStateCopyWith(PaketState value, $Res Function(PaketState) _then) = _$PaketStateCopyWithImpl;
@useResult
$Res call({
 List<PaketModel?> daftarPaket, List<PaketModel?> daftarPaketPublik, int jumlahPaket
});




}
/// @nodoc
class _$PaketStateCopyWithImpl<$Res>
    implements $PaketStateCopyWith<$Res> {
  _$PaketStateCopyWithImpl(this._self, this._then);

  final PaketState _self;
  final $Res Function(PaketState) _then;

/// Create a copy of PaketState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? daftarPaket = null,Object? daftarPaketPublik = null,Object? jumlahPaket = null,}) {
  return _then(_self.copyWith(
daftarPaket: null == daftarPaket ? _self.daftarPaket : daftarPaket // ignore: cast_nullable_to_non_nullable
as List<PaketModel?>,daftarPaketPublik: null == daftarPaketPublik ? _self.daftarPaketPublik : daftarPaketPublik // ignore: cast_nullable_to_non_nullable
as List<PaketModel?>,jumlahPaket: null == jumlahPaket ? _self.jumlahPaket : jumlahPaket // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [PaketState].
extension PaketStatePatterns on PaketState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PaketState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PaketState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PaketState value)  $default,){
final _that = this;
switch (_that) {
case _PaketState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PaketState value)?  $default,){
final _that = this;
switch (_that) {
case _PaketState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<PaketModel?> daftarPaket,  List<PaketModel?> daftarPaketPublik,  int jumlahPaket)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PaketState() when $default != null:
return $default(_that.daftarPaket,_that.daftarPaketPublik,_that.jumlahPaket);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<PaketModel?> daftarPaket,  List<PaketModel?> daftarPaketPublik,  int jumlahPaket)  $default,) {final _that = this;
switch (_that) {
case _PaketState():
return $default(_that.daftarPaket,_that.daftarPaketPublik,_that.jumlahPaket);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<PaketModel?> daftarPaket,  List<PaketModel?> daftarPaketPublik,  int jumlahPaket)?  $default,) {final _that = this;
switch (_that) {
case _PaketState() when $default != null:
return $default(_that.daftarPaket,_that.daftarPaketPublik,_that.jumlahPaket);case _:
  return null;

}
}

}

/// @nodoc


class _PaketState implements PaketState {
  const _PaketState({final  List<PaketModel?> daftarPaket = const [], final  List<PaketModel?> daftarPaketPublik = const [], this.jumlahPaket = 0}): _daftarPaket = daftarPaket,_daftarPaketPublik = daftarPaketPublik;
  

 final  List<PaketModel?> _daftarPaket;
@override@JsonKey() List<PaketModel?> get daftarPaket {
  if (_daftarPaket is EqualUnmodifiableListView) return _daftarPaket;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_daftarPaket);
}

 final  List<PaketModel?> _daftarPaketPublik;
@override@JsonKey() List<PaketModel?> get daftarPaketPublik {
  if (_daftarPaketPublik is EqualUnmodifiableListView) return _daftarPaketPublik;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_daftarPaketPublik);
}

@override@JsonKey() final  int jumlahPaket;

/// Create a copy of PaketState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PaketStateCopyWith<_PaketState> get copyWith => __$PaketStateCopyWithImpl<_PaketState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PaketState&&const DeepCollectionEquality().equals(other._daftarPaket, _daftarPaket)&&const DeepCollectionEquality().equals(other._daftarPaketPublik, _daftarPaketPublik)&&(identical(other.jumlahPaket, jumlahPaket) || other.jumlahPaket == jumlahPaket));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_daftarPaket),const DeepCollectionEquality().hash(_daftarPaketPublik),jumlahPaket);

@override
String toString() {
  return 'PaketState(daftarPaket: $daftarPaket, daftarPaketPublik: $daftarPaketPublik, jumlahPaket: $jumlahPaket)';
}


}

/// @nodoc
abstract mixin class _$PaketStateCopyWith<$Res> implements $PaketStateCopyWith<$Res> {
  factory _$PaketStateCopyWith(_PaketState value, $Res Function(_PaketState) _then) = __$PaketStateCopyWithImpl;
@override @useResult
$Res call({
 List<PaketModel?> daftarPaket, List<PaketModel?> daftarPaketPublik, int jumlahPaket
});




}
/// @nodoc
class __$PaketStateCopyWithImpl<$Res>
    implements _$PaketStateCopyWith<$Res> {
  __$PaketStateCopyWithImpl(this._self, this._then);

  final _PaketState _self;
  final $Res Function(_PaketState) _then;

/// Create a copy of PaketState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? daftarPaket = null,Object? daftarPaketPublik = null,Object? jumlahPaket = null,}) {
  return _then(_PaketState(
daftarPaket: null == daftarPaket ? _self._daftarPaket : daftarPaket // ignore: cast_nullable_to_non_nullable
as List<PaketModel?>,daftarPaketPublik: null == daftarPaketPublik ? _self._daftarPaketPublik : daftarPaketPublik // ignore: cast_nullable_to_non_nullable
as List<PaketModel?>,jumlahPaket: null == jumlahPaket ? _self.jumlahPaket : jumlahPaket // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
