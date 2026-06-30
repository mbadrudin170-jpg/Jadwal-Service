// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pelanggan_aktif_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PelangganAktifState implements DiagnosticableTreeMixin {

 List<DetailPelangganAktifModel> get daftarPelangganAktif; int get jumlahPelangganAktif;
/// Create a copy of PelangganAktifState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PelangganAktifStateCopyWith<PelangganAktifState> get copyWith => _$PelangganAktifStateCopyWithImpl<PelangganAktifState>(this as PelangganAktifState, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'PelangganAktifState'))
    ..add(DiagnosticsProperty('daftarPelangganAktif', daftarPelangganAktif))..add(DiagnosticsProperty('jumlahPelangganAktif', jumlahPelangganAktif));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PelangganAktifState&&const DeepCollectionEquality().equals(other.daftarPelangganAktif, daftarPelangganAktif)&&(identical(other.jumlahPelangganAktif, jumlahPelangganAktif) || other.jumlahPelangganAktif == jumlahPelangganAktif));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(daftarPelangganAktif),jumlahPelangganAktif);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'PelangganAktifState(daftarPelangganAktif: $daftarPelangganAktif, jumlahPelangganAktif: $jumlahPelangganAktif)';
}


}

/// @nodoc
abstract mixin class $PelangganAktifStateCopyWith<$Res>  {
  factory $PelangganAktifStateCopyWith(PelangganAktifState value, $Res Function(PelangganAktifState) _then) = _$PelangganAktifStateCopyWithImpl;
@useResult
$Res call({
 List<DetailPelangganAktifModel> daftarPelangganAktif, int jumlahPelangganAktif
});




}
/// @nodoc
class _$PelangganAktifStateCopyWithImpl<$Res>
    implements $PelangganAktifStateCopyWith<$Res> {
  _$PelangganAktifStateCopyWithImpl(this._self, this._then);

  final PelangganAktifState _self;
  final $Res Function(PelangganAktifState) _then;

/// Create a copy of PelangganAktifState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? daftarPelangganAktif = null,Object? jumlahPelangganAktif = null,}) {
  return _then(_self.copyWith(
daftarPelangganAktif: null == daftarPelangganAktif ? _self.daftarPelangganAktif : daftarPelangganAktif // ignore: cast_nullable_to_non_nullable
as List<DetailPelangganAktifModel>,jumlahPelangganAktif: null == jumlahPelangganAktif ? _self.jumlahPelangganAktif : jumlahPelangganAktif // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [PelangganAktifState].
extension PelangganAktifStatePatterns on PelangganAktifState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PelangganAktifState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PelangganAktifState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PelangganAktifState value)  $default,){
final _that = this;
switch (_that) {
case _PelangganAktifState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PelangganAktifState value)?  $default,){
final _that = this;
switch (_that) {
case _PelangganAktifState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<DetailPelangganAktifModel> daftarPelangganAktif,  int jumlahPelangganAktif)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PelangganAktifState() when $default != null:
return $default(_that.daftarPelangganAktif,_that.jumlahPelangganAktif);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<DetailPelangganAktifModel> daftarPelangganAktif,  int jumlahPelangganAktif)  $default,) {final _that = this;
switch (_that) {
case _PelangganAktifState():
return $default(_that.daftarPelangganAktif,_that.jumlahPelangganAktif);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<DetailPelangganAktifModel> daftarPelangganAktif,  int jumlahPelangganAktif)?  $default,) {final _that = this;
switch (_that) {
case _PelangganAktifState() when $default != null:
return $default(_that.daftarPelangganAktif,_that.jumlahPelangganAktif);case _:
  return null;

}
}

}

/// @nodoc


class _PelangganAktifState with DiagnosticableTreeMixin implements PelangganAktifState {
  const _PelangganAktifState({final  List<DetailPelangganAktifModel> daftarPelangganAktif = const [], this.jumlahPelangganAktif = 0}): _daftarPelangganAktif = daftarPelangganAktif;
  

 final  List<DetailPelangganAktifModel> _daftarPelangganAktif;
@override@JsonKey() List<DetailPelangganAktifModel> get daftarPelangganAktif {
  if (_daftarPelangganAktif is EqualUnmodifiableListView) return _daftarPelangganAktif;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_daftarPelangganAktif);
}

