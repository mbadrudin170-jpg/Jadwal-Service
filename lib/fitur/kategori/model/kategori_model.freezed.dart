// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'kategori_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$KategoriModel {
  String get id;
  String get nama;
  TipeKategori get tipe;
  List<SubCategoryModel> get idSubKategori;
  DateTime? get diperbaruiPada;
  bool get diHapus;
  DateTime? get diarsipkanPada;

  /// Create a copy of KategoriModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $KategoriModelCopyWith<KategoriModel> get copyWith =>
      _$KategoriModelCopyWithImpl<KategoriModel>(
          this as KategoriModel, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is KategoriModel &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.nama, nama) || other.nama == nama) &&
            (identical(other.tipe, tipe) || other.tipe == tipe) &&
            const DeepCollectionEquality()
                .equals(other.idSubKategori, idSubKategori) &&
            (identical(other.diperbaruiPada, diperbaruiPada) ||
                other.diperbaruiPada == diperbaruiPada) &&
            (identical(other.diHapus, diHapus) || other.diHapus == diHapus) &&
            (identical(other.diarsipkanPada, diarsipkanPada) ||
                other.diarsipkanPada == diarsipkanPada));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      nama,
      tipe,
      const DeepCollectionEquality().hash(idSubKategori),
      diperbaruiPada,
      diHapus,
      diarsipkanPada);

  @override
  String toString() {
    return 'KategoriModel(id: $id, nama: $nama, tipe: $tipe, idSubKategori: $idSubKategori, diperbaruiPada: $diperbaruiPada, diHapus: $diHapus, diarsipkanPada: $diarsipkanPada)';
  }
}

/// @nodoc
abstract mixin class $KategoriModelCopyWith<$Res> {
  factory $KategoriModelCopyWith(
          KategoriModel value, $Res Function(KategoriModel) _then) =
      _$KategoriModelCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String nama,
      TipeKategori tipe,
      List<SubCategoryModel> idSubKategori,
      DateTime? diperbaruiPada,
      bool diHapus,
      DateTime? diarsipkanPada});
}

