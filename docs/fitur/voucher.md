# Dokumentasi Fitur: voucher

## Daftar file

- [lib/fitur/voucher/enum/tipe_voucher.dart](../../lib/fitur/voucher/enum/tipe_voucher.dart)
- [lib/fitur/voucher/model/voucher_model.dart](../../lib/fitur/voucher/model/voucher_model.dart)
- [lib/fitur/voucher/operasi/voucher_op_firebase.dart](../../lib/fitur/voucher/operasi/voucher_op_firebase.dart)
- [lib/fitur/voucher/page/detail_voucher.dart](../../lib/fitur/voucher/page/detail_voucher.dart)
- [lib/fitur/voucher/page/form_voucher.dart](../../lib/fitur/voucher/page/form_voucher.dart)
- [lib/fitur/voucher/page/voucher.dart](../../lib/fitur/voucher/page/voucher.dart)
- [lib/fitur/voucher/provider/voucher_provider.dart](../../lib/fitur/voucher/provider/voucher_provider.dart)

## Isi file

### File: `lib/fitur/voucher/enum/tipe_voucher.dart`
```dart
// path: lib/fitur/voucher/enum/tipe_voucher.dart

enum TipeVoucher { satu, beberapa }
```

### File: `lib/fitur/voucher/model/voucher_model.dart`
```dart
// path lib/fitur/voucher/model/voucher_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:wifi/fitur/voucher/enum/tipe_voucher.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/model/has_id.dart';
import 'package:wifi/shared/utils/parser_util.dart';

part 'voucher_model.freezed.dart';

@freezed
abstract class VoucherModel with _$VoucherModel implements HasId {
  const VoucherModel._();
  const factory VoucherModel({
    required String id,
    required String voucher,
    required String idPaket,
    required String tipeVoucher,
    @Default(false) bool terpakai,
    @Default(false) bool dihapus,
    DateTime? diperbaruiPada,
    DateTime? diarsipkanPada,
  }) = _VoucherModel;

  factory VoucherModel.fromFirebase(String id, Map<String, dynamic> data) {
    return VoucherModel(
      id: id,
      voucher: data[NamaKolom.voucher] as String? ?? '',
      idPaket: data[NamaKolom.idPaket] as String? ?? '',
      terpakai: ParserUtil.parseBool(data[NamaKolom.terpakai]),
      dihapus: ParserUtil.parseBool(data[NamaKolom.dihapus]),
      tipeVoucher:
          data[NamaKolom.tipeVoucher] as String? ?? TipeVoucher.satu.name,
      diperbaruiPada: ParserUtil.parseDateTime(data[NamaKolom.diperbaruiPada]),
      diarsipkanPada: ParserUtil.parseDateTime(data[NamaKolom.diarsipkanPada]),
    );
  }

  Map<String, dynamic> toFirebase() {
    return {
      NamaKolom.id: id,
      NamaKolom.voucher: voucher,
      NamaKolom.idPaket: idPaket,
      NamaKolom.terpakai: terpakai,
      NamaKolom.dihapus: dihapus,
      NamaKolom.tipeVoucher: tipeVoucher,
      NamaKolom.diperbaruiPada: Timestamp.fromDate(
        (diperbaruiPada ?? DateTime.now()),
      ),
      NamaKolom.diarsipkanPada: diarsipkanPada != null
          ? Timestamp.fromDate(diarsipkanPada!)
          : null,
    };
  }
}
```