@override@JsonKey() final  int jumlahPelangganAktif;

/// Create a copy of PelangganAktifState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PelangganAktifStateCopyWith<_PelangganAktifState> get copyWith => __$PelangganAktifStateCopyWithImpl<_PelangganAktifState>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'PelangganAktifState'))
    ..add(DiagnosticsProperty('daftarPelangganAktif', daftarPelangganAktif))..add(DiagnosticsProperty('jumlahPelangganAktif', jumlahPelangganAktif));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PelangganAktifState&&const DeepCollectionEquality().equals(other._daftarPelangganAktif, _daftarPelangganAktif)&&(identical(other.jumlahPelangganAktif, jumlahPelangganAktif) || other.jumlahPelangganAktif == jumlahPelangganAktif));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_daftarPelangganAktif),jumlahPelangganAktif);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'PelangganAktifState(daftarPelangganAktif: $daftarPelangganAktif, jumlahPelangganAktif: $jumlahPelangganAktif)';
}


}

/// @nodoc
abstract mixin class _$PelangganAktifStateCopyWith<$Res> implements $PelangganAktifStateCopyWith<$Res> {
  factory _$PelangganAktifStateCopyWith(_PelangganAktifState value, $Res Function(_PelangganAktifState) _then) = __$PelangganAktifStateCopyWithImpl;
@override @useResult
$Res call({
 List<DetailPelangganAktifModel> daftarPelangganAktif, int jumlahPelangganAktif
});




}
/// @nodoc
class __$PelangganAktifStateCopyWithImpl<$Res>
    implements _$PelangganAktifStateCopyWith<$Res> {
  __$PelangganAktifStateCopyWithImpl(this._self, this._then);

  final _PelangganAktifState _self;
  final $Res Function(_PelangganAktifState) _then;

/// Create a copy of PelangganAktifState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? daftarPelangganAktif = null,Object? jumlahPelangganAktif = null,}) {
  return _then(_PelangganAktifState(
daftarPelangganAktif: null == daftarPelangganAktif ? _self._daftarPelangganAktif : daftarPelangganAktif // ignore: cast_nullable_to_non_nullable
as List<DetailPelangganAktifModel>,jumlahPelangganAktif: null == jumlahPelangganAktif ? _self.jumlahPelangganAktif : jumlahPelangganAktif // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$DetailPelangganAktifState implements DiagnosticableTreeMixin {

 PelangganAktifModel get pelangganAktif; PelangganModel get pelanggan; TransaksiModel get transaksi; PaketModel get paket;
/// Create a copy of DetailPelangganAktifState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DetailPelangganAktifStateCopyWith<DetailPelangganAktifState> get copyWith => _$DetailPelangganAktifStateCopyWithImpl<DetailPelangganAktifState>(this as DetailPelangganAktifState, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'DetailPelangganAktifState'))
    ..add(DiagnosticsProperty('pelangganAktif', pelangganAktif))..add(DiagnosticsProperty('pelanggan', pelanggan))..add(DiagnosticsProperty('transaksi', transaksi))..add(DiagnosticsProperty('paket', paket));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DetailPelangganAktifState&&(identical(other.pelangganAktif, pelangganAktif) || other.pelangganAktif == pelangganAktif)&&(identical(other.pelanggan, pelanggan) || other.pelanggan == pelanggan)&&(identical(other.transaksi, transaksi) || other.transaksi == transaksi)&&(identical(other.paket, paket) || other.paket == paket));
}


@override
int get hashCode => Object.hash(runtimeType,pelangganAktif,pelanggan,transaksi,paket);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'DetailPelangganAktifState(pelangganAktif: $pelangganAktif, pelanggan: $pelanggan, transaksi: $transaksi, paket: $paket)';
}


}

