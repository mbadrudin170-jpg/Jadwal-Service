// path: lib/shared/utils/role_util.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wifi/shared/enum/app_role_enum.dart';

part 'role_util.g.dart';

@Riverpod(keepAlive: true)
AppRole appRole(Ref ref) {
  throw UnimplementedError(
    'appRoleProvider harus di-override di dalam ProviderScope',
  );
}

class RoleUtil {
  static bool isAdmin(Ref ref) {
    return ref.read(appRoleProvider) == AppRole.admin;
  }

  static bool isUser(Ref ref) {
    return ref.read(appRoleProvider) == AppRole.user;
  }

  static bool hasRole(Ref ref, AppRole role) {
    return ref.read(appRoleProvider) == role;
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
    return ref.read(appRoleProvider).name;
  }

  static Future<String> getRoleNameAsync(Ref ref) async {
    final role = ref.watch(appRoleProvider);
    return role.name;
  }
}

extension RoleExtension on WidgetRef {
  /// Mengecek apakah pengguna saat ini adalah admin.
  bool get isAdmin => read(appRoleProvider) == AppRole.admin;

  /// Mengecek apakah pengguna saat ini adalah user.
  bool get isUser => read(appRoleProvider) == AppRole.user;

  /// Mengecek apakah pengguna saat ini memiliki role yang sama dengan [role].
  bool hasRole(AppRole role) => read(appRoleProvider) == role;

  /// Mendapatkan role saat ini.
  AppRole get currentRole => read(appRoleProvider);
}
