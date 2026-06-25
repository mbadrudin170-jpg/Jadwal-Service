// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'transaksi_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TransaksiState {

 List<TransaksiModel> get transaksi; double get totalPemasukan; double get totalPengeluaran; double get total; int get totalPoinSemuaPelanggan; List<PaketTerlarisModel> get paketTerlaris; List<double> get pendapatanHarian; List<double> get pendapatanMingguan; List<double> get pendapatanBulanan;
/// Create a copy of TransaksiState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TransaksiStateCopyWith<TransaksiState> get copyWith => _$TransaksiStateCopyWithImpl<TransaksiState>(this as TransaksiState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TransaksiState&&const DeepCollectionEquality().equals(other.transaksi, transaksi)&&(identical(other.totalPemasukan, totalPemasukan) || other.totalPemasukan == totalPemasukan)&&(identical(other.totalPengeluaran, totalPengeluaran) || other.totalPengeluaran == totalPengeluaran)&&(identical(other.total, total) || other.total == total)&&(identical(other.totalPoinSemuaPelanggan, totalPoinSemuaPelanggan) || other.totalPoinSemuaPelanggan == totalPoinSemuaPelanggan)&&const DeepCollectionEquality().equals(other.paketTerlaris, paketTerlaris)&&const DeepCollectionEquality().equals(other.pendapatanHarian, pendapatanHarian)&&const DeepCollectionEquality().equals(other.pendapatanMingguan, pendapatanMingguan)&&const DeepCollectionEquality().equals(other.pendapatanBulanan, pendapatanBulanan));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(transaksi),totalPemasukan,totalPengeluaran,total,totalPoinSemuaPelanggan,const DeepCollectionEquality().hash(paketTerlaris),const DeepCollectionEquality().hash(pendapatanHarian),const DeepCollectionEquality().hash(pendapatanMingguan),const DeepCollectionEquality().hash(pendapatanBulanan));

@override
String toString() {
  return 'TransaksiState(transaksi: $transaksi, totalPemasukan: $totalPemasukan, totalPengeluaran: $totalPengeluaran, total: $total, totalPoinSemuaPelanggan: $totalPoinSemuaPelanggan, paketTerlaris: $paketTerlaris, pendapatanHarian: $pendapatanHarian, pendapatanMingguan: $pendapatanMingguan, pendapatanBulanan: $pendapatanBulanan)';
}


}

/// @nodoc
abstract mixin class $TransaksiStateCopyWith<$Res>  {
  factory $TransaksiStateCopyWith(TransaksiState value, $Res Function(TransaksiState) _then) = _$TransaksiStateCopyWithImpl;
@useResult
$Res call({
 List<TransaksiModel> transaksi, double totalPemasukan, double totalPengeluaran, double total, int totalPoinSemuaPelanggan, List<PaketTerlarisModel> paketTerlaris, List<double> pendapatanHarian, List<double> pendapatanMingguan, List<double> pendapatanBulanan
});




}
/// @nodoc
class _$TransaksiStateCopyWithImpl<$Res>
    implements $TransaksiStateCopyWith<$Res> {
  _$TransaksiStateCopyWithImpl(this._self, this._then);

  final TransaksiState _self;
  final $Res Function(TransaksiState) _then;

/// Create a copy of TransaksiState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? transaksi = null,Object? totalPemasukan = null,Object? totalPengeluaran = null,Object? total = null,Object? totalPoinSemuaPelanggan = null,Object? paketTerlaris = null,Object? pendapatanHarian = null,Object? pendapatanMingguan = null,Object? pendapatanBulanan = null,}) {
  return _then(_self.copyWith(
transaksi: null == transaksi ? _self.transaksi : transaksi // ignore: cast_nullable_to_non_nullable
as List<TransaksiModel>,totalPemasukan: null == totalPemasukan ? _self.totalPemasukan : totalPemasukan // ignore: cast_nullable_to_non_nullable
as double,totalPengeluaran: null == totalPengeluaran ? _self.totalPengeluaran : totalPengeluaran // ignore: cast_nullable_to_non_nullable
as double,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as double,totalPoinSemuaPelanggan: null == totalPoinSemuaPelanggan ? _self.totalPoinSemuaPelanggan : totalPoinSemuaPelanggan // ignore: cast_nullable_to_non_nullable
as int,paketTerlaris: null == paketTerlaris ? _self.paketTerlaris : paketTerlaris // ignore: cast_nullable_to_non_nullable
as List<PaketTerlarisModel>,pendapatanHarian: null == pendapatanHarian ? _self.pendapatanHarian : pendapatanHarian // ignore: cast_nullable_to_non_nullable
as List<double>,pendapatanMingguan: null == pendapatanMingguan ? _self.pendapatanMingguan : pendapatanMingguan // ignore: cast_nullable_to_non_nullable
as List<double>,pendapatanBulanan: null == pendapatanBulanan ? _self.pendapatanBulanan : pendapatanBulanan // ignore: cast_nullable_to_non_nullable
as List<double>,
  ));
}

}


