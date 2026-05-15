// path: lib/shared/services/pembaruan_data_service.dart
import 'dart:async';

import 'package:wifi/shared/debug/log.dart';

/// Service singleton untuk menyiarkan pembaruan data ke seluruh aplikasi.
///
/// Gunakan service ini untuk memberi tahu widget lain ketika ada perubahan
/// data penting (misalnya, setelah operasi CRUD) sehingga mereka dapat
/// memuat ulang state mereka.
///
/// Contoh penggunaan:
///
/// Untuk memicu pembaruan:
/// `PembaruanDataService.instance.picuPembaruan();`
///
/// Untuk mendengarkan pembaruan di dalam StatefulWidget:
/// ```dart
/// class MyWidgetState extends State<MyWidget> {
///   StreamSubscription? _subscription;
///
///   @override
///   void initState() {
///     super.initState();
///     _subscription = PembaruanDataService.instance.stream.listen((_) {
///       // Panggil setState atau metode untuk muat ulang data di sini
///     });
///   }
///
///   @override
///   void dispose() {
///     _subscription?.cancel();
///     super.dispose();
///   }
/// }
/// ```
class PembaruanDataService {
  // Membuat constructor privat untuk singleton.
  PembaruanDataService._privateConstructor();

  /// Instance tunggal (singleton) dari [PembaruanDataService].
  static final PembaruanDataService instance =
      PembaruanDataService._privateConstructor();

  // StreamController yang dapat memiliki banyak listener (broadcast).
  final StreamController<void> _controller = StreamController.broadcast();

  /// Stream yang akan memberi tahu listener setiap kali ada pembaruan data.
  ///
  /// Widget dapat mendengarkan [stream] ini untuk tahu kapan harus memperbarui UI-nya.
  Stream<void> get stream => _controller.stream;

  /// Panggil metode ini untuk memicu event pembaruan ke semua listener.
  void picuPembaruan() {
    Log.info('Pembaruan data dipicu melalui PembaruanDataService.');
    _controller.add(null);
  }

  /// Menutup StreamController. Sebaiknya tidak pernah dipanggil dalam aplikasi normal
  /// karena ini adalah singleton seumur hidup aplikasi.
  Future<void> dispose() async {
    Log.warning('PembaruanDataService sedang di-dispose.');
    await _controller.close();
  }
}