### File: `lib/fitur/voucher/operasi/voucher_op_firebase.dart`
```dart
// lib/fitur/voucher/operasi/voucher_op_firebase.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/voucher/model/voucher_model.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/debug/log.dart';

class VoucherOpFirebase {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _koleksiVoucher = 'voucher'; // ganti sesuai nama koleksimu

  /// Mengambil semua dokumen voucher dari Firestore.
  /// Perhatian: jika data sangat banyak, pertimbangkan pagination.
  Future<List<VoucherModel>> ambilSemua({
    bool tampilkanYangDiarsip = false,
  }) async {
    try {
      final snapshot =
          await (tampilkanYangDiarsip
                  ? _firestore.collection(_koleksiVoucher)
                  : _firestore
                        .collection(_koleksiVoucher)
                        .where(NamaKolom.dihapus, isEqualTo: false))
              .get();
      final vouchers = snapshot.docs.map((doc) {
        return VoucherModel.fromFirebase(doc.id, doc.data());
      }).toList();
      return vouchers;
    } on Exception catch (e, s) {
      Log.error('Error di ambilSemua: $e', e: e, s: s);
      rethrow;
    }
  }

  Future<VoucherModel> tambah({required VoucherModel voucher}) async {
    try {
      final data = voucher.toFirebase();
      await _firestore.collection(_koleksiVoucher).doc(voucher.id).set(data);
      return voucher.copyWith(id: voucher.id);
    } on Exception catch (e, s) {
      Log.error('Error di tambah: $e', e: e, s: s);
      rethrow;
    }
  }

  Future<VoucherModel> perbarui({required VoucherModel voucher}) async {
    try {
      final data = voucher.toFirebase();
      await _firestore.collection(_koleksiVoucher).doc(voucher.id).update(data);
      return voucher;
    } on Exception catch (e, s) {
      Log.error('Error di perbarui: $e', e: e, s: s);
      rethrow;
    }
  }

  Future<void> softDelete(String idVoucher) async {
    try {
      await _firestore.collection(_koleksiVoucher).doc(idVoucher).update({
        NamaKolom.dihapus: true,
        NamaKolom.diarsipkanPada: Timestamp.fromDate(DateTime.now()),
      });
    } on Exception catch (e, s) {
      Log.error('Error di hapus: $e', e: e, s: s);
      rethrow;
    }
  }

  /// Mengecek apakah kode voucher sudah ada di Firestore.
  /// [kode] adalah kode voucher yang ingin dicek.
  /// [kecualiId] adalah id voucher yang dikecualikan (untuk mode edit).
  Future<bool> cekKodeVoucherSudahAda(String kode, {String? kecualiId}) async {
    try {
      // Query mencari dokumen dengan voucher == kode dan dihapus == false
      final query = _firestore
          .collection(_koleksiVoucher)
          .where(NamaKolom.voucher, isEqualTo: kode)
          .where(NamaKolom.dihapus, isEqualTo: false);

      // Jika ada ID yang dikecualikan, kita filter di sisi client
      // karena Firestore tidak mendukung "!=" dalam query secara langsung
      // atau kita bisa ambil semua lalu filter.
      final snapshot = await query.get();

      // Kalau ada dokumen yang id-nya bukan kecualiId, berarti sudah ada
      return snapshot.docs.any((doc) => doc.id != kecualiId);
    } on Exception catch (e, s) {
      Log.error('Error di cekKodeVoucherSudahAda: $e', e: e, s: s);
      rethrow;
    }
  }
}

final voucherOpFirebaseProvider = Provider<VoucherOpFirebase>((ref) {
  return VoucherOpFirebase();
});
```

### File: `lib/fitur/voucher/page/detail_voucher.dart`
```dart
// path: lib/fitur/voucher/page/detail_voucher.dart

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/voucher/enum/tipe_voucher.dart';
import 'package:wifi/fitur/voucher/model/voucher_model.dart'; // tambahkan ini
import 'package:wifi/fitur/voucher/page/form_voucher.dart';
import 'package:wifi/fitur/voucher/provider/voucher_provider.dart';
import 'package:wifi/shared/export/theme.dart';
import 'package:wifi/shared/widget/nama_paket_widget.dart';

class DetailVoucher extends ConsumerWidget {
  final String idVoucher;
  const DetailVoucher({super.key, required this.idVoucher});

  void _navigasiKeForm(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (contex) => FormVoucher(idVoucher: idVoucher),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final voucherAsync = ref.watch(voucherProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Voucher'),
        actions: [
          IconButton(
            onPressed: () => _navigasiKeForm(context),
            icon: const Icon(TIcons.edit),
          ),
        ],
      ),
      body: voucherAsync.when(
        data: (state) {
          final voucher = state.voucher.firstWhereOrNull(
            (v) => v.id == idVoucher,
          );
          if (voucher == null) {
            return const Center(child: Text('Voucher tidak ditemukan'));
          }
          return _buildDetail(context, voucher);
        },
        error: (error, _) => Center(child: Text('Error: $error')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget _buildDetail(BuildContext context, VoucherModel voucher) {
    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.card_giftcard, color: Colors.purple),
                const SizedBox(width: 8),
                Text(
                  voucher.voucher,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(),
            Row(
              children: [
                const Icon(Icons.shopping_bag, color: Colors.blue),
                const SizedBox(width: 8),
                NamaPaketWidget(idPaket: voucher.idPaket),
              ],
            ),
            const SizedBox(height: 12),
            Chip(
              label: Text(voucher.terpakai ? 'Terpakai' : 'Belum Terpakai'),
              backgroundColor: voucher.terpakai
                  ? Colors.green.shade100
                  : Colors.red.shade100,
            ),
            const SizedBox(height: 12),
            if (voucher.tipeVoucher.isNotEmpty)
              Chip(
                avatar: Icon(
                  voucher.tipeVoucher == TipeVoucher.satu.name
                      ? Icons.phone_android
                      : Icons.devices,
                  size: 18,
                ),
                label: Text(
                  voucher.tipeVoucher == TipeVoucher.satu.name
                      ? 'Satu Perangkat'
                      : 'Beberapa Perangkat',
                ),
                backgroundColor: Colors.blue.shade50,
              ),
            const SizedBox(height: 12),
            if (voucher.diperbaruiPada != null)
              Row(
                children: [
                  const Icon(Icons.update, size: 18, color: Colors.grey),
                  const SizedBox(width: 6),
                  Text(
                    'Terakhir diperbarui: ${_formatDateTime(voucher.diperbaruiPada!)}',
                  ),
                ],
              ),
            if (voucher.diarsipkanPada != null)
              Row(
                children: [
                  const Icon(Icons.archive, size: 18, color: Colors.grey),
                  const SizedBox(width: 6),
                  Text(
                    'Diarsipkan pada: ${_formatDateTime(voucher.diarsipkanPada!)}',
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute}';
  }
}
```