/// @nodoc
abstract mixin class $DetailPelangganAktifStateCopyWith<$Res>  {
  factory $DetailPelangganAktifStateCopyWith(DetailPelangganAktifState value, $Res Function(DetailPelangganAktifState) _then) = _$DetailPelangganAktifStateCopyWithImpl;
@useResult
$Res call({
 PelangganAktifModel pelangganAktif, PelangganModel pelanggan, TransaksiModel transaksi, PaketModel paket
});


$PelangganAktifModelCopyWith<$Res> get pelangganAktif;$PelangganModelCopyWith<$Res> get pelanggan;$TransaksiModelCopyWith<$Res> get transaksi;$PaketModelCopyWith<$Res> get paket;

}
/// @nodoc
class _$DetailPelangganAktifStateCopyWithImpl<$Res>
    implements $DetailPelangganAktifStateCopyWith<$Res> {
  _$DetailPelangganAktifStateCopyWithImpl(this._self, this._then);

  final DetailPelangganAktifState _self;
  final $Res Function(DetailPelangganAktifState) _then;

/// Create a copy of DetailPelangganAktifState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? pelangganAktif = null,Object? pelanggan = null,Object? transaksi = null,Object? paket = null,}) {
  return _then(_self.copyWith(
pelangganAktif: null == pelangganAktif ? _self.pelangganAktif : pelangganAktif // ignore: cast_nullable_to_non_nullable
as PelangganAktifModel,pelanggan: null == pelanggan ? _self.pelanggan : pelanggan // ignore: cast_nullable_to_non_nullable
as PelangganModel,transaksi: null == transaksi ? _self.transaksi : transaksi // ignore: cast_nullable_to_non_nullable
as TransaksiModel,paket: null == paket ? _self.paket : paket // ignore: cast_nullable_to_non_nullable
as PaketModel,
  ));
}
/// Create a copy of DetailPelangganAktifState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PelangganAktifModelCopyWith<$Res> get pelangganAktif {
  
  return $PelangganAktifModelCopyWith<$Res>(_self.pelangganAktif, (value) {
    return _then(_self.copyWith(pelangganAktif: value));
  });
}/// Create a copy of DetailPelangganAktifState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PelangganModelCopyWith<$Res> get pelanggan {
  
  return $PelangganModelCopyWith<$Res>(_self.pelanggan, (value) {
    return _then(_self.copyWith(pelanggan: value));
  });
}/// Create a copy of DetailPelangganAktifState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TransaksiModelCopyWith<$Res> get transaksi {
  
  return $TransaksiModelCopyWith<$Res>(_self.transaksi, (value) {
    return _then(_self.copyWith(transaksi: value));
  });
}/// Create a copy of DetailPelangganAktifState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PaketModelCopyWith<$Res> get paket {
  
  return $PaketModelCopyWith<$Res>(_self.paket, (value) {
    return _then(_self.copyWith(paket: value));
  });
}
}


/// Adds pattern-matching-related methods to [DetailPelangganAktifState].
extension DetailPelangganAktifStatePatterns on DetailPelangganAktifState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DetailPelangganAktifState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DetailPelangganAktifState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DetailPelangganAktifState value)  $default,){
final _that = this;
switch (_that) {
case _DetailPelangganAktifState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DetailPelangganAktifState value)?  $default,){
final _that = this;
switch (_that) {
case _DetailPelangganAktifState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( PelangganAktifModel pelangganAktif,  PelangganModel pelanggan,  TransaksiModel transaksi,  PaketModel paket)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DetailPelangganAktifState() when $default != null:
return $default(_that.pelangganAktif,_that.pelanggan,_that.transaksi,_that.paket);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( PelangganAktifModel pelangganAktif,  PelangganModel pelanggan,  TransaksiModel transaksi,  PaketModel paket)  $default,) {final _that = this;
switch (_that) {
case _DetailPelangganAktifState():
return $default(_that.pelangganAktif,_that.pelanggan,_that.transaksi,_that.paket);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( PelangganAktifModel pelangganAktif,  PelangganModel pelanggan,  TransaksiModel transaksi,  PaketModel paket)?  $default,) {final _that = this;
switch (_that) {
case _DetailPelangganAktifState() when $default != null:
return $default(_that.pelangganAktif,_that.pelanggan,_that.transaksi,_that.paket);case _:
  return null;

}
}

}

/// @nodoc


class _DetailPelangganAktifState with DiagnosticableTreeMixin implements DetailPelangganAktifState {
  const _DetailPelangganAktifState({required this.pelangganAktif, required this.pelanggan, required this.transaksi, required this.paket});
  

@override final  PelangganAktifModel pelangganAktif;
@override final  PelangganModel pelanggan;
@override final  TransaksiModel transaksi;
@override final  PaketModel paket;

/// Create a copy of DetailPelangganAktifState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DetailPelangganAktifStateCopyWith<_DetailPelangganAktifState> get copyWith => __$DetailPelangganAktifStateCopyWithImpl<_DetailPelangganAktifState>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'DetailPelangganAktifState'))
    ..add(DiagnosticsProperty('pelangganAktif', pelangganAktif))..add(DiagnosticsProperty('pelanggan', pelanggan))..add(DiagnosticsProperty('transaksi', transaksi))..add(DiagnosticsProperty('paket', paket));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DetailPelangganAktifState&&(identical(other.pelangganAktif, pelangganAktif) || other.pelangganAktif == pelangganAktif)&&(identical(other.pelanggan, pelanggan) || other.pelanggan == pelanggan)&&(identical(other.transaksi, transaksi) || other.transaksi == transaksi)&&(identical(other.paket, paket) || other.paket == paket));
}


