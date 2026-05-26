// path: lib/shared/data/services/data_refresh_service.dart
import 'package:flutter/foundation.dart';

/// Service ini bertindak sebagai jembatan untuk memberi sinyal pembaruan data
/// dari satu bagian aplikasi ke bagian lain yang tidak terhubung langsung,
/// misalnya dari proses sinkronisasi di background ke UI yang sedang tampil.
class DataRefreshService {
  // Pola Singleton untuk memastikan hanya ada satu instance dari service ini.
  static final DataRefreshService _instance = DataRefreshService._internal();
  factory DataRefreshService() => _instance;
  DataRefreshService._internal();

  /// ValueNotifier yang akan didengarkan oleh UI.
  /// Nilai integer di dalamnya tidak penting, yang penting adalah perubahannya.
  final ValueNotifier<int> refreshNotifier = ValueNotifier(0);

  /// Panggil method ini untuk memberi tahu semua pendengar bahwa ada data baru.
  void notify() {
    // Menambah nilai akan memicu semua listener yang terdaftar.
    refreshNotifier.value++;
  }
}
