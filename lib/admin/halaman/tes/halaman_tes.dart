// // path: lib/halaman/tes/halaman_tes.dart
// import 'package:admin_wifi/data/operasi/status_unggah_operasi.dart';
// // import 'package:admin_wifi/halaman/tes/contoh_simpan_status.dart';
// import 'package:flutter/material.dart';

// class HalamanTes extends StatelessWidget {
//   const HalamanTes({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Halaman Uji Coba')),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Text(
//               'test data yang muncul untuk StatusUnggahModel',
//               textAlign: TextAlign.center,
//               style: TextStyle(fontSize: 16),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () {
//                 // Memanggil fungsi dari file contoh
//                 StatusUnggahOperasi().ambilSemuaStatusUnggah();
//                 // Menampilkan snackbar sebagai feedback
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(
//                     content: Text(
//                       'Fungsi simpanContohStatusUnggah() dijalankan. Cek konsol debug Anda!',
//                     ),
//                     duration: Duration(seconds: 3),
//                   ),
//                 );
//               },
//               child: const Text('Jalankan simpanContohStatusUnggah'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
