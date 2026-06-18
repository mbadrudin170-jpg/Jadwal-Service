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

 List<TransaksiModel> get transaksi; double get totalPemasukan; double get totalPengeluaran; double get total; SortBy get sortBy;
/// Create a copy of TransaksiState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TransaksiStateCopyWith<TransaksiState> get copyWith => _$TransaksiStateCopyWithImpl<TransaksiState>(this as TransaksiState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TransaksiState&&const DeepCollectionEquality().equals(other.transaksi, transaksi)&&(identical(other.totalPemasukan, totalPemasukan) || other.totalPemasukan == totalPemasukan)&&(identical(other.totalPengeluaran, totalPengeluaran) || other.totalPengeluaran == totalPengeluaran)&&(identical(other.total, total) || other.total == total)&&(identical(other.sortBy, sortBy) || other.sortBy == sortBy));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(transaksi),totalPemasukan,totalPengeluaran,total,sortBy);

@override
String toString() {
  return 'TransaksiState(transaksi: $transaksi, totalPemasukan: $totalPemasukan, totalPengeluaran: $totalPengeluaran, total: $total, sortBy: $sortBy)';
}


}

/// @nodoc
abstract mixin class $TransaksiStateCopyWith<$Res>  {
  factory $TransaksiStateCopyWith(TransaksiState value, $Res Function(TransaksiState) _then) = _$TransaksiStateCopyWithImpl;
@useResult
$Res call({
 List<TransaksiModel> transaksi, double totalPemasukan, double totalPengeluaran, double total, SortBy sortBy
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
@pragma('vm:prefer-inline') @override $Res call({Object? transaksi = null,Object? totalPemasukan = null,Object? totalPengeluaran = null,Object? total = null,Object? sortBy = null,}) {
  return _then(_self.copyWith(
transaksi: null == transaksi ? _self.transaksi : transaksi // ignore: cast_nullable_to_non_nullable
as List<TransaksiModel>,totalPemasukan: null == totalPemasukan ? _self.totalPemasukan : totalPemasukan // ignore: cast_nullable_to_non_nullable
as double,totalPengeluaran: null == totalPengeluaran ? _self.totalPengeluaran : totalPengeluaran // ignore: cast_nullable_to_non_nullable
as double,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as double,sortBy: null == sortBy ? _self.sortBy : sortBy // ignore: cast_nullable_to_non_nullable
as SortBy,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<TransaksiModel> transaksi,  double totalPemasukan,  double totalPengeluaran,  double total,  SortBy sortBy)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TransaksiState() when $default != null:
return $default(_that.transaksi,_that.totalPemasukan,_that.totalPengeluaran,_that.total,_that.sortBy);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<TransaksiModel> transaksi,  double totalPemasukan,  double totalPengeluaran,  double total,  SortBy sortBy)  $default,) {final _that = this;
switch (_that) {
case _TransaksiState():
return $default(_that.transaksi,_that.totalPemasukan,_that.totalPengeluaran,_that.total,_that.sortBy);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<TransaksiModel> transaksi,  double totalPemasukan,  double totalPengeluaran,  double total,  SortBy sortBy)?  $default,) {final _that = this;
switch (_that) {
case _TransaksiState() when $default != null:
return $default(_that.transaksi,_that.totalPemasukan,_that.totalPengeluaran,_that.total,_that.sortBy);case _:
  return null;

}
}

}

/// @nodoc


class _TransaksiState implements TransaksiState {
  const _TransaksiState({final  List<TransaksiModel> transaksi = const [], this.totalPemasukan = 0.0, this.totalPengeluaran = 0.0, this.total = 0.0, this.sortBy = SortBy.newest}): _transaksi = transaksi;
  

 final  List<TransaksiModel> _transaksi;
@override@JsonKey() List<TransaksiModel> get transaksi {
  if (_transaksi is EqualUnmodifiableListView) return _transaksi;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_transaksi);
}

@override@JsonKey() final  double totalPemasukan;
@override@JsonKey() final  double totalPengeluaran;
@override@JsonKey() final  double total;
@override@JsonKey() final  SortBy sortBy;

/// Create a copy of TransaksiState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TransaksiStateCopyWith<_TransaksiState> get copyWith => __$TransaksiStateCopyWithImpl<_TransaksiState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TransaksiState&&const DeepCollectionEquality().equals(other._transaksi, _transaksi)&&(identical(other.totalPemasukan, totalPemasukan) || other.totalPemasukan == totalPemasukan)&&(identical(other.totalPengeluaran, totalPengeluaran) || other.totalPengeluaran == totalPengeluaran)&&(identical(other.total, total) || other.total == total)&&(identical(other.sortBy, sortBy) || other.sortBy == sortBy));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_transaksi),totalPemasukan,totalPengeluaran,total,sortBy);

@override
String toString() {
  return 'TransaksiState(transaksi: $transaksi, totalPemasukan: $totalPemasukan, totalPengeluaran: $totalPengeluaran, total: $total, sortBy: $sortBy)';
}


}

/// @nodoc
abstract mixin class _$TransaksiStateCopyWith<$Res> implements $TransaksiStateCopyWith<$Res> {
  factory _$TransaksiStateCopyWith(_TransaksiState value, $Res Function(_TransaksiState) _then) = __$TransaksiStateCopyWithImpl;
@override @useResult
$Res call({
 List<TransaksiModel> transaksi, double totalPemasukan, double totalPengeluaran, double total, SortBy sortBy
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
@override @pragma('vm:prefer-inline') $Res call({Object? transaksi = null,Object? totalPemasukan = null,Object? totalPengeluaran = null,Object? total = null,Object? sortBy = null,}) {
  return _then(_TransaksiState(
transaksi: null == transaksi ? _self._transaksi : transaksi // ignore: cast_nullable_to_non_nullable
as List<TransaksiModel>,totalPemasukan: null == totalPemasukan ? _self.totalPemasukan : totalPemasukan // ignore: cast_nullable_to_non_nullable
as double,totalPengeluaran: null == totalPengeluaran ? _self.totalPengeluaran : totalPengeluaran // ignore: cast_nullable_to_non_nullable
as double,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as double,sortBy: null == sortBy ? _self.sortBy : sortBy // ignore: cast_nullable_to_non_nullable
as SortBy,
  ));
}


}

// dart format on