/// Adds pattern-matching-related methods to [TransaksiState].
extension TransaksiStatePatterns on TransaksiState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TransaksiState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TransaksiState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TransaksiState value)  $default,){
final _that = this;
switch (_that) {
case _TransaksiState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TransaksiState value)?  $default,){
final _that = this;
switch (_that) {
case _TransaksiState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<TransaksiModel> transaksi,  double totalPemasukan,  double totalPengeluaran,  double total,  int totalPoinSemuaPelanggan,  List<PaketTerlarisModel> paketTerlaris,  List<double> pendapatanHarian,  List<double> pendapatanMingguan,  List<double> pendapatanBulanan)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TransaksiState() when $default != null:
return $default(_that.transaksi,_that.totalPemasukan,_that.totalPengeluaran,_that.total,_that.totalPoinSemuaPelanggan,_that.paketTerlaris,_that.pendapatanHarian,_that.pendapatanMingguan,_that.pendapatanBulanan);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<TransaksiModel> transaksi,  double totalPemasukan,  double totalPengeluaran,  double total,  int totalPoinSemuaPelanggan,  List<PaketTerlarisModel> paketTerlaris,  List<double> pendapatanHarian,  List<double> pendapatanMingguan,  List<double> pendapatanBulanan)  $default,) {final _that = this;
switch (_that) {
case _TransaksiState():
return $default(_that.transaksi,_that.totalPemasukan,_that.totalPengeluaran,_that.total,_that.totalPoinSemuaPelanggan,_that.paketTerlaris,_that.pendapatanHarian,_that.pendapatanMingguan,_that.pendapatanBulanan);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<TransaksiModel> transaksi,  double totalPemasukan,  double totalPengeluaran,  double total,  int totalPoinSemuaPelanggan,  List<PaketTerlarisModel> paketTerlaris,  List<double> pendapatanHarian,  List<double> pendapatanMingguan,  List<double> pendapatanBulanan)?  $default,) {final _that = this;
switch (_that) {
case _TransaksiState() when $default != null:
return $default(_that.transaksi,_that.totalPemasukan,_that.totalPengeluaran,_that.total,_that.totalPoinSemuaPelanggan,_that.paketTerlaris,_that.pendapatanHarian,_that.pendapatanMingguan,_that.pendapatanBulanan);case _:
  return null;

}
}

}

/// @nodoc


class _TransaksiState implements TransaksiState {
  const _TransaksiState({final  List<TransaksiModel> transaksi = const [], this.totalPemasukan = 0.0, this.totalPengeluaran = 0.0, this.total = 0.0, this.totalPoinSemuaPelanggan = 0, required final  List<PaketTerlarisModel> paketTerlaris, required final  List<double> pendapatanHarian, required final  List<double> pendapatanMingguan, required final  List<double> pendapatanBulanan}): _transaksi = transaksi,_paketTerlaris = paketTerlaris,_pendapatanHarian = pendapatanHarian,_pendapatanMingguan = pendapatanMingguan,_pendapatanBulanan = pendapatanBulanan;
  

 final  List<TransaksiModel> _transaksi;
@override@JsonKey() List<TransaksiModel> get transaksi {
  if (_transaksi is EqualUnmodifiableListView) return _transaksi;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_transaksi);
}

@override@JsonKey() final  double totalPemasukan;
@override@JsonKey() final  double totalPengeluaran;
@override@JsonKey() final  double total;
@override@JsonKey() final  int totalPoinSemuaPelanggan;
 final  List<PaketTerlarisModel> _paketTerlaris;
@override List<PaketTerlarisModel> get paketTerlaris {
  if (_paketTerlaris is EqualUnmodifiableListView) return _paketTerlaris;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_paketTerlaris);
}

 final  List<double> _pendapatanHarian;
@override List<double> get pendapatanHarian {
  if (_pendapatanHarian is EqualUnmodifiableListView) return _pendapatanHarian;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_pendapatanHarian);
}

 final  List<double> _pendapatanMingguan;
@override List<double> get pendapatanMingguan {
  if (_pendapatanMingguan is EqualUnmodifiableListView) return _pendapatanMingguan;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_pendapatanMingguan);
}

 final  List<double> _pendapatanBulanan;
@override List<double> get pendapatanBulanan {
  if (_pendapatanBulanan is EqualUnmodifiableListView) return _pendapatanBulanan;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_pendapatanBulanan);
}