@override
int get hashCode => Object.hash(runtimeType,pelangganAktif,pelanggan,transaksi,paket);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'DetailPelangganAktifState(pelangganAktif: $pelangganAktif, pelanggan: $pelanggan, transaksi: $transaksi, paket: $paket)';
}


}

/// @nodoc
abstract mixin class _$DetailPelangganAktifStateCopyWith<$Res> implements $DetailPelangganAktifStateCopyWith<$Res> {
  factory _$DetailPelangganAktifStateCopyWith(_DetailPelangganAktifState value, $Res Function(_DetailPelangganAktifState) _then) = __$DetailPelangganAktifStateCopyWithImpl;
@override @useResult
$Res call({
 PelangganAktifModel pelangganAktif, PelangganModel pelanggan, TransaksiModel transaksi, PaketModel paket
});


@override $PelangganAktifModelCopyWith<$Res> get pelangganAktif;@override $PelangganModelCopyWith<$Res> get pelanggan;@override $TransaksiModelCopyWith<$Res> get transaksi;@override $PaketModelCopyWith<$Res> get paket;

}
/// @nodoc
class __$DetailPelangganAktifStateCopyWithImpl<$Res>
    implements _$DetailPelangganAktifStateCopyWith<$Res> {
  __$DetailPelangganAktifStateCopyWithImpl(this._self, this._then);

  final _DetailPelangganAktifState _self;
  final $Res Function(_DetailPelangganAktifState) _then;

/// Create a copy of DetailPelangganAktifState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? pelangganAktif = null,Object? pelanggan = null,Object? transaksi = null,Object? paket = null,}) {
  return _then(_DetailPelangganAktifState(
pelangganAktif: null == pelangganAktif ? _self.pelangganAktif : pelangganAktif // ignore: cast_nullable_to_non_nullable
as PelangganAktifModel,pelanggan: null == pelanggan ? _self.pelanggan : pelanggan // ignore: cast_nullable_to_non_nullable
as PelangganModel,transaksi: null == transaksi ? _self.transaksi : transaksi // ignore: cast_nullable_to_non_nullable
as TransaksiModel,paket: null == paket ? _self.paket : paket // ignore: cast_nullable_to_non_nullable
as PaketModel,
  ));
}

/// Create a copy of DetailPelangganAktifState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PelangganAktifModelCopyWith<$Res> get pelangganAktif {
  
  return $PelangganAktifModelCopyWith<$Res>(_self.pelangganAktif, (value) {
    return _then(_self.copyWith(pelangganAktif: value));
  });
}/// Create a copy of DetailPelangganAktifState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PelangganModelCopyWith<$Res> get pelanggan {
  
  return $PelangganModelCopyWith<$Res>(_self.pelanggan, (value) {
    return _then(_self.copyWith(pelanggan: value));
  });
}/// Create a copy of DetailPelangganAktifState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TransaksiModelCopyWith<$Res> get transaksi {
  
  return $TransaksiModelCopyWith<$Res>(_self.transaksi, (value) {
    return _then(_self.copyWith(transaksi: value));
  });
}/// Create a copy of DetailPelangganAktifState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PaketModelCopyWith<$Res> get paket {
  
  return $PaketModelCopyWith<$Res>(_self.paket, (value) {
    return _then(_self.copyWith(paket: value));
  });
}
}

// dart format on
