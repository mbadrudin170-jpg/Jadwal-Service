// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'transaksi_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TransaksiModel {
  String get id;
  DateTime get tanggal;
  String get deskripsi;
  double get jumlah;
  TipeTransaksi get tipe;
  String get idDompet;
  String get idKategori;
  String? get idDompetTujuan;
  String? get idPelanggan;
  String? get idPaket;
  String? get idSubKategori;
  StatusPembayaran get statusPembayaran;
  int get poinDidapat;
  int get poinDigunakan;
  DateTime? get diperbaruiPada;
  DateTime? get diarsipkanPada;
  bool get diHapus;
  int? get durasiPaket;
  TipeDurasiPaket? get tipeDurasiPaket;
  int get durasiBonus;
  TipeDurasiPaket? get tipeDurasiBonus;
  DateTime? get tanggalMulai;
  DateTime? get tangglberakhir;
  bool get statusAktivasi;

  /// Create a copy of TransaksiModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $TransaksiModelCopyWith<TransaksiModel> get copyWith =>
      _$TransaksiModelCopyWithImpl<TransaksiModel>(
          this as TransaksiModel, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is TransaksiModel &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.tanggal, tanggal) || other.tanggal == tanggal) &&
            (identical(other.deskripsi, deskripsi) ||
                other.deskripsi == deskripsi) &&
            (identical(other.jumlah, jumlah) || other.jumlah == jumlah) &&
            (identical(other.tipe, tipe) || other.tipe == tipe) &&
            (identical(other.idDompet, idDompet) ||
                other.idDompet == idDompet) &&
            (identical(other.idKategori, idKategori) ||
                other.idKategori == idKategori) &&
            (identical(other.idDompetTujuan, idDompetTujuan) ||
                other.idDompetTujuan == idDompetTujuan) &&
            (identical(other.idPelanggan, idPelanggan) ||
                other.idPelanggan == idPelanggan) &&
            (identical(other.idPaket, idPaket) || other.idPaket == idPaket) &&
            (identical(other.idSubKategori, idSubKategori) ||
                other.idSubKategori == idSubKategori) &&
            (identical(other.statusPembayaran, statusPembayaran) ||
                other.statusPembayaran == statusPembayaran) &&
            (identical(other.poinDidapat, poinDidapat) ||
                other.poinDidapat == poinDidapat) &&
            (identical(other.poinDigunakan, poinDigunakan) ||
                other.poinDigunakan == poinDigunakan) &&
            (identical(other.diperbaruiPada, diperbaruiPada) ||
                other.diperbaruiPada == diperbaruiPada) &&
            (identical(other.diarsipkanPada, diarsipkanPada) ||
                other.diarsipkanPada == diarsipkanPada) &&
            (identical(other.diHapus, diHapus) || other.diHapus == diHapus) &&
            (identical(other.durasiPaket, durasiPaket) ||
                other.durasiPaket == durasiPaket) &&
            (identical(other.tipeDurasiPaket, tipeDurasiPaket) ||
                other.tipeDurasiPaket == tipeDurasiPaket) &&
            (identical(other.durasiBonus, durasiBonus) ||
                other.durasiBonus == durasiBonus) &&
            (identical(other.tipeDurasiBonus, tipeDurasiBonus) ||
                other.tipeDurasiBonus == tipeDurasiBonus) &&
            (identical(other.tanggalMulai, tanggalMulai) ||
                other.tanggalMulai == tanggalMulai) &&
            (identical(other.tangglberakhir, tangglberakhir) ||
                other.tangglberakhir == tangglberakhir) &&
            (identical(other.statusAktivasi, statusAktivasi) ||
                other.statusAktivasi == statusAktivasi));
  }

  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        tanggal,
        deskripsi,
        jumlah,
        tipe,
        idDompet,
        idKategori,
        idDompetTujuan,
        idPelanggan,
        idPaket,
        idSubKategori,
        statusPembayaran,
        poinDidapat,
        poinDigunakan,
        diperbaruiPada,
        diarsipkanPada,
        diHapus,
        durasiPaket,
        tipeDurasiPaket,
        durasiBonus,
        tipeDurasiBonus,
        tanggalMulai,
        tangglberakhir,
        statusAktivasi
      ]);

  @override
  String toString() {
    return 'TransaksiModel(id: $id, tanggal: $tanggal, deskripsi: $deskripsi, jumlah: $jumlah, tipe: $tipe, idDompet: $idDompet, idKategori: $idKategori, idDompetTujuan: $idDompetTujuan, idPelanggan: $idPelanggan, idPaket: $idPaket, idSubKategori: $idSubKategori, statusPembayaran: $statusPembayaran, poinDidapat: $poinDidapat, poinDigunakan: $poinDigunakan, diperbaruiPada: $diperbaruiPada, diarsipkanPada: $diarsipkanPada, diHapus: $diHapus, durasiPaket: $durasiPaket, tipeDurasiPaket: $tipeDurasiPaket, durasiBonus: $durasiBonus, tipeDurasiBonus: $tipeDurasiBonus, tanggalMulai: $tanggalMulai, tangglberakhir: $tangglberakhir, statusAktivasi: $statusAktivasi)';
  }
}

