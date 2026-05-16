// path: lib/services/firebase_migration/firebase_migration_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/enum/nama_tabel_enum.dart';

/// A service to handle data migrations in Firebase.
class FirebaseMigrationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // TODO: Verifikasi apakah 'riwayat_langganan' perlu disertakan dalam migrasi.
  // Enum NamaTabel tidak memiliki entri untuk 'riwayat_langganan'.
  final List<String> _isDeletedCollections = [
    NamaTabel.dompet.name,
    NamaTabel.kategori.name,
    NamaTabel.paket.name,
    NamaTabel.pelangganAktif.name,
    NamaTabel.pelanggan.name,
    NamaTabel.pesanan.name,
    NamaTabel.subKategori.name,
    NamaTabel.transaksi.name,
    NamaTabel.versiApkUser.name,
    NamaTabel.kritikSaran.name,
  ];

  // Migrasi untuk field `isDeleted` dari int ke bool
  Future<void> _migrateIsDeleted(
    final String collectionName,
    final WriteBatch batch,
    final List<String> logs,
  ) async {
    final QuerySnapshot snapshot =
        await _firestore.collection(collectionName).get();
    int migratedCount = 0;

    for (final doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>?;

      if (data != null && data.containsKey('isDeleted')) {
        final currentValue = data['isDeleted'];
        if (currentValue is int) {
          final bool newValue = currentValue == 1;
          batch.update(doc.reference, {'isDeleted': newValue});
          migratedCount++;
        }
      }
    }

    if (migratedCount > 0) {
      logs.add(
        '  - [isDeleted] $migratedCount dokumen akan dimigrasi di `$collectionName`.',
      );
    }
  }

  // Migrasi untuk field di koleksi `versi_apk_user`
  Future<void> _migrateVersiApkUser(
      final WriteBatch batch, final List<String> logs) async {
    final QuerySnapshot snapshot =
        await _firestore.collection(NamaTabel.versiApkUser.name).get();
    int migratedBuildCount = 0;
    int migratedTautanCount = 0;
    int migratedBuildDanTautanCount = 0;

    for (final doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final docRef = doc.reference;

      final dynamic nomorBuildLama = data['nomor_build_terbaru'];
      final dynamic tautanUnduhanLama = data['tautan_unduhan'];

      final Map<String, dynamic> updateData = {};
      bool buildPerluMigrasi = false;
      bool tautanPerluMigrasi = false;

      // Migrasi nomor_build_terbaru
      if (nomorBuildLama != null && nomorBuildLama is! Map) {
        buildPerluMigrasi = true;

        if (nomorBuildLama is int) {
          updateData['nomor_build_terbaru'] = {
            'universal': nomorBuildLama,
            'bit_32': 0,
            'bit_64': 0,
          };
        } else if (nomorBuildLama is String &&
            int.tryParse(nomorBuildLama) != null) {
          updateData['nomor_build_terbaru'] = {
            'universal': int.parse(nomorBuildLama),
            'bit_32': 0,
            'bit_64': 0,
          };
        } else {
          updateData['nomor_build_terbaru'] = {
            'universal': 0,
            'bit_32': 0,
            'bit_64': 0,
          };
        }
      }

      // Migrasi tautan_unduhan
      if (tautanUnduhanLama != null && tautanUnduhanLama is! Map) {
        tautanPerluMigrasi = true;

        if (tautanUnduhanLama is String && tautanUnduhanLama.isNotEmpty) {
          updateData['tautan_unduhan'] = {
            'universal': tautanUnduhanLama,
            'bit_32': '',
            'bit_64': '',
          };
        } else {
          updateData['tautan_unduhan'] = {
            'universal': '',
            'bit_32': '',
            'bit_64': '',
          };
        }
      }

      if (updateData.isNotEmpty) {
        batch.update(docRef, updateData);

        if (buildPerluMigrasi && tautanPerluMigrasi) {
          migratedBuildDanTautanCount++;
        } else if (buildPerluMigrasi) {
          migratedBuildCount++;
        } else if (tautanPerluMigrasi) {
          migratedTautanCount++;
        }
      }
    }

    if (migratedBuildCount > 0) {
      logs.add(
        '  - [nomor_build_terbaru] $migratedBuildCount dokumen akan dimigrasi.',
      );
    }
    if (migratedTautanCount > 0) {
      logs.add(
        '  - [tautan_unduhan] $migratedTautanCount dokumen akan dimigrasi.',
      );
    }
    if (migratedBuildDanTautanCount > 0) {
      logs.add(
        '  - [nomor_build + tautan] $migratedBuildDanTautanCount dokumen akan dimigrasi.',
      );
    }

    final totalMigrated =
        migratedBuildCount + migratedTautanCount + migratedBuildDanTautanCount;
    if (totalMigrated > 0) {
      logs.add(
        '  Total: $totalMigrated dokumen di `${NamaTabel.versiApkUser.name}` akan dimigrasi.',
      );
    }
  }

  /// Migrasi untuk mengganti nama field 'isPublic' menjadi 'is_public'.
  Future<void> _migrateIsPublic(
    final WriteBatch batch,
    final List<String> logs,
  ) async {
    final QuerySnapshot snapshot =
        await _firestore.collection(NamaTabel.paket.name).get();
    int migratedCount = 0;

    for (final doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>?;

      if (data != null && data.containsKey('isPublic')) {
        final currentValue = data['isPublic'];
        // Rename field by creating the new one and deleting the old one.
        batch.update(doc.reference, {
          'is_public': currentValue,
          'isPublic': FieldValue.delete(),
        });
        migratedCount++;
      }
    }

    if (migratedCount > 0) {
      logs.add(
        '  - [isPublic -> is_public] $migratedCount dokumen akan dimigrasi di `${NamaTabel.paket.name}`.',
      );
    }
  }

  /// Analyzes and runs all necessary Firebase data migrations.
  ///
  /// This includes:
  /// - Converting `isDeleted` from `int` to `bool` across multiple collections.
  /// - Restructuring `nomor_build_terbaru` and `tautan_unduhan` in `versi_apk_user`.
  ///
  /// A [WriteBatch] is used to commit all changes at once.
  /// The [onProgress] callback provides real-time feedback on the migration status.
  ///
  /// Throws an [Exception] if any migration step fails, to halt the process.
  /// Returns a list of log messages detailing the operations performed.
  Future<List<String>> runAllMigrations(
    final void Function(String message) onProgress,
  ) async {
    onProgress('Memulai semua migrasi...');
    final WriteBatch batch = _firestore.batch();
    final List<String> logs = [];
    int totalMigrations = 0;

    onProgress('Menganalisis migrasi `isDeleted`...');
    for (final collectionName in _isDeletedCollections) {
      try {
        final List<String> collectionLogs = [];
        await _migrateIsDeleted(collectionName, batch, collectionLogs);
        if (collectionLogs.isNotEmpty) {
          logs.addAll(collectionLogs);
          totalMigrations++;
        }
      } on Exception catch (e, s) {
        final message =
            'Error saat menganalisis migrasi isDeleted untuk $collectionName: $e';
        Log.error(message, e: e, st: s);
        onProgress(message);
        throw Exception(
          'Migrasi dihentikan karena error pada koleksi $collectionName.',
        );
      }
    }
    if (totalMigrations == 0) {
      logs.add('Tidak ada migrasi `isDeleted` yang perlu dilakukan.');
    }

    int versiApkMigrations = 0;
    onProgress('Menganalisis migrasi `versi_apk_user`...');
    try {
      final List<String> versiApkLogs = [];
      await _migrateVersiApkUser(batch, versiApkLogs);
      if (versiApkLogs.isNotEmpty) {
        logs.addAll(versiApkLogs);
        versiApkMigrations++;
      }
    } on Exception catch (e, s) {
      final message = 'Error saat menganalisis migrasi versi_apk_user: $e';
      Log.error(message, e: e, st: s);
      onProgress(message);
      throw Exception(
        'Migrasi dihentikan karena error pada koleksi ${NamaTabel.versiApkUser.name}.',
      );
    }
    if (versiApkMigrations == 0) {
      logs.add('Tidak ada migrasi `versi_apk_user` yang perlu dilakukan.');
    }

    int isPublicMigrations = 0;
    onProgress('Menganalisis migrasi `isPublic` di koleksi paket...');
    try {
      final List<String> isPublicLogs = [];
      await _migrateIsPublic(batch, isPublicLogs);
      if (isPublicLogs.isNotEmpty) {
        logs.addAll(isPublicLogs);
        isPublicMigrations++;
      }
    } on Exception catch (e, s) {
      final message = 'Error saat menganalisis migrasi isPublic: $e';
      Log.error(message, e: e, st: s);
      onProgress(message);
      throw Exception(
        'Migrasi dihentikan karena error pada koleksi ${NamaTabel.paket.name}.',
      );
    }
    if (isPublicMigrations == 0) {
      logs.add('Tidak ada migrasi `isPublic` yang perlu dilakukan.');
    }

    if (totalMigrations > 0 ||
        versiApkMigrations > 0 ||
        isPublicMigrations > 0) {
      onProgress('Menjalankan semua perubahan...');
      try {
        await batch.commit();
        onProgress('Semua migrasi telah selesai dengan sukses!');
      } on Exception catch (e, s) {
        final message = 'Gagal melakukan commit perubahan: $e';
        Log.error(
          message,
          e: e,
          st: s,
        );
        onProgress(message);
        throw Exception('Gagal menyimpan perubahan ke Firestore.');
      }
    } else {
      onProgress('Tidak ada data yang perlu dimigrasi.');
    }

    return logs;
  }
}
