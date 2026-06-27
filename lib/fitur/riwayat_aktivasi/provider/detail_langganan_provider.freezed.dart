// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'detail_langganan_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DetailLanggananState {

 TransaksiModel? get transaksi; PelangganModel? get pelanggan; PaketModel? get paket;
/// Create a copy of DetailLanggananState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DetailLanggananStateCopyWith<DetailLanggananState> get copyWith => _$DetailLanggananStateCopyWithImpl<DetailLanggananState>(this as DetailLanggananState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DetailLanggananState&&(identical(other.transaksi, transaksi) || other.transaksi == transaksi)&&(identical(other.pelanggan, pelanggan) || other.pelanggan == pelanggan)&&(identical(other.paket, paket) || other.paket == paket));
}


@override
int get hashCode => Object.hash(runtimeType,transaksi,pelanggan,paket);

@override
String toString() {
  return 'DetailLanggananState(transaksi: $transaksi, pelanggan: $pelanggan, paket: $paket)';
}


}

/// @nodoc
abstract mixin class $DetailLanggananStateCopyWith<$Res>  {
  factory $DetailLanggananStateCopyWith(DetailLanggananState value, $Res Function(DetailLanggananState) _then) = _$DetailLanggananStateCopyWithImpl;
@useResult
$Res call({
 TransaksiModel? transaksi, PelangganModel? pelanggan, PaketModel? paket
});


$TransaksiModelCopyWith<$Res>? get transaksi;$PelangganModelCopyWith<$Res>? get pelanggan;$PaketModelCopyWith<$Res>? get paket;

}
/// @nodoc
class _$DetailLanggananStateCopyWithImpl<$Res>
    implements $DetailLanggananStateCopyWith<$Res> {
  _$DetailLanggananStateCopyWithImpl(this._self, this._then);

  final DetailLanggananState _self;
  final $Res Function(DetailLanggananState) _then;

/// Create a copy of DetailLanggananState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? transaksi = freezed,Object? pelanggan = freezed,Object? paket = freezed,}) {
  return _then(_self.copyWith(
transaksi: freezed == transaksi ? _self.transaksi : transaksi // ignore: cast_nullable_to_non_nullable
as TransaksiModel?,pelanggan: freezed == pelanggan ? _self.pelanggan : pelanggan // ignore: cast_nullable_to_non_nullable
as PelangganModel?,paket: freezed == paket ? _self.paket : paket // ignore: cast_nullable_to_non_nullable
as PaketModel?,
  ));
}
/// Create a copy of DetailLanggananState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TransaksiModelCopyWith<$Res>? get transaksi {
    if (_self.transaksi == null) {
    return null;
  }

  return $TransaksiModelCopyWith<$Res>(_self.transaksi!, (value) {
    return _then(_self.copyWith(transaksi: value));
  });
}/// Create a copy of DetailLanggananState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PelangganModelCopyWith<$Res>? get pelanggan {
    if (_self.pelanggan == null) {
    return null;
  }

  return $PelangganModelCopyWith<$Res>(_self.pelanggan!, (value) {
    return _then(_self.copyWith(pelanggan: value));
  });
}/// Create a copy of DetailLanggananState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PaketModelCopyWith<$Res>? get paket {
    if (_self.paket == null) {
    return null;
  }

  return $PaketModelCopyWith<$Res>(_self.paket!, (value) {
    return _then(_self.copyWith(paket: value));
  });
}
}


