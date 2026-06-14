// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'paket_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PaketModel {
  String get id;
  String get nama;
  int get harga;
  int get durasi;
  TipeDurasiPaket get tipe;
  int get poinHadiah;
  int get poinPenukaran;
  bool get statusPublik;
  DateTime? get diperbaruiPada;
  bool get statusHapus;
  DateTime? get diarsipkanPada;

  /// Create a copy of PaketModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $PaketModelCopyWith<PaketModel> get copyWith =>
      _$PaketModelCopyWithImpl<PaketModel>(this as PaketModel, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is PaketModel &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.nama, nama) || other.nama == nama) &&
            (identical(other.harga, harga) || other.harga == harga) &&
            (identical(other.durasi, durasi) || other.durasi == durasi) &&
            (identical(other.tipe, tipe) || other.tipe == tipe) &&
            (identical(other.poinHadiah, poinHadiah) ||
                other.poinHadiah == poinHadiah) &&
            (identical(other.poinPenukaran, poinPenukaran) ||
                other.poinPenukaran == poinPenukaran) &&
            (identical(other.statusPublik, statusPublik) ||
                other.statusPublik == statusPublik) &&
            (identical(other.diperbaruiPada, diperbaruiPada) ||
                other.diperbaruiPada == diperbaruiPada) &&
            (identical(other.statusHapus, statusHapus) ||
                other.statusHapus == statusHapus) &&
            (identical(other.diarsipkanPada, diarsipkanPada) ||
                other.diarsipkanPada == diarsipkanPada));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      nama,
      harga,
      durasi,
      tipe,
      poinHadiah,
      poinPenukaran,
      statusPublik,
      diperbaruiPada,
      statusHapus,
      diarsipkanPada);

  @override
  String toString() {
    return 'PaketModel(id: $id, nama: $nama, harga: $harga, durasi: $durasi, tipe: $tipe, poinHadiah: $poinHadiah, poinPenukaran: $poinPenukaran, statusPublik: $statusPublik, diperbaruiPada: $diperbaruiPada, statusHapus: $statusHapus, diarsipkanPada: $diarsipkanPada)';
  }
}

/// @nodoc
abstract mixin class $PaketModelCopyWith<$Res> {
  factory $PaketModelCopyWith(
          PaketModel value, $Res Function(PaketModel) _then) =
      _$PaketModelCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String nama,
      int harga,
      int durasi,
      TipeDurasiPaket tipe,
      int poinHadiah,
      int poinPenukaran,
      bool statusPublik,
      DateTime? diperbaruiPada,
      bool statusHapus,
      DateTime? diarsipkanPada});
}

/// @nodoc
class _$PaketModelCopyWithImpl<$Res> implements $PaketModelCopyWith<$Res> {
  _$PaketModelCopyWithImpl(this._self, this._then);

  final PaketModel _self;
  final $Res Function(PaketModel) _then;

