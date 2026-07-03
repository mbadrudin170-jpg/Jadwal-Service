// path lib/fitur/voucher/voucher.md
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
