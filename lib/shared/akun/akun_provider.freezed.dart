// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'akun_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AkunState {
  CustomerModel? get akunSaatIni;
  List<CustomerModel> get daftarAkunTersimpan;

  /// Create a copy of AkunState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $AkunStateCopyWith<AkunState> get copyWith =>
      _$AkunStateCopyWithImpl<AkunState>(this as AkunState, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is AkunState &&
            (identical(other.akunSaatIni, akunSaatIni) ||
                other.akunSaatIni == akunSaatIni) &&
            const DeepCollectionEquality()
                .equals(other.daftarAkunTersimpan, daftarAkunTersimpan));
  }

  @override
  int get hashCode => Object.hash(runtimeType, akunSaatIni,
      const DeepCollectionEquality().hash(daftarAkunTersimpan));

  @override
  String toString() {
    return 'AkunState(akunSaatIni: $akunSaatIni, daftarAkunTersimpan: $daftarAkunTersimpan)';
  }
}

/// @nodoc
abstract mixin class $AkunStateCopyWith<$Res> {
  factory $AkunStateCopyWith(AkunState value, $Res Function(AkunState) _then) =
      _$AkunStateCopyWithImpl;
  @useResult
  $Res call(
      {CustomerModel? akunSaatIni, List<CustomerModel> daftarAkunTersimpan});
}

/// @nodoc
class _$AkunStateCopyWithImpl<$Res> implements $AkunStateCopyWith<$Res> {
  _$AkunStateCopyWithImpl(this._self, this._then);

  final AkunState _self;
  final $Res Function(AkunState) _then;

  /// Create a copy of AkunState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? akunSaatIni = freezed,
    Object? daftarAkunTersimpan = null,
  }) {
    return _then(_self.copyWith(
      akunSaatIni: freezed == akunSaatIni
          ? _self.akunSaatIni
          : akunSaatIni // ignore: cast_nullable_to_non_nullable
              as CustomerModel?,
      daftarAkunTersimpan: null == daftarAkunTersimpan
          ? _self.daftarAkunTersimpan
          : daftarAkunTersimpan // ignore: cast_nullable_to_non_nullable
              as List<CustomerModel>,
    ));
  }
}

/// Adds pattern-matching-related methods to [AkunState].
extension AkunStatePatterns on AkunState {
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
    TResult Function(_AkunState value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _AkunState() when $default != null:
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
    TResult Function(_AkunState value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AkunState():
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
    TResult? Function(_AkunState value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AkunState() when $default != null:
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
    TResult Function(CustomerModel? akunSaatIni,
            List<CustomerModel> daftarAkunTersimpan)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _AkunState() when $default != null:
        return $default(_that.akunSaatIni, _that.daftarAkunTersimpan);
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
    TResult Function(
            CustomerModel? akunSaatIni, List<CustomerModel> daftarAkunTersimpan)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AkunState():
        return $default(_that.akunSaatIni, _that.daftarAkunTersimpan);
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
    TResult? Function(CustomerModel? akunSaatIni,
            List<CustomerModel> daftarAkunTersimpan)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AkunState() when $default != null:
        return $default(_that.akunSaatIni, _that.daftarAkunTersimpan);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _AkunState implements AkunState {
  const _AkunState(
      {this.akunSaatIni,
      final List<CustomerModel> daftarAkunTersimpan = const []})
      : _daftarAkunTersimpan = daftarAkunTersimpan;

  @override
  final CustomerModel? akunSaatIni;
  final List<CustomerModel> _daftarAkunTersimpan;
  @override
  @JsonKey()
  List<CustomerModel> get daftarAkunTersimpan {
    if (_daftarAkunTersimpan is EqualUnmodifiableListView)
      return _daftarAkunTersimpan;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_daftarAkunTersimpan);
  }

  /// Create a copy of AkunState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$AkunStateCopyWith<_AkunState> get copyWith =>
      __$AkunStateCopyWithImpl<_AkunState>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _AkunState &&
            (identical(other.akunSaatIni, akunSaatIni) ||
                other.akunSaatIni == akunSaatIni) &&
            const DeepCollectionEquality()
                .equals(other._daftarAkunTersimpan, _daftarAkunTersimpan));
  }

  @override
  int get hashCode => Object.hash(runtimeType, akunSaatIni,
      const DeepCollectionEquality().hash(_daftarAkunTersimpan));

  @override
  String toString() {
    return 'AkunState(akunSaatIni: $akunSaatIni, daftarAkunTersimpan: $daftarAkunTersimpan)';
  }
}

/// @nodoc
abstract mixin class _$AkunStateCopyWith<$Res>
    implements $AkunStateCopyWith<$Res> {
  factory _$AkunStateCopyWith(
          _AkunState value, $Res Function(_AkunState) _then) =
      __$AkunStateCopyWithImpl;
  @override
  @useResult
  $Res call(
      {CustomerModel? akunSaatIni, List<CustomerModel> daftarAkunTersimpan});
}

/// @nodoc
class __$AkunStateCopyWithImpl<$Res> implements _$AkunStateCopyWith<$Res> {
  __$AkunStateCopyWithImpl(this._self, this._then);

  final _AkunState _self;
  final $Res Function(_AkunState) _then;

  /// Create a copy of AkunState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? akunSaatIni = freezed,
    Object? daftarAkunTersimpan = null,
  }) {
    return _then(_AkunState(
      akunSaatIni: freezed == akunSaatIni
          ? _self.akunSaatIni
          : akunSaatIni // ignore: cast_nullable_to_non_nullable
              as CustomerModel?,
      daftarAkunTersimpan: null == daftarAkunTersimpan
          ? _self._daftarAkunTersimpan
          : daftarAkunTersimpan // ignore: cast_nullable_to_non_nullable
              as List<CustomerModel>,
    ));
  }
}

// dart format on
