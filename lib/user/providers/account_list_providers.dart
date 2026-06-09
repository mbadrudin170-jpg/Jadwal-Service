// path: lib/user/providers/account_list_providers.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wifi/fitur/pelanggan/model/customer_model.dart';
import 'package:wifi/shared/providers/shared_providers.dart';

part 'account_list_providers.g.dart';

/// DIUBAH: FutureProvider yang menunggu LocalStorageService siap sebelum memuat daftar akun.
@riverpod
Future<List<CustomerModel>> accountList(Ref ref) async {
  final storage = await ref.watch(localStorageServiceProvider.future);
  return storage.ambilDaftarAkun();
}