### File: `lib/fitur/voucher/page/form_voucher.dart`
```dart
// lib/fitur/voucher/page/form_voucher.dart
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:wifi/fitur/paket/model/paket_model.dart';
import 'package:wifi/fitur/paket/provider/paket_provider.dart';
import 'package:wifi/fitur/voucher/enum/tipe_voucher.dart';
import 'package:wifi/fitur/voucher/model/voucher_model.dart';
import 'package:wifi/fitur/voucher/operasi/voucher_op_firebase.dart';
import 'package:wifi/fitur/voucher/provider/voucher_provider.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/utils/toast_util.dart';
import 'package:wifi/shared/widget/input/input_teks.dart';

class FormVoucher extends ConsumerStatefulWidget {
  final String? idVoucher;
  const FormVoucher({super.key, this.idVoucher});

  @override
  ConsumerState<FormVoucher> createState() => _FormVoucherState();
}

class _FormVoucherState extends ConsumerState<FormVoucher> {
  final TextEditingController _voucherController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _menyimpan = false;
  bool _sudahInisialisasi = false;
  String? _selectedPaketId;
  TipeVoucher _tipeVoucher = TipeVoucher.satu;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _voucherController.dispose();
    super.dispose();
  }

  Future<void> _simpanForm() async {
    if (_menyimpan) return;
    if (!_formKey.currentState!.validate()) return;
    final kode = _voucherController.text.trim();
    final isEdit = widget.idVoucher != null;
    try {
      setState(() => _menyimpan = true);
      final voucherOp = ref.read(voucherOpFirebaseProvider);
      final sudahAda = await voucherOp.cekKodeVoucherSudahAda(
        kode,
        kecualiId: isEdit ? widget.idVoucher : null,
      );
      if (sudahAda) {
        if (mounted) {
          ToastUtil.error(
            context,
            'Kode voucher "$kode" sudah digunakan. Silakan masukkan kode lain.',
          );
        }
        return;
      }
      if (isEdit) {
        // Mode edit - ambil data existing untuk mempertahankan id
        final currentState = ref.read(voucherProvider).value;
        final existing = currentState?.voucher.firstWhereOrNull(
          (v) => v.id == widget.idVoucher,
        );
        if (existing == null) {
          throw Exception('Data voucher tidak ditemukan untuk diedit');
        }
        final updatedVoucher = existing.copyWith(
          voucher: _voucherController.text.trim(),
          idPaket: _selectedPaketId!,
          tipeVoucher: _tipeVoucher == TipeVoucher.satu
              ? TipeVoucher.satu.name
              : TipeVoucher.beberapa.name,
          diperbaruiPada: DateTime.now(),
        );
        await ref.read(voucherProvider.notifier).perbarui(updatedVoucher);
      } else {
        // Mode tambah
        final voucherBaru = VoucherModel(
          id: const Uuid().v4(),
          voucher: _voucherController.text.trim(),
          idPaket: _selectedPaketId!,
          tipeVoucher: _tipeVoucher == TipeVoucher.satu
              ? TipeVoucher.satu.name
              : TipeVoucher.beberapa.name,
          diperbaruiPada: DateTime.now(),
        );
        await ref.read(voucherProvider.notifier).tambah(voucherBaru);
      }
      if (mounted) {
        ToastUtil.success(
          context,
          isEdit ? 'Voucher berhasil diperbarui' : 'Voucher berhasil disimpan',
        );
        Navigator.pop(context);
      }
    } catch (e, s) {
      Log.error('Error di simpanForm: $e', e: e, s: s);
      if (mounted) {
        ToastUtil.error(context, 'Gagal menyimpan data');
      }
    } finally {
      if (mounted) {
        setState(() => _menyimpan = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final paketAsync = ref.watch(paketProvider);
    if (widget.idVoucher != null && !_sudahInisialisasi) {
      final voucherState = ref.watch(voucherProvider).value;
      if (voucherState != null) {
        final existing = voucherState.voucher.firstWhereOrNull(
          (v) => v.id == widget.idVoucher,
        );
        if (existing != null) {
          _voucherController.text = existing.voucher;
          _selectedPaketId = existing.idPaket.isEmpty ? null : existing.idPaket;
          _tipeVoucher = existing.tipeVoucher == TipeVoucher.satu.name
              ? TipeVoucher.satu
              : TipeVoucher.beberapa;
          _sudahInisialisasi = true;
        }
      }
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.idVoucher != null ? 'Edit Voucher' : 'Tambah Voucher',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Input Kode Voucher
              InputTeks(
                controller: _voucherController,
                label: 'Voucher',
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 16),
              paketAsync.when(
                data: (paketState) {
                  final daftarPaket = paketState.daftarPaket
                      .whereType<PaketModel>()
                      .toList();
                  if (daftarPaket.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Tidak ada paket tersedia'),
                    );
                  }
                  return DropdownButtonFormField<String>(
                    initialValue: _selectedPaketId,
                    decoration: const InputDecoration(
                      labelText: 'Pilih Paket',
                      border: OutlineInputBorder(),
                    ),
                    hint: const Text('Pilih paket'),
                    items: daftarPaket.map((paket) {
                      return DropdownMenuItem<String>(
                        value: paket.id,
                        child: Text(paket.nama),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _selectedPaketId = value);
                    },
                    validator: (value) => (value == null || value.isEmpty)
                        ? 'Paket wajib dipilih!'
                        : null,
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('Gagal memuat paket: $e'),
              ),

              Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('Satu Perangkat'),
                    selected: _tipeVoucher == TipeVoucher.satu,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _tipeVoucher = TipeVoucher.satu);
                      }
                    },
                  ),
                  ChoiceChip(
                    label: const Text('Beberapa Perangkat'),
                    selected: _tipeVoucher == TipeVoucher.beberapa,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _tipeVoucher = TipeVoucher.beberapa);
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Tombol Simpan
              ElevatedButton(
                onPressed: _menyimpan ? null : _simpanForm,
                child: _menyimpan
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

### File: `lib/fitur/voucher/page/voucher.dart`
```dart
// path lib/fitur/voucher/page/voucher.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/paket/model/paket_model.dart';
import 'package:wifi/fitur/paket/provider/paket_provider.dart';
import 'package:wifi/fitur/voucher/model/voucher_model.dart';
import 'package:wifi/fitur/voucher/page/detail_voucher.dart';
import 'package:wifi/fitur/voucher/page/form_voucher.dart';
import 'package:wifi/fitur/voucher/provider/voucher_provider.dart';
import 'package:wifi/shared/export/theme.dart';
import 'package:wifi/shared/utils/toast_util.dart';
import 'package:wifi/shared/widget/nama_paket_widget.dart';