/// Create a copy of TransaksiState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TransaksiStateCopyWith<_TransaksiState> get copyWith => __$TransaksiStateCopyWithImpl<_TransaksiState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TransaksiState&&const DeepCollectionEquality().equals(other._transaksi, _transaksi)&&(identical(other.totalPemasukan, totalPemasukan) || other.totalPemasukan == totalPemasukan)&&(identical(other.totalPengeluaran, totalPengeluaran) || other.totalPengeluaran == totalPengeluaran)&&(identical(other.total, total) || other.total == total)&&(identical(other.totalPoinSemuaPelanggan, totalPoinSemuaPelanggan) || other.totalPoinSemuaPelanggan == totalPoinSemuaPelanggan)&&const DeepCollectionEquality().equals(other._paketTerlaris, _paketTerlaris)&&const DeepCollectionEquality().equals(other._pendapatanHarian, _pendapatanHarian)&&const DeepCollectionEquality().equals(other._pendapatanMingguan, _pendapatanMingguan)&&const DeepCollectionEquality().equals(other._pendapatanBulanan, _pendapatanBulanan));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_transaksi),totalPemasukan,totalPengeluaran,total,totalPoinSemuaPelanggan,const DeepCollectionEquality().hash(_paketTerlaris),const DeepCollectionEquality().hash(_pendapatanHarian),const DeepCollectionEquality().hash(_pendapatanMingguan),const DeepCollectionEquality().hash(_pendapatanBulanan));

@override
String toString() {
  return 'TransaksiState(transaksi: $transaksi, totalPemasukan: $totalPemasukan, totalPengeluaran: $totalPengeluaran, total: $total, totalPoinSemuaPelanggan: $totalPoinSemuaPelanggan, paketTerlaris: $paketTerlaris, pendapatanHarian: $pendapatanHarian, pendapatanMingguan: $pendapatanMingguan, pendapatanBulanan: $pendapatanBulanan)';
}


}

/// @nodoc
abstract mixin class _$TransaksiStateCopyWith<$Res> implements $TransaksiStateCopyWith<$Res> {
  factory _$TransaksiStateCopyWith(_TransaksiState value, $Res Function(_TransaksiState) _then) = __$TransaksiStateCopyWithImpl;
@override @useResult
$Res call({
 List<TransaksiModel> transaksi, double totalPemasukan, double totalPengeluaran, double total, int totalPoinSemuaPelanggan, List<PaketTerlarisModel> paketTerlaris, List<double> pendapatanHarian, List<double> pendapatanMingguan, List<double> pendapatanBulanan
});




}
/// @nodoc
class __$TransaksiStateCopyWithImpl<$Res>
    implements _$TransaksiStateCopyWith<$Res> {
  __$TransaksiStateCopyWithImpl(this._self, this._then);

  final _TransaksiState _self;
  final $Res Function(_TransaksiState) _then;

/// Create a copy of TransaksiState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? transaksi = null,Object? totalPemasukan = null,Object? totalPengeluaran = null,Object? total = null,Object? totalPoinSemuaPelanggan = null,Object? paketTerlaris = null,Object? pendapatanHarian = null,Object? pendapatanMingguan = null,Object? pendapatanBulanan = null,}) {
  return _then(_TransaksiState(
transaksi: null == transaksi ? _self._transaksi : transaksi // ignore: cast_nullable_to_non_nullable
as List<TransaksiModel>,totalPemasukan: null == totalPemasukan ? _self.totalPemasukan : totalPemasukan // ignore: cast_nullable_to_non_nullable
as double,totalPengeluaran: null == totalPengeluaran ? _self.totalPengeluaran : totalPengeluaran // ignore: cast_nullable_to_non_nullable
as double,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as double,totalPoinSemuaPelanggan: null == totalPoinSemuaPelanggan ? _self.totalPoinSemuaPelanggan : totalPoinSemuaPelanggan // ignore: cast_nullable_to_non_nullable
as int,paketTerlaris: null == paketTerlaris ? _self._paketTerlaris : paketTerlaris // ignore: cast_nullable_to_non_nullable
as List<PaketTerlarisModel>,pendapatanHarian: null == pendapatanHarian ? _self._pendapatanHarian : pendapatanHarian // ignore: cast_nullable_to_non_nullable
as List<double>,pendapatanMingguan: null == pendapatanMingguan ? _self._pendapatanMingguan : pendapatanMingguan // ignore: cast_nullable_to_non_nullable
as List<double>,pendapatanBulanan: null == pendapatanBulanan ? _self._pendapatanBulanan : pendapatanBulanan // ignore: cast_nullable_to_non_nullable
as List<double>,
  ));
}


}

// dart format on
