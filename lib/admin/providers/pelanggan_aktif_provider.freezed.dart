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
mixin _$PelangganAktifState {
  List<DetailPelangganAktifModel> get daftarPelangganAktif;
  SortOption get sortBy;

  /// Create a copy of PelangganAktifState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $PelangganAktifStateCopyWith<PelangganAktifState> get copyWith =>
      _$PelangganAktifStateCopyWithImpl<PelangganAktifState>(
          this as PelangganAktifState, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is PelangganAktifState &&
            const DeepCollectionEquality()
                .equals(other.daftarPelangganAktif, daftarPelangganAktif) &&
            (identical(other.sortBy, sortBy) || other.sortBy == sortBy));
  }

  @override
  int get hashCode => Object.hash(runtimeType,
      const DeepCollectionEquality().hash(daftarPelangganAktif), sortBy);

  @override
  String toString() {
    return 'PelangganAktifState(daftarPelangganAktif: $daftarPelangganAktif, sortBy: $sortBy)';
  }
}

/// @nodoc
abstract mixin class $PelangganAktifStateCopyWith<$Res> {
  factory $PelangganAktifStateCopyWith(
          PelangganAktifState value, $Res Function(PelangganAktifState) _then) =
      _$PelangganAktifStateCopyWithImpl;
  @useResult
  $Res call(
      {List<DetailPelangganAktifModel> daftarPelangganAktif,
      SortOption sortBy});
}

/// @nodoc
class _$PelangganAktifStateCopyWithImpl<$Res>
    implements $PelangganAktifStateCopyWith<$Res> {
  _$PelangganAktifStateCopyWithImpl(this._self, this._then);

  final PelangganAktifState _self;
  final $Res Function(PelangganAktifState) _then;

  /// Create a copy of PelangganAktifState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? daftarPelangganAktif = null,
    Object? sortBy = null,
  }) {
    return _then(_self.copyWith(
      daftarPelangganAktif: null == daftarPelangganAktif
          ? _self.daftarPelangganAktif
          : daftarPelangganAktif // ignore: cast_nullable_to_non_nullable
              as List<DetailPelangganAktifModel>,
      sortBy: null == sortBy
          ? _self.sortBy
          : sortBy // ignore: cast_nullable_to_non_nullable
              as SortOption,
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

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_PelangganAktifState value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _PelangganAktifState() when $default != null:
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
    TResult Function(_PelangganAktifState value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PelangganAktifState():
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
    TResult? Function(_PelangganAktifState value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PelangganAktifState() when $default != null:
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
    TResult Function(List<DetailPelangganAktifModel> daftarPelangganAktif,
            SortOption sortBy)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _PelangganAktifState() when $default != null:
        return $default(_that.daftarPelangganAktif, _that.sortBy);
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
    TResult Function(List<DetailPelangganAktifModel> daftarPelangganAktif,
            SortOption sortBy)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PelangganAktifState():
        return $default(_that.daftarPelangganAktif, _that.sortBy);
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
    TResult? Function(List<DetailPelangganAktifModel> daftarPelangganAktif,
            SortOption sortBy)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PelangganAktifState() when $default != null:
        return $default(_that.daftarPelangganAktif, _that.sortBy);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _PelangganAktifState implements PelangganAktifState {
  const _PelangganAktifState(
      {final List<DetailPelangganAktifModel> daftarPelangganAktif = const [],
      this.sortBy = SortOption.berakhirHariIni})
      : _daftarPelangganAktif = daftarPelangganAktif;

  final List<DetailPelangganAktifModel> _daftarPelangganAktif;
  @override
  @JsonKey()
  List<DetailPelangganAktifModel> get daftarPelangganAktif {
    if (_daftarPelangganAktif is EqualUnmodifiableListView)
      return _daftarPelangganAktif;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_daftarPelangganAktif);
  }

  @override
  @JsonKey()
  final SortOption sortBy;

  /// Create a copy of PelangganAktifState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$PelangganAktifStateCopyWith<_PelangganAktifState> get copyWith =>
      __$PelangganAktifStateCopyWithImpl<_PelangganAktifState>(
          this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _PelangganAktifState &&
            const DeepCollectionEquality()
                .equals(other._daftarPelangganAktif, _daftarPelangganAktif) &&
            (identical(other.sortBy, sortBy) || other.sortBy == sortBy));
  }

  @override
  int get hashCode => Object.hash(runtimeType,
      const DeepCollectionEquality().hash(_daftarPelangganAktif), sortBy);

  @override
  String toString() {
    return 'PelangganAktifState(daftarPelangganAktif: $daftarPelangganAktif, sortBy: $sortBy)';
  }
}

/// @nodoc
abstract mixin class _$PelangganAktifStateCopyWith<$Res>
    implements $PelangganAktifStateCopyWith<$Res> {
  factory _$PelangganAktifStateCopyWith(_PelangganAktifState value,
          $Res Function(_PelangganAktifState) _then) =
      __$PelangganAktifStateCopyWithImpl;
  @override
  @useResult
  $Res call(
      {List<DetailPelangganAktifModel> daftarPelangganAktif,
      SortOption sortBy});
}

/// @nodoc
class __$PelangganAktifStateCopyWithImpl<$Res>
    implements _$PelangganAktifStateCopyWith<$Res> {
  __$PelangganAktifStateCopyWithImpl(this._self, this._then);

  final _PelangganAktifState _self;
  final $Res Function(_PelangganAktifState) _then;

  /// Create a copy of PelangganAktifState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? daftarPelangganAktif = null,
    Object? sortBy = null,
  }) {
    return _then(_PelangganAktifState(
      daftarPelangganAktif: null == daftarPelangganAktif
          ? _self._daftarPelangganAktif
          : daftarPelangganAktif // ignore: cast_nullable_to_non_nullable
              as List<DetailPelangganAktifModel>,
      sortBy: null == sortBy
          ? _self.sortBy
          : sortBy // ignore: cast_nullable_to_non_nullable
              as SortOption,
    ));
  }
}

// dart format on