/// @nodoc
abstract mixin class $TransaksiModelCopyWith<$Res> {
  factory $TransaksiModelCopyWith(
          TransaksiModel value, $Res Function(TransaksiModel) _then) =
      _$TransaksiModelCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      DateTime tanggal,
      String deskripsi,
      double jumlah,
      TipeTransaksi tipe,
      String idDompet,
      String idKategori,
      String? idDompetTujuan,
      String? idPelanggan,
      String? idPaket,
      String? idSubKategori,
      StatusPembayaran statusPembayaran,
      int poinDidapat,
      int poinDigunakan,
      DateTime? diperbaruiPada,
      DateTime? diarsipkanPada,
      bool diHapus,
      int? durasiPaket,
      TipeDurasiPaket? tipeDurasiPaket,
      int durasiBonus,
      TipeDurasiPaket? tipeDurasiBonus,
      DateTime? tanggalMulai,
      DateTime? tangglberakhir,
      bool statusAktivasi});
}

/// @nodoc
class _$TransaksiModelCopyWithImpl<$Res>
    implements $TransaksiModelCopyWith<$Res> {
  _$TransaksiModelCopyWithImpl(this._self, this._then);

  final TransaksiModel _self;
  final $Res Function(TransaksiModel) _then;

  /// Create a copy of TransaksiModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tanggal = null,
    Object? deskripsi = null,
    Object? jumlah = null,
    Object? tipe = null,
    Object? idDompet = null,
    Object? idKategori = null,
    Object? idDompetTujuan = freezed,
    Object? idPelanggan = freezed,
    Object? idPaket = freezed,
    Object? idSubKategori = freezed,
    Object? statusPembayaran = null,
    Object? poinDidapat = null,
    Object? poinDigunakan = null,
    Object? diperbaruiPada = freezed,
    Object? diarsipkanPada = freezed,
    Object? diHapus = null,
    Object? durasiPaket = freezed,
    Object? tipeDurasiPaket = freezed,
    Object? durasiBonus = null,
    Object? tipeDurasiBonus = freezed,
    Object? tanggalMulai = freezed,
    Object? tangglberakhir = freezed,
    Object? statusAktivasi = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      tanggal: null == tanggal
          ? _self.tanggal
          : tanggal // ignore: cast_nullable_to_non_nullable
              as DateTime,
      deskripsi: null == deskripsi
          ? _self.deskripsi
          : deskripsi // ignore: cast_nullable_to_non_nullable
              as String,
      jumlah: null == jumlah
          ? _self.jumlah
          : jumlah // ignore: cast_nullable_to_non_nullable
              as double,
      tipe: null == tipe
          ? _self.tipe
          : tipe // ignore: cast_nullable_to_non_nullable
              as TipeTransaksi,
      idDompet: null == idDompet
          ? _self.idDompet
          : idDompet // ignore: cast_nullable_to_non_nullable
              as String,
      idKategori: null == idKategori
          ? _self.idKategori
          : idKategori // ignore: cast_nullable_to_non_nullable
              as String,
      idDompetTujuan: freezed == idDompetTujuan
          ? _self.idDompetTujuan
          : idDompetTujuan // ignore: cast_nullable_to_non_nullable
              as String?,
      idPelanggan: freezed == idPelanggan
          ? _self.idPelanggan
          : idPelanggan // ignore: cast_nullable_to_non_nullable
              as String?,
      idPaket: freezed == idPaket
          ? _self.idPaket
          : idPaket // ignore: cast_nullable_to_non_nullable
              as String?,
      idSubKategori: freezed == idSubKategori
          ? _self.idSubKategori
          : idSubKategori // ignore: cast_nullable_to_non_nullable
              as String?,
      statusPembayaran: null == statusPembayaran
          ? _self.statusPembayaran
          : statusPembayaran // ignore: cast_nullable_to_non_nullable
              as StatusPembayaran,
      poinDidapat: null == poinDidapat
          ? _self.poinDidapat
          : poinDidapat // ignore: cast_nullable_to_non_nullable
              as int,
      poinDigunakan: null == poinDigunakan
          ? _self.poinDigunakan
          : poinDigunakan // ignore: cast_nullable_to_non_nullable
              as int,
      diperbaruiPada: freezed == diperbaruiPada
          ? _self.diperbaruiPada
          : diperbaruiPada // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      diarsipkanPada: freezed == diarsipkanPada
          ? _self.diarsipkanPada
          : diarsipkanPada // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      diHapus: null == diHapus
          ? _self.diHapus
          : diHapus // ignore: cast_nullable_to_non_nullable
              as bool,
      durasiPaket: freezed == durasiPaket
          ? _self.durasiPaket
          : durasiPaket // ignore: cast_nullable_to_non_nullable
              as int?,
      tipeDurasiPaket: freezed == tipeDurasiPaket
          ? _self.tipeDurasiPaket
          : tipeDurasiPaket // ignore: cast_nullable_to_non_nullable
              as TipeDurasiPaket?,
      durasiBonus: null == durasiBonus
          ? _self.durasiBonus
          : durasiBonus // ignore: cast_nullable_to_non_nullable
              as int,
      tipeDurasiBonus: freezed == tipeDurasiBonus
          ? _self.tipeDurasiBonus
          : tipeDurasiBonus // ignore: cast_nullable_to_non_nullable
              as TipeDurasiPaket?,
      tanggalMulai: freezed == tanggalMulai
          ? _self.tanggalMulai
          : tanggalMulai // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      tangglberakhir: freezed == tangglberakhir
          ? _self.tangglberakhir
          : tangglberakhir // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      statusAktivasi: null == statusAktivasi
          ? _self.statusAktivasi
          : statusAktivasi // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// Adds pattern-matching-related methods to [TransaksiModel].
extension TransaksiModelPatterns on TransaksiModel {
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
    TResult Function(_TransaksiModel value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _TransaksiModel() when $default != null:
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
    TResult Function(_TransaksiModel value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TransaksiModel():
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
    TResult? Function(_TransaksiModel value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TransaksiModel() when $default != null:
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
            DateTime tanggal,
            String deskripsi,
            double jumlah,
            TipeTransaksi tipe,
            String idDompet,
            String idKategori,
            String? idDompetTujuan,
            String? idPelanggan,
            String? idPaket,
            String? idSubKategori,
            StatusPembayaran statusPembayaran,
            int poinDidapat,
            int poinDigunakan,
            DateTime? diperbaruiPada,
            DateTime? diarsipkanPada,
            bool diHapus,
            int? durasiPaket,
            TipeDurasiPaket? tipeDurasiPaket,
            int durasiBonus,
            TipeDurasiPaket? tipeDurasiBonus,
            DateTime? tanggalMulai,
            DateTime? tangglberakhir,
            bool statusAktivasi)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _TransaksiModel() when $default != null:
        return $default(
            _that.id,
            _that.tanggal,
            _that.deskripsi,
            _that.jumlah,
            _that.tipe,
            _that.idDompet,
            _that.idKategori,
            _that.idDompetTujuan,
            _that.idPelanggan,
            _that.idPaket,
            _that.idSubKategori,
            _that.statusPembayaran,
            _that.poinDidapat,
            _that.poinDigunakan,
            _that.diperbaruiPada,
            _that.diarsipkanPada,
            _that.diHapus,
            _that.durasiPaket,
            _that.tipeDurasiPaket,
            _that.durasiBonus,
            _that.tipeDurasiBonus,
            _that.tanggalMulai,
            _that.tangglberakhir,
            _that.statusAktivasi);
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
            DateTime tanggal,
            String deskripsi,
            double jumlah,
            TipeTransaksi tipe,
            String idDompet,
            String idKategori,
            String? idDompetTujuan,
            String? idPelanggan,
            String? idPaket,
            String? idSubKategori,
            StatusPembayaran statusPembayaran,
            int poinDidapat,
            int poinDigunakan,
            DateTime? diperbaruiPada,
            DateTime? diarsipkanPada,
            bool diHapus,
            int? durasiPaket,
            TipeDurasiPaket? tipeDurasiPaket,
            int durasiBonus,
            TipeDurasiPaket? tipeDurasiBonus,
            DateTime? tanggalMulai,
            DateTime? tangglberakhir,
            bool statusAktivasi)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TransaksiModel():
        return $default(
            _that.id,
            _that.tanggal,
            _that.deskripsi,
            _that.jumlah,
            _that.tipe,
            _that.idDompet,
            _that.idKategori,
            _that.idDompetTujuan,
            _that.idPelanggan,
            _that.idPaket,
            _that.idSubKategori,
            _that.statusPembayaran,
            _that.poinDidapat,
            _that.poinDigunakan,
            _that.diperbaruiPada,
            _that.diarsipkanPada,
            _that.diHapus,
            _that.durasiPaket,
            _that.tipeDurasiPaket,
            _that.durasiBonus,
            _that.tipeDurasiBonus,
            _that.tanggalMulai,
            _that.tangglberakhir,
            _that.statusAktivasi);
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
            DateTime tanggal,
            String deskripsi,
            double jumlah,
            TipeTransaksi tipe,
            String idDompet,
            String idKategori,
            String? idDompetTujuan,
            String? idPelanggan,
            String? idPaket,
            String? idSubKategori,
            StatusPembayaran statusPembayaran,
            int poinDidapat,
            int poinDigunakan,
            DateTime? diperbaruiPada,
            DateTime? diarsipkanPada,
            bool diHapus,
            int? durasiPaket,
            TipeDurasiPaket? tipeDurasiPaket,
            int durasiBonus,
            TipeDurasiPaket? tipeDurasiBonus,
            DateTime? tanggalMulai,
            DateTime? tangglberakhir,
            bool statusAktivasi)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TransaksiModel() when $default != null:
        return $default(
            _that.id,
            _that.tanggal,
            _that.deskripsi,
            _that.jumlah,
            _that.tipe,
            _that.idDompet,
            _that.idKategori,
            _that.idDompetTujuan,
            _that.idPelanggan,
            _that.idPaket,
            _that.idSubKategori,
            _that.statusPembayaran,
            _that.poinDidapat,
            _that.poinDigunakan,
            _that.diperbaruiPada,
            _that.diarsipkanPada,
            _that.diHapus,
            _that.durasiPaket,
            _that.tipeDurasiPaket,
            _that.durasiBonus,
            _that.tipeDurasiBonus,
            _that.tanggalMulai,
            _that.tangglberakhir,
            _that.statusAktivasi);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _TransaksiModel extends TransaksiModel {
  const _TransaksiModel(
      {this.id = '',
      required this.tanggal,
      required this.deskripsi,
      required this.jumlah,
      required this.tipe,
      required this.idDompet,
      required this.idKategori,
      this.idDompetTujuan,
      this.idPelanggan,
      this.idPaket,
      this.idSubKategori,
      this.statusPembayaran = StatusPembayaran.unpaid,
      this.poinDidapat = 0,
      this.poinDigunakan = 0,
      this.diperbaruiPada,
      this.diarsipkanPada,
      this.diHapus = false,
      this.durasiPaket,
      this.tipeDurasiPaket,
      this.durasiBonus = 0,
      this.tipeDurasiBonus,
      this.tanggalMulai,
      this.tangglberakhir,
      this.statusAktivasi = false})
      : super._();

  @override
  @JsonKey()
  final String id;
  @override
  final DateTime tanggal;
  @override
  final String deskripsi;
  @override
  final double jumlah;
  @override
  final TipeTransaksi tipe;
  @override
  final String idDompet;
  @override
  final String idKategori;
  @override
  final String? idDompetTujuan;
  @override
  final String? idPelanggan;
  @override
  final String? idPaket;
  @override
  final String? idSubKategori;
  @override
  @JsonKey()
  final StatusPembayaran statusPembayaran;
  @override
  @JsonKey()
  final int poinDidapat;
  @override
  @JsonKey()
  final int poinDigunakan;
  @override
  final DateTime? diperbaruiPada;
  @override
  final DateTime? diarsipkanPada;
  @override
  @JsonKey()
  final bool diHapus;
  @override
  final int? durasiPaket;
  @override
  final TipeDurasiPaket? tipeDurasiPaket;
  @override
  @JsonKey()
  final int durasiBonus;
  @override
  final TipeDurasiPaket? tipeDurasiBonus;
  @override
  final DateTime? tanggalMulai;
  @override
  final DateTime? tangglberakhir;
  @override
  @JsonKey()
  final bool statusAktivasi;

  /// Create a copy of TransaksiModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$TransaksiModelCopyWith<_TransaksiModel> get copyWith =>
      __$TransaksiModelCopyWithImpl<_TransaksiModel>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _TransaksiModel &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.tanggal, tanggal) || other.tanggal == tanggal) &&
            (identical(other.deskripsi, deskripsi) ||
                other.deskripsi == deskripsi) &&
            (identical(other.jumlah, jumlah) || other.jumlah == jumlah) &&
            (identical(other.tipe, tipe) || other.tipe == tipe) &&
            (identical(other.idDompet, idDompet) ||
                other.idDompet == idDompet) &&
            (identical(other.idKategori, idKategori) ||
                other.idKategori == idKategori) &&
            (identical(other.idDompetTujuan, idDompetTujuan) ||
                other.idDompetTujuan == idDompetTujuan) &&
            (identical(other.idPelanggan, idPelanggan) ||
                other.idPelanggan == idPelanggan) &&
            (identical(other.idPaket, idPaket) || other.idPaket == idPaket) &&
            (identical(other.idSubKategori, idSubKategori) ||
                other.idSubKategori == idSubKategori) &&
            (identical(other.statusPembayaran, statusPembayaran) ||
                other.statusPembayaran == statusPembayaran) &&
            (identical(other.poinDidapat, poinDidapat) ||
                other.poinDidapat == poinDidapat) &&
            (identical(other.poinDigunakan, poinDigunakan) ||
                other.poinDigunakan == poinDigunakan) &&
            (identical(other.diperbaruiPada, diperbaruiPada) ||
                other.diperbaruiPada == diperbaruiPada) &&
            (identical(other.diarsipkanPada, diarsipkanPada) ||
                other.diarsipkanPada == diarsipkanPada) &&
            (identical(other.diHapus, diHapus) || other.diHapus == diHapus) &&
            (identical(other.durasiPaket, durasiPaket) ||
                other.durasiPaket == durasiPaket) &&
            (identical(other.tipeDurasiPaket, tipeDurasiPaket) ||
                other.tipeDurasiPaket == tipeDurasiPaket) &&
            (identical(other.durasiBonus, durasiBonus) ||
                other.durasiBonus == durasiBonus) &&
            (identical(other.tipeDurasiBonus, tipeDurasiBonus) ||
                other.tipeDurasiBonus == tipeDurasiBonus) &&
            (identical(other.tanggalMulai, tanggalMulai) ||
                other.tanggalMulai == tanggalMulai) &&
            (identical(other.tangglberakhir, tangglberakhir) ||
                other.tangglberakhir == tangglberakhir) &&
            (identical(other.statusAktivasi, statusAktivasi) ||
                other.statusAktivasi == statusAktivasi));
  }

  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        tanggal,
        deskripsi,
        jumlah,
        tipe,
        idDompet,
        idKategori,
        idDompetTujuan,
        idPelanggan,
        idPaket,
        idSubKategori,
        statusPembayaran,
        poinDidapat,
        poinDigunakan,
        diperbaruiPada,
        diarsipkanPada,
        diHapus,
        durasiPaket,
        tipeDurasiPaket,
        durasiBonus,
        tipeDurasiBonus,
        tanggalMulai,
        tangglberakhir,
        statusAktivasi
      ]);

  @override
  String toString() {
    return 'TransaksiModel(id: $id, tanggal: $tanggal, deskripsi: $deskripsi, jumlah: $jumlah, tipe: $tipe, idDompet: $idDompet, idKategori: $idKategori, idDompetTujuan: $idDompetTujuan, idPelanggan: $idPelanggan, idPaket: $idPaket, idSubKategori: $idSubKategori, statusPembayaran: $statusPembayaran, poinDidapat: $poinDidapat, poinDigunakan: $poinDigunakan, diperbaruiPada: $diperbaruiPada, diarsipkanPada: $diarsipkanPada, diHapus: $diHapus, durasiPaket: $durasiPaket, tipeDurasiPaket: $tipeDurasiPaket, durasiBonus: $durasiBonus, tipeDurasiBonus: $tipeDurasiBonus, tanggalMulai: $tanggalMulai, tangglberakhir: $tangglberakhir, statusAktivasi: $statusAktivasi)';
  }
}

