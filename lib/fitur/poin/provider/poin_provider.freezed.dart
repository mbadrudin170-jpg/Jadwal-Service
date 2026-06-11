// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'poin_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PoinState {
  List<PackageModel> get rewards;
  List<TransactionModel> get transaksi;
  int get totalPoin;

  /// Create a copy of PoinState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $PoinStateCopyWith<PoinState> get copyWith =>
      _$PoinStateCopyWithImpl<PoinState>(this as PoinState, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is PoinState &&
            const DeepCollectionEquality().equals(other.rewards, rewards) &&
            const DeepCollectionEquality().equals(other.transaksi, transaksi) &&
            (identical(other.totalPoin, totalPoin) ||
                other.totalPoin == totalPoin));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(rewards),
      const DeepCollectionEquality().hash(transaksi),
      totalPoin);

  @override
  String toString() {
    return 'PoinState(rewards: $rewards, transaksi: $transaksi, totalPoin: $totalPoin)';
  }
}

/// @nodoc
abstract mixin class $PoinStateCopyWith<$Res> {
  factory $PoinStateCopyWith(PoinState value, $Res Function(PoinState) _then) =
      _$PoinStateCopyWithImpl;
  @useResult
  $Res call(
      {List<PackageModel> rewards,
      List<TransactionModel> transaksi,
      int totalPoin});
}

/// @nodoc
class _$PoinStateCopyWithImpl<$Res> implements $PoinStateCopyWith<$Res> {
  _$PoinStateCopyWithImpl(this._self, this._then);

  final PoinState _self;
  final $Res Function(PoinState) _then;

  /// Create a copy of PoinState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? rewards = null,
    Object? transaksi = null,
    Object? totalPoin = null,
  }) {
    return _then(_self.copyWith(
      rewards: null == rewards
          ? _self.rewards
          : rewards // ignore: cast_nullable_to_non_nullable
              as List<PackageModel>,
      transaksi: null == transaksi
          ? _self.transaksi
          : transaksi // ignore: cast_nullable_to_non_nullable
              as List<TransactionModel>,
      totalPoin: null == totalPoin
          ? _self.totalPoin
          : totalPoin // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// Adds pattern-matching-related methods to [PoinState].
extension PoinStatePatterns on PoinState {
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
    TResult Function(_PoinState value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _PoinState() when $default != null:
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
    TResult Function(_PoinState value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PoinState():
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
    TResult? Function(_PoinState value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PoinState() when $default != null:
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
    TResult Function(List<PackageModel> rewards,
            List<TransactionModel> transaksi, int totalPoin)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _PoinState() when $default != null:
        return $default(_that.rewards, _that.transaksi, _that.totalPoin);
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
    TResult Function(List<PackageModel> rewards,
            List<TransactionModel> transaksi, int totalPoin)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PoinState():
        return $default(_that.rewards, _that.transaksi, _that.totalPoin);
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
    TResult? Function(List<PackageModel> rewards,
            List<TransactionModel> transaksi, int totalPoin)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PoinState() when $default != null:
        return $default(_that.rewards, _that.transaksi, _that.totalPoin);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _PoinState implements PoinState {
  const _PoinState(
      {final List<PackageModel> rewards = const [],
      final List<TransactionModel> transaksi = const [],
      this.totalPoin = 0})
      : _rewards = rewards,
        _transaksi = transaksi;

  final List<PackageModel> _rewards;
  @override
  @JsonKey()
  List<PackageModel> get rewards {
    if (_rewards is EqualUnmodifiableListView) return _rewards;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_rewards);
  }

  final List<TransactionModel> _transaksi;
  @override
  @JsonKey()
  List<TransactionModel> get transaksi {
    if (_transaksi is EqualUnmodifiableListView) return _transaksi;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_transaksi);
  }

  @override
  @JsonKey()
  final int totalPoin;

  /// Create a copy of PoinState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$PoinStateCopyWith<_PoinState> get copyWith =>
      __$PoinStateCopyWithImpl<_PoinState>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _PoinState &&
            const DeepCollectionEquality().equals(other._rewards, _rewards) &&
            const DeepCollectionEquality()
                .equals(other._transaksi, _transaksi) &&
            (identical(other.totalPoin, totalPoin) ||
                other.totalPoin == totalPoin));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_rewards),
      const DeepCollectionEquality().hash(_transaksi),
      totalPoin);

  @override
  String toString() {
    return 'PoinState(rewards: $rewards, transaksi: $transaksi, totalPoin: $totalPoin)';
  }
}

/// @nodoc
abstract mixin class _$PoinStateCopyWith<$Res>
    implements $PoinStateCopyWith<$Res> {
  factory _$PoinStateCopyWith(
          _PoinState value, $Res Function(_PoinState) _then) =
      __$PoinStateCopyWithImpl;
  @override
  @useResult
  $Res call(
      {List<PackageModel> rewards,
      List<TransactionModel> transaksi,
      int totalPoin});
}

/// @nodoc
class __$PoinStateCopyWithImpl<$Res> implements _$PoinStateCopyWith<$Res> {
  __$PoinStateCopyWithImpl(this._self, this._then);

  final _PoinState _self;
  final $Res Function(_PoinState) _then;

  /// Create a copy of PoinState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? rewards = null,
    Object? transaksi = null,
    Object? totalPoin = null,
  }) {
    return _then(_PoinState(
      rewards: null == rewards
          ? _self._rewards
          : rewards // ignore: cast_nullable_to_non_nullable
              as List<PackageModel>,
      transaksi: null == transaksi
          ? _self._transaksi
          : transaksi // ignore: cast_nullable_to_non_nullable
              as List<TransactionModel>,
      totalPoin: null == totalPoin
          ? _self.totalPoin
          : totalPoin // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

// dart format on