enum SortVoucherBy { kode, status, paket }

class Voucher extends ConsumerStatefulWidget {
  const Voucher({super.key});

  @override
  ConsumerState<Voucher> createState() => _VoucherState();
}

class _VoucherState extends ConsumerState<Voucher> {
  SortVoucherBy _sortBy = SortVoucherBy.kode;
  bool _ascending = true;
  String? _filterPaketId; // null berarti tampilkan semua

  List<VoucherModel> _urutkanVoucher(List<VoucherModel> daftar) {
    var hasil = daftar;
    if (_filterPaketId != null) {
      hasil = hasil.where((v) => v.idPaket == _filterPaketId).toList();
    }
    var sorted = List<VoucherModel>.from(hasil);
    switch (_sortBy) {
      case SortVoucherBy.kode:
        sorted.sort((a, b) => a.voucher.compareTo(b.voucher));
        break;
      case SortVoucherBy.status:
        sorted.sort(
          (a, b) => a.terpakai.toString().compareTo(b.terpakai.toString()),
        );
        break;
      case SortVoucherBy.paket:
        sorted.sort((a, b) => a.idPaket.compareTo(b.idPaket));
        break;
    }
    if (!_ascending) {
      sorted = sorted.reversed.toList();
    }
    return sorted;
  }

