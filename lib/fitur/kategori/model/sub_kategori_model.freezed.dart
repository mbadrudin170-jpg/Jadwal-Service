// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sub_kategori_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SubKategoriModel {
  String get id;
  String get nama;
  String get idKategori;
  DateTime? get diperbaruiPada;
  bool get diHapus;
  DateTime? get diarsipkanPada;

  /// Create a copy of SubKategoriModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SubKategoriModelCopyWith<SubKategoriModel> get copyWith =>
      _$SubKategoriModelCopyWithImpl<SubKategoriModel>(
          this as SubKategoriModel, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SubKategoriModel &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.nama, nama) || other.nama == nama) &&
            (identical(other.idKategori, idKategori) ||
                other.idKategori == idKategori) &&
            (identical(other.diperbaruiPada, diperbaruiPada) ||
                other.diperbaruiPada == diperbaruiPada) &&
            (identical(other.diHapus, diHapus) || other.diHapus == diHapus) &&
            (identical(other.diarsipkanPada, diarsipkanPada) ||
                other.diarsipkanPada == diarsipkanPada));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, nama, idKategori,
      diperbaruiPada, diHapus, diarsipkanPada);

  @override
  String toString() {
    return 'SubKategoriModel(id: $id, nama: $nama, idKategori: $idKategori, diperbaruiPada: $diperbaruiPada, diHapus: $diHapus, diarsipkanPada: $diarsipkanPada)';
  }
}

/// @nodoc
abstract mixin class $SubKategoriModelCopyWith<$Res> {
  factory $SubKategoriModelCopyWith(
          SubKategoriModel value, $Res Function(SubKategoriModel) _then) =
      _$SubKategoriModelCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String nama,
      String idKategori,
      DateTime? diperbaruiPada,
      bool diHapus,
      DateTime? diarsipkanPada});
}

/// @nodoc
class _$SubKategoriModelCopyWithImpl<$Res>
    implements $SubKategoriModelCopyWith<$Res> {
  _$SubKategoriModelCopyWithImpl(this._self, this._then);

  final SubKategoriModel _self;
  final $Res Function(SubKategoriModel) _then;

  /// Create a copy of SubKategoriModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? nama = null,
    Object? idKategori = null,
    Object? diperbaruiPada = freezed,
    Object? diHapus = null,
    Object? diarsipkanPada = freezed,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      nama: null == nama
          ? _self.nama
          : nama // ignore: cast_nullable_to_non_nullable
              as String,
      idKategori: null == idKategori
          ? _self.idKategori
          : idKategori // ignore: cast_nullable_to_non_nullable
              as String,
      diperbaruiPada: freezed == diperbaruiPada
          ? _self.diperbaruiPada
          : diperbaruiPada // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      diHapus: null == diHapus
          ? _self.diHapus
          : diHapus // ignore: cast_nullable_to_non_nullable
              as bool,
      diarsipkanPada: freezed == diarsipkanPada
          ? _self.diarsipkanPada
          : diarsipkanPada // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// Adds pattern-matching-related methods to [SubKategoriModel].
extension SubKategoriModelPatterns on SubKategoriModel {
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
    TResult Function(_SubKategoriModel value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _SubKategoriModel() when $default != null:
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
    TResult Function(_SubKategoriModel value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SubKategoriModel():
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
    TResult? Function(_SubKategoriModel value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SubKategoriModel() when $default != null:
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
    TResult Function(String id, String nama, String idKategori,
            DateTime? diperbaruiPada, bool diHapus, DateTime? diarsipkanPada)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _SubKategoriModel() when $default != null:
        return $default(_that.id, _that.nama, _that.idKategori,
            _that.diperbaruiPada, _that.diHapus, _that.diarsipkanPada);
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
    TResult Function(String id, String nama, String idKategori,
            DateTime? diperbaruiPada, bool diHapus, DateTime? diarsipkanPada)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SubKategoriModel():
        return $default(_that.id, _that.nama, _that.idKategori,
            _that.diperbaruiPada, _that.diHapus, _that.diarsipkanPada);
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
    TResult? Function(String id, String nama, String idKategori,
            DateTime? diperbaruiPada, bool diHapus, DateTime? diarsipkanPada)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SubKategoriModel() when $default != null:
        return $default(_that.id, _that.nama, _that.idKategori,
            _that.diperbaruiPada, _that.diHapus, _that.diarsipkanPada);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _SubKategoriModel extends SubKategoriModel {
  const _SubKategoriModel(
      {required this.id,
      required this.nama,
      required this.idKategori,
      this.diperbaruiPada,
      this.diHapus = false,
      this.diarsipkanPada})
      : super._();

  @override
  final String id;
  @override
  final String nama;
  @override
  final String idKategori;
  @override
  final DateTime? diperbaruiPada;
  @override
  @JsonKey()
  final bool diHapus;
  @override
  final DateTime? diarsipkanPada;

  /// Create a copy of SubKategoriModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SubKategoriModelCopyWith<_SubKategoriModel> get copyWith =>
      __$SubKategoriModelCopyWithImpl<_SubKategoriModel>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _SubKategoriModel &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.nama, nama) || other.nama == nama) &&
            (identical(other.idKategori, idKategori) ||
                other.idKategori == idKategori) &&
            (identical(other.diperbaruiPada, diperbaruiPada) ||
                other.diperbaruiPada == diperbaruiPada) &&
            (identical(other.diHapus, diHapus) || other.diHapus == diHapus) &&
            (identical(other.diarsipkanPada, diarsipkanPada) ||
                other.diarsipkanPada == diarsipkanPada));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, nama, idKategori,
      diperbaruiPada, diHapus, diarsipkanPada);

  @override
  String toString() {
    return 'SubKategoriModel(id: $id, nama: $nama, idKategori: $idKategori, diperbaruiPada: $diperbaruiPada, diHapus: $diHapus, diarsipkanPada: $diarsipkanPada)';
  }
}

/// @nodoc
abstract mixin class _$SubKategoriModelCopyWith<$Res>
    implements $SubKategoriModelCopyWith<$Res> {
  factory _$SubKategoriModelCopyWith(
          _SubKategoriModel value, $Res Function(_SubKategoriModel) _then) =
      __$SubKategoriModelCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String nama,
      String idKategori,
      DateTime? diperbaruiPada,
      bool diHapus,
      DateTime? diarsipkanPada});
}

/// @nodoc
class __$SubKategoriModelCopyWithImpl<$Res>
    implements _$SubKategoriModelCopyWith<$Res> {
  __$SubKategoriModelCopyWithImpl(this._self, this._then);

  final _SubKategoriModel _self;
  final $Res Function(_SubKategoriModel) _then;

  /// Create a copy of SubKategoriModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? nama = null,
    Object? idKategori = null,
    Object? diperbaruiPada = freezed,
    Object? diHapus = null,
    Object? diarsipkanPada = freezed,
  }) {
    return _then(_SubKategoriModel(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      nama: null == nama
          ? _self.nama
          : nama // ignore: cast_nullable_to_non_nullable
              as String,
      idKategori: null == idKategori
          ? _self.idKategori
          : idKategori // ignore: cast_nullable_to_non_nullable
              as String,
      diperbaruiPada: freezed == diperbaruiPada
          ? _self.diperbaruiPada
          : diperbaruiPada // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      diHapus: null == diHapus
          ? _self.diHapus
          : diHapus // ignore: cast_nullable_to_non_nullable
              as bool,
      diarsipkanPada: freezed == diarsipkanPada
          ? _self.diarsipkanPada
          : diarsipkanPada // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

// dart format on
