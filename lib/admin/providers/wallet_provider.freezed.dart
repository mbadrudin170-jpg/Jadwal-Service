// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'wallet_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$WalletState {
  List<WalletModel> get wallets;
  double get totalPositiveBalance;
  double get totalNegativeBalance;
  double get totalBalance;

  /// Create a copy of WalletState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $WalletStateCopyWith<WalletState> get copyWith =>
      _$WalletStateCopyWithImpl<WalletState>(this as WalletState, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is WalletState &&
            const DeepCollectionEquality().equals(other.wallets, wallets) &&
            (identical(other.totalPositiveBalance, totalPositiveBalance) ||
                other.totalPositiveBalance == totalPositiveBalance) &&
            (identical(other.totalNegativeBalance, totalNegativeBalance) ||
                other.totalNegativeBalance == totalNegativeBalance) &&
            (identical(other.totalBalance, totalBalance) ||
                other.totalBalance == totalBalance));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(wallets),
      totalPositiveBalance,
      totalNegativeBalance,
      totalBalance);

  @override
  String toString() {
    return 'WalletState(wallets: $wallets, totalPositiveBalance: $totalPositiveBalance, totalNegativeBalance: $totalNegativeBalance, totalBalance: $totalBalance)';
  }
}

/// @nodoc
abstract mixin class $WalletStateCopyWith<$Res> {
  factory $WalletStateCopyWith(
          WalletState value, $Res Function(WalletState) _then) =
      _$WalletStateCopyWithImpl;
  @useResult
  $Res call(
      {List<WalletModel> wallets,
      double totalPositiveBalance,
      double totalNegativeBalance,
      double totalBalance});
}

/// @nodoc
class _$WalletStateCopyWithImpl<$Res> implements $WalletStateCopyWith<$Res> {
  _$WalletStateCopyWithImpl(this._self, this._then);

  final WalletState _self;
  final $Res Function(WalletState) _then;

  /// Create a copy of WalletState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? wallets = null,
    Object? totalPositiveBalance = null,
    Object? totalNegativeBalance = null,
    Object? totalBalance = null,
  }) {
    return _then(_self.copyWith(
      wallets: null == wallets
          ? _self.wallets
          : wallets // ignore: cast_nullable_to_non_nullable
              as List<WalletModel>,
      totalPositiveBalance: null == totalPositiveBalance
          ? _self.totalPositiveBalance
          : totalPositiveBalance // ignore: cast_nullable_to_non_nullable
              as double,
      totalNegativeBalance: null == totalNegativeBalance
          ? _self.totalNegativeBalance
          : totalNegativeBalance // ignore: cast_nullable_to_non_nullable
              as double,
      totalBalance: null == totalBalance
          ? _self.totalBalance
          : totalBalance // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// Adds pattern-matching-related methods to [WalletState].
extension WalletStatePatterns on WalletState {
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
    TResult Function(_WalletState value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _WalletState() when $default != null:
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
    TResult Function(_WalletState value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _WalletState():
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
    TResult? Function(_WalletState value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _WalletState() when $default != null:
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
    TResult Function(List<WalletModel> wallets, double totalPositiveBalance,
            double totalNegativeBalance, double totalBalance)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _WalletState() when $default != null:
        return $default(_that.wallets, _that.totalPositiveBalance,
            _that.totalNegativeBalance, _that.totalBalance);
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
    TResult Function(List<WalletModel> wallets, double totalPositiveBalance,
            double totalNegativeBalance, double totalBalance)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _WalletState():
        return $default(_that.wallets, _that.totalPositiveBalance,
            _that.totalNegativeBalance, _that.totalBalance);
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
    TResult? Function(List<WalletModel> wallets, double totalPositiveBalance,
            double totalNegativeBalance, double totalBalance)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _WalletState() when $default != null:
        return $default(_that.wallets, _that.totalPositiveBalance,
            _that.totalNegativeBalance, _that.totalBalance);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _WalletState implements WalletState {
  const _WalletState(
      {final List<WalletModel> wallets = const [],
      this.totalPositiveBalance = 0.0,
      this.totalNegativeBalance = 0.0,
      this.totalBalance = 0.0})
      : _wallets = wallets;

  final List<WalletModel> _wallets;
  @override
  @JsonKey()
  List<WalletModel> get wallets {
    if (_wallets is EqualUnmodifiableListView) return _wallets;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_wallets);
  }

  @override
  @JsonKey()
  final double totalPositiveBalance;
  @override
  @JsonKey()
  final double totalNegativeBalance;
  @override
  @JsonKey()
  final double totalBalance;

  /// Create a copy of WalletState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$WalletStateCopyWith<_WalletState> get copyWith =>
      __$WalletStateCopyWithImpl<_WalletState>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _WalletState &&
            const DeepCollectionEquality().equals(other._wallets, _wallets) &&
            (identical(other.totalPositiveBalance, totalPositiveBalance) ||
                other.totalPositiveBalance == totalPositiveBalance) &&
            (identical(other.totalNegativeBalance, totalNegativeBalance) ||
                other.totalNegativeBalance == totalNegativeBalance) &&
            (identical(other.totalBalance, totalBalance) ||
                other.totalBalance == totalBalance));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_wallets),
      totalPositiveBalance,
      totalNegativeBalance,
      totalBalance);

  @override
  String toString() {
    return 'WalletState(wallets: $wallets, totalPositiveBalance: $totalPositiveBalance, totalNegativeBalance: $totalNegativeBalance, totalBalance: $totalBalance)';
  }
}

/// @nodoc
abstract mixin class _$WalletStateCopyWith<$Res>
    implements $WalletStateCopyWith<$Res> {
  factory _$WalletStateCopyWith(
          _WalletState value, $Res Function(_WalletState) _then) =
      __$WalletStateCopyWithImpl;
  @override
  @useResult
  $Res call(
      {List<WalletModel> wallets,
      double totalPositiveBalance,
      double totalNegativeBalance,
      double totalBalance});
}

/// @nodoc
class __$WalletStateCopyWithImpl<$Res> implements _$WalletStateCopyWith<$Res> {
  __$WalletStateCopyWithImpl(this._self, this._then);

  final _WalletState _self;
  final $Res Function(_WalletState) _then;

  /// Create a copy of WalletState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? wallets = null,
    Object? totalPositiveBalance = null,
    Object? totalNegativeBalance = null,
    Object? totalBalance = null,
  }) {
    return _then(_WalletState(
      wallets: null == wallets
          ? _self._wallets
          : wallets // ignore: cast_nullable_to_non_nullable
              as List<WalletModel>,
      totalPositiveBalance: null == totalPositiveBalance
          ? _self.totalPositiveBalance
          : totalPositiveBalance // ignore: cast_nullable_to_non_nullable
              as double,
      totalNegativeBalance: null == totalNegativeBalance
          ? _self.totalNegativeBalance
          : totalNegativeBalance // ignore: cast_nullable_to_non_nullable
              as double,
      totalBalance: null == totalBalance
          ? _self.totalBalance
          : totalBalance // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

// dart format on
