// // path: lib/halaman/form/form_edit_riwayat_langganan.dart
// // File ini bertanggung jawab untuk form edit data riwayat langganan, termasuk tanggal dan jam.

// import 'package:admin_wifi/data/operasi/riwayat_langganan_operasi.dart';
// import 'package:admin_wifi/enum/status_pembayaran.dart';
// import 'package:admin_wifi/model/riwayat_langganan_model.dart';
// import 'package:admin_wifi/utils/format_util.dart';
// import 'package:flutter/material.dart';

// class FormEditRiwayatLangganan extends StatefulWidget {
//   final RiwayatLanggananModel riwayat;

//   const FormEditRiwayatLangganan({super.key, required this.riwayat});

//   @override
//   State<FormEditRiwayatLangganan> createState() =>
//       _FormEditRiwayatLanggananState();
// }

// class _FormEditRiwayatLanggananState extends State<FormEditRiwayatLangganan> {
//   final _formKey = GlobalKey<FormState>();
//   final RiwayatLanggananOperasi _riwayatOperasi = RiwayatLanggananOperasi();

//   late DateTime _tanggalMulai;
//   late DateTime _tanggalBerakhir;
//   late StatusPembayaran _status;

//   @override
//   void initState() {
//     super.initState();
//     _tanggalMulai = widget.riwayat.tanggalMulai;
//     _tanggalBerakhir = widget.riwayat.tanggalBerakhir;
//     _status = widget.riwayat.status;
//   }

//   // Fungsi untuk memilih tanggal
//   Future<void> _pilihTanggal(BuildContext context, bool isTanggalMulai) async {
//     final DateTime? pickedDate = await showDatePicker(
//       context: context,
//       initialDate: isTanggalMulai ? _tanggalMulai : _tanggalBerakhir,
//       firstDate: DateTime(2000),
//       lastDate: DateTime(2101),
//     );
//     if (pickedDate != null) {
//       setState(() {
//         if (isTanggalMulai) {
//           _tanggalMulai = DateTime(
//             pickedDate.year,
//             pickedDate.month,
//             pickedDate.day,
//             _tanggalMulai.hour,
//             _tanggalMulai.minute,
//           );
//         } else {
//           _tanggalBerakhir = DateTime(
//             pickedDate.year,
//             pickedDate.month,
//             pickedDate.day,
//             _tanggalBerakhir.hour,
//             _tanggalBerakhir.minute,
//           );
//         }
//       });
//     }
//   }

//   // Fungsi untuk memilih jam dengan format 24 jam
//   Future<void> _pilihWaktu(BuildContext context, bool isTanggalMulai) async {
//     final TimeOfDay? pickedTime = await showTimePicker(
//       context: context,
//       initialTime: TimeOfDay.fromDateTime(
//         isTanggalMulai ? _tanggalMulai : _tanggalBerakhir,
//       ),
//       builder: (BuildContext context, Widget? child) {
//         return MediaQuery(
//           data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
//           child: child!,
//         );
//       },
//     );
//     if (pickedTime != null) {
//       setState(() {
//         if (isTanggalMulai) {
//           _tanggalMulai = DateTime(
//             _tanggalMulai.year,
//             _tanggalMulai.month,
//             _tanggalMulai.day,
//             pickedTime.hour,
//             pickedTime.minute,
//           );
//         } else {
//           _tanggalBerakhir = DateTime(
//             _tanggalBerakhir.year,
//             _tanggalBerakhir.month,
//             _tanggalBerakhir.day,
//             pickedTime.hour,
//             pickedTime.minute,
//           );
//         }
//       });
//     }
//   }

//   void _simpanPerubahan() async {
//     if (_formKey.currentState!.validate()) {
//       final riwayatBaru = RiwayatLanggananModel(
//         id: widget.riwayat.id,
//         idPelanggan: widget.riwayat.idPelanggan,
//         idPaket: widget.riwayat.idPaket,
//         namaPaket: widget.riwayat.namaPaket,
//         hargaPaket: widget.riwayat.hargaPaket,
//         durasiPaket: widget.riwayat.durasiPaket,
//         tipeDurasiPaket: widget.riwayat.tipeDurasiPaket,
//         tanggalMulai: _tanggalMulai,
//         tanggalBerakhir: _tanggalBerakhir,
//         status: _status,
//         diperbarui: DateTime.now(), // Penting untuk sinkronisasi
//       );

//       try {
//         await _riwayatOperasi.updateRiwayat(riwayatBaru);

//         if (!mounted) return;
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Riwayat berhasil diperbarui.'),
//             backgroundColor: Colors.green,
//           ),
//         );
//         // Kirim 'true' untuk menandakan ada perubahan
//         Navigator.of(context).pop(true);
//       } catch (e) {
//         if (!mounted) return;
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Gagal memperbarui riwayat: $e'),
//             backgroundColor: Theme.of(context).colorScheme.error,
//           ),
//         );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Edit Riwayat Langganan')),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: ListView(
//             children: <Widget>[
//               // Input Tanggal dan Jam Mulai
//               ListTile(
//                 title: const Text('Tanggal & Jam Mulai'),
//                 subtitle: Text(
//                   FormatTanggal.formatTanggalDanJam(_tanggalMulai),
//                 ),
//                 trailing: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     IconButton(
//                       icon: const Icon(Icons.calendar_today),
//                       onPressed: () => _pilihTanggal(context, true),
//                       tooltip: 'Pilih Tanggal',
//                     ),
//                     IconButton(
//                       icon: const Icon(Icons.access_time),
//                       onPressed: () => _pilihWaktu(context, true),
//                       tooltip: 'Pilih Jam',
//                     ),
//                   ],
//                 ),
//               ),
//               // Input Tanggal dan Jam Berakhir
//               ListTile(
//                 title: const Text('Tanggal & Jam Berakhir'),
//                 subtitle: Text(
//                   FormatTanggal.formatTanggalDanJam(_tanggalBerakhir),
//                 ),
//                 trailing: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     IconButton(
//                       icon: const Icon(Icons.calendar_today),
//                       onPressed: () => _pilihTanggal(context, false),
//                       tooltip: 'Pilih Tanggal',
//                     ),
//                     IconButton(
//                       icon: const Icon(Icons.access_time),
//                       onPressed: () => _pilihWaktu(context, false),
//                       tooltip: 'Pilih Jam',
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 16),
//               // Input Status Pembayaran
//               DropdownButtonFormField<StatusPembayaran>(
//                 initialValue: _status,
//                 decoration: const InputDecoration(
//                   labelText: 'Status Pembayaran',
//                   border: OutlineInputBorder(),
//                 ),
//                 items: StatusPembayaran.values.map((StatusPembayaran status) {
//                   return DropdownMenuItem<StatusPembayaran>(
//                     value: status,
//                     child: Text(status.displayName),
//                   );
//                 }).toList(),
//                 onChanged: (StatusPembayaran? newValue) {
//                   if (newValue != null) {
//                     setState(() {
//                       _status = newValue;
//                     });
//                   }
//                 },
//               ),
//               const SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: _simpanPerubahan,
//                 child: const Text('Simpan Perubahan'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
