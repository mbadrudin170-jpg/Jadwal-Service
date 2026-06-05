// path: lib/user/providers/account_list_providers.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wifi/shared/model/customer_model.dart';
import 'package:wifi/shared/providers/shared_providers.dart';

part 'account_list_providers.g.dart';

/// DIUBAH: FutureProvider yang menunggu LocalStorageService siap sebelum memuat daftar akun.
@riverpod
Future<List<CustomerModel>> accountList(Ref ref) async {
  // Menunggu LocalStorageService selesai diinisialisasi.
  final storage = await ref.watch(localStorageServiceProvider.future);
  // Setelah siap, panggil fungsi untuk mendapatkan daftar akun.
  return storage.getAccountList();
}
