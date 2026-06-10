// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'uji_kecepatan_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UjiKecepatanState {
  double get kecepatanUnduh;
  double get kecepatanUnggah;
  int get ping;
  bool get sedangMenguji;
  String get statusPesan;

  /// Create a copy of UjiKecepatanState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $UjiKecepatanStateCopyWith<UjiKecepatanState> get copyWith =>
      _$UjiKecepatanStateCopyWithImpl<UjiKecepatanState>(
          this as UjiKecepatanState, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is UjiKecepatanState &&
            (identical(other.kecepatanUnduh, kecepatanUnduh) ||
                other.kecepatanUnduh == kecepatanUnduh) &&
            (identical(other.kecepatanUnggah, kecepatanUnggah) ||
                other.kecepatanUnggah == kecepatanUnggah) &&
            (identical(other.ping, ping) || other.ping == ping) &&
            (identical(other.sedangMenguji, sedangMenguji) ||
                other.sedangMenguji == sedangMenguji) &&
            (identical(other.statusPesan, statusPesan) ||
                other.statusPesan == statusPesan));
  }

  @override
  int get hashCode => Object.hash(runtimeType, kecepatanUnduh, kecepatanUnggah,
      ping, sedangMenguji, statusPesan);

  @override
  String toString() {
    return 'UjiKecepatanState(kecepatanUnduh: $kecepatanUnduh, kecepatanUnggah: $kecepatanUnggah, ping: $ping, sedangMenguji: $sedangMenguji, statusPesan: $statusPesan)';
  }
}

/// @nodoc
abstract mixin class $UjiKecepatanStateCopyWith<$Res> {
  factory $UjiKecepatanStateCopyWith(
          UjiKecepatanState value, $Res Function(UjiKecepatanState) _then) =
      _$UjiKecepatanStateCopyWithImpl;
  @useResult
  $Res call(
      {double kecepatanUnduh,
      double kecepatanUnggah,
      int ping,
      bool sedangMenguji,
      String statusPesan});
}

