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
mixin _$DetailDompetState {

 List<TransaksiModel> get daftarTransaksi; DompetModel? get dompet; int get totalTransaksi; double get totalPemasukan; double get totalPengeluaran; double get totalSaldo; String get namaDompet;
/// Create a copy of DetailDompetState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DetailDompetStateCopyWith<DetailDompetState> get copyWith => _$DetailDompetStateCopyWithImpl<DetailDompetState>(this as DetailDompetState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DetailDompetState&&const DeepCollectionEquality().equals(other.daftarTransaksi, daftarTransaksi)&&(identical(other.dompet, dompet) || other.dompet == dompet)&&(identical(other.totalTransaksi, totalTransaksi) || other.totalTransaksi == totalTransaksi)&&(identical(other.totalPemasukan, totalPemasukan) || other.totalPemasukan == totalPemasukan)&&(identical(other.totalPengeluaran, totalPengeluaran) || other.totalPengeluaran == totalPengeluaran)&&(identical(other.totalSaldo, totalSaldo) || other.totalSaldo == totalSaldo)&&(identical(other.namaDompet, namaDompet) || other.namaDompet == namaDompet));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(daftarTransaksi),dompet,totalTransaksi,totalPemasukan,totalPengeluaran,totalSaldo,namaDompet);

@override
String toString() {
  return 'DetailDompetState(daftarTransaksi: $daftarTransaksi, dompet: $dompet, totalTransaksi: $totalTransaksi, totalPemasukan: $totalPemasukan, totalPengeluaran: $totalPengeluaran, totalSaldo: $totalSaldo, namaDompet: $namaDompet)';
}


}

/// @nodoc
abstract mixin class $DetailDompetStateCopyWith<$Res>  {
  factory $DetailDompetStateCopyWith(DetailDompetState value, $Res Function(DetailDompetState) _then) = _$DetailDompetStateCopyWithImpl;
@useResult
$Res call({
 List<TransaksiModel> daftarTransaksi, DompetModel? dompet, int totalTransaksi, double totalPemasukan, double totalPengeluaran, double totalSaldo, String namaDompet
});


$DompetModelCopyWith<$Res>? get dompet;

}
/// @nodoc
class _$DetailDompetStateCopyWithImpl<$Res>
    implements $DetailDompetStateCopyWith<$Res> {
  _$DetailDompetStateCopyWithImpl(this._self, this._then);

  final DetailDompetState _self;
  final $Res Function(DetailDompetState) _then;

/// Create a copy of DetailDompetState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? daftarTransaksi = null,Object? dompet = freezed,Object? totalTransaksi = null,Object? totalPemasukan = null,Object? totalPengeluaran = null,Object? totalSaldo = null,Object? namaDompet = null,}) {
  return _then(_self.copyWith(
daftarTransaksi: null == daftarTransaksi ? _self.daftarTransaksi : daftarTransaksi // ignore: cast_nullable_to_non_nullable
as List<TransaksiModel>,dompet: freezed == dompet ? _self.dompet : dompet // ignore: cast_nullable_to_non_nullable
as DompetModel?,totalTransaksi: null == totalTransaksi ? _self.totalTransaksi : totalTransaksi // ignore: cast_nullable_to_non_nullable
as int,totalPemasukan: null == totalPemasukan ? _self.totalPemasukan : totalPemasukan // ignore: cast_nullable_to_non_nullable
as double,totalPengeluaran: null == totalPengeluaran ? _self.totalPengeluaran : totalPengeluaran // ignore: cast_nullable_to_non_nullable
as double,totalSaldo: null == totalSaldo ? _self.totalSaldo : totalSaldo // ignore: cast_nullable_to_non_nullable
as double,namaDompet: null == namaDompet ? _self.namaDompet : namaDompet // ignore: cast_nullable_to_non_nullable
as String,
  ));
}
/// Create a copy of DetailDompetState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DompetModelCopyWith<$Res>? get dompet {
    if (_self.dompet == null) {
    return null;
  }

  return $DompetModelCopyWith<$Res>(_self.dompet!, (value) {
    return _then(_self.copyWith(dompet: value));
  });
}
}


