// path: test/shared/model/transaksi_model_test.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wifi/shared/enum/status_pembayaran_enum.dart';
import 'package:wifi/shared/enum/tipe_transaksi_enum.dart';
import 'package:wifi/shared/model/paket_model.dart'; // Untuk TipeDurasi
import 'package:wifi/shared/model/transaksi_model.dart';

void main() {
  group('TransaksiModel', () {
    final tanggalSekarang = DateTime.now();

    // Data dasar untuk transaksi umum
    final transaksiDasar = TransactionModel(
      id: 'trans-001',
      tanggal: tanggalSekarang,
      keterangan: 'Beli pulsa',
      jumlah: 50000,
      tipe: TipeTransaksiEnum.pengeluaran,
      idDompet: 'dompet-A',
      idKategori: 'kat-pulsa',
    );

    // Data untuk transaksi langganan
    final transaksiLangganan = TransactionModel(
      id: 'trans-002',
      tanggal: tanggalSekarang,
      keterangan: 'Aktivasi Paket Internet 1 Bulan',
      jumlah: 150000,
      tipe: TipeTransaksiEnum.pemasukan, // DIGANTI: dari langganan ke pemasukan
      idDompet: 'dompet-B',
      idKategori: 'kat-internet',
      idPelanggan: 'pel-007',
      idPaket: 'pkt-net-1bln',
      statusPembayaran: StatusPembayaranEnum.lunas,
      aktivasiPaket: true,
      durasiPaket: 1,
      tipeDurasiPaket: TipeDurasi.bulan,
      tanggalMulai: tanggalSekarang,
      tanggalBerakhir: tanggalSekarang.add(const Duration(days: 30)),
    );

    // 1. Uji Konstruktor dan Nilai Default
    test('Konstruktor harus menerapkan nilai default dengan benar', () {
      expect(transaksiDasar.statusPembayaran, StatusPembayaranEnum.belumLunas);
      expect(transaksiDasar.poinYangDihasilkan, 0);
      expect(transaksiDasar.poinYangDigunakan, 0);
      expect(transaksiDasar.isDeleted, isFalse);
      expect(transaksiDasar.aktivasiPaket, isFalse);
      expect(transaksiDasar.idPelanggan, isNull);
      expect(transaksiDasar.durasiPaket, isNull);
    });

    // 2. Uji copyWith
    test('copyWith harus menyalin dan memperbarui semua field', () {
      final diperbarui = transaksiLangganan.copyWith(
        jumlah: 155000,
        keterangan: 'Update: Aktivasi Paket Internet 1 Bulan + Admin',
        isDeleted: true,
        tipeDurasiPaket: TipeDurasi.hari, // Mengubah tipe durasi
      );

      expect(diperbarui.id, 'trans-002');
      expect(diperbarui.jumlah, 155000);
      expect(diperbarui.keterangan, contains('Update'));
      expect(diperbarui.isDeleted, isTrue);
      expect(
        diperbarui.tipe,
        TipeTransaksiEnum.pemasukan,
      ); // VERIFIKASI: tipe tetap sama
      expect(diperbarui.tipeDurasiPaket, TipeDurasi.hari);
      expect(diperbarui.tanggalMulai, transaksiLangganan.tanggalMulai);
    });

    // 3. Uji Konversi SQLite
    group('Konversi SQLite', () {
      final sqliteMap = {
        'id': 'sqlite-trans-1',
        'tanggal': tanggalSekarang.millisecondsSinceEpoch,
        'keterangan': 'Bayar Listrik',
        'jumlah': 250000.0,
        'tipe': 'pengeluaran',
        'id_dompet': 'd-sq-1',
        'id_kategori': 'k-sq-1',
        'id_dompet_tujuan': null,
        'id_pelanggan': 'p-sq-1',
        'id_paket': null,
        'id_sub_kategori': 'sk-sq-1',
        'status_pembayaran': 'lunas',
        'poin_yang_dihasilkan': 10,
        'poin_yang_digunakan': 5,
        'diperbarui': tanggalSekarang.millisecondsSinceEpoch,
        'diarsipkan': null,
        'isDeleted': 0,
        'durasi_paket': 30,
        'tipe_durasi_paket': 'hari',
        'tanggal_mulai': tanggalSekarang.millisecondsSinceEpoch,
        'tanggal_berakhir': tanggalSekarang
            .add(const Duration(days: 30))
            .millisecondsSinceEpoch,
        'aktivasi_paket': 1,
      };

      test('fromSqlite harus membuat model dengan benar', () {
        final model = TransactionModel.fromSqlite(sqliteMap);

        expect(model.id, 'sqlite-trans-1');
        expect(model.jumlah, 250000.0);
        expect(model.tipe, TipeTransaksiEnum.pengeluaran);
        expect(model.statusPembayaran, StatusPembayaranEnum.lunas);
        expect(model.poinYangDihasilkan, 10);
        expect(model.isDeleted, isFalse);
        expect(model.durasiPaket, 30);
        expect(model.tipeDurasiPaket, TipeDurasi.hari);
        expect(model.aktivasiPaket, isTrue);
        expect(
          model.tanggal.millisecondsSinceEpoch,
          tanggalSekarang.millisecondsSinceEpoch,
        );
      });

      test('toSqlite harus menghasilkan map dengan benar', () {
        final model = TransactionModel.fromSqlite(sqliteMap);
        final hasilMap = model.toSqlite();
        expect(hasilMap, sqliteMap);
      });

      test('fromSqlite harus menangani nilai null dan default', () {
        final mapKosong = {
          'id': 'kosong',
          'tanggal': tanggalSekarang.millisecondsSinceEpoch,
          'keterangan': 'test',
          'jumlah': 1.0,
          'id_dompet': 'd',
          'id_kategori': 'k',
        };
        final model = TransactionModel.fromSqlite(mapKosong);
        expect(model.tipe, TipeTransaksiEnum.pengeluaran); // Default
        expect(
          model.statusPembayaran,
          StatusPembayaranEnum.belumLunas,
        ); // Default
        expect(model.durasiPaket, isNull);
      });
    });

    // 4. Uji Konversi Firebase
    group('Konversi Firebase', () {
      final tanggalMulai = DateTime(2024);
      final tanggalBerakhir = DateTime(2024, 2);

      final firebaseData = {
        'tanggal': Timestamp.fromDate(tanggalMulai),
        'keterangan': 'Sewa Hosting',
        'jumlah': 500000.0,
        'tipe': 'pengeluaran',
        'id_dompet': 'd-fb-1',
        'id_kategori': 'k-fb-1',
        'status_pembayaran': 'lunas',
        'isDeleted': false,
        'durasiPaket': 1,
        'tipeDurasiPaket': 'bulan',
        'tanggalMulai': Timestamp.fromDate(tanggalMulai),
        'tanggalBerakhir': Timestamp.fromDate(tanggalBerakhir),
        'aktivasiPaket': false,
        'diperbarui': FieldValue.serverTimestamp(),
      };

      test('fromFirebase harus membuat model dengan benar', () {
        final model = TransactionModel.fromFirebase('fb-trans-1', firebaseData);

        expect(model.id, 'fb-trans-1');
        expect(model.jumlah, 500000.0);
        expect(model.tipe, TipeTransaksiEnum.pengeluaran);
        expect(model.tipeDurasiPaket, TipeDurasi.bulan);
        expect(model.tanggalMulai, tanggalMulai);
      });

      test('toFirebase harus menghasilkan map dengan benar', () {
        final model = TransactionModel(
          id: 'fb-trans-2',
          tanggal: tanggalMulai,
          keterangan: 'Sewa Hosting',
          jumlah: 500000.0,
          tipe: TipeTransaksiEnum.pengeluaran,
          idDompet: 'd-fb-1',
          idKategori: 'k-fb-1',
          statusPembayaran: StatusPembayaranEnum.lunas,
          durasiPaket: 1,
          tipeDurasiPaket: TipeDurasi.bulan,
          tanggalMulai: tanggalMulai,
          tanggalBerakhir: tanggalBerakhir,
        );

        final hasilMap = model.toFirebase();

        expect(hasilMap['jumlah'], 500000.0);
        expect(hasilMap['tipe'], 'pengeluaran');
        expect(hasilMap['tipeDurasiPaket'], 'bulan');
        expect(hasilMap['tanggalMulai'], Timestamp.fromDate(tanggalMulai));
        expect(hasilMap['diperbarui'], isA<FieldValue>());
      });
    });
  });
}
