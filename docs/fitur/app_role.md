# Dokumentasi Fitur: app_role

## Daftar file

- [lib/fitur/app_role/app_role_enum.dart](../../lib/fitur/app_role/app_role_enum.dart)
- [lib/fitur/app_role/role_util.dart](../../lib/fitur/app_role/role_util.dart)

## Isi file

### File: `lib/fitur/app_role/app_role_enum.dart`
```dart
// path: lib/fitur/app_role/app_role_enum.dart

/// Mendefinisikan peran pengguna dalam aplikasi.
enum AppRole {
  /// Peran administrator dengan hak akses penuh.
  admin,

  /// Peran pengguna biasa dengan hak akses terbatas.
  user,

  investor,
}
```

### File: `lib/fitur/app_role/role_util.dart`
```dart
// path: lib/shared/utils/role_util.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wifi/fitur/akun/provider/akun_provider.dart';
import 'package:wifi/fitur/app_role/app_role_enum.dart';
import 'package:wifi/shared/debug/log.dart';

part 'role_util.g.dart';

@Riverpod(keepAlive: true)
AppRole appRole(Ref ref) {
  final akunState = ref.watch(pengelolaAkunProvider);
  final role = akunState.value?.akunSaatIni?.role ?? AppRole.user;
  Log.info('Role saat ini: ${role.name} (dari pengelolaAkunProvider)');
  return role;
}

// ✅ Extension untuk WidgetRef (digunakan di UI)
extension RoleExtension on WidgetRef {
  bool get isAdmin => watch(appRoleProvider) == AppRole.admin;
  bool get isUser => watch(appRoleProvider) == AppRole.user;
  bool get isInvestor => watch(appRoleProvider) == AppRole.investor;
  bool hasRole(AppRole role) => watch(appRoleProvider) == role;
  AppRole get currentRole => watch(appRoleProvider);
}

// ✅ Extension untuk Ref (digunakan di service/operation)
extension RoleRefExtension on Ref {
  bool get isAdmin => read(appRoleProvider) == AppRole.admin;
  bool get isUser => read(appRoleProvider) == AppRole.user;
  bool get isInvestor => read(appRoleProvider) == AppRole.investor;
  bool hasRole(AppRole role) => read(appRoleProvider) == role;
  AppRole get currentRole => read(appRoleProvider);
}
```

