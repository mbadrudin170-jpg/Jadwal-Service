// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'feedback_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FeedbackModel {
  String get id;
  String get pesan;
  DateTime? get tanggal;
  String get userId;
  DateTime? get diperbaruiPada;
  bool get dihapus;
  DateTime? get diarsipkanPada;

  /// Create a copy of FeedbackModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $FeedbackModelCopyWith<FeedbackModel> get copyWith =>
      _$FeedbackModelCopyWithImpl<FeedbackModel>(
          this as FeedbackModel, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is FeedbackModel &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.pesan, pesan) || other.pesan == pesan) &&
            (identical(other.tanggal, tanggal) || other.tanggal == tanggal) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.diperbaruiPada, diperbaruiPada) ||
                other.diperbaruiPada == diperbaruiPada) &&
            (identical(other.dihapus, dihapus) || other.dihapus == dihapus) &&
            (identical(other.diarsipkanPada, diarsipkanPada) ||
                other.diarsipkanPada == diarsipkanPada));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, pesan, tanggal, userId,
      diperbaruiPada, dihapus, diarsipkanPada);

  @override
  String toString() {
    return 'FeedbackModel(id: $id, pesan: $pesan, tanggal: $tanggal, userId: $userId, diperbaruiPada: $diperbaruiPada, dihapus: $dihapus, diarsipkanPada: $diarsipkanPada)';
  }
}

/// @nodoc
abstract mixin class $FeedbackModelCopyWith<$Res> {
  factory $FeedbackModelCopyWith(
          FeedbackModel value, $Res Function(FeedbackModel) _then) =
      _$FeedbackModelCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String pesan,
      DateTime? tanggal,
      String userId,
      DateTime? diperbaruiPada,
      bool dihapus,
      DateTime? diarsipkanPada});
}

