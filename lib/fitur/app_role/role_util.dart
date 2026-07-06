// path: lib/shared/utils/role_util.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wifi/fitur/app_role/app_role_enum.dart';
import 'package:wifi/shared/debug/log.dart';

part 'role_util.g.dart';

@Riverpod(keepAlive: true)
AppRole appRole(Ref ref) {
  throw UnimplementedError(
    'appRoleProvider harus di-override di dalam ProviderScope',
  );
}

class RoleUtil {
  static bool isAdmin(Ref ref) {
    final role = ref.watch(appRoleProvider);
    Log.info('Role saat ini: ${role.name}'); // ← lihat log ini
    return role == AppRole.admin;
  }

  static bool isUser(Ref ref) {
    return ref.watch(appRoleProvider) == AppRole.user;
  }

  static bool isInvestor(Ref ref) {
    return ref.watch(appRoleProvider) == AppRole.investor;
  }

  static bool hasRole(Ref ref, AppRole role) {
    return ref.watch(appRoleProvider) == role;
  }

  static Future<bool> isAdminAsync(Ref ref) async {
    final role = ref.watch(appRoleProvider);
    return role == AppRole.admin;
  }

  static Future<bool> isUserAsync(Ref ref) async {
    final role = ref.watch(appRoleProvider);
    return role == AppRole.user;
  }

  static Future<bool> hasRoleAsync(Ref ref, AppRole role) async {
    final currentRole = ref.watch(appRoleProvider);
    return currentRole == role;
  }

  static String getRoleName(Ref ref) {
    return ref.watch(appRoleProvider).name;
  }

  static Future<String> getRoleNameAsync(Ref ref) async {
    final role = ref.watch(appRoleProvider);
    return role.name;
  }
}

extension RoleExtension on WidgetRef {
  /// Mengecek apakah pengguna saat ini adalah admin.
  bool get isAdmin => watch(appRoleProvider) == AppRole.admin;

  /// Mengecek apakah pengguna saat ini adalah user.
  bool get isUser => watch(appRoleProvider) == AppRole.user;

  bool get isInvestor => watch(appRoleProvider) == AppRole.investor;

  /// Mengecek apakah pengguna saat ini memiliki role yang sama dengan [role].
  bool hasRole(AppRole role) => watch(appRoleProvider) == role;

  /// Mendapatkan role saat ini.
  AppRole get currentRole => watch(appRoleProvider);
}
