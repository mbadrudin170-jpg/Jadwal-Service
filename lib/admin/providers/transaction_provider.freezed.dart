// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'transaction_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TransactionState {
  List<TransaksiModel> get transactions;
  double get totalIncome;
  double get totalExpense;
  double get netTotal;
  SortBy get sortBy;

  /// Create a copy of TransactionState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $TransactionStateCopyWith<TransactionState> get copyWith =>
      _$TransactionStateCopyWithImpl<TransactionState>(
          this as TransactionState, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is TransactionState &&
            const DeepCollectionEquality()
                .equals(other.transactions, transactions) &&
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
      const DeepCollectionEquality().hash(transactions),
      totalIncome,
      totalExpense,
      netTotal,
      sortBy);

  @override
  String toString() {
    return 'TransactionState(transactions: $transactions, totalIncome: $totalIncome, totalExpense: $totalExpense, netTotal: $netTotal, sortBy: $sortBy)';
  }
}

/// @nodoc
abstract mixin class $TransactionStateCopyWith<$Res> {
  factory $TransactionStateCopyWith(
          TransactionState value, $Res Function(TransactionState) _then) =
      _$TransactionStateCopyWithImpl;
  @useResult
  $Res call(
      {List<TransaksiModel> transactions,
      double totalIncome,
      double totalExpense,
      double netTotal,
      SortBy sortBy});
}

/// @nodoc
class _$TransactionStateCopyWithImpl<$Res>
    implements $TransactionStateCopyWith<$Res> {
  _$TransactionStateCopyWithImpl(this._self, this._then);

  final TransactionState _self;
  final $Res Function(TransactionState) _then;

  /// Create a copy of TransactionState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? transactions = null,
    Object? totalIncome = null,
    Object? totalExpense = null,
    Object? netTotal = null,
    Object? sortBy = null,
  }) {
    return _then(_self.copyWith(
      transactions: null == transactions
          ? _self.transactions
          : transactions // ignore: cast_nullable_to_non_nullable
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

/// Adds pattern-matching-related methods to [TransactionState].
extension TransactionStatePatterns on TransactionState {
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
    TResult Function(_TransactionState value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _TransactionState() when $default != null:
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
    TResult Function(_TransactionState value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TransactionState():
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
    TResult? Function(_TransactionState value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TransactionState() when $default != null:
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
    TResult Function(List<TransaksiModel> transactions, double totalIncome,
            double totalExpense, double netTotal, SortBy sortBy)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _TransactionState() when $default != null:
        return $default(_that.transactions, _that.totalIncome,
            _that.totalExpense, _that.netTotal, _that.sortBy);
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
    TResult Function(List<TransaksiModel> transactions, double totalIncome,
            double totalExpense, double netTotal, SortBy sortBy)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TransactionState():
        return $default(_that.transactions, _that.totalIncome,
            _that.totalExpense, _that.netTotal, _that.sortBy);
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
    TResult? Function(List<TransaksiModel> transactions, double totalIncome,
            double totalExpense, double netTotal, SortBy sortBy)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TransactionState() when $default != null:
        return $default(_that.transactions, _that.totalIncome,
            _that.totalExpense, _that.netTotal, _that.sortBy);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _TransactionState implements TransactionState {
  const _TransactionState(
      {final List<TransaksiModel> transactions = const [],
      this.totalIncome = 0.0,
      this.totalExpense = 0.0,
      this.netTotal = 0.0,
      this.sortBy = SortBy.newest})
      : _transactions = transactions;

  final List<TransaksiModel> _transactions;
  @override
  @JsonKey()
  List<TransaksiModel> get transactions {
    if (_transactions is EqualUnmodifiableListView) return _transactions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_transactions);
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

  /// Create a copy of TransactionState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$TransactionStateCopyWith<_TransactionState> get copyWith =>
      __$TransactionStateCopyWithImpl<_TransactionState>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _TransactionState &&
            const DeepCollectionEquality()
                .equals(other._transactions, _transactions) &&
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
      const DeepCollectionEquality().hash(_transactions),
      totalIncome,
      totalExpense,
      netTotal,
      sortBy);

  @override
  String toString() {
    return 'TransactionState(transactions: $transactions, totalIncome: $totalIncome, totalExpense: $totalExpense, netTotal: $netTotal, sortBy: $sortBy)';
  }
}

/// @nodoc
abstract mixin class _$TransactionStateCopyWith<$Res>
    implements $TransactionStateCopyWith<$Res> {
  factory _$TransactionStateCopyWith(
          _TransactionState value, $Res Function(_TransactionState) _then) =
      __$TransactionStateCopyWithImpl;
  @override
  @useResult
  $Res call(
      {List<TransaksiModel> transactions,
      double totalIncome,
      double totalExpense,
      double netTotal,
      SortBy sortBy});
}

/// @nodoc
class __$TransactionStateCopyWithImpl<$Res>
    implements _$TransactionStateCopyWith<$Res> {
  __$TransactionStateCopyWithImpl(this._self, this._then);

  final _TransactionState _self;
  final $Res Function(_TransactionState) _then;

  /// Create a copy of TransactionState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? transactions = null,
    Object? totalIncome = null,
    Object? totalExpense = null,
    Object? netTotal = null,
    Object? sortBy = null,
  }) {
    return _then(_TransactionState(
      transactions: null == transactions
          ? _self._transactions
          : transactions // ignore: cast_nullable_to_non_nullable
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
