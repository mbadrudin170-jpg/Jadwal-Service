// path: lib/fitur/transaksi/operasi/transaksi_op_firebase.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wifi/fitur/transaksi/enum/status_pembayaran.dart';
import 'package:wifi/fitur/transaksi/model/transaksi_model.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/constant/nama_tabel.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/operasi/firebase_operasi/base_op_firebase.dart';

class TransaksiOpFirebase extends BaseOpFirebase {
  TransaksiOpFirebase({super.firestore}) {
    Log.info('TransactionOpFirebase diinisialisasi.');
  }
  CollectionReference get _koleksi => firestore.collection(NamaTabel.transaksi);
  Future<void> tambahTransaksi(TransaksiModel transaksi) async {
    Log.info('Menambahkan transaksi baru: ${transaksi.id}');
    try {
      await sisipkan(NamaTabel.transaksi, transaksi.id, transaksi.toFirebase());
      Log.info('Berhasil menambahkan transaksi: ${transaksi.id}');
    } on FirebaseException catch (e, s) {
      Log.error('Gagal menambahkan transaksi: ${transaksi.id}', e: e, s: s);
      rethrow;
    }
  }

  Future<TransaksiModel?> ambilBerdasarkanId(String id) async {
    Log.info('Mendapatkan transaksi by ID: $id');
    try {
      final doc = await _koleksi.doc(id).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>?;
        if (data != null) {
          return TransaksiModel.fromFirebase(doc.id, data);
        }
        return null;
      }
      return null;
    } catch (e, st) {
      Log.error(
        'Error mendapatkan transaksi by ID',
        e: e,
        s: st,
        data: {'transactionId': id},
      );
      return null;
    }
  }

  /// Mengambil semua transaksi yang merupakan aktivasi paket dari Firebase.
  Future<List<TransaksiModel>> ambilBerdasarkanStatusAktivasi() async {
    try {
      Log.info(
        'Mengambil transaksi dengan status aktivasi = true dari Firebase',
      );
      final querySnapshot = await _koleksi
          .where(NamaKolom.statusAktivasi, isEqualTo: true)
          .where(NamaKolom.dihapus, isEqualTo: false)
          .orderBy(NamaKolom.tanggal, descending: true)
          .get();
      Log.info(
        'Berhasil mengambil ${querySnapshot.docs.length} transaksi aktivasi paket dari Firebase',
      );
      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return TransaksiModel.fromFirebase(doc.id, data);
      }).toList();
    } on FirebaseException catch (e, st) {
      Log.error(
        'Error saat mengambil transaksi aktivasi paket dari Firebase',
        e: e,
        s: st,
      );
      return [];
    } on Exception catch (e, st) {
      Log.error(
        'Error umum saat mengambil transaksi aktivasi paket dari Firebase',
        e: e,
        s: st,
      );
      return [];
    }
  }

  Future<TransaksiModel?> ambilTransaksiLunasTerbaruBerdasarkanIdPelanggan(
    String idPelanggan,
  ) async {
    try {
      Log.info(
        'Mencari transaksi lunas terbaru dari Firebase untuk pengguna ID: $idPelanggan',
      );
      final querySnapshot = await _koleksi
          .where(NamaKolom.idPelanggan, isEqualTo: idPelanggan)
          .where(
            NamaKolom.statusPembayaran,
            isEqualTo: StatusPembayaran.paid.name,
          )
          .where(NamaKolom.dihapus, isEqualTo: false)
          .orderBy(NamaKolom.tanggalBerakhir, descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        Log.warning(
          'Tidak ada transaksi lunas yang aktif dari Firebase untuk pengguna ID: $idPelanggan',
        );
        return null;
      }

      final doc = querySnapshot.docs.first;
      final data = doc.data() as Map<String, dynamic>;
      Log.info(
        'Transaksi lunas terbaru dari Firebase ditemukan untuk pengguna ID: $idPelanggan',
      );
      return TransaksiModel.fromFirebase(doc.id, data);
    } on Exception catch (e, s) {
      Log.error(
        'Error mengambil transaksi lunas terbaru dari Firebase untuk pengguna ID: $idPelanggan',
        e: e,
        s: s,
      );
      return null;
    }
  }

  Future<List<TransaksiModel>> ambilBelumLunasBerdasarkanIdPelanggan(
    String idPelanggan,
  ) async {
    try {
      final querySnapshot = await _koleksi
          .where(
            NamaKolom.statusPembayaran,
            isEqualTo: StatusPembayaran.unpaid.name,
          )
          .where(NamaKolom.idPelanggan, isEqualTo: idPelanggan)
          .where(NamaKolom.dihapus, isEqualTo: false)
          .orderBy(NamaKolom.tanggal, descending: true)
          .get();
      // jika query tidak cocok atau daftar kosong kembalikan daftar kosong
      if (querySnapshot.docs.isEmpty) {
        Log.info('Tidak ada paket aktif yang ditemukan untuk: $idPelanggan');
        return [];
      }
      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return TransaksiModel.fromFirebase(doc.id, data);
      }).toList();
    } on Exception catch (e, s) {
      Log.error('terjadi error saat pengambilan dftar belum lunas', e: e, s: s);
      return [];
    }
  }

  /// Mengambil semua transaksi untuk seorang pelanggan.
  Future<List<TransaksiModel>> ambilBerdasarkanIdPelanggan(
    String idPelanggan,
  ) async {
    try {
      Log.info('Mengambil semua transaksi untuk: $idPelanggan');
      final querySnapshot = await _koleksi
          .where(NamaKolom.idPelanggan, isEqualTo: idPelanggan)
          .where(NamaKolom.dihapus, isEqualTo: false)
          .orderBy(NamaKolom.tanggal, descending: true)
          .get();
      Log.info('Menemukan ${querySnapshot.docs.length} transaksi.');
      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return TransaksiModel.fromFirebase(doc.id, data);
      }).toList();
    } on Exception catch (e, s) {
      Log.error('Error mengambil transaksi: $e', e: e, s: s);
      return [];
    }
  }

  /// Mengambil semua transaksi yang terkait dengan sebuah dompet (baik sebagai sumber maupun tujuan).
  Future<List<TransaksiModel>> ambilBerdasarkanIdDompet(String idDompet) async {
    try {
      Log.info('Mengambil transaksi terkait Wallet ID: $idDompet');
      final querySnapshot = await _koleksi
          .where(NamaKolom.idDompet, isEqualTo: idDompet)
          .where(NamaKolom.dihapus, isEqualTo: false)
          .orderBy(NamaKolom.tanggal, descending: true)
          .get();
      final querySnapshotTujuan = await _koleksi
          .where(NamaKolom.idDompetTujuan, isEqualTo: idDompet)
          .where(NamaKolom.dihapus, isEqualTo: false)
          .orderBy(NamaKolom.tanggal, descending: true)
          .get();
      final List<TransaksiModel> hasil = [];
      for (final doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        hasil.add(TransaksiModel.fromFirebase(doc.id, data));
      }
      for (final doc in querySnapshotTujuan.docs) {
        final data = doc.data() as Map<String, dynamic>;
        hasil.add(TransaksiModel.fromFirebase(doc.id, data));
      }
      hasil.sort((a, b) => b.tanggal.compareTo(a.tanggal));
      Log.info(
        'Berhasil mengambil ${hasil.length} transaksi untuk Wallet ID: $idDompet',
      );
      return hasil;
    } on Exception catch (e, s) {
      Log.error(
        'Error mengambil transaksi berdasarkan ID dompet: $idDompet',
        e: e,
        s: s,
      );
      return [];
    }
  }

  Future<int> ambilTotalPoin(String idPelanggan) async {
    try {
      Log.info('Menghitung total poin untuk: $idPelanggan');
      final querySnapshot = await _koleksi
          .where(NamaKolom.idPelanggan, isEqualTo: idPelanggan)
          .where(NamaKolom.dihapus, isEqualTo: false)
          .where(
            NamaKolom.statusPembayaran,
            isEqualTo: StatusPembayaran.paid.name,
          )
          .get();
      int totalPoin = 0;
      for (final doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        totalPoin += (data[NamaKolom.poinDidapat] as int? ?? 0);
        totalPoin -= (data[NamaKolom.poinDigunakan] as int? ?? 0);
      }
      Log.info('Total poin untuk $idPelanggan adalah $totalPoin');
      return totalPoin;
    } on Exception catch (e, s) {
      Log.error('Error menghitung total poin: $e', e: e, s: s);
      return 0;
    }
  }

  /// Melakukan soft delete pada transaksi di Firestore.
  Future<void> softDeleteTransaksi(String id) async {
    Log.info('Memulai soft delete transaksi di Firestore: $id');
    try {
      await softDelete(NamaTabel.transaksi, id);
      Log.info('Soft delete transaksi berhasil: $id');
    } on FirebaseException catch (e, s) {
      Log.error('Gagal melakukan soft delete transaksi: $id', e: e, s: s);
      rethrow;
    }
  }

  /// Mengambil daftar paket aktif (transaksi yang belum kedaluwarsa)
  /// untuk seorang pelanggan.
  Future<List<TransaksiModel>> ambilPaketAktifPelanggan(
    String idPelanggan,
  ) async {
    try {
      Log.info('Mulai mengambil paket aktif untuk pelanggan: $idPelanggan');
      // Ambil waktu saat ini
      final DateTime now = DateTime.now();

      final querySnapshot = await _koleksi
          // 1. Cari transaksi milik pelanggan yang benar
          .where(NamaKolom.idPelanggan, isEqualTo: idPelanggan)
          // 2. Pastikan transaksi tidak dihapus
          .where(NamaKolom.dihapus, isEqualTo: false)
          // 3. Filter utama: endDate harus lebih besar dari waktu sekarang
          .where(NamaKolom.tanggalBerakhir, isGreaterThan: now)
          .get();

      // Jika tidak ada dokumen yang cocok, kembalikan list kosong
      if (querySnapshot.docs.isEmpty) {
        Log.info('Tidak ada paket aktif yang ditemukan untuk: $idPelanggan');
        return [];
      }

      // Ubah setiap dokumen menjadi objek TransactionModel
      final daftarPaketAktif = querySnapshot.docs.map((doc) {
        return TransaksiModel.fromFirebase(
          doc.id,
          doc.data() as Map<String, dynamic>,
        );
      }).toList();

      Log.info(
        '${daftarPaketAktif.length} paket aktif ditemukan untuk: $idPelanggan',
      );
      return daftarPaketAktif;
    } on Exception catch (e, s) {
      Log.error(
        'Gagal mengambil paket aktif untuk pelanggan $idPelanggan: $e',
        e: e,
        s: s,
      );
      // Kembalikan list kosong jika terjadi error agar aplikasi tidak crash
      return [];
    }
  }

  /// Menyisipkan atau memperbarui beberapa transaksi sekaligus (batch) di Firestore.
  ///
  /// [items] adalah daftar [TransaksiModel] yang akan disisipkan atau diperbarui.
  /// Fungsi ini menggunakan batch write untuk efisiensi dan atomisitas.
  Future<void> sisipkanAtauPerbaruiBatch(List<TransaksiModel> items) async {
    if (items.isEmpty) {
      Log.info('Batch transaksi: daftar kosong, operasi dibatalkan.');
      return;
    }

    Log.info(
      'Memulai batch insert/update untuk ${items.length} transaksi di Firestore',
    );

    try {
      final batch = firestore.batch();
      for (final transaksi in items) {
        final docRef = _koleksi.doc(transaksi.id);
        final data = transaksi.toFirebase();
        data[NamaKolom.diperbaruiPada] = FieldValue.serverTimestamp();
        batch.set(docRef, data, SetOptions(merge: true));
      }

      await batch.commit();
      Log.info(
        'Batch ${items.length} transaksi berhasil diproses di Firestore',
      );
    } on FirebaseException catch (e, st) {
      Log.error(
        'Gagal memproses batch transaksi di Firestore',
        e: e,
        s: st,
        data: {'jumlahItem': items.length},
      );
      rethrow;
    } on Exception catch (e, st) {
      Log.error(
        'Error umum saat memproses batch transaksi di Firestore',
        e: e,
        s: st,
        data: {'jumlahItem': items.length},
      );
      rethrow;
    }
  }
}