/// @nodoc
class _$FeedbackModelCopyWithImpl<$Res>
    implements $FeedbackModelCopyWith<$Res> {
  _$FeedbackModelCopyWithImpl(this._self, this._then);

  final FeedbackModel _self;
  final $Res Function(FeedbackModel) _then;

  /// Create a copy of FeedbackModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? pesan = null,
    Object? tanggal = freezed,
    Object? userId = null,
    Object? diperbaruiPada = freezed,
    Object? dihapus = null,
    Object? diarsipkanPada = freezed,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      pesan: null == pesan
          ? _self.pesan
          : pesan // ignore: cast_nullable_to_non_nullable
              as String,
      tanggal: freezed == tanggal
          ? _self.tanggal
          : tanggal // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      userId: null == userId
          ? _self.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      diperbaruiPada: freezed == diperbaruiPada
          ? _self.diperbaruiPada
          : diperbaruiPada // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      dihapus: null == dihapus
          ? _self.dihapus
          : dihapus // ignore: cast_nullable_to_non_nullable
              as bool,
      diarsipkanPada: freezed == diarsipkanPada
          ? _self.diarsipkanPada
          : diarsipkanPada // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// Adds pattern-matching-related methods to [FeedbackModel].
extension FeedbackModelPatterns on FeedbackModel {
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
    TResult Function(_FeedbackModel value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _FeedbackModel() when $default != null:
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
    TResult Function(_FeedbackModel value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _FeedbackModel():
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
    TResult? Function(_FeedbackModel value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _FeedbackModel() when $default != null:
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
    TResult Function(String id, String pesan, DateTime? tanggal, String userId,
            DateTime? diperbaruiPada, bool dihapus, DateTime? diarsipkanPada)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _FeedbackModel() when $default != null:
        return $default(_that.id, _that.pesan, _that.tanggal, _that.userId,
            _that.diperbaruiPada, _that.dihapus, _that.diarsipkanPada);
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
    TResult Function(String id, String pesan, DateTime? tanggal, String userId,
            DateTime? diperbaruiPada, bool dihapus, DateTime? diarsipkanPada)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _FeedbackModel():
        return $default(_that.id, _that.pesan, _that.tanggal, _that.userId,
            _that.diperbaruiPada, _that.dihapus, _that.diarsipkanPada);
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
    TResult? Function(String id, String pesan, DateTime? tanggal, String userId,
            DateTime? diperbaruiPada, bool dihapus, DateTime? diarsipkanPada)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _FeedbackModel() when $default != null:
        return $default(_that.id, _that.pesan, _that.tanggal, _that.userId,
            _that.diperbaruiPada, _that.dihapus, _that.diarsipkanPada);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _FeedbackModel extends FeedbackModel {
  const _FeedbackModel(
      {required this.id,
      required this.pesan,
      this.tanggal,
      required this.userId,
      this.diperbaruiPada,
      this.dihapus = false,
      this.diarsipkanPada})
      : super._();

  @override
  final String id;
  @override
  final String pesan;
  @override
  final DateTime? tanggal;
  @override
  final String userId;
  @override
  final DateTime? diperbaruiPada;
  @override
  @JsonKey()
  final bool dihapus;
  @override
  final DateTime? diarsipkanPada;

  /// Create a copy of FeedbackModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$FeedbackModelCopyWith<_FeedbackModel> get copyWith =>
      __$FeedbackModelCopyWithImpl<_FeedbackModel>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _FeedbackModel &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.pesan, pesan) || other.pesan == pesan) &&
            (identical(other.tanggal, tanggal) || other.tanggal == tanggal) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.diperbaruiPada, diperbaruiPada) ||
                other.diperbaruiPada == diperbaruiPada) &&
            (identical(other.dihapus, dihapus) || other.dihapus == dihapus) &&
            (identical(other.diarsipkanPada, diarsipkanPada) ||
                other.diarsipkanPada == diarsipkanPada));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, pesan, tanggal, userId,
      diperbaruiPada, dihapus, diarsipkanPada);

  @override
  String toString() {
    return 'FeedbackModel(id: $id, pesan: $pesan, tanggal: $tanggal, userId: $userId, diperbaruiPada: $diperbaruiPada, dihapus: $dihapus, diarsipkanPada: $diarsipkanPada)';
  }
}

/// @nodoc
abstract mixin class _$FeedbackModelCopyWith<$Res>
    implements $FeedbackModelCopyWith<$Res> {
  factory _$FeedbackModelCopyWith(
          _FeedbackModel value, $Res Function(_FeedbackModel) _then) =
      __$FeedbackModelCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String pesan,
      DateTime? tanggal,
      String userId,
      DateTime? diperbaruiPada,
      bool dihapus,
      DateTime? diarsipkanPada});
}

/// @nodoc
class __$FeedbackModelCopyWithImpl<$Res>
    implements _$FeedbackModelCopyWith<$Res> {
  __$FeedbackModelCopyWithImpl(this._self, this._then);

  final _FeedbackModel _self;
  final $Res Function(_FeedbackModel) _then;

  /// Create a copy of FeedbackModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? pesan = null,
    Object? tanggal = freezed,
    Object? userId = null,
    Object? diperbaruiPada = freezed,
    Object? dihapus = null,
    Object? diarsipkanPada = freezed,
  }) {
    return _then(_FeedbackModel(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      pesan: null == pesan
          ? _self.pesan
          : pesan // ignore: cast_nullable_to_non_nullable
              as String,
      tanggal: freezed == tanggal
          ? _self.tanggal
          : tanggal // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      userId: null == userId
          ? _self.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      diperbaruiPada: freezed == diperbaruiPada
          ? _self.diperbaruiPada
          : diperbaruiPada // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      dihapus: null == dihapus
          ? _self.dihapus
          : dihapus // ignore: cast_nullable_to_non_nullable
              as bool,
      diarsipkanPada: freezed == diarsipkanPada
          ? _self.diarsipkanPada
          : diarsipkanPada // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

// dart format on