/// Adds pattern-matching-related methods to [DetailDompetState].
extension DetailDompetStatePatterns on DetailDompetState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DetailDompetState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DetailDompetState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DetailDompetState value)  $default,){
final _that = this;
switch (_that) {
case _DetailDompetState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DetailDompetState value)?  $default,){
final _that = this;
switch (_that) {
case _DetailDompetState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<TransaksiModel> daftarTransaksi,  DompetModel? dompet,  int totalTransaksi,  double totalPemasukan,  double totalPengeluaran,  double totalSaldo,  String namaDompet)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DetailDompetState() when $default != null:
return $default(_that.daftarTransaksi,_that.dompet,_that.totalTransaksi,_that.totalPemasukan,_that.totalPengeluaran,_that.totalSaldo,_that.namaDompet);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<TransaksiModel> daftarTransaksi,  DompetModel? dompet,  int totalTransaksi,  double totalPemasukan,  double totalPengeluaran,  double totalSaldo,  String namaDompet)  $default,) {final _that = this;
switch (_that) {
case _DetailDompetState():
return $default(_that.daftarTransaksi,_that.dompet,_that.totalTransaksi,_that.totalPemasukan,_that.totalPengeluaran,_that.totalSaldo,_that.namaDompet);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<TransaksiModel> daftarTransaksi,  DompetModel? dompet,  int totalTransaksi,  double totalPemasukan,  double totalPengeluaran,  double totalSaldo,  String namaDompet)?  $default,) {final _that = this;
switch (_that) {
case _DetailDompetState() when $default != null:
return $default(_that.daftarTransaksi,_that.dompet,_that.totalTransaksi,_that.totalPemasukan,_that.totalPengeluaran,_that.totalSaldo,_that.namaDompet);case _:
  return null;

}
}

}

/// @nodoc


class _DetailDompetState implements DetailDompetState {
  const _DetailDompetState({required final  List<TransaksiModel> daftarTransaksi, this.dompet, required this.totalTransaksi, required this.totalPemasukan, required this.totalPengeluaran, required this.totalSaldo, required this.namaDompet}): _daftarTransaksi = daftarTransaksi;
  

 final  List<TransaksiModel> _daftarTransaksi;
@override List<TransaksiModel> get daftarTransaksi {
  if (_daftarTransaksi is EqualUnmodifiableListView) return _daftarTransaksi;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_daftarTransaksi);
}

@override final  DompetModel? dompet;
@override final  int totalTransaksi;
@override final  double totalPemasukan;
@override final  double totalPengeluaran;
@override final  double totalSaldo;
@override final  String namaDompet;

/// Create a copy of DetailDompetState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DetailDompetStateCopyWith<_DetailDompetState> get copyWith => __$DetailDompetStateCopyWithImpl<_DetailDompetState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DetailDompetState&&const DeepCollectionEquality().equals(other._daftarTransaksi, _daftarTransaksi)&&(identical(other.dompet, dompet) || other.dompet == dompet)&&(identical(other.totalTransaksi, totalTransaksi) || other.totalTransaksi == totalTransaksi)&&(identical(other.totalPemasukan, totalPemasukan) || other.totalPemasukan == totalPemasukan)&&(identical(other.totalPengeluaran, totalPengeluaran) || other.totalPengeluaran == totalPengeluaran)&&(identical(other.totalSaldo, totalSaldo) || other.totalSaldo == totalSaldo)&&(identical(other.namaDompet, namaDompet) || other.namaDompet == namaDompet));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_daftarTransaksi),dompet,totalTransaksi,totalPemasukan,totalPengeluaran,totalSaldo,namaDompet);

@override
String toString() {
  return 'DetailDompetState(daftarTransaksi: $daftarTransaksi, dompet: $dompet, totalTransaksi: $totalTransaksi, totalPemasukan: $totalPemasukan, totalPengeluaran: $totalPengeluaran, totalSaldo: $totalSaldo, namaDompet: $namaDompet)';
}


}