/// @nodoc
abstract mixin class _$TransaksiModelCopyWith<$Res>
    implements $TransaksiModelCopyWith<$Res> {
  factory _$TransaksiModelCopyWith(
          _TransaksiModel value, $Res Function(_TransaksiModel) _then) =
      __$TransaksiModelCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      DateTime tanggal,
      String deskripsi,
      double jumlah,
      TipeTransaksi tipe,
      String idDompet,
      String idKategori,
      String? idDompetTujuan,
      String? idPelanggan,
      String? idPaket,
      String? idSubKategori,
      StatusPembayaran statusPembayaran,
      int poinDidapat,
      int poinDigunakan,
      DateTime? diperbaruiPada,
      DateTime? diarsipkanPada,
      bool diHapus,
      int? durasiPaket,
      TipeDurasiPaket? tipeDurasiPaket,
      int durasiBonus,
      TipeDurasiPaket? tipeDurasiBonus,
      DateTime? tanggalMulai,
      DateTime? tangglberakhir,
      bool statusAktivasi});
}

/// @nodoc
class __$TransaksiModelCopyWithImpl<$Res>
    implements _$TransaksiModelCopyWith<$Res> {
  __$TransaksiModelCopyWithImpl(this._self, this._then);

  final _TransaksiModel _self;
  final $Res Function(_TransaksiModel) _then;

  /// Create a copy of TransaksiModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? tanggal = null,
    Object? deskripsi = null,
    Object? jumlah = null,
    Object? tipe = null,
    Object? idDompet = null,
    Object? idKategori = null,
    Object? idDompetTujuan = freezed,
    Object? idPelanggan = freezed,
    Object? idPaket = freezed,
    Object? idSubKategori = freezed,
    Object? statusPembayaran = null,
    Object? poinDidapat = null,
    Object? poinDigunakan = null,
    Object? diperbaruiPada = freezed,
    Object? diarsipkanPada = freezed,
    Object? diHapus = null,
    Object? durasiPaket = freezed,
    Object? tipeDurasiPaket = freezed,
    Object? durasiBonus = null,
    Object? tipeDurasiBonus = freezed,
    Object? tanggalMulai = freezed,
    Object? tangglberakhir = freezed,
    Object? statusAktivasi = null,
  }) {
    return _then(_TransaksiModel(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      tanggal: null == tanggal
          ? _self.tanggal
          : tanggal // ignore: cast_nullable_to_non_nullable
              as DateTime,
      deskripsi: null == deskripsi
          ? _self.deskripsi
          : deskripsi // ignore: cast_nullable_to_non_nullable
              as String,
      jumlah: null == jumlah
          ? _self.jumlah
          : jumlah // ignore: cast_nullable_to_non_nullable
              as double,
      tipe: null == tipe
          ? _self.tipe
          : tipe // ignore: cast_nullable_to_non_nullable
              as TipeTransaksi,
      idDompet: null == idDompet
          ? _self.idDompet
          : idDompet // ignore: cast_nullable_to_non_nullable
              as String,
      idKategori: null == idKategori
          ? _self.idKategori
          : idKategori // ignore: cast_nullable_to_non_nullable
              as String,
      idDompetTujuan: freezed == idDompetTujuan
          ? _self.idDompetTujuan
          : idDompetTujuan // ignore: cast_nullable_to_non_nullable
              as String?,
      idPelanggan: freezed == idPelanggan
          ? _self.idPelanggan
          : idPelanggan // ignore: cast_nullable_to_non_nullable
              as String?,
      idPaket: freezed == idPaket
          ? _self.idPaket
          : idPaket // ignore: cast_nullable_to_non_nullable
              as String?,
      idSubKategori: freezed == idSubKategori
          ? _self.idSubKategori
          : idSubKategori // ignore: cast_nullable_to_non_nullable
              as String?,
      statusPembayaran: null == statusPembayaran
          ? _self.statusPembayaran
          : statusPembayaran // ignore: cast_nullable_to_non_nullable
              as StatusPembayaran,
      poinDidapat: null == poinDidapat
          ? _self.poinDidapat
          : poinDidapat // ignore: cast_nullable_to_non_nullable
              as int,
      poinDigunakan: null == poinDigunakan
          ? _self.poinDigunakan
          : poinDigunakan // ignore: cast_nullable_to_non_nullable
              as int,
      diperbaruiPada: freezed == diperbaruiPada
          ? _self.diperbaruiPada
          : diperbaruiPada // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      diarsipkanPada: freezed == diarsipkanPada
          ? _self.diarsipkanPada
          : diarsipkanPada // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      diHapus: null == diHapus
          ? _self.diHapus
          : diHapus // ignore: cast_nullable_to_non_nullable
              as bool,
      durasiPaket: freezed == durasiPaket
          ? _self.durasiPaket
          : durasiPaket // ignore: cast_nullable_to_non_nullable
              as int?,
      tipeDurasiPaket: freezed == tipeDurasiPaket
          ? _self.tipeDurasiPaket
          : tipeDurasiPaket // ignore: cast_nullable_to_non_nullable
              as TipeDurasiPaket?,
      durasiBonus: null == durasiBonus
          ? _self.durasiBonus
          : durasiBonus // ignore: cast_nullable_to_non_nullable
              as int,
      tipeDurasiBonus: freezed == tipeDurasiBonus
          ? _self.tipeDurasiBonus
          : tipeDurasiBonus // ignore: cast_nullable_to_non_nullable
              as TipeDurasiPaket?,
      tanggalMulai: freezed == tanggalMulai
          ? _self.tanggalMulai
          : tanggalMulai // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      tangglberakhir: freezed == tangglberakhir
          ? _self.tangglberakhir
          : tangglberakhir // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      statusAktivasi: null == statusAktivasi
          ? _self.statusAktivasi
          : statusAktivasi // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

// dart format on