/// @nodoc
class _$KategoriModelCopyWithImpl<$Res>
    implements $KategoriModelCopyWith<$Res> {
  _$KategoriModelCopyWithImpl(this._self, this._then);

  final KategoriModel _self;
  final $Res Function(KategoriModel) _then;

  /// Create a copy of KategoriModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? nama = null,
    Object? tipe = null,
    Object? idSubKategori = null,
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
      tipe: null == tipe
          ? _self.tipe
          : tipe // ignore: cast_nullable_to_non_nullable
              as TipeKategori,
      idSubKategori: null == idSubKategori
          ? _self.idSubKategori
          : idSubKategori // ignore: cast_nullable_to_non_nullable
              as List<SubCategoryModel>,
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

/// Adds pattern-matching-related methods to [KategoriModel].
extension KategoriModelPatterns on KategoriModel {
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
    TResult Function(_KategoriModel value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _KategoriModel() when $default != null:
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
    TResult Function(_KategoriModel value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _KategoriModel():
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
    TResult? Function(_KategoriModel value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _KategoriModel() when $default != null:
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
    TResult Function(
            String id,
            String nama,
            TipeKategori tipe,
            List<SubCategoryModel> idSubKategori,
            DateTime? diperbaruiPada,
            bool diHapus,
            DateTime? diarsipkanPada)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _KategoriModel() when $default != null:
        return $default(_that.id, _that.nama, _that.tipe, _that.idSubKategori,
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
    TResult Function(
            String id,
            String nama,
            TipeKategori tipe,
            List<SubCategoryModel> idSubKategori,
            DateTime? diperbaruiPada,
            bool diHapus,
            DateTime? diarsipkanPada)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _KategoriModel():
        return $default(_that.id, _that.nama, _that.tipe, _that.idSubKategori,
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
    TResult? Function(
            String id,
            String nama,
            TipeKategori tipe,
            List<SubCategoryModel> idSubKategori,
            DateTime? diperbaruiPada,
            bool diHapus,
            DateTime? diarsipkanPada)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _KategoriModel() when $default != null:
        return $default(_that.id, _that.nama, _that.tipe, _that.idSubKategori,
            _that.diperbaruiPada, _that.diHapus, _that.diarsipkanPada);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _KategoriModel extends KategoriModel {
  const _KategoriModel(
      {this.id = '',
      required this.nama,
      required this.tipe,
      final List<SubCategoryModel> idSubKategori = const <SubCategoryModel>[],
      this.diperbaruiPada,
      this.diHapus = false,
      this.diarsipkanPada})
      : _idSubKategori = idSubKategori,
        super._();

  @override
  @JsonKey()
  final String id;
  @override
  final String nama;
  @override
  final TipeKategori tipe;
  final List<SubCategoryModel> _idSubKategori;
  @override
  @JsonKey()
  List<SubCategoryModel> get idSubKategori {
    if (_idSubKategori is EqualUnmodifiableListView) return _idSubKategori;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_idSubKategori);
  }

  @override
  final DateTime? diperbaruiPada;
  @override
  @JsonKey()
  final bool diHapus;
  @override
  final DateTime? diarsipkanPada;

  /// Create a copy of KategoriModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$KategoriModelCopyWith<_KategoriModel> get copyWith =>
      __$KategoriModelCopyWithImpl<_KategoriModel>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _KategoriModel &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.nama, nama) || other.nama == nama) &&
            (identical(other.tipe, tipe) || other.tipe == tipe) &&
            const DeepCollectionEquality()
                .equals(other._idSubKategori, _idSubKategori) &&
            (identical(other.diperbaruiPada, diperbaruiPada) ||
                other.diperbaruiPada == diperbaruiPada) &&
            (identical(other.diHapus, diHapus) || other.diHapus == diHapus) &&
            (identical(other.diarsipkanPada, diarsipkanPada) ||
                other.diarsipkanPada == diarsipkanPada));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      nama,
      tipe,
      const DeepCollectionEquality().hash(_idSubKategori),
      diperbaruiPada,
      diHapus,
      diarsipkanPada);

  @override
  String toString() {
    return 'KategoriModel(id: $id, nama: $nama, tipe: $tipe, idSubKategori: $idSubKategori, diperbaruiPada: $diperbaruiPada, diHapus: $diHapus, diarsipkanPada: $diarsipkanPada)';
  }
}

/// @nodoc
abstract mixin class _$KategoriModelCopyWith<$Res>
    implements $KategoriModelCopyWith<$Res> {
  factory _$KategoriModelCopyWith(
          _KategoriModel value, $Res Function(_KategoriModel) _then) =
      __$KategoriModelCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String nama,
      TipeKategori tipe,
      List<SubCategoryModel> idSubKategori,
      DateTime? diperbaruiPada,
      bool diHapus,
      DateTime? diarsipkanPada});
}

/// @nodoc
class __$KategoriModelCopyWithImpl<$Res>
    implements _$KategoriModelCopyWith<$Res> {
  __$KategoriModelCopyWithImpl(this._self, this._then);

  final _KategoriModel _self;
  final $Res Function(_KategoriModel) _then;

  /// Create a copy of KategoriModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? nama = null,
    Object? tipe = null,
    Object? idSubKategori = null,
    Object? diperbaruiPada = freezed,
    Object? diHapus = null,
    Object? diarsipkanPada = freezed,
  }) {
    return _then(_KategoriModel(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      nama: null == nama
          ? _self.nama
          : nama // ignore: cast_nullable_to_non_nullable
              as String,
      tipe: null == tipe
          ? _self.tipe
          : tipe // ignore: cast_nullable_to_non_nullable
              as TipeKategori,
      idSubKategori: null == idSubKategori
          ? _self._idSubKategori
          : idSubKategori // ignore: cast_nullable_to_non_nullable
              as List<SubCategoryModel>,
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