/// @nodoc
abstract mixin class _$DetailDompetStateCopyWith<$Res> implements $DetailDompetStateCopyWith<$Res> {
  factory _$DetailDompetStateCopyWith(_DetailDompetState value, $Res Function(_DetailDompetState) _then) = __$DetailDompetStateCopyWithImpl;
@override @useResult
$Res call({
 List<TransaksiModel> daftarTransaksi, DompetModel? dompet, int totalTransaksi, double totalPemasukan, double totalPengeluaran, double totalSaldo, String namaDompet
});


@override $DompetModelCopyWith<$Res>? get dompet;

}
/// @nodoc
class __$DetailDompetStateCopyWithImpl<$Res>
    implements _$DetailDompetStateCopyWith<$Res> {
  __$DetailDompetStateCopyWithImpl(this._self, this._then);

  final _DetailDompetState _self;
  final $Res Function(_DetailDompetState) _then;

/// Create a copy of DetailDompetState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? daftarTransaksi = null,Object? dompet = freezed,Object? totalTransaksi = null,Object? totalPemasukan = null,Object? totalPengeluaran = null,Object? totalSaldo = null,Object? namaDompet = null,}) {
  return _then(_DetailDompetState(
daftarTransaksi: null == daftarTransaksi ? _self._daftarTransaksi : daftarTransaksi // ignore: cast_nullable_to_non_nullable
as List<TransaksiModel>,dompet: freezed == dompet ? _self.dompet : dompet // ignore: cast_nullable_to_non_nullable
as DompetModel?,totalTransaksi: null == totalTransaksi ? _self.totalTransaksi : totalTransaksi // ignore: cast_nullable_to_non_nullable
as int,totalPemasukan: null == totalPemasukan ? _self.totalPemasukan : totalPemasukan // ignore: cast_nullable_to_non_nullable
as double,totalPengeluaran: null == totalPengeluaran ? _self.totalPengeluaran : totalPengeluaran // ignore: cast_nullable_to_non_nullable
as double,totalSaldo: null == totalSaldo ? _self.totalSaldo : totalSaldo // ignore: cast_nullable_to_non_nullable
as double,namaDompet: null == namaDompet ? _self.namaDompet : namaDompet // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of DetailDompetState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DompetModelCopyWith<$Res>? get dompet {
    if (_self.dompet == null) {
    return null;
  }

  return $DompetModelCopyWith<$Res>(_self.dompet!, (value) {
    return _then(_self.copyWith(dompet: value));
  });
}
}

/// @nodoc
mixin _$DompetState {

 List<DompetModel> get daftarDompet; double get totalSaldoPositif; double get totalSaldoNegatif; double get totalSaldo;
/// Create a copy of DompetState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DompetStateCopyWith<DompetState> get copyWith => _$DompetStateCopyWithImpl<DompetState>(this as DompetState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DompetState&&const DeepCollectionEquality().equals(other.daftarDompet, daftarDompet)&&(identical(other.totalSaldoPositif, totalSaldoPositif) || other.totalSaldoPositif == totalSaldoPositif)&&(identical(other.totalSaldoNegatif, totalSaldoNegatif) || other.totalSaldoNegatif == totalSaldoNegatif)&&(identical(other.totalSaldo, totalSaldo) || other.totalSaldo == totalSaldo));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(daftarDompet),totalSaldoPositif,totalSaldoNegatif,totalSaldo);

@override
String toString() {
  return 'DompetState(daftarDompet: $daftarDompet, totalSaldoPositif: $totalSaldoPositif, totalSaldoNegatif: $totalSaldoNegatif, totalSaldo: $totalSaldo)';
}


}

/// @nodoc
abstract mixin class $DompetStateCopyWith<$Res>  {
  factory $DompetStateCopyWith(DompetState value, $Res Function(DompetState) _then) = _$DompetStateCopyWithImpl;
@useResult
$Res call({
 List<DompetModel> daftarDompet, double totalSaldoPositif, double totalSaldoNegatif, double totalSaldo
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
@pragma('vm:prefer-inline') @override $Res call({Object? daftarDompet = null,Object? totalSaldoPositif = null,Object? totalSaldoNegatif = null,Object? totalSaldo = null,}) {
  return _then(_self.copyWith(
daftarDompet: null == daftarDompet ? _self.daftarDompet : daftarDompet // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<DompetModel> daftarDompet,  double totalSaldoPositif,  double totalSaldoNegatif,  double totalSaldo)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DompetState() when $default != null:
return $default(_that.daftarDompet,_that.totalSaldoPositif,_that.totalSaldoNegatif,_that.totalSaldo);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<DompetModel> daftarDompet,  double totalSaldoPositif,  double totalSaldoNegatif,  double totalSaldo)  $default,) {final _that = this;
switch (_that) {
case _DompetState():
return $default(_that.daftarDompet,_that.totalSaldoPositif,_that.totalSaldoNegatif,_that.totalSaldo);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<DompetModel> daftarDompet,  double totalSaldoPositif,  double totalSaldoNegatif,  double totalSaldo)?  $default,) {final _that = this;
switch (_that) {
case _DompetState() when $default != null:
return $default(_that.daftarDompet,_that.totalSaldoPositif,_that.totalSaldoNegatif,_that.totalSaldo);case _:
  return null;

}
}

}

/// @nodoc


class _DompetState implements DompetState {
  const _DompetState({final  List<DompetModel> daftarDompet = const [], this.totalSaldoPositif = 0.0, this.totalSaldoNegatif = 0.0, this.totalSaldo = 0.0}): _daftarDompet = daftarDompet;
  

 final  List<DompetModel> _daftarDompet;
@override@JsonKey() List<DompetModel> get daftarDompet {
  if (_daftarDompet is EqualUnmodifiableListView) return _daftarDompet;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_daftarDompet);
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DompetState&&const DeepCollectionEquality().equals(other._daftarDompet, _daftarDompet)&&(identical(other.totalSaldoPositif, totalSaldoPositif) || other.totalSaldoPositif == totalSaldoPositif)&&(identical(other.totalSaldoNegatif, totalSaldoNegatif) || other.totalSaldoNegatif == totalSaldoNegatif)&&(identical(other.totalSaldo, totalSaldo) || other.totalSaldo == totalSaldo));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_daftarDompet),totalSaldoPositif,totalSaldoNegatif,totalSaldo);

@override
String toString() {
  return 'DompetState(daftarDompet: $daftarDompet, totalSaldoPositif: $totalSaldoPositif, totalSaldoNegatif: $totalSaldoNegatif, totalSaldo: $totalSaldo)';
}


}

/// @nodoc
abstract mixin class _$DompetStateCopyWith<$Res> implements $DompetStateCopyWith<$Res> {
  factory _$DompetStateCopyWith(_DompetState value, $Res Function(_DompetState) _then) = __$DompetStateCopyWithImpl;
@override @useResult
$Res call({
 List<DompetModel> daftarDompet, double totalSaldoPositif, double totalSaldoNegatif, double totalSaldo
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
@override @pragma('vm:prefer-inline') $Res call({Object? daftarDompet = null,Object? totalSaldoPositif = null,Object? totalSaldoNegatif = null,Object? totalSaldo = null,}) {
  return _then(_DompetState(
daftarDompet: null == daftarDompet ? _self._daftarDompet : daftarDompet // ignore: cast_nullable_to_non_nullable
as List<DompetModel>,totalSaldoPositif: null == totalSaldoPositif ? _self.totalSaldoPositif : totalSaldoPositif // ignore: cast_nullable_to_non_nullable
as double,totalSaldoNegatif: null == totalSaldoNegatif ? _self.totalSaldoNegatif : totalSaldoNegatif // ignore: cast_nullable_to_non_nullable
as double,totalSaldo: null == totalSaldo ? _self.totalSaldo : totalSaldo // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
