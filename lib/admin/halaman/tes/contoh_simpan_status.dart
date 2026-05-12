// // path: lib/halaman/tes/contoh_simpan_status.dart
// import 'package:admin_wifi/data/operasi/status_unggah_operasi.dart';
// import 'package:admin_wifi/enum/nama_tabel_enum.dart';
// import 'package:admin_wifi/model/status_unggah_model.dart';
// import 'package:flutter/material.dart';

// /// CONTOH PENGGUNAAN:
// /// Ini adalah fungsi contoh yang menunjukkan bagaimana Anda akan
// /// membuat dan menyimpan sebuah `StatusUnggahModel`.
// Future<void> simpanContohStatusUnggah() async {
//   // 1. Buat instance dari kelas operasi.
//   final statusOperasi = StatusUnggahOperasi();

//   // 2. Buat objek StatusUnggahModel.
//   //    Misalnya, kita ingin menandai bahwa ada perubahan spesifik
//   //    pada tabel 'dompet' dengan ID 'dompet_1' dan 'dompet_3'.
//   final statusUntukDisimpan = StatusUnggahModel(
//     tabel: NamaTabel.dompet,
//     status: true, // true berarti perlu diunggah.
//     ids: ['dompet_1', 'dompet_3'],
//   );

//   // 3. Panggil metode simpanStatusUnggah.
//   //    Metode ini akan mengonversi objek Dart menjadi Map menggunakan
//   //    `toMapForSqlite()` dan menyimpannya ke database.
//   await statusOperasi.simpanStatusUnggah(statusUntukDisimpan);

//   debugPrint(
//     "Status Unggah untuk tabel '${statusUntukDisimpan.tabel.name}' telah disimpan.",
//   );

//   // 4. (Opsional) Verifikasi bahwa data telah tersimpan.
//   //    Kita bisa mengambilnya kembali dari database.
//   final statusDariDB = await statusOperasi.ambilStatusUnggahByTabel(
//     NamaTabel.dompet,
//   );

//   if (statusDariDB != null) {
//     debugPrint("--- Verifikasi Data dari Database ---");
//     debugPrint("Tabel: ${statusDariDB.tabel.name}");
//     debugPrint("Status: ${statusDariDB.status}");
//     debugPrint("IDs: ${statusDariDB.ids}");
//     debugPrint("------------------------------------");
//   }
// }
