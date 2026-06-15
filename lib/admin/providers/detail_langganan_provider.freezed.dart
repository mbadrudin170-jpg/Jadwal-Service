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
  TransaksiModel? get transaction;
  PelangganModel? get customer;
  PaketModel? get package;

  /// Create a copy of DetailLanggananState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $DetailLanggananStateCopyWith<DetailLanggananState> get copyWith =>
      _$DetailLanggananStateCopyWithImpl<DetailLanggananState>(
          this as DetailLanggananState, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is DetailLanggananState &&
            (identical(other.transaction, transaction) ||
                other.transaction == transaction) &&
            (identical(other.customer, customer) ||
                other.customer == customer) &&
            (identical(other.package, package) || other.package == package));
  }

  @override
  int get hashCode => Object.hash(runtimeType, transaction, customer, package);

  @override
  String toString() {
    return 'DetailLanggananState(transaction: $transaction, customer: $customer, package: $package)';
  }
}

/// @nodoc
abstract mixin class $DetailLanggananStateCopyWith<$Res> {
  factory $DetailLanggananStateCopyWith(DetailLanggananState value,
          $Res Function(DetailLanggananState) _then) =
      _$DetailLanggananStateCopyWithImpl;
  @useResult
  $Res call(
      {TransaksiModel? transaction,
      PelangganModel? customer,
      PaketModel? package});

  $TransaksiModelCopyWith<$Res>? get transaction;
  $PelangganModelCopyWith<$Res>? get customer;
  $PaketModelCopyWith<$Res>? get package;
}

/// @nodoc
class _$DetailLanggananStateCopyWithImpl<$Res>
    implements $DetailLanggananStateCopyWith<$Res> {
  _$DetailLanggananStateCopyWithImpl(this._self, this._then);

  final DetailLanggananState _self;
  final $Res Function(DetailLanggananState) _then;

  /// Create a copy of DetailLanggananState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? transaction = freezed,
    Object? customer = freezed,
    Object? package = freezed,
  }) {
    return _then(_self.copyWith(
      transaction: freezed == transaction
          ? _self.transaction
          : transaction // ignore: cast_nullable_to_non_nullable
              as TransaksiModel?,
      customer: freezed == customer
          ? _self.customer
          : customer // ignore: cast_nullable_to_non_nullable
              as PelangganModel?,
      package: freezed == package
          ? _self.package
          : package // ignore: cast_nullable_to_non_nullable
              as PaketModel?,
    ));
  }

  /// Create a copy of DetailLanggananState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TransaksiModelCopyWith<$Res>? get transaction {
    if (_self.transaction == null) {
      return null;
    }

    return $TransaksiModelCopyWith<$Res>(_self.transaction!, (value) {
      return _then(_self.copyWith(transaction: value));
    });
  }

  /// Create a copy of DetailLanggananState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PelangganModelCopyWith<$Res>? get customer {
    if (_self.customer == null) {
      return null;
    }

    return $PelangganModelCopyWith<$Res>(_self.customer!, (value) {
      return _then(_self.copyWith(customer: value));
    });
  }

  /// Create a copy of DetailLanggananState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PaketModelCopyWith<$Res>? get package {
    if (_self.package == null) {
      return null;
    }

    return $PaketModelCopyWith<$Res>(_self.package!, (value) {
      return _then(_self.copyWith(package: value));
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

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_DetailLanggananState value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _DetailLanggananState() when $default != null:
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
    TResult Function(_DetailLanggananState value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DetailLanggananState():
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
    TResult? Function(_DetailLanggananState value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DetailLanggananState() when $default != null:
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
    TResult Function(TransaksiModel? transaction, PelangganModel? customer,
            PaketModel? package)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _DetailLanggananState() when $default != null:
        return $default(_that.transaction, _that.customer, _that.package);
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
    TResult Function(TransaksiModel? transaction, PelangganModel? customer,
            PaketModel? package)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DetailLanggananState():
        return $default(_that.transaction, _that.customer, _that.package);
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
    TResult? Function(TransaksiModel? transaction, PelangganModel? customer,
            PaketModel? package)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DetailLanggananState() when $default != null:
        return $default(_that.transaction, _that.customer, _that.package);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _DetailLanggananState implements DetailLanggananState {
  const _DetailLanggananState({this.transaction, this.customer, this.package});

  @override
  final TransaksiModel? transaction;
  @override
  final PelangganModel? customer;
  @override
  final PaketModel? package;

  /// Create a copy of DetailLanggananState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$DetailLanggananStateCopyWith<_DetailLanggananState> get copyWith =>
      __$DetailLanggananStateCopyWithImpl<_DetailLanggananState>(
          this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _DetailLanggananState &&
            (identical(other.transaction, transaction) ||
                other.transaction == transaction) &&
            (identical(other.customer, customer) ||
                other.customer == customer) &&
            (identical(other.package, package) || other.package == package));
  }

  @override
  int get hashCode => Object.hash(runtimeType, transaction, customer, package);

  @override
  String toString() {
    return 'DetailLanggananState(transaction: $transaction, customer: $customer, package: $package)';
  }
}

/// @nodoc
abstract mixin class _$DetailLanggananStateCopyWith<$Res>
    implements $DetailLanggananStateCopyWith<$Res> {
  factory _$DetailLanggananStateCopyWith(_DetailLanggananState value,
          $Res Function(_DetailLanggananState) _then) =
      __$DetailLanggananStateCopyWithImpl;
  @override
  @useResult
  $Res call(
      {TransaksiModel? transaction,
      PelangganModel? customer,
      PaketModel? package});

  @override
  $TransaksiModelCopyWith<$Res>? get transaction;
  @override
  $PelangganModelCopyWith<$Res>? get customer;
  @override
  $PaketModelCopyWith<$Res>? get package;
}

/// @nodoc
class __$DetailLanggananStateCopyWithImpl<$Res>
    implements _$DetailLanggananStateCopyWith<$Res> {
  __$DetailLanggananStateCopyWithImpl(this._self, this._then);

  final _DetailLanggananState _self;
  final $Res Function(_DetailLanggananState) _then;

  /// Create a copy of DetailLanggananState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? transaction = freezed,
    Object? customer = freezed,
    Object? package = freezed,
  }) {
    return _then(_DetailLanggananState(
      transaction: freezed == transaction
          ? _self.transaction
          : transaction // ignore: cast_nullable_to_non_nullable
              as TransaksiModel?,
      customer: freezed == customer
          ? _self.customer
          : customer // ignore: cast_nullable_to_non_nullable
              as PelangganModel?,
      package: freezed == package
          ? _self.package
          : package // ignore: cast_nullable_to_non_nullable
              as PaketModel?,
    ));
  }

  /// Create a copy of DetailLanggananState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TransaksiModelCopyWith<$Res>? get transaction {
    if (_self.transaction == null) {
      return null;
    }

    return $TransaksiModelCopyWith<$Res>(_self.transaction!, (value) {
      return _then(_self.copyWith(transaction: value));
    });
  }

  /// Create a copy of DetailLanggananState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PelangganModelCopyWith<$Res>? get customer {
    if (_self.customer == null) {
      return null;
    }

    return $PelangganModelCopyWith<$Res>(_self.customer!, (value) {
      return _then(_self.copyWith(customer: value));
    });
  }

  /// Create a copy of DetailLanggananState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PaketModelCopyWith<$Res>? get package {
    if (_self.package == null) {
      return null;
    }

    return $PaketModelCopyWith<$Res>(_self.package!, (value) {
      return _then(_self.copyWith(package: value));
    });
  }
}

// dart format on
