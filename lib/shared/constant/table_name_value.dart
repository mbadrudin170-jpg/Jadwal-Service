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
    TableName.transactions: 'transactions',
    TableName.wallet: 'wallet',
    TableName.feedback: 'feedback',
    TableName.customerOrder: 'customerOrder',
    TableName.userApkVersion: 'user_apk_version',
    TableName.settings: 'settings',
    TableName.uploadStatus: 'upload_status',
    TableName.message: 'message',
    TableName.fcmToken: 'fcm_token',
    TableName.notification: 'notification',
    TableName.statusGlobal: 'status_global',
    TableName.events: 'events',
  };

  /// Mendapatkan nama tabel dalam format snake_case.
  static String get(final TableName table) => _map[table]!;
}
