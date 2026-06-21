// path: lib/admin/providers/customer_provider.dart
import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wifi/fitur/pelanggan/model/pelanggan_model.dart';
import 'package:wifi/fitur/pelanggan/operasi/pelanggan_op_firebase.dart';
import 'package:wifi/shared/operasi/firebase_operasi/firebase_operation_provider/firebase_operation_provider.dart';

part 'customer_provider.g.dart';

@riverpod
class CustomerNotifier extends _$CustomerNotifier {
  late PelangganOpFirebase _pelangganOpFirebase;
  List<PelangganModel> _semuaPelanggan = [];
  
  @override
  Future<List<PelangganModel>> build() async {
    _pelangganOpFirebase = ref.watch(pelangganOpFirebaseProvider);
    final pelanggan = await _pelangganOpFirebase.ambilSemuaPelanggan();
    _semuaPelanggan = pelanggan;
    return pelanggan;
  }

  Future<void> search(String query) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      if (query.isEmpty) {
        return _semuaPelanggan;
      }
      return _semuaPelanggan
          .where((pelanggan) =>
              pelanggan.nama.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }
}
