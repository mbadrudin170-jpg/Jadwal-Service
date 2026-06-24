// path: lib/fitur/poin/service/poin_transaction_service.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:wifi/fitur/notfikasi/enum/tipe_notifikasi_enum.dart';
import 'package:wifi/fitur/notfikasi/model/notifikasi_model.dart';
import 'package:wifi/fitur/order/enum/status_order_enum.dart';
import 'package:wifi/fitur/order/model/order_model.dart';
import 'package:wifi/fitur/paket/model/paket_model.dart';
import 'package:wifi/fitur/pelanggan_aktif/model/pelanggan_aktif_model.dart';
import 'package:wifi/fitur/transaksi/enum/status_pembayaran.dart';
import 'package:wifi/fitur/transaksi/enum/tipe_transaksi.dart';
import 'package:wifi/fitur/transaksi/model/transaksi_model.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/constant/nama_tabel.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/enum/app_role_enum.dart';
import 'package:wifi/shared/operasi/firebase_operasi/base_op_firebase.dart';
import 'package:wifi/shared/operasi/firebase_operasi/firebase_operation_provider/firebase_operation_provider.dart';
import 'package:wifi/shared/utils/perhitungan_util.dart';

/// Service untuk menangani transaksi penukaran poin dengan Firestore Transaction.
class PoinTransactionService {
  final BaseOpFirebase _baseOpFirebase;

  PoinTransactionService({required BaseOpFirebase baseOpFirebase})
    : _baseOpFirebase = baseOpFirebase {
    Log.info('PoinTransactionService diinisialisasi.');
  }