  /// Create a copy of PaketModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? nama = null,
    Object? harga = null,
    Object? durasi = null,
    Object? tipe = null,
    Object? poinHadiah = null,
    Object? poinPenukaran = null,
    Object? statusPublik = null,
    Object? diperbaruiPada = freezed,
    Object? statusHapus = null,
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
      harga: null == harga
          ? _self.harga
          : harga // ignore: cast_nullable_to_non_nullable
              as int,
      durasi: null == durasi
          ? _self.durasi
          : durasi // ignore: cast_nullable_to_non_nullable
              as int,
      tipe: null == tipe
          ? _self.tipe
          : tipe // ignore: cast_nullable_to_non_nullable
              as TipeDurasiPaket,
      poinHadiah: null == poinHadiah
          ? _self.poinHadiah
          : poinHadiah // ignore: cast_nullable_to_non_nullable
              as int,
      poinPenukaran: null == poinPenukaran
          ? _self.poinPenukaran
          : poinPenukaran // ignore: cast_nullable_to_non_nullable
              as int,
      statusPublik: null == statusPublik
          ? _self.statusPublik
          : statusPublik // ignore: cast_nullable_to_non_nullable
              as bool,
      diperbaruiPada: freezed == diperbaruiPada
          ? _self.diperbaruiPada
          : diperbaruiPada // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      statusHapus: null == statusHapus
          ? _self.statusHapus
          : statusHapus // ignore: cast_nullable_to_non_nullable
              as bool,
      diarsipkanPada: freezed == diarsipkanPada
          ? _self.diarsipkanPada
          : diarsipkanPada // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// Adds pattern-matching-related methods to [PaketModel].
extension PaketModelPatterns on PaketModel {
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
    TResult Function(_PaketModel value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _PaketModel() when $default != null:
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
    TResult Function(_PaketModel value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PaketModel():
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
    TResult? Function(_PaketModel value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PaketModel() when $default != null:
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
            int harga,
            int durasi,
            TipeDurasiPaket tipe,
            int poinHadiah,
            int poinPenukaran,
            bool statusPublik,
            DateTime? diperbaruiPada,
            bool statusHapus,
            DateTime? diarsipkanPada)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _PaketModel() when $default != null:
        return $default(
            _that.id,
            _that.nama,
            _that.harga,
            _that.durasi,
            _that.tipe,
            _that.poinHadiah,
            _that.poinPenukaran,
            _that.statusPublik,
            _that.diperbaruiPada,
            _that.statusHapus,
            _that.diarsipkanPada);
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
            int harga,
            int durasi,
            TipeDurasiPaket tipe,
            int poinHadiah,
            int poinPenukaran,
            bool statusPublik,
            DateTime? diperbaruiPada,
            bool statusHapus,
            DateTime? diarsipkanPada)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PaketModel():
        return $default(
            _that.id,
            _that.nama,
            _that.harga,
            _that.durasi,
            _that.tipe,
            _that.poinHadiah,
            _that.poinPenukaran,
            _that.statusPublik,
            _that.diperbaruiPada,
            _that.statusHapus,
            _that.diarsipkanPada);
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
            int harga,
            int durasi,
            TipeDurasiPaket tipe,
            int poinHadiah,
            int poinPenukaran,
            bool statusPublik,
            DateTime? diperbaruiPada,
            bool statusHapus,
            DateTime? diarsipkanPada)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PaketModel() when $default != null:
        return $default(
            _that.id,
            _that.nama,
            _that.harga,
            _that.durasi,
            _that.tipe,
            _that.poinHadiah,
            _that.poinPenukaran,
            _that.statusPublik,
            _that.diperbaruiPada,
            _that.statusHapus,
            _that.diarsipkanPada);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _PaketModel extends PaketModel {
  const _PaketModel(
      {this.id = '',
      required this.nama,
      required this.harga,
      required this.durasi,
      required this.tipe,
      this.poinHadiah = 0,
      this.poinPenukaran = 0,
      this.statusPublik = true,
      this.diperbaruiPada,
      this.statusHapus = false,
      this.diarsipkanPada})
      : super._();

  @override
  @JsonKey()
  final String id;
  @override
  final String nama;
  @override
  final int harga;
  @override
  final int durasi;
  @override
  final TipeDurasiPaket tipe;
  @override
  @JsonKey()
  final int poinHadiah;
  @override
  @JsonKey()
  final int poinPenukaran;
  @override
  @JsonKey()
  final bool statusPublik;
  @override
  final DateTime? diperbaruiPada;
  @override
  @JsonKey()
  final bool statusHapus;
  @override
  final DateTime? diarsipkanPada;

  /// Create a copy of PaketModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$PaketModelCopyWith<_PaketModel> get copyWith =>
      __$PaketModelCopyWithImpl<_PaketModel>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _PaketModel &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.nama, nama) || other.nama == nama) &&
            (identical(other.harga, harga) || other.harga == harga) &&
            (identical(other.durasi, durasi) || other.durasi == durasi) &&
            (identical(other.tipe, tipe) || other.tipe == tipe) &&
            (identical(other.poinHadiah, poinHadiah) ||
                other.poinHadiah == poinHadiah) &&
            (identical(other.poinPenukaran, poinPenukaran) ||
                other.poinPenukaran == poinPenukaran) &&
            (identical(other.statusPublik, statusPublik) ||
                other.statusPublik == statusPublik) &&
            (identical(other.diperbaruiPada, diperbaruiPada) ||
                other.diperbaruiPada == diperbaruiPada) &&
            (identical(other.statusHapus, statusHapus) ||
                other.statusHapus == statusHapus) &&
            (identical(other.diarsipkanPada, diarsipkanPada) ||
                other.diarsipkanPada == diarsipkanPada));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      nama,
      harga,
      durasi,
      tipe,
      poinHadiah,
      poinPenukaran,
      statusPublik,
      diperbaruiPada,
      statusHapus,
      diarsipkanPada);

  @override
  String toString() {
    return 'PaketModel(id: $id, nama: $nama, harga: $harga, durasi: $durasi, tipe: $tipe, poinHadiah: $poinHadiah, poinPenukaran: $poinPenukaran, statusPublik: $statusPublik, diperbaruiPada: $diperbaruiPada, statusHapus: $statusHapus, diarsipkanPada: $diarsipkanPada)';
  }
}

