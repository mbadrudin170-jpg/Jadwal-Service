// path: lib/shared/constant/table_name_value.dart

import 'package:wifi/shared/enum/table_name_enum.dart';

/// Mapping nama tabel dari [TableName] ke format snake_case.
abstract final class TableNameValue {
  static const Map<TableName, String> _map = {
    TableName.category: 'category',
    TableName.subCategory: 'sub_category',
    TableName.package: 'package',
    TableName.customer: 'customer',
    TableName.activeCustomer: 'active_customer',

    // KONSISTEN: Menggunakan enum jamak dan string jamak
    TableName.transactions: 'transactions',

    TableName.wallet: 'wallet',
    TableName.feedback: 'feedback',
    TableName.order: 'order',
    TableName.userApkVersion: 'user_apk_version',
    TableName.setting: 'setting',
    TableName.uploadStatus: 'upload_status',
    TableName.message: 'message',
    TableName.appStatus: 'app_status',
    TableName.fcmToken: 'fcm_token',
    TableName.notification: 'notification',
  };

  /// Mendapatkan nama tabel dalam format snake_case.
  static String get(final TableName table) => _map[table]!;
}