  void _navigasiKeDetail(BuildContext context, String idVoucher) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => DetailVoucher(idVoucher: idVoucher),
      ),
    );
  }

  void _navigasiKeForm(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (context) => const FormVoucher()),
    );
  }

  Future<void> _konfirmasiHapus(
    BuildContext context,
    WidgetRef ref,
    String idVoucher,
    String kodeVoucher,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Voucher'),
        content: Text('Yakin ingin menghapus voucher "$kodeVoucher"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(voucherProvider.notifier).softDelete(idVoucher);
        if (context.mounted) {
          ToastUtil.success(context, 'Voucher berhasil dihapus');
        }
      } catch (e) {
        if (context.mounted) {
          ToastUtil.error(context, 'Gagal menghapus voucher');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final voucherAsync = ref.watch(voucherProvider);
    final paketAsync = ref.watch(paketProvider);

    // Ambil daftar voucher (jika tersedia) untuk menghitung badge
    final daftarVoucher = voucherAsync.value?.voucher ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Voucher'),
        actions: [
          PopupMenuButton<SortVoucherBy>(
            icon: const Icon(TIcons.sort),
            onSelected: (value) {
              setState(() {
                if (_sortBy == value) {
                  _ascending = !_ascending;
                } else {
                  _sortBy = value;
                  _ascending = true;
                }
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: SortVoucherBy.kode,
                child: Row(
                  children: [
                    const Text('Kode Voucher'),
                    if (_sortBy == SortVoucherBy.kode)
                      Icon(
                        _ascending ? Icons.arrow_upward : Icons.arrow_downward,
                        size: 16,
                      ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: SortVoucherBy.status,
                child: Row(
                  children: [
                    const Text('Status'),
                    if (_sortBy == SortVoucherBy.status)
                      Icon(
                        _ascending ? Icons.arrow_upward : Icons.arrow_downward,
                        size: 16,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips dengan badge jumlah voucher
          paketAsync.when(
            data: (paketState) =>
                _buildDaftarTombolPaket(paketState.daftarPaket, daftarVoucher),
            loading: () => const SizedBox.shrink(),
            error: (e, _) => const SizedBox.shrink(),
          ),
          // Daftar voucher
          Expanded(
            child: voucherAsync.when(
              data: (state) {
                final urut = _urutkanVoucher(state.voucher);
                if (urut.isEmpty) {
                  return const Center(child: Text('Tidak ada data'));
                }
                return ListView.builder(
                  itemCount: urut.length,
                  itemBuilder: (context, index) {
                    final voucher = urut[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                      child: ListTile(
                        onTap: () => _navigasiKeDetail(context, voucher.id),
                        onLongPress: () => _konfirmasiHapus(
                          context,
                          ref,
                          voucher.id,
                          voucher.voucher,
                        ),
                        title: Text(voucher.voucher),
                        subtitle: NamaPaketWidget(idPaket: voucher.idPaket),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: voucher.terpakai
                                ? Colors.green.shade50
                                : Colors.red.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: voucher.terpakai
                                  ? Colors.green.shade200
                                  : Colors.red.shade200,
                            ),
                          ),
                          child: Text(
                            voucher.terpakai ? 'Terpakai' : 'Belum Terpakai',
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              error: (error, stackTrace) => Text('$error'),
              loading: () => const Center(child: CircularProgressIndicator()),
              skipLoadingOnReload: true,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'tambah_voucher',
        onPressed: () => _navigasiKeForm(context),
        child: const Icon(TIcons.add),
      ),
    );
  }

  Widget _buildDaftarTombolPaket(
    List<PaketModel?> daftarPaket,
    List<VoucherModel> daftarVoucher,
  ) {
    final paketValid = daftarPaket.whereType<PaketModel>().toList();
    final totalSemua = daftarVoucher.length;

    // Hitung jumlah voucher per paket
    final countMap = <String, int>{};
    for (final v in daftarVoucher) {
      countMap[v.idPaket] = (countMap[v.idPaket] ?? 0) + 1;
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        spacing: 8,
        children: [
          FilterChip(
            avatar: CircleAvatar(
              radius: 10,
              backgroundColor: _filterPaketId == null
                  ? Colors.white
                  : Theme.of(context).colorScheme.primaryContainer,
              child: Text('$totalSemua', style: const TextStyle(fontSize: 10)),
            ),
            showCheckmark: false,
            selected: _filterPaketId == null,
            label: const Text('Semua'),
            onSelected: (_) => setState(() => _filterPaketId = null),
          ),
          ...paketValid.map((paket) {
            final count = countMap[paket.id] ?? 0;
            return FilterChip(
              avatar: CircleAvatar(
                radius: 10,
                backgroundColor: _filterPaketId == paket.id
                    ? Colors.white
                    : Theme.of(context).colorScheme.primaryContainer,
                child: Text('$count', style: const TextStyle(fontSize: 10)),
              ),
              showCheckmark: false,
              selected: _filterPaketId == paket.id,
              label: Text(paket.nama),
              onSelected: (selected) {
                setState(() {
                  _filterPaketId = selected ? paket.id : null;
                });
              },
            );
          }),
        ],
      ),
    );
  }
}
```

### File: `lib/fitur/voucher/provider/voucher_provider.dart`
```dart
// path lib/fitur/voucher/provider/voucher_provider.dart

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wifi/fitur/voucher/model/voucher_model.dart';
import 'package:wifi/fitur/voucher/operasi/voucher_op_firebase.dart';
import 'package:wifi/shared/debug/log.dart';

part 'voucher_provider.g.dart';
part 'voucher_provider.freezed.dart';

@freezed
abstract class VoucherState with _$VoucherState {
  const factory VoucherState({required List<VoucherModel> voucher}) =
      _VoucherState;
}

@riverpod
class Voucher extends _$Voucher {
  @override
  FutureOr<VoucherState> build() async {
    return _loadData();
  }

  Future<VoucherState> _loadData() async {
    try {
      final voucher = ref.read(voucherOpFirebaseProvider);
      final daftar = await voucher.ambilSemua();
      return VoucherState(voucher: daftar);
    } on Exception catch (e, s) {
      Log.error('Error di loadData: $e', e: e, s: s);
      rethrow;
    }
  }

  Future<void> tambah(VoucherModel voucherBaru) async {
    try {
      final tersimpan = await ref
          .read(voucherOpFirebaseProvider)
          .tambah(voucher: voucherBaru);
      final currentState = state.value;
      if (currentState == null) {
        state = await AsyncValue.guard(_loadData);
        return;
      }
      final updatedList = [...currentState.voucher, tersimpan];
      state = AsyncData(currentState.copyWith(voucher: updatedList));
    } on Exception catch (e, s) {
      Log.error('Error ditambah: $e', e: e, s: s);
      await _loadData();
      rethrow;
    }
  }
  Future<void> perbarui(VoucherModel voucher) async {
  try {
    await ref.read(voucherOpFirebaseProvider).perbarui(voucher: voucher);
    final current = state.value;
    if (current == null) {
      state = await AsyncValue.guard(_loadData);
      return;
    }
    final updatedList = current.voucher.map((v) => v.id == voucher.id ? voucher : v).toList();
    state = AsyncData(current.copyWith(voucher: updatedList));
  } catch (e, s) {
    Log.error('Gagal perbarui', e: e, s: s);
    await _loadData();
    rethrow;
  }
}

Future<void> softDelete(String id) async {
  try {
    await ref.read(voucherOpFirebaseProvider).softDelete(id);
    final current = state.value;
    if (current != null) {
      final updatedList = current.voucher.where((v) => v.id != id).toList();
      state = AsyncData(current.copyWith(voucher: updatedList));
    } else {
      await _loadData();
    }
  } catch (e, s) {
    Log.error('Gagal hapus', e: e, s: s);
    await _loadData();
    rethrow;
  }
}

  Future<void> refresh() async {
    state = await AsyncValue.guard(_loadData);
  }
}
```