/// @nodoc
abstract mixin class _$PaketModelCopyWith<$Res>
    implements $PaketModelCopyWith<$Res> {
  factory _$PaketModelCopyWith(
          _PaketModel value, $Res Function(_PaketModel) _then) =
      __$PaketModelCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String nama,
      int harga,
      int durasi,
      TipeDurasiPaket tipe,
      int poinHadiah,
      int poinPenukaran,
      bool statusPublik,
      DateTime? diperbaruiPada,
      bool statusHapus,
      DateTime? diarsipkanPada});
}

/// @nodoc
class __$PaketModelCopyWithImpl<$Res> implements _$PaketModelCopyWith<$Res> {
  __$PaketModelCopyWithImpl(this._self, this._then);

  final _PaketModel _self;
  final $Res Function(_PaketModel) _then;

  /// Create a copy of PaketModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? nama = null,
    Object? harga = null,
    Object? durasi = null,
    Object? tipe = null,
    Object? poinHadiah = null,
    Object? poinPenukaran = null,
    Object? statusPublik = null,
    Object? diperbaruiPada = freezed,
    Object? statusHapus = null,
    Object? diarsipkanPada = freezed,
  }) {
    return _then(_PaketModel(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      nama: null == nama
          ? _self.nama
          : nama // ignore: cast_nullable_to_non_nullable
              as String,
      harga: null == harga
          ? _self.harga
          : harga // ignore: cast_nullable_to_non_nullable
              as int,
      durasi: null == durasi
          ? _self.durasi
          : durasi // ignore: cast_nullable_to_non_nullable
              as int,
      tipe: null == tipe
          ? _self.tipe
          : tipe // ignore: cast_nullable_to_non_nullable
              as TipeDurasiPaket,
      poinHadiah: null == poinHadiah
          ? _self.poinHadiah
          : poinHadiah // ignore: cast_nullable_to_non_nullable
              as int,
      poinPenukaran: null == poinPenukaran
          ? _self.poinPenukaran
          : poinPenukaran // ignore: cast_nullable_to_non_nullable
              as int,
      statusPublik: null == statusPublik
          ? _self.statusPublik
          : statusPublik // ignore: cast_nullable_to_non_nullable
              as bool,
      diperbaruiPada: freezed == diperbaruiPada
          ? _self.diperbaruiPada
          : diperbaruiPada // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      statusHapus: null == statusHapus
          ? _self.statusHapus
          : statusHapus // ignore: cast_nullable_to_non_nullable
              as bool,
      diarsipkanPada: freezed == diarsipkanPada
          ? _self.diarsipkanPada
          : diarsipkanPada // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

// dart format on
