// // path lib/fitur/pelanggan/page/admin/detail_pelanggan_a.dart

// import 'dart:async';

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:wifi/fitur/pelanggan/model/pelanggan_model.dart';
// import 'package:wifi/fitur/pelanggan/page/admin/form_pelanggan.dart';
// import 'package:wifi/fitur/pelanggan/provider/pelanggan_provider.dart';
// import 'package:wifi/fitur/pelanggan/widget/detail_pelanggan_ui.dart';
// import 'package:wifi/fitur/poin/page/halaman_poin.dart';
// import 'package:wifi/shared/debug/log.dart';
// import 'package:wifi/shared/utils/toast_util.dart';

// class DetailPelanggan extends ConsumerWidget {
//   final String idPelanggan;

//   const DetailPelanggan({super.key, required this.idPelanggan});

//   Future<void> _editPelanggan(
//     BuildContext context,
//     PelangganModel? pelanggan,
//   ) async {
//     if (pelanggan == null) return;
//     Log.info('Navigasi ke form edit pelanggan: ${pelanggan.nama}');
//     unawaited(
//       Navigator.push<bool>(
//         context,
//         MaterialPageRoute<bool>(
//           builder: (context) => FormPelanggan(pelanggan: pelanggan),
//         ),
//       ),
//     );
//   }

//   Future<void> _salinSemuaInfo(
//     BuildContext context,
//     PelangganModel customer,
//     int totalPoin,
//   ) async {
//     Log.info('Menyalin info pelanggan: ${customer.nama}');
//     final info =
//         '''
// Nama : ${customer.nama}
// No HP : ${customer.telepon}
// Alamat : ${customer.alamat}
// Password : ${customer.kataSandi}
// MAC : ${customer.macAddress}
// Poin: $totalPoin
// '''
//             .trim();

//     await Clipboard.setData(ClipboardData(text: info));
//     if (context.mounted) {
//       ToastUtil.success(context, 'Informasi pelanggan berhasil disalin.');
//     }
//   }

//   Future<void> _navigasiKePoin(
//     BuildContext context,
//     PelangganModel? pelanggan,
//   ) async {
//     if (pelanggan == null) return;
//     Log.info('Navigasi ke halaman poin pelanggan: ${pelanggan.nama}');

//     unawaited(
//       Navigator.push<void>(
//         context,
//         MaterialPageRoute<void>(
//           builder: (context) => HalamanPoin(idPelanggan: pelanggan.id),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final detailAsync = ref.watch(pelangganDetailProvider(idPelanggan));
//     return detailAsync.when(
//       skipLoadingOnReload: true,
//       loading: () => Scaffold(
//         appBar: AppBar(title: const Text('Memuat Detail...')),
//         body: const Center(child: CircularProgressIndicator()),
//       ),
//       error: (e, s) {
//         Log.error(
//           'Gagal mengambil data pelanggan ID: $idPelanggan.',
//           e: e,
//           s: s,
//         );
//         return Scaffold(
//           appBar: AppBar(title: const Text('Detail Pelanggan')),
//           body: Center(child: Text('Gagal memuat data: $e')),
//         );
//       },
//       data: (data) {
//         final (pelanggan, totalPoin) = data;
//         if (pelanggan == null) {
//           return Scaffold(
//             appBar: AppBar(title: const Text('Detail Pelanggan')),
//             body: const Center(child: Text('Pelanggan tidak ditemukan')),
//           );
//         }
//         return DetailPelangganUI(
//           pelanggan: pelanggan,
//           totalPoin: totalPoin,
//           navigasiKeEdit: () => _editPelanggan(context, pelanggan),
//           navigasiKePoin: () => _navigasiKePoin(context, pelanggan),

//           onCopyAll: () => _salinSemuaInfo(context, pelanggan, totalPoin),
//         );
//       },
//     );
//   }
// }