/// @nodoc
class _$UjiKecepatanStateCopyWithImpl<$Res>
    implements $UjiKecepatanStateCopyWith<$Res> {
  _$UjiKecepatanStateCopyWithImpl(this._self, this._then);

  final UjiKecepatanState _self;
  final $Res Function(UjiKecepatanState) _then;

  /// Create a copy of UjiKecepatanState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? kecepatanUnduh = null,
    Object? kecepatanUnggah = null,
    Object? ping = null,
    Object? sedangMenguji = null,
    Object? statusPesan = null,
  }) {
    return _then(_self.copyWith(
      kecepatanUnduh: null == kecepatanUnduh
          ? _self.kecepatanUnduh
          : kecepatanUnduh // ignore: cast_nullable_to_non_nullable
              as double,
      kecepatanUnggah: null == kecepatanUnggah
          ? _self.kecepatanUnggah
          : kecepatanUnggah // ignore: cast_nullable_to_non_nullable
              as double,
      ping: null == ping
          ? _self.ping
          : ping // ignore: cast_nullable_to_non_nullable
              as int,
      sedangMenguji: null == sedangMenguji
          ? _self.sedangMenguji
          : sedangMenguji // ignore: cast_nullable_to_non_nullable
              as bool,
      statusPesan: null == statusPesan
          ? _self.statusPesan
          : statusPesan // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// Adds pattern-matching-related methods to [UjiKecepatanState].
extension UjiKecepatanStatePatterns on UjiKecepatanState {
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
    TResult Function(_UjiKecepatanState value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _UjiKecepatanState() when $default != null:
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
    TResult Function(_UjiKecepatanState value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _UjiKecepatanState():
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
    TResult? Function(_UjiKecepatanState value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _UjiKecepatanState() when $default != null:
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
    TResult Function(double kecepatanUnduh, double kecepatanUnggah, int ping,
            bool sedangMenguji, String statusPesan)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _UjiKecepatanState() when $default != null:
        return $default(_that.kecepatanUnduh, _that.kecepatanUnggah, _that.ping,
            _that.sedangMenguji, _that.statusPesan);
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
    TResult Function(double kecepatanUnduh, double kecepatanUnggah, int ping,
            bool sedangMenguji, String statusPesan)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _UjiKecepatanState():
        return $default(_that.kecepatanUnduh, _that.kecepatanUnggah, _that.ping,
            _that.sedangMenguji, _that.statusPesan);
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
    TResult? Function(double kecepatanUnduh, double kecepatanUnggah, int ping,
            bool sedangMenguji, String statusPesan)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _UjiKecepatanState() when $default != null:
        return $default(_that.kecepatanUnduh, _that.kecepatanUnggah, _that.ping,
            _that.sedangMenguji, _that.statusPesan);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _UjiKecepatanState implements UjiKecepatanState {
  const _UjiKecepatanState(
      {this.kecepatanUnduh = 0.0,
      this.kecepatanUnggah = 0.0,
      this.ping = 0,
      this.sedangMenguji = false,
      this.statusPesan = 'Siap melakukan pengujian'});

  @override
  @JsonKey()
  final double kecepatanUnduh;
  @override
  @JsonKey()
  final double kecepatanUnggah;
  @override
  @JsonKey()
  final int ping;
  @override
  @JsonKey()
  final bool sedangMenguji;
  @override
  @JsonKey()
  final String statusPesan;

  /// Create a copy of UjiKecepatanState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$UjiKecepatanStateCopyWith<_UjiKecepatanState> get copyWith =>
      __$UjiKecepatanStateCopyWithImpl<_UjiKecepatanState>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _UjiKecepatanState &&
            (identical(other.kecepatanUnduh, kecepatanUnduh) ||
                other.kecepatanUnduh == kecepatanUnduh) &&
            (identical(other.kecepatanUnggah, kecepatanUnggah) ||
                other.kecepatanUnggah == kecepatanUnggah) &&
            (identical(other.ping, ping) || other.ping == ping) &&
            (identical(other.sedangMenguji, sedangMenguji) ||
                other.sedangMenguji == sedangMenguji) &&
            (identical(other.statusPesan, statusPesan) ||
                other.statusPesan == statusPesan));
  }

  @override
  int get hashCode => Object.hash(runtimeType, kecepatanUnduh, kecepatanUnggah,
      ping, sedangMenguji, statusPesan);

  @override
  String toString() {
    return 'UjiKecepatanState(kecepatanUnduh: $kecepatanUnduh, kecepatanUnggah: $kecepatanUnggah, ping: $ping, sedangMenguji: $sedangMenguji, statusPesan: $statusPesan)';
  }
}

/// @nodoc
abstract mixin class _$UjiKecepatanStateCopyWith<$Res>
    implements $UjiKecepatanStateCopyWith<$Res> {
  factory _$UjiKecepatanStateCopyWith(
          _UjiKecepatanState value, $Res Function(_UjiKecepatanState) _then) =
      __$UjiKecepatanStateCopyWithImpl;
  @override
  @useResult
  $Res call(
      {double kecepatanUnduh,
      double kecepatanUnggah,
      int ping,
      bool sedangMenguji,
      String statusPesan});
}

/// @nodoc
class __$UjiKecepatanStateCopyWithImpl<$Res>
    implements _$UjiKecepatanStateCopyWith<$Res> {
  __$UjiKecepatanStateCopyWithImpl(this._self, this._then);

  final _UjiKecepatanState _self;
  final $Res Function(_UjiKecepatanState) _then;

  /// Create a copy of UjiKecepatanState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? kecepatanUnduh = null,
    Object? kecepatanUnggah = null,
    Object? ping = null,
    Object? sedangMenguji = null,
    Object? statusPesan = null,
  }) {
    return _then(_UjiKecepatanState(
      kecepatanUnduh: null == kecepatanUnduh
          ? _self.kecepatanUnduh
          : kecepatanUnduh // ignore: cast_nullable_to_non_nullable
              as double,
      kecepatanUnggah: null == kecepatanUnggah
          ? _self.kecepatanUnggah
          : kecepatanUnggah // ignore: cast_nullable_to_non_nullable
              as double,
      ping: null == ping
          ? _self.ping
          : ping // ignore: cast_nullable_to_non_nullable
              as int,
      sedangMenguji: null == sedangMenguji
          ? _self.sedangMenguji
          : sedangMenguji // ignore: cast_nullable_to_non_nullable
              as bool,
      statusPesan: null == statusPesan
          ? _self.statusPesan
          : statusPesan // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

// dart format on