/// Adds pattern-matching-related methods to [DetailLanggananState].
extension DetailLanggananStatePatterns on DetailLanggananState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DetailLanggananState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DetailLanggananState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DetailLanggananState value)  $default,){
final _that = this;
switch (_that) {
case _DetailLanggananState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DetailLanggananState value)?  $default,){
final _that = this;
switch (_that) {
case _DetailLanggananState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( TransaksiModel? transaksi,  PelangganModel? pelanggan,  PaketModel? paket)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DetailLanggananState() when $default != null:
return $default(_that.transaksi,_that.pelanggan,_that.paket);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( TransaksiModel? transaksi,  PelangganModel? pelanggan,  PaketModel? paket)  $default,) {final _that = this;
switch (_that) {
case _DetailLanggananState():
return $default(_that.transaksi,_that.pelanggan,_that.paket);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( TransaksiModel? transaksi,  PelangganModel? pelanggan,  PaketModel? paket)?  $default,) {final _that = this;
switch (_that) {
case _DetailLanggananState() when $default != null:
return $default(_that.transaksi,_that.pelanggan,_that.paket);case _:
  return null;

}
}

}

/// @nodoc


class _DetailLanggananState implements DetailLanggananState {
  const _DetailLanggananState({this.transaksi, this.pelanggan, this.paket});
  

@override final  TransaksiModel? transaksi;
@override final  PelangganModel? pelanggan;
@override final  PaketModel? paket;

/// Create a copy of DetailLanggananState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DetailLanggananStateCopyWith<_DetailLanggananState> get copyWith => __$DetailLanggananStateCopyWithImpl<_DetailLanggananState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DetailLanggananState&&(identical(other.transaksi, transaksi) || other.transaksi == transaksi)&&(identical(other.pelanggan, pelanggan) || other.pelanggan == pelanggan)&&(identical(other.paket, paket) || other.paket == paket));
}


@override
int get hashCode => Object.hash(runtimeType,transaksi,pelanggan,paket);

@override
String toString() {
  return 'DetailLanggananState(transaksi: $transaksi, pelanggan: $pelanggan, paket: $paket)';
}


}

/// @nodoc
abstract mixin class _$DetailLanggananStateCopyWith<$Res> implements $DetailLanggananStateCopyWith<$Res> {
  factory _$DetailLanggananStateCopyWith(_DetailLanggananState value, $Res Function(_DetailLanggananState) _then) = __$DetailLanggananStateCopyWithImpl;
@override @useResult
$Res call({
 TransaksiModel? transaksi, PelangganModel? pelanggan, PaketModel? paket
});


@override $TransaksiModelCopyWith<$Res>? get transaksi;@override $PelangganModelCopyWith<$Res>? get pelanggan;@override $PaketModelCopyWith<$Res>? get paket;

}
/// @nodoc
class __$DetailLanggananStateCopyWithImpl<$Res>
    implements _$DetailLanggananStateCopyWith<$Res> {
  __$DetailLanggananStateCopyWithImpl(this._self, this._then);

  final _DetailLanggananState _self;
  final $Res Function(_DetailLanggananState) _then;

/// Create a copy of DetailLanggananState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? transaksi = freezed,Object? pelanggan = freezed,Object? paket = freezed,}) {
  return _then(_DetailLanggananState(
transaksi: freezed == transaksi ? _self.transaksi : transaksi // ignore: cast_nullable_to_non_nullable
as TransaksiModel?,pelanggan: freezed == pelanggan ? _self.pelanggan : pelanggan // ignore: cast_nullable_to_non_nullable
as PelangganModel?,paket: freezed == paket ? _self.paket : paket // ignore: cast_nullable_to_non_nullable
as PaketModel?,
  ));
}

/// Create a copy of DetailLanggananState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TransaksiModelCopyWith<$Res>? get transaksi {
    if (_self.transaksi == null) {
    return null;
  }

  return $TransaksiModelCopyWith<$Res>(_self.transaksi!, (value) {
    return _then(_self.copyWith(transaksi: value));
  });
}/// Create a copy of DetailLanggananState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PelangganModelCopyWith<$Res>? get pelanggan {
    if (_self.pelanggan == null) {
    return null;
  }

  return $PelangganModelCopyWith<$Res>(_self.pelanggan!, (value) {
    return _then(_self.copyWith(pelanggan: value));
  });
}/// Create a copy of DetailLanggananState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PaketModelCopyWith<$Res>? get paket {
    if (_self.paket == null) {
    return null;
  }

  return $PaketModelCopyWith<$Res>(_self.paket!, (value) {
    return _then(_self.copyWith(paket: value));
  });
}
}

// dart format on
