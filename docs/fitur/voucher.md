# Dokumentasi Fitur: voucher

## Daftar file

- [lib/fitur/voucher/model/voucher_model.dart](../../lib/fitur/voucher/model/voucher_model.dart)
- [lib/fitur/voucher/operasi/voucher_op_firebase.dart](../../lib/fitur/voucher/operasi/voucher_op_firebase.dart)
- [lib/fitur/voucher/page/detail_voucher.dart](../../lib/fitur/voucher/page/detail_voucher.dart)
- [lib/fitur/voucher/page/form_voucher.dart](../../lib/fitur/voucher/page/form_voucher.dart)
- [lib/fitur/voucher/page/voucher.dart](../../lib/fitur/voucher/page/voucher.dart)
- [lib/fitur/voucher/provider/voucher_provider.dart](../../lib/fitur/voucher/provider/voucher_provider.dart)

## Isi file

### File: `lib/fitur/voucher/model/voucher_model.dart`
```dart
// path lib/fitur/voucher/model/voucher_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
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
}

final voucherOpFirebaseProvider = Provider<VoucherOpFirebase>((ref) {
  return VoucherOpFirebase();
});
```

### File: `lib/fitur/voucher/page/detail_voucher.dart`
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/voucher/model/voucher_model.dart'; // tambahkan ini
import 'package:wifi/fitur/voucher/page/form_voucher.dart';
import 'package:wifi/fitur/voucher/provider/voucher_provider.dart';
import 'package:wifi/shared/export/theme.dart';
import 'package:wifi/shared/widget/nama_paket_widget.dart';

class DetailVoucher extends ConsumerWidget {
  final String idVoucher;
  const DetailVoucher({super.key, required this.idVoucher});

  void _naviagasiKeForm(BuildContext context) {
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
            onPressed: () => _naviagasiKeForm(context),
            icon: const Icon(TIcons.edit),
          ),
        ],
      ),
      body: voucherAsync.when(
        data: (state) {
          final voucher = state.voucher.firstWhere(
            (v) => v.id == idVoucher,
            orElse: () => throw Exception('Voucher tidak ditemukan'),
          );

          return _buildDetail(context, voucher);
        },
        error: (error, _) => Center(child: Text('Error: $error')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  // ⬇️ Perubahan: dynamic → VoucherModel
  Widget _buildDetail(BuildContext context, VoucherModel voucher) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            voucher.voucher,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text('Paket: '),
              NamaPaketWidget(idPaket: voucher.idPaket),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text('Status: '),
              Icon(
                voucher.terpakai ? Icons.check_circle : Icons.cancel,
                color: voucher.terpakai ? Colors.green : Colors.red,
                size: 20,
              ),
              const SizedBox(width: 4),
              Text(voucher.terpakai ? 'Terpakai' : 'Belum Terpakai'),
            ],
          ),
          const SizedBox(height: 8),
          if (voucher.diperbaruiPada != null)
            Text(
              'Terakhir diperbarui: ${_formatDateTime(voucher.diperbaruiPada!)}',
              style: const TextStyle(color: Colors.grey),
            ),
          if (voucher.diarsipkanPada != null)
            Text(
              'Diarsipkan pada: ${_formatDateTime(voucher.diarsipkanPada!)}',
              style: const TextStyle(color: Colors.grey),
            ),
          const SizedBox(height: 16),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.edit),
                label: const Text('Edit'),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.delete),
                label: const Text('Hapus'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
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
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:wifi/fitur/paket/model/paket_model.dart';
import 'package:wifi/fitur/paket/provider/paket_provider.dart';
import 'package:wifi/fitur/voucher/model/voucher_model.dart';
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

  // Simpan ID paket yang dipilih (bukan nama paket)
  String? _selectedPaketId;

  @override
  void dispose() {
    _voucherController.dispose();
    super.dispose();
  }

  Future<void> _simpanForm() async {
    if (_menyimpan) return;
    if (!_formKey.currentState!.validate()) return;

    try {
      setState(() => _menyimpan = true);

      // Buat voucher baru (id kosong, nanti diisi Firestore)
      final voucherBaru = VoucherModel(
        id: const Uuid().v4(),
        voucher: _voucherController.text.trim(),
        idPaket: _selectedPaketId!,
        diperbaruiPada: DateTime.now(),
      );

      // Simpan via provider
      await ref.read(voucherProvider.notifier).tambah(voucherBaru);

      if (mounted) {
        ToastUtil.success(context, 'Voucher berhasil disimpan');
        Navigator.pop(context);
      }
    } on Exception catch (e, s) {
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
    // Ambil data paket dari provider
    final paketAsync = ref.watch(paketProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Voucher')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Input Kode Voucher
              InputTeks(controller: _voucherController, label: 'Voucher'),
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
                    value: _selectedPaketId,
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
                    validator: (value) =>
                        value == null ? 'Paket wajib dipilih!' : null,
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('Gagal memuat paket: $e'),
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
import 'package:wifi/fitur/voucher/page/detail_voucher.dart';
import 'package:wifi/fitur/voucher/page/form_voucher.dart';
import 'package:wifi/fitur/voucher/provider/voucher_provider.dart';
import 'package:wifi/shared/export/theme.dart';
import 'package:wifi/shared/widget/nama_paket_widget.dart';

class Voucher extends ConsumerWidget {
  const Voucher({super.key});

  void _naviagasiKeDetail(BuildContext context, String idVoucher) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => DetailVoucher(idVoucher: idVoucher),
      ),
    );
  }

  void _naviagasiKeForm(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (context) => const FormVoucher()),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final voucherAsync = ref.watch(voucherProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Voucher')),
      body: voucherAsync.when(
        data: (state) {
          if (state.voucher.isEmpty) {
            return const Center(child: Text('Tidak ada data'));
          }
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: state.voucher.length,
                  itemBuilder: (context, index) {
                    final voucher = state.voucher[index];
                    return ListTile(
                      onTap: () => _naviagasiKeDetail(context, voucher.id),
                      title: Text(voucher.voucher),
                      subtitle: NamaPaketWidget(idPaket: voucher.idPaket),
                    );
                  },
                ),
              ),
            ],
          );
        },
        error: (error, stackTrace) => Text('$error'),
        loading: () => const Center(child: CircularProgressIndicator()),
        skipLoadingOnReload: true,
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'tambah_voucher',
        onPressed: () => _naviagasiKeForm(context),
        child: const Icon(TIcons.add),
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

  Future<void> refresh() async {
    state = await AsyncValue.guard(_loadData);
  }
}
```