  /// Menukar poin dengan paket menggunakan Firestore Transaction
  ///
  /// Menggunakan BaseOpFirebase.runComplexOperation untuk konsistensi
  /// dengan pattern yang sudah ada di seluruh aplikasi.
  Future<void> tukarPoin({
    required String idPelanggan,
    required PaketModel paket,
    required int poinSaatIni,
  }) async {
    Log.info('Memulai transaksi penukaran poin', {
      'customerId': idPelanggan,
      'packageId': paket.id,
      'packageName': paket.nama,
      'pointsNeeded': paket.poinPenukaran,
      'currentPoints': poinSaatIni,
    });

    // Validasi awal sebelum transaction
    if (poinSaatIni < paket.poinPenukaran) {
      Log.warning('Poin tidak mencukupi untuk penukaran', {
        'customerId': idPelanggan,
        'currentPoints': poinSaatIni,
        'neededPoints': paket.poinPenukaran,
      });
      throw Exception('Poin tidak mencukupi');
    }

    try {
      // Gunakan BaseOpFirebase.runComplexOperation
      await _baseOpFirebase.runComplexOperation((txn) async {
        Log.info('Transaksi Firestore dimulai melalui BaseOpFirebase');

        // 1. BACA DATA PELANGGAN
        final pelangganRef = _baseOpFirebase.firestore
            .collection(NamaTabel.pelanggan)
            .doc(idPelanggan);
        final pelangganDoc = await txn.get(pelangganRef);

        if (!pelangganDoc.exists) {
          Log.error(
            'Pelanggan tidak ditemukan',
            data: {'customerId': idPelanggan},
          );
          throw Exception('Pelanggan tidak ditemukan');
        }

        // 2. HITUNG ULANG POIN DARI TRANSAKSI
        // PERBAIKAN: Gunakan firestore langsung untuk query, bukan txn.get()
        final transaksiSnapshot = await _baseOpFirebase.firestore
            .collection(NamaTabel.transaksi)
            .where(NamaKolom.idPelanggan, isEqualTo: idPelanggan)
            .where(NamaKolom.dihapus, isEqualTo: false)
            .where(
              NamaKolom.statusPembayaran,
              isEqualTo: StatusPembayaran.paid.name,
            )
            .get();

        int totalPoin = 0;
        for (final doc in transaksiSnapshot.docs) {
          final data = doc.data();
          totalPoin += (data[NamaKolom.poinDidapat] as int? ?? 0);
          totalPoin -= (data[NamaKolom.poinDigunakan] as int? ?? 0);
        }

        Log.info('Total poin dihitung ulang', {
          'customerId': idPelanggan,
          'totalPoints': totalPoin,
        });

        // 3. VALIDASI POIN
        if (totalPoin < paket.poinPenukaran) {
          Log.warning('Poin tidak mencukupi setelah perhitungan ulang', {
            'customerId': idPelanggan,
            'totalPoints': totalPoin,
            'neededPoints': paket.poinPenukaran,
          });
          throw Exception(
            'Poin tidak mencukupi (total: $totalPoin, dibutuhkan: ${paket.poinPenukaran})',
          );
        }

        // 4. BUAT DATA YANG DIPERLUKAN
        final now = DateTime.now();
        final idTransaksi = const Uuid().v4();
        final idOrder = const Uuid().v4();
        final idPelangganAktif = const Uuid().v4();

        // Gunakan PerhitunganUtil yang sudah ada
        final tanggalBerakhir = PerhitunganUtil.hitungTanggalBerakhir(
          now,
          paket,
        );

        // 4a. Transaksi
        final transaksiBaru = TransaksiModel(
          id: idTransaksi,
          tanggal: now,
          deskripsi: 'Tukar Poin: ${paket.nama}',
          jumlah: 0,
          tipe: TipeTransaksi.expense,
          idDompet: '',
          idKategori: '',
          idPaket: paket.id,
          idPelanggan: idPelanggan,
          poinDigunakan: paket.poinPenukaran,
          tanggalMulai: now,
          tanggalBerakhir: tanggalBerakhir,
          statusAktivasi: true,
          diperbaruiPada: now.toUtc(),
        );

        // 4b. Pelanggan Aktif
        final pelangganAktifBaru = PelangganAktifModel(
          id: idPelangganAktif,
          idPelanggan: idPelanggan,
          idPaket: paket.id,
          idTransaksi: idTransaksi,
          tanggalMulai: now,
          tanggalBerakhir: tanggalBerakhir,
          status: StatusPembayaran.paid,
          diperbaruiPada: now.toUtc(),
        );

        // 4c. Order
        final orderBaru = OrderModel(
          id: idOrder,
          idPelanggan: idPelanggan,
          idPaket: paket.id,
          tanggal: now,
          status: StatusOrderEnum.baru,
          diperbaruiPada: now.toUtc(),
        );

        // 4d. Notifikasi untuk admin
        final notifikasiBaru = NotifikasiModel(
          id: const Uuid().v4(),
          tanggalMulai: now,
          tanggalBerakhir: now,
          tanggalTampil: now,
          judul: 'Order Paket',
          deskripsi: 'Pelanggan menukar poin untuk paket ${paket.nama}',
          tipe: TipeNotifikasiEnum.order,
          diperbaruiPada: now.toUtc(),
          idTujuan: idOrder,
          userId: idPelanggan,
          targetRole: AppRole.admin,
        );

        // 5. SIMPAN SEMUA DATA DALAM SATU TRANSACTION
        Log.info('Menyimpan semua data dalam transaction...', {
          'transactionId': idTransaksi,
          'orderId': idOrder,
          'activeCustomerId': idPelangganAktif,
        });

        // Simpan transaksi
        txn.set(
          _baseOpFirebase.firestore
              .collection(NamaTabel.transaksi)
              .doc(idTransaksi),
          transaksiBaru.toFirebase(),
        );

        // Simpan pelanggan aktif
        txn.set(
          _baseOpFirebase.firestore
              .collection(NamaTabel.pelangganAktif)
              .doc(idPelangganAktif),
          pelangganAktifBaru.toFirebase(),
        );

        // Simpan order
        txn.set(
          _baseOpFirebase.firestore
              .collection(NamaTabel.pesananPelanggan)
              .doc(idOrder),
          orderBaru.toFirebase(),
        );

        // Simpan notifikasi
        txn.set(
          _baseOpFirebase.firestore
              .collection(NamaTabel.notifikasi)
              .doc(notifikasiBaru.id),
          notifikasiBaru.toFirebase(),
        );

        Log.info('Semua data berhasil disimpan dalam transaction');
      });

      Log.info('Transaksi penukaran poin BERHASIL', {
        'customerId': idPelanggan,
        'packageId': paket.id,
        'pointsUsed': paket.poinPenukaran,
      });
    } catch (e, st) {
      Log.error(
        'Transaksi penukaran poin GAGAL',
        e: e,
        s: st,
        data: {'customerId': idPelanggan, 'packageId': paket.id},
      );
      rethrow;
    }
  }
}

/// Provider untuk PoinTransactionService
final poinTransactionServiceProvider = Provider<PoinTransactionService>((ref) {
  final baseOpFirebase = ref.watch(baseOpFirebaseProvider);
  return PoinTransactionService(baseOpFirebase: baseOpFirebase);
});
