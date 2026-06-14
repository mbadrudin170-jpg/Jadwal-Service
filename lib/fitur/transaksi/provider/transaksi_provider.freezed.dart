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
  List<TransaksiModel> get transaksi;
  double get totalIncome;
  double get totalExpense;
  double get netTotal;
  SortBy get sortBy;

  /// Create a copy of TransaksiState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $TransaksiStateCopyWith<TransaksiState> get copyWith =>
      _$TransaksiStateCopyWithImpl<TransaksiState>(
          this as TransaksiState, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is TransaksiState &&
            const DeepCollectionEquality().equals(other.transaksi, transaksi) &&
            (identical(other.totalIncome, totalIncome) ||
                other.totalIncome == totalIncome) &&
            (identical(other.totalExpense, totalExpense) ||
                other.totalExpense == totalExpense) &&
            (identical(other.netTotal, netTotal) ||
                other.netTotal == netTotal) &&
            (identical(other.sortBy, sortBy) || other.sortBy == sortBy));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(transaksi),
      totalIncome,
      totalExpense,
      netTotal,
      sortBy);

  @override
  String toString() {
    return 'TransaksiState(transaksi: $transaksi, totalIncome: $totalIncome, totalExpense: $totalExpense, netTotal: $netTotal, sortBy: $sortBy)';
  }
}

/// @nodoc
abstract mixin class $TransaksiStateCopyWith<$Res> {
  factory $TransaksiStateCopyWith(
          TransaksiState value, $Res Function(TransaksiState) _then) =
      _$TransaksiStateCopyWithImpl;
  @useResult
  $Res call(
      {List<TransaksiModel> transaksi,
      double totalIncome,
      double totalExpense,
      double netTotal,
      SortBy sortBy});
}

/// @nodoc
class _$TransaksiStateCopyWithImpl<$Res>
    implements $TransaksiStateCopyWith<$Res> {
  _$TransaksiStateCopyWithImpl(this._self, this._then);

  final TransaksiState _self;
  final $Res Function(TransaksiState) _then;

  /// Create a copy of TransaksiState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? transaksi = null,
    Object? totalIncome = null,
    Object? totalExpense = null,
    Object? netTotal = null,
    Object? sortBy = null,
  }) {
    return _then(_self.copyWith(
      transaksi: null == transaksi
          ? _self.transaksi
          : transaksi // ignore: cast_nullable_to_non_nullable
              as List<TransaksiModel>,
      totalIncome: null == totalIncome
          ? _self.totalIncome
          : totalIncome // ignore: cast_nullable_to_non_nullable
              as double,
      totalExpense: null == totalExpense
          ? _self.totalExpense
          : totalExpense // ignore: cast_nullable_to_non_nullable
              as double,
      netTotal: null == netTotal
          ? _self.netTotal
          : netTotal // ignore: cast_nullable_to_non_nullable
              as double,
      sortBy: null == sortBy
          ? _self.sortBy
          : sortBy // ignore: cast_nullable_to_non_nullable
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

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_TransaksiState value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _TransaksiState() when $default != null:
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_TransaksiState value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TransaksiState():
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_TransaksiState value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TransaksiState() when $default != null:
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(List<TransaksiModel> transaksi, double totalIncome,
            double totalExpense, double netTotal, SortBy sortBy)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _TransaksiState() when $default != null:
        return $default(_that.transaksi, _that.totalIncome, _that.totalExpense,
            _that.netTotal, _that.sortBy);
      case _:
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

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(List<TransaksiModel> transaksi, double totalIncome,
            double totalExpense, double netTotal, SortBy sortBy)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TransaksiState():
        return $default(_that.transaksi, _that.totalIncome, _that.totalExpense,
            _that.netTotal, _that.sortBy);
      case _:
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

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(List<TransaksiModel> transaksi, double totalIncome,
            double totalExpense, double netTotal, SortBy sortBy)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TransaksiState() when $default != null:
        return $default(_that.transaksi, _that.totalIncome, _that.totalExpense,
            _that.netTotal, _that.sortBy);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _TransaksiState implements TransaksiState {
  const _TransaksiState(
      {final List<TransaksiModel> transaksi = const [],
      this.totalIncome = 0.0,
      this.totalExpense = 0.0,
      this.netTotal = 0.0,
      this.sortBy = SortBy.newest})
      : _transaksi = transaksi;

  final List<TransaksiModel> _transaksi;
  @override
  @JsonKey()
  List<TransaksiModel> get transaksi {
    if (_transaksi is EqualUnmodifiableListView) return _transaksi;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_transaksi);
  }

  @override
  @JsonKey()
  final double totalIncome;
  @override
  @JsonKey()
  final double totalExpense;
  @override
  @JsonKey()
  final double netTotal;
  @override
  @JsonKey()
  final SortBy sortBy;

  /// Create a copy of TransaksiState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$TransaksiStateCopyWith<_TransaksiState> get copyWith =>
      __$TransaksiStateCopyWithImpl<_TransaksiState>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _TransaksiState &&
            const DeepCollectionEquality()
                .equals(other._transaksi, _transaksi) &&
            (identical(other.totalIncome, totalIncome) ||
                other.totalIncome == totalIncome) &&
            (identical(other.totalExpense, totalExpense) ||
                other.totalExpense == totalExpense) &&
            (identical(other.netTotal, netTotal) ||
                other.netTotal == netTotal) &&
            (identical(other.sortBy, sortBy) || other.sortBy == sortBy));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_transaksi),
      totalIncome,
      totalExpense,
      netTotal,
      sortBy);

  @override
  String toString() {
    return 'TransaksiState(transaksi: $transaksi, totalIncome: $totalIncome, totalExpense: $totalExpense, netTotal: $netTotal, sortBy: $sortBy)';
  }
}

/// @nodoc
abstract mixin class _$TransaksiStateCopyWith<$Res>
    implements $TransaksiStateCopyWith<$Res> {
  factory _$TransaksiStateCopyWith(
          _TransaksiState value, $Res Function(_TransaksiState) _then) =
      __$TransaksiStateCopyWithImpl;
  @override
  @useResult
  $Res call(
      {List<TransaksiModel> transaksi,
      double totalIncome,
      double totalExpense,
      double netTotal,
      SortBy sortBy});
}

/// @nodoc
class __$TransaksiStateCopyWithImpl<$Res>
    implements _$TransaksiStateCopyWith<$Res> {
  __$TransaksiStateCopyWithImpl(this._self, this._then);

  final _TransaksiState _self;
  final $Res Function(_TransaksiState) _then;

  /// Create a copy of TransaksiState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? transaksi = null,
    Object? totalIncome = null,
    Object? totalExpense = null,
    Object? netTotal = null,
    Object? sortBy = null,
  }) {
    return _then(_TransaksiState(
      transaksi: null == transaksi
          ? _self._transaksi
          : transaksi // ignore: cast_nullable_to_non_nullable
              as List<TransaksiModel>,
      totalIncome: null == totalIncome
          ? _self.totalIncome
          : totalIncome // ignore: cast_nullable_to_non_nullable
              as double,
      totalExpense: null == totalExpense
          ? _self.totalExpense
          : totalExpense // ignore: cast_nullable_to_non_nullable
              as double,
      netTotal: null == netTotal
          ? _self.netTotal
          : netTotal // ignore: cast_nullable_to_non_nullable
              as double,
      sortBy: null == sortBy
          ? _self.sortBy
          : sortBy // ignore: cast_nullable_to_non_nullable
              as SortBy,
    ));
  }
}

// dart format on
