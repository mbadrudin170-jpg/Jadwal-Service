# File lengkap untuk kategori Model


// path: lib/shared/model/order_model.dart
// new file: Renamed from pesanan_model.dart and refactored to English.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:wifi/shared/constant/column_names.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/has_id.dart';

/// Model for order data.
class OrderModel implements HasId {
  @override
  final String id;

  /// The ID of the customer who placed the order.
  final String customerId;

  /// The ID of the package ordered.
  final String packageId;

  /// The date the order was created.
  final DateTime date;

  /// The status of the order (e.g., "new", "processing", "completed").
  final String status;

  /// The last time the data was updated.
  final DateTime? updatedAt;

  /// The status of whether this order has been deleted (soft delete).
  final bool isDeleted;

  /// The time this order was archived.
  final DateTime? archivedAt;

  /// Constructor for `OrderModel`.
  OrderModel({
    final String? id,
    required this.customerId,
    required this.packageId,
    required this.date,
    required this.status,
    this.updatedAt,
    this.isDeleted = false,
    this.archivedAt,
  }) : id = id ?? const Uuid().v4() {
    Log.info('OrderModel created: $id for customer $customerId');
  }

  /// Creates a copy of `OrderModel` with some modified values.
  OrderModel copyWith({
    final String? id,
    final String? customerId,
    final String? packageId,
    final DateTime? date,
    final String? status,
    final DateTime? updatedAt,
    final bool? isDeleted,
    final DateTime? archivedAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      packageId: packageId ?? this.packageId,
      date: date ?? this.date,
      status: status ?? this.status,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      archivedAt: archivedAt ?? this.archivedAt,
    );
  }

  /// Helper to parse date values from various formats.
  static DateTime? _parseDateTime(final dynamic dateValue) {
    if (dateValue == null) return null;
    if (dateValue is Timestamp) return dateValue.toDate();
    if (dateValue is DateTime) return dateValue;
    if (dateValue is String) return DateTime.tryParse(dateValue);
    if (dateValue is int) {
      return DateTime.fromMillisecondsSinceEpoch(dateValue);
    }
    return null;
  }

  /// Helper to parse boolean from various formats.
  static bool _parseBool(final dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value.toLowerCase() == 'true';
    return false;
  }

  /// Creates an `OrderModel` instance from SQLite map data.
  factory OrderModel.fromSqlite(final Map<String, dynamic> map) {
    Log.info('Creating OrderModel from SQLite: ${map[ColumnNames.id]}');
    return OrderModel(
      id: map[ColumnNames.id] as String? ?? '',
      customerId: map[ColumnNames.customerId] as String? ?? '',
      packageId: map[ColumnNames.packageId] as String? ?? '',
      date: _parseDateTime(map[ColumnNames.date]) ?? DateTime.now(),
      status: map[ColumnNames.status] as String? ?? 'new',
      updatedAt: _parseDateTime(map[ColumnNames.updatedAt]),
      isDeleted: _parseBool(map[ColumnNames.isDeleted]),
      archivedAt: _parseDateTime(map[ColumnNames.archivedAt]),
    );
  }

  /// Converts `OrderModel` to a Map format for SQLite storage.
  Map<String, dynamic> toSqlite() {
    return {
      ColumnNames.id: id,
      ColumnNames.customerId: customerId,
      ColumnNames.packageId: packageId,
      ColumnNames.date: date.millisecondsSinceEpoch,
      ColumnNames.status: status,
      ColumnNames.updatedAt: updatedAt?.millisecondsSinceEpoch,
      ColumnNames.isDeleted: isDeleted ? 1 : 0,
      ColumnNames.archivedAt: archivedAt?.millisecondsSinceEpoch,
    };
  }

  /// Creates an `OrderModel` instance from Firebase map data.
  factory OrderModel.fromFirebase(
      final String id, final Map<String, dynamic> data) {
    Log.info('Creating OrderModel from Firebase: $id');
    return OrderModel(
      id: id,
      customerId: data[ColumnNames.customerId] as String? ?? '',
      packageId: data[ColumnNames.packageId] as String? ?? '',
      date: _parseDateTime(data[ColumnNames.date]) ?? DateTime.now(),
      status: data[ColumnNames.status] as String? ?? 'new',
      updatedAt: _parseDateTime(data[ColumnNames.updatedAt]),
      isDeleted: _parseBool(data[ColumnNames.isDeleted]),
      archivedAt: _parseDateTime(data[ColumnNames.archivedAt]),
    );
  }

  /// Converts `OrderModel` to a Map format for Firebase storage.
  Map<String, dynamic> toFirebase() {
    return {
      ColumnNames.customerId: customerId,
      ColumnNames.packageId: packageId,
      ColumnNames.date: Timestamp.fromDate(date.toUtc()),
      ColumnNames.status: status,
      ColumnNames.updatedAt:
          Timestamp.fromDate((updatedAt ?? DateTime.now()).toUtc()),
      ColumnNames.isDeleted: isDeleted,
      ColumnNames.archivedAt:
          archivedAt != null ? Timestamp.fromDate(archivedAt!.toUtc()) : null,
    };
  }
}
// path: lib/shared/model/has_id.dart
// new file: Refactored from memiliki_id.dart to use English naming conventions.

/// An interface for models that have an ID property.
///
/// All models in the application that require a unique identity
/// should implement this interface.
///
/// Example:
/// ```dart
/// class UserModel implements HasId {
///   @override
///   final String id;
///
///   UserModel({required this.id});
/// }
/// ```
abstract class HasId {
  /// The unique ID for each model.
  ///
  /// Typically uses a UUID v4 or an ID from the database.
  String get id;
}
// path: lib/shared/model/active_customer_model.dart
// new file: Refactored from pelanggan_aktif_model.dart to use English naming conventions.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:wifi/shared/constant/column_names.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/enum/payment_status_enum.dart';
import 'package:wifi/shared/model/has_id.dart';

/// Model for active customer data.
class ActiveCustomerModel implements HasId {
  @override
  final String id;

  /// The ID of the customer associated with this entry.
  final String customerId;

  /// The ID of the package purchased by the customer.
  final String packageId;

  /// The ID of the transaction associated with the package purchase.
  final String? transactionId;

  /// The start date of the package activation.
  final DateTime startDate;

  /// The end date of the package.
  final DateTime endDate;

  /// The payment status of the package.
  final PaymentStatus status;

  /// The last time the data was updated.
  final DateTime? updatedAt;

  /// The status of whether this entry has been deleted (soft delete).
  final bool isDeleted;

  /// The time this entry was archived.
  final DateTime? archivedAt;

  /// Constructor for `ActiveCustomerModel`.
  ActiveCustomerModel({
    final String? id,
    required this.customerId,
    required this.packageId,
    this.transactionId,
    required this.startDate,
    required this.endDate,
    required this.status,
    this.updatedAt,
    this.isDeleted = false,
    this.archivedAt,
  }) : id = id ?? const Uuid().v4() {
    Log.info('ActiveCustomerModel created: $id for customer $customerId');
  }

  /// Creates a copy of this `ActiveCustomerModel` with some modified values.
  ActiveCustomerModel copyWith({
    final String? id,
    final String? customerId,
    final String? packageId,
    final String? transactionId,
    final DateTime? startDate,
    final DateTime? endDate,
    final PaymentStatus? status,
    final DateTime? updatedAt,
    final bool? isDeleted,
    final DateTime? archivedAt,
  }) {
    return ActiveCustomerModel(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      packageId: packageId ?? this.packageId,
      transactionId: transactionId ?? this.transactionId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      archivedAt: archivedAt ?? this.archivedAt,
    );
  }

  /// Helper to parse DateTime from various formats.
  static DateTime? _parseDateTime(final dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is String) return DateTime.tryParse(value);
    Log.warning('Unrecognized DateTime format: $value');
    return null;
  }

  /// Helper to parse boolean from various formats.
  static bool _parseBool(final dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value.toLowerCase() == 'true';
    Log.warning('Unrecognized Boolean format, defaulting to false: $value');
    return false;
  }

  /// Creates an `ActiveCustomerModel` instance from SQLite map data.
  factory ActiveCustomerModel.fromSqlite(final Map<String, dynamic> map) {
    try {
      final startDate = _parseDateTime(map[ColumnNames.startDate]);
      final endDate = _parseDateTime(map[ColumnNames.endDate]);

      if (startDate == null) {
        throw ArgumentError.notNull('startDate from SQLite');
      }
      if (endDate == null) {
        throw ArgumentError.notNull('endDate from SQLite');
      }

      final model = ActiveCustomerModel(
        id: map[ColumnNames.id] as String,
        customerId: map[ColumnNames.customerId] as String? ?? '',
        packageId: map[ColumnNames.packageId] as String? ?? '',
        transactionId: map[ColumnNames.transactionId] as String?,
        startDate: startDate,
        endDate: endDate,
        status: PaymentStatus.values.firstWhere(
          (final e) => e.name == map[ColumnNames.status],
          orElse: () => PaymentStatus.paid,
        ),
        updatedAt: _parseDateTime(map[ColumnNames.updatedAt]),
        isDeleted: _parseBool(map[ColumnNames.isDeleted]),
        archivedAt: _parseDateTime(map[ColumnNames.archivedAt]),
      );
      Log.info('ActiveCustomerModel loaded from SQLite: ${model.id}');
      return model;
    } catch (e, stack) {
      Log.error('Failed to parse from SQLite: $map', e: e, st: stack);
      rethrow;
    }
  }

  /// Converts `ActiveCustomerModel` to a Map for SQLite storage.
  Map<String, dynamic> toSqlite() {
    return {
      ColumnNames.id: id,
      ColumnNames.customerId: customerId,
      ColumnNames.packageId: packageId,
      ColumnNames.transactionId: transactionId,
      ColumnNames.startDate: startDate.millisecondsSinceEpoch,
      ColumnNames.endDate: endDate.millisecondsSinceEpoch,
      ColumnNames.status: status.name,
      ColumnNames.updatedAt: updatedAt?.millisecondsSinceEpoch,
      ColumnNames.isDeleted: isDeleted ? 1 : 0,
      ColumnNames.archivedAt: archivedAt?.millisecondsSinceEpoch,
    };
  }

  /// Creates an `ActiveCustomerModel` instance from Firebase map data.
  factory ActiveCustomerModel.fromFirebase(
    final String id,
    final Map<String, dynamic> data,
  ) {
    try {
      final startDate = _parseDateTime(data[ColumnNames.startDate]);
      final endDate = _parseDateTime(data[ColumnNames.endDate]);

      if (startDate == null) {
        throw ArgumentError.notNull('startDate from Firebase');
      }
      if (endDate == null) {
        throw ArgumentError.notNull('endDate from Firebase');
      }

      final model = ActiveCustomerModel(
        id: id,
        customerId: data[ColumnNames.customerId] as String? ?? '',
        packageId: data[ColumnNames.packageId] as String? ?? '',
        transactionId: data[ColumnNames.transactionId] as String?,
        startDate: startDate,
        endDate: endDate,
        status: PaymentStatus.values.firstWhere(
          (final e) => e.name == data[ColumnNames.status],
          orElse: () => PaymentStatus.paid,
        ),
        updatedAt: _parseDateTime(data[ColumnNames.updatedAt]),
        isDeleted: _parseBool(data[ColumnNames.isDeleted]),
        archivedAt: _parseDateTime(data[ColumnNames.archivedAt]),
      );
      Log.info('ActiveCustomerModel loaded from Firebase: ${model.id}');
      return model;
    } catch (e, stack) {
      Log.error('Failed to parse from Firebase: $data', e: e, st: stack);
      rethrow;
    }
  }

  /// Converts `ActiveCustomerModel` to a Map for Firebase storage.
  Map<String, dynamic> toFirebase() {
    Log.info('Preparing toFirebase for ActiveCustomerModel $id');
    return {
      ColumnNames.customerId: customerId,
      ColumnNames.packageId: packageId,
      ColumnNames.transactionId: transactionId,
      ColumnNames.startDate: Timestamp.fromDate(startDate.toUtc()),
      ColumnNames.endDate: Timestamp.fromDate(endDate.toUtc()),
      ColumnNames.status: status.name,
      ColumnNames.isDeleted: isDeleted,
      ColumnNames.updatedAt:
          Timestamp.fromDate((updatedAt ?? DateTime.now()).toUtc()),
      ColumnNames.archivedAt:
          archivedAt != null ? Timestamp.fromDate(archivedAt!.toUtc()) : null,
    };
  }
}
// path: lib/shared/model/apk_version_model.dart
// new file: Refactored from user_apk_version_model.dart to use English naming and proper structure.

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:wifi/shared/constant/column_names.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/enum/apk_architecture_enum.dart';
import 'package:wifi/shared/model/has_id.dart';

/// Model representing application version information for the user.
class ApkVersionModel implements HasId {
  @override
  final String id;

  /// Release notes or changelog for this version.
  final String releaseNotes;

  /// A map containing the latest build number for each APK architecture.
  final Map<ApkArchitectureEnum, int> latestBuildNumber;

  /// A map containing the download link for each APK architecture.
  final Map<ApkArchitectureEnum, String> downloadLinks;

  /// The user-facing version number, e.g., "1.0.2".
  final String latestVersion;

  /// Indicates whether updating to this version is mandatory.
  final bool isUpdateRequired;

  /// Link to a relevant YouTube tutorial for this version.
  final String youtubeTutorial;

  /// Soft delete flag.
  final bool isDeleted;

  /// Timestamp when this version was archived.
  final DateTime? archivedAt;

  /// Timestamp when this version was last updated.
  final DateTime? updatedAt;

  /// Constructor for creating an instance of `ApkVersionModel`.
  ApkVersionModel({
    final String? id,
    this.releaseNotes = '',
    this.latestBuildNumber = const {},
    this.downloadLinks = const {},
    this.latestVersion = '',
    this.isUpdateRequired = false,
    this.youtubeTutorial = '',
    this.isDeleted = false,
    this.archivedAt,
    this.updatedAt,
  }) : id = id ?? const Uuid().v4();

  /// Creates a copy of this model with updated values.
  ApkVersionModel copyWith({
    final String? id,
    final String? releaseNotes,
    final Map<ApkArchitectureEnum, int>? latestBuildNumber,
    final Map<ApkArchitectureEnum, String>? downloadLinks,
    final String? latestVersion,
    final bool? isUpdateRequired,
    final String? youtubeTutorial,
    final bool? isDeleted,
    final DateTime? archivedAt,
    final DateTime? updatedAt,
  }) {
    return ApkVersionModel(
      id: id ?? this.id,
      releaseNotes: releaseNotes ?? this.releaseNotes,
      latestBuildNumber: latestBuildNumber ?? this.latestBuildNumber,
      downloadLinks: downloadLinks ?? this.downloadLinks,
      latestVersion: latestVersion ?? this.latestVersion,
      isUpdateRequired: isUpdateRequired ?? this.isUpdateRequired,
      youtubeTutorial: youtubeTutorial ?? this.youtubeTutorial,
      isDeleted: isDeleted ?? this.isDeleted,
      archivedAt: archivedAt ?? this.archivedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // =========================
  // HELPERS
  // =========================

  /// Helper to parse `DateTime` from various formats.
  static DateTime? _parseDateTime(final dynamic date) {
    if (date == null) return null;
    if (date is Timestamp) return date.toDate();
    if (date is DateTime) return date;
    if (date is String) return DateTime.tryParse(date);
    if (date is int) return DateTime.fromMillisecondsSinceEpoch(date);
    return null;
  }

  /// Helper to convert a String to an `ApkArchitectureEnum` enum.
  static ApkArchitectureEnum? _architectureFromString(final String? value) {
    if (value == null) return null;
    for (final val in ApkArchitectureEnum.values) {
      if (val.name == value) {
        return val;
      }
    }
    return null;
  }

  /// Helper to parse build number data from a Map or JSON String.
  static Map<ApkArchitectureEnum, int> _parseBuildNumber(final dynamic data) {
    final result = <ApkArchitectureEnum, int>{};
    Map<dynamic, dynamic>? mapData;

    if (data is Map) {
      mapData = data;
    } else if (data is String) {
      try {
        final decoded = jsonDecode(data);
        if (decoded is Map) mapData = decoded;
      } on FormatException catch (e, st) {
        Log.error('Failed to parse build number JSON', e: e, st: st);
      }
    }

    if (mapData != null) {
      for (final item in mapData.entries) {
        final architecture = _architectureFromString(item.key.toString());
        if (architecture != null) {
          result[architecture] =
              item.value is num ? (item.value as num).toInt() : 0;
        }
      }
    }

    return result;
  }

  /// Helper to parse download link data from a Map or JSON String.
  static Map<ApkArchitectureEnum, String> _parseDownloadLinks(
      final dynamic data) {
    final result = <ApkArchitectureEnum, String>{};
    Map<dynamic, dynamic>? mapData;

    if (data is Map) {
      mapData = data;
    } else if (data is String) {
      try {
        final decoded = jsonDecode(data);
        if (decoded is Map) mapData = decoded;
      } on FormatException catch (e, st) {
        Log.error('Failed to parse download links JSON', e: e, st: st);
      }
    }

    if (mapData != null) {
      for (final item in mapData.entries) {
        final architecture = _architectureFromString(item.key.toString());
        if (architecture != null) {
          result[architecture] = item.value?.toString() ?? '';
        }
      }
    }

    return result;
  }

  // =========================
  // SQLITE
  // =========================

  /// Factory to create `ApkVersionModel` from SQLite data.
  factory ApkVersionModel.fromSqlite(final Map<String, dynamic> map) {
    return ApkVersionModel(
      id: map[ColumnNames.id] as String? ?? '',
      releaseNotes: map[ColumnNames.releaseNotes] as String? ?? '',
      latestVersion: map[ColumnNames.latestVersion] as String? ?? '',
      youtubeTutorial: map[ColumnNames.youtubeTutorial] as String? ?? '',
      isUpdateRequired: (map[ColumnNames.isUpdateRequired] as int? ?? 0) == 1,
      isDeleted: (map[ColumnNames.isDeleted] as int? ?? 0) == 1,
      latestBuildNumber:
          _parseBuildNumber(map[ColumnNames.latestBuildNumber]),
      downloadLinks: _parseDownloadLinks(map[ColumnNames.downloadLinks]),
      archivedAt: _parseDateTime(map[ColumnNames.archivedAt]),
      updatedAt: _parseDateTime(map[ColumnNames.updatedAt]),
    );
  }

  /// Converts the model to a Map for SQLite.
  Map<String, dynamic> toSqlite() {
    return {
      ColumnNames.id: id,
      ColumnNames.releaseNotes: releaseNotes,
      ColumnNames.latestVersion: latestVersion,
      ColumnNames.youtubeTutorial: youtubeTutorial,
      ColumnNames.archivedAt: archivedAt?.millisecondsSinceEpoch,
      ColumnNames.updatedAt: updatedAt?.millisecondsSinceEpoch,
      ColumnNames.latestBuildNumber: jsonEncode(
        latestBuildNumber.map((final key, final value) => MapEntry(key.name, value)),
      ),
      ColumnNames.downloadLinks: jsonEncode(
        downloadLinks.map((final key, final value) => MapEntry(key.name, value)),
      ),
      ColumnNames.isUpdateRequired: isUpdateRequired ? 1 : 0,
      ColumnNames.isDeleted: isDeleted ? 1 : 0,
    };
  }

  // =========================
  // FIREBASE
  // =========================

  /// Factory to create `ApkVersionModel` from Firebase data.
  factory ApkVersionModel.fromFirebase(
      final String id, final Map<String, dynamic> map) {
    return ApkVersionModel(
      id: id,
      releaseNotes: map[ColumnNames.releaseNotes] as String? ?? '',
      latestVersion: map[ColumnNames.latestVersion] as String? ?? '',
      youtubeTutorial: map[ColumnNames.youtubeTutorial] as String? ?? '',
      isUpdateRequired: map[ColumnNames.isUpdateRequired] as bool? ?? false,
      isDeleted: map[ColumnNames.isDeleted] as bool? ?? false,
      latestBuildNumber:
          _parseBuildNumber(map[ColumnNames.latestBuildNumber]),
      downloadLinks: _parseDownloadLinks(map[ColumnNames.downloadLinks]),
      archivedAt: _parseDateTime(map[ColumnNames.archivedAt]),
      updatedAt: _parseDateTime(map[ColumnNames.updatedAt]),
    );
  }

  /// Converts the model to a Map for Firestore.
  Map<String, dynamic> toFirebase() {
    return {
      ColumnNames.releaseNotes: releaseNotes,
      ColumnNames.latestVersion: latestVersion,
      ColumnNames.youtubeTutorial: youtubeTutorial,
      ColumnNames.updatedAt:
          updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      if (archivedAt != null)
        ColumnNames.archivedAt: Timestamp.fromDate(archivedAt!),
      ColumnNames.latestBuildNumber: latestBuildNumber.map(
        (final key, final value) => MapEntry(key.name, value),
      ),
      ColumnNames.downloadLinks: downloadLinks.map(
        (final key, final value) => MapEntry(key.name, value),
      ),
      ColumnNames.isUpdateRequired: isUpdateRequired,
      ColumnNames.isDeleted: isDeleted,
    };
  }
}
// path: lib/shared/model/category_model.dart
// diperbarui: Memindahkan enum ke file sendiri dan memperbaiki typo.

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:wifi/shared/constant/column_names.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/enum/category_type_enum.dart';
import 'package:wifi/shared/model/has_id.dart';
import 'package:wifi/shared/model/sub_category_model.dart';

/// Model that represents a transaction category.
class CategoryModel implements HasId {
  @override
  final String id;

  /// The name of the category.
  final String name;

  /// The type of the category (e.g., expense, income).
  final CategoryType type;

  /// A list of sub-categories under this category.
  final List<SubCategoryModel> subCategories;

  /// The last time the data was updated.
  final DateTime? updatedAt;

  /// The status of whether this category has been deleted (soft delete).
  final bool isDeleted;

  /// The time this category was archived.
  final DateTime? archivedAt;

  /// Main constructor for [CategoryModel].
  CategoryModel({
    final String? id,
    required this.name,
    required this.type,
    this.subCategories = const [],
    this.updatedAt,
    this.isDeleted = false,
    this.archivedAt,
  }) : id = id ?? const Uuid().v4() {
    Log.info('CategoryModel created: $id, name: $name');
  }

  /// Creates a copy of [CategoryModel] with some updated fields.
  CategoryModel copyWith({
    final String? id,
    final String? name,
    final CategoryType? type,
    final List<SubCategoryModel>? subCategories,
    final DateTime? updatedAt,
    final bool? isDeleted,
    final DateTime? archivedAt,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      subCategories: subCategories ?? this.subCategories,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      archivedAt: archivedAt ?? this.archivedAt,
    );
  }

  /// Helper to parse date values from various formats.
  static DateTime? _parseDateTime(final dynamic dateValue) {
    if (dateValue == null) return null;
    if (dateValue is Timestamp) return dateValue.toDate();
    if (dateValue is DateTime) return dateValue;
    if (dateValue is int) {
      return DateTime.fromMillisecondsSinceEpoch(dateValue);
    }
    if (dateValue is String) return DateTime.tryParse(dateValue);
    return null;
  }

  /// Safe helper to parse an enum from a string.
  static T? _safeParseEnum<T extends Enum>(
    final List<T> values,
    final dynamic name,
  ) {
    if (name == null || name is! String) {
      return null;
    }
    for (final value in values) {
      if (value.name == name) {
        return value;
      }
    }
    Log.warning('Failed to parse enum for type $T', name);
    return null;
  }

  /// Helper to parse boolean from various formats.
  static bool _parseBool(final dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value.toLowerCase() == 'true';
    return false;
  }

  /// Factory constructor to create [CategoryModel] from SQLite data.
  factory CategoryModel.fromSqlite(final Map<String, dynamic> map) {
    List<SubCategoryModel> parseSubCategories(final dynamic data) {
      if (data == null) return [];
      try {
        if (data is String && data.isNotEmpty) {
          final list = jsonDecode(data) as List<dynamic>;
          return list
              .map((final item) {
                if (item is Map<String, dynamic>) {
                  return SubCategoryModel.fromSqlite(item);
                }
                return null;
              })
              .whereType<SubCategoryModel>()
              .toList();
        }
        return [];
      } on FormatException catch (e, st) {
        Log.error('Failed to parse subcategories from JSON', e: e, st: st);
        return [];
      }
    }

    return CategoryModel(
      id: map[ColumnNames.id] as String? ?? '',
      name: map[ColumnNames.name] as String? ?? '',
      type: _safeParseEnum(CategoryType.values, map[ColumnNames.type]) ??
          CategoryType.expense,
      subCategories: parseSubCategories(map[ColumnNames.subCategoryId]),
      updatedAt: _parseDateTime(map[ColumnNames.updatedAt]),
      isDeleted: _parseBool(map[ColumnNames.isDeleted]),
      archivedAt: _parseDateTime(map[ColumnNames.archivedAt]),
    );
  }

  /// Converts [CategoryModel] to a Map for SQLite storage.
  Map<String, dynamic> toSqlite() {
    final data = {
      ColumnNames.id: id,
      ColumnNames.name: name,
      ColumnNames.type: type.name,
      ColumnNames.subCategoryId: jsonEncode(
        subCategories.map((final sub) => sub.toSqlite()).toList(),
      ),
      ColumnNames.updatedAt: updatedAt?.millisecondsSinceEpoch,
      ColumnNames.isDeleted: isDeleted ? 1 : 0,
      ColumnNames.archivedAt: archivedAt?.millisecondsSinceEpoch,
    };
    return data;
  }

  /// Factory constructor to create [CategoryModel] from Firebase data.
  factory CategoryModel.fromFirebase(
    final String id,
    final Map<String, dynamic> data,
  ) {
    List<SubCategoryModel> parseSubCategories(final dynamic subCategoryData) {
      if (subCategoryData is List) {
        return subCategoryData
            .map((final item) {
              if (item is Map<String, dynamic>) {
                final String subId =
                    item[ColumnNames.id] as String? ?? const Uuid().v4();
                return SubCategoryModel.fromFirebase(subId, item);
              }
              return null;
            })
            .whereType<SubCategoryModel>()
            .toList();
      }
      return [];
    }

    return CategoryModel(
      id: id,
      name: data[ColumnNames.name] as String? ?? '',
      type: _safeParseEnum(CategoryType.values, data[ColumnNames.type]) ??
          CategoryType.expense,
      subCategories: parseSubCategories(data[ColumnNames.subCategoryId]),
      updatedAt: _parseDateTime(data[ColumnNames.updatedAt]),
      isDeleted: _parseBool(data[ColumnNames.isDeleted]),
      archivedAt: _parseDateTime(data[ColumnNames.archivedAt]),
    );
  }

  /// Converts [CategoryModel] to a Map for Firebase storage.
  Map<String, dynamic> toFirebase() {
    final data = {
      ColumnNames.name: name,
      ColumnNames.type: type.name,
      ColumnNames.subCategoryId:
          subCategories.map((final sub) => sub.toFirebase()).toList(),
      ColumnNames.isDeleted: isDeleted,
      ColumnNames.updatedAt:
          Timestamp.fromDate((updatedAt ?? DateTime.now()).toUtc()),
      ColumnNames.archivedAt:
          archivedAt != null ? Timestamp.fromDate(archivedAt!.toUtc()) : null,
    };
    return data;
  }
}
// path: lib/shared/model/customer_model.dart
// new file: Refactored from pelanggan_model.dart to use English naming conventions.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:wifi/shared/constant/column_names.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/has_id.dart';

/// Model representing a customer's data.
class CustomerModel implements HasId {
  @override
  final String id;

  /// The name of the customer.
  final String name;

  /// The phone number of the customer.
  final String phone;

  /// The address of the customer.
  final String address;

  /// The password for the customer's account.
  final String password;

  /// The MAC address of the customer's device.
  final String macAddress;

  /// A flag indicating if the customer has been soft-deleted.
  final bool isDeleted;

  /// The timestamp of the last update.
  final DateTime? updatedAt;

  /// The timestamp of when the customer was archived.
  final DateTime? archivedAt;

  /// Creates a new instance of the [CustomerModel].
  CustomerModel({
    final String? id,
    required this.name,
    required this.phone,
    required this.address,
    required this.password,
    this.macAddress = '',
    this.isDeleted = false,
    this.updatedAt,
    this.archivedAt,
  }) : id = id ?? const Uuid().v4() {
    Log.info('CustomerModel created: $id, name: $name');
  }

  /// Creates a copy of the [CustomerModel] with updated fields.
  CustomerModel copyWith({
    final String? id,
    final String? name,
    final String? phone,
    final String? address,
    final String? password,
    final String? macAddress,
    final bool? isDeleted,
    final DateTime? updatedAt,
    final DateTime? archivedAt,
  }) {
    return CustomerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      password: password ?? this.password,
      macAddress: macAddress ?? this.macAddress,
      isDeleted: isDeleted ?? this.isDeleted,
      updatedAt: updatedAt ?? this.updatedAt,
      archivedAt: archivedAt ?? this.archivedAt,
    );
  }

  /// Parses a dynamic value into a [DateTime] object.
  static DateTime? _parseDateTime(final dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    Log.warning('Unrecognized DateTime format: $value');
    return null;
  }

  /// Parses a dynamic value into a boolean.
  static bool _parseBool(final dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value.toLowerCase() == 'true';
    Log.warning('Unrecognized Boolean format, defaulting to false: $value');
    return false;
  }

  /// Creates a [CustomerModel] from a SQLite map.
  factory CustomerModel.fromSqlite(final Map<String, dynamic> map) {
    Log.info('Creating CustomerModel from SQLite: ${map[ColumnNames.id]}');
    return CustomerModel(
      id: map[ColumnNames.id] as String? ?? '',
      name: map[ColumnNames.name] as String? ?? '',
      phone: map[ColumnNames.phone] as String? ?? '',
      address: map[ColumnNames.address] as String? ?? '',
      password: map[ColumnNames.password] as String? ?? '',
      macAddress: map[ColumnNames.macAddress] as String? ?? '',
      isDeleted: _parseBool(map[ColumnNames.isDeleted]),
      updatedAt: _parseDateTime(map[ColumnNames.updatedAt]),
      archivedAt: _parseDateTime(map[ColumnNames.archivedAt]),
    );
  }

  /// Converts the [CustomerModel] to a map for SQLite storage.
  Map<String, dynamic> toSqlite() {
    return {
      ColumnNames.id: id,
      ColumnNames.name: name,
      ColumnNames.phone: phone,
      ColumnNames.address: address,
      ColumnNames.password: password,
      ColumnNames.macAddress: macAddress,
      ColumnNames.isDeleted: isDeleted ? 1 : 0,
      ColumnNames.updatedAt: updatedAt?.millisecondsSinceEpoch,
      ColumnNames.archivedAt: archivedAt?.millisecondsSinceEpoch,
    };
  }

  /// Creates a [CustomerModel] from a Firebase document.
  factory CustomerModel.fromFirebase(final String id, final Map<String, dynamic> data) {
    Log.info('Creating CustomerModel from Firebase: $id');
    return CustomerModel(
      id: id,
      name: data[ColumnNames.name] as String? ?? '',
      phone: data[ColumnNames.phone] as String? ?? '',
      address: data[ColumnNames.address] as String? ?? '',
      password: data[ColumnNames.password] as String? ?? '',
      macAddress: data[ColumnNames.macAddress] as String? ?? '',
      isDeleted: _parseBool(data[ColumnNames.isDeleted]),
      updatedAt: _parseDateTime(data[ColumnNames.updatedAt]),
      archivedAt: _parseDateTime(data[ColumnNames.archivedAt]),
    );
  }

  /// Converts the [CustomerModel] to a map for Firebase storage.
  Map<String, dynamic> toFirebase() {
    return {
      ColumnNames.name: name,
      ColumnNames.phone: phone,
      ColumnNames.address: address,
      ColumnNames.password: password,
      ColumnNames.macAddress: macAddress,
      ColumnNames.isDeleted: isDeleted,
      ColumnNames.updatedAt:
          Timestamp.fromDate((updatedAt ?? DateTime.now()).toUtc()),
      ColumnNames.archivedAt:
          archivedAt != null ? Timestamp.fromDate(archivedAt!.toUtc()) : null,
    };
  }
}
// path: lib/shared/model/feedback_model.dart
// diperbarui: Mengganti nama variabel ke bahasa Inggris dan memperbaiki metode toFirebase.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:wifi/shared/constant/column_names.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/has_id.dart';

/// Model for feedback data from users.
class FeedbackModel implements HasId {
  @override
  final String id;

  /// The content of the feedback.
  final String content;

  /// The date the feedback was created.
  final DateTime? date;

  /// The ID of the user who submitted the feedback.
  final String userId;

  /// The last time the data was updated.
  final DateTime? updatedAt;

  /// The status of whether this feedback has been deleted (soft delete).
  final bool isDeleted;

  /// The time this feedback was archived.
  final DateTime? archivedAt;

  /// Constructor to create a [FeedbackModel] instance.
  FeedbackModel({
    final String? id,
    required this.content,
    this.date,
    required this.userId,
    this.updatedAt,
    this.isDeleted = false,
    this.archivedAt,
  }) : id = id ?? const Uuid().v4() {
    Log.info('FeedbackModel created: $id, userId: $userId');
  }

  /// Creates a copy of [FeedbackModel] with some updated fields.
  FeedbackModel copyWith({
    final String? id,
    final String? content,
    final DateTime? date,
    final String? userId,
    final DateTime? updatedAt,
    final bool? isDeleted,
    final DateTime? archivedAt,
  }) {
    return FeedbackModel(
      id: id ?? this.id,
      content: content ?? this.content,
      date: date ?? this.date,
      userId: userId ?? this.userId,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      archivedAt: archivedAt ?? this.archivedAt,
    );
  }

  /// Parses a date value from various data types.
  static DateTime? parseDateTime(final dynamic dateValue) {
    if (dateValue == null) return null;
    if (dateValue is Timestamp) return dateValue.toDate();
    if (dateValue is DateTime) return dateValue;
    if (dateValue is String) return DateTime.tryParse(dateValue);
    if (dateValue is int) {
      return DateTime.fromMillisecondsSinceEpoch(dateValue);
    }
    Log.warning('Failed to parse date: $dateValue');
    return null;
  }

  /// Helper to parse boolean from various formats.
  static bool _parseBool(final dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value.toLowerCase() == 'true';
    return false;
  }

  /// Creates a [FeedbackModel] instance from SQLite data.
  factory FeedbackModel.fromSqlite(final Map<String, dynamic> map) {
    Log.info('Creating FeedbackModel from SQLite: ${map[ColumnNames.id]}');
    return FeedbackModel(
      id: map[ColumnNames.id] as String?,
      content: map[ColumnNames.content] as String? ?? '',
      userId: map[ColumnNames.userId] as String? ?? '',
      date: parseDateTime(map[ColumnNames.date]),
      updatedAt: parseDateTime(map[ColumnNames.updatedAt]),
      isDeleted: _parseBool(map[ColumnNames.isDeleted]),
      archivedAt: parseDateTime(map[ColumnNames.archivedAt]),
    );
  }

  /// Converts [FeedbackModel] to a Map format for SQLite.
  Map<String, dynamic> toSqlite() {
    return {
      ColumnNames.id: id,
      ColumnNames.content: content,
      ColumnNames.userId: userId,
      ColumnNames.date: date?.millisecondsSinceEpoch,
      ColumnNames.updatedAt: updatedAt?.millisecondsSinceEpoch,
      ColumnNames.isDeleted: isDeleted ? 1 : 0,
      ColumnNames.archivedAt: archivedAt?.millisecondsSinceEpoch,
    };
  }

  /// Creates a [FeedbackModel] instance from Firebase data.
  factory FeedbackModel.fromFirebase(
      final String id, final Map<String, dynamic> data) {
    Log.info('Creating FeedbackModel from Firebase: $id');
    return FeedbackModel(
      id: id,
      content: data[ColumnNames.content] as String? ?? '',
      userId: data[ColumnNames.userId] as String? ?? '',
      date: parseDateTime(data[ColumnNames.date]),
      updatedAt: parseDateTime(data[ColumnNames.updatedAt]),
      isDeleted: _parseBool(data[ColumnNames.isDeleted]),
      archivedAt: parseDateTime(data[ColumnNames.archivedAt]),
    );
  }

  /// Converts [FeedbackModel] to a Map format for Firebase.
  Map<String, dynamic> toFirebase() {
    return {
      ColumnNames.content: content,
      ColumnNames.userId: userId,
      ColumnNames.date: date != null ? Timestamp.fromDate(date!.toUtc()) : null,
      ColumnNames.isDeleted: isDeleted,
      ColumnNames.updatedAt:
          updatedAt != null ? Timestamp.fromDate(updatedAt!.toUtc()) : null,
      ColumnNames.archivedAt:
          archivedAt != null ? Timestamp.fromDate(archivedAt!.toUtc()) : null,
    };
  }
}
// path: lib/shared/model/save_result_model.dart
// new file: Refactored from hasil_simpan_model.dart to use English naming conventions.

import 'package:wifi/shared/debug/log.dart';

/// A generic model to represent the result of a save or update operation.
class SaveResultModel<T> {
  /// Indicates whether the operation was successful.
  final bool success;

  /// A message providing more detail about the operation's result.
  final String message;

  /// Optional data that may be returned upon a successful operation.
  final T? data;

  /// Constructor for `SaveResultModel`.
  SaveResultModel({
    required this.success,
    required this.message,
    this.data,
  }) {
    Log.info('SaveResultModel created: success=$success, message=$message');
  }
}
// path: lib/shared/model/settings_model.dart
// new file: Refactored from pengaturan_model.dart to use English naming conventions.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wifi/shared/constant/column_names.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/has_id.dart';

/// Global ID for the settings document.
const String globalSettingsId = 'global_config';

/// Model for application settings.
class SettingsModel implements HasId {
  @override
  final String id;

  /// The interval in hours for auto-sync.
  final int autoSyncInterval;

  /// The number of days after which archived data is auto-deleted.
  final int autoDeleteArchiveDays;

  /// A flag indicating if the application is in maintenance mode.
  final bool maintenanceMode;

  /// Information about the maintenance mode.
  final String maintenanceInfo;

  /// The timestamp of the last update.
  final DateTime? updatedAt;

  /// Constructor for `SettingsModel`.
  SettingsModel({
    this.id = globalSettingsId,
    this.autoSyncInterval = 24,
    this.autoDeleteArchiveDays = 30,
    this.maintenanceMode = false,
    this.maintenanceInfo = '',
    this.updatedAt,
  });

  /// Creates a copy of this `SettingsModel` with some modified values.
  SettingsModel copyWith({
    final String? id,
    final int? autoSyncInterval,
    final int? autoDeleteArchiveDays,
    final bool? maintenanceMode,
    final String? maintenanceInfo,
    final DateTime? updatedAt,
  }) {
    return SettingsModel(
      id: id ?? this.id,
      autoSyncInterval: autoSyncInterval ?? this.autoSyncInterval,
      autoDeleteArchiveDays:
          autoDeleteArchiveDays ?? this.autoDeleteArchiveDays,
      maintenanceMode: maintenanceMode ?? this.maintenanceMode,
      maintenanceInfo: maintenanceInfo ?? this.maintenanceInfo,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Helper to parse DateTime from various formats.
  static DateTime? _parseDateTime(final dynamic dateValue) {
    if (dateValue == null) return null;
    if (dateValue is Timestamp) return dateValue.toDate();
    if (dateValue is DateTime) return dateValue;
    if (dateValue is int) {
      return DateTime.fromMillisecondsSinceEpoch(dateValue);
    }
    if (dateValue is String) return DateTime.tryParse(dateValue);
    return null;
  }

  /// Creates a `SettingsModel` instance from SQLite map data.
  factory SettingsModel.fromSqlite(final Map<String, dynamic> map) {
    Log.info('Creating SettingsModel from SQLite');
    return SettingsModel(
      autoSyncInterval: map[ColumnNames.autoSyncInterval] as int? ?? 24,
      autoDeleteArchiveDays:
          map[ColumnNames.autoDeleteArchiveDays] as int? ?? 30,
      maintenanceMode: (map[ColumnNames.maintenanceMode] as int? ?? 0) == 1,
      maintenanceInfo: map[ColumnNames.maintenanceInfo] as String? ?? '',
      updatedAt: _parseDateTime(map[ColumnNames.updatedAt]),
    );
  }

  /// Converts `SettingsModel` to a Map for SQLite storage.
  Map<String, dynamic> toSqlite() {
    return {
      ColumnNames.id: id,
      ColumnNames.autoSyncInterval: autoSyncInterval,
      ColumnNames.autoDeleteArchiveDays: autoDeleteArchiveDays,
      ColumnNames.maintenanceMode: maintenanceMode ? 1 : 0,
      ColumnNames.maintenanceInfo: maintenanceInfo,
      ColumnNames.updatedAt: updatedAt?.millisecondsSinceEpoch,
    };
  }

  /// Creates a `SettingsModel` instance from Firebase map data.
  factory SettingsModel.fromFirebase(final Map<String, dynamic> data) {
    Log.info('Creating SettingsModel from Firebase');
    return SettingsModel(
      id: data[ColumnNames.id] as String? ?? globalSettingsId,
      autoSyncInterval: data[ColumnNames.autoSyncInterval] as int? ?? 24,
      autoDeleteArchiveDays: data[ColumnNames.autoDeleteArchiveDays] as int? ?? 30,
      maintenanceMode: data[ColumnNames.maintenanceMode] as bool? ?? false,
      maintenanceInfo: data[ColumnNames.maintenanceInfo] as String? ?? '',
      updatedAt: _parseDateTime(data[ColumnNames.updatedAt]),
    );
  }

  /// Converts `SettingsModel` to a Map for Firebase storage.
  Map<String, dynamic> toFirebase() {
    return {
      ColumnNames.autoSyncInterval: autoSyncInterval,
      ColumnNames.autoDeleteArchiveDays: autoDeleteArchiveDays,
      ColumnNames.maintenanceMode: maintenanceMode,
      ColumnNames.maintenanceInfo: maintenanceInfo,
      ColumnNames.updatedAt:
          Timestamp.fromDate((updatedAt ?? DateTime.now()).toUtc()),
    };
  }
}
// path: lib/shared/model/sub_category_model.dart
// diperbarui: Mengganti impor dan menambahkan logging.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:wifi/shared/constant/column_names.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/category_model.dart' show CategoryModel;
import 'package:wifi/shared/model/has_id.dart';

/// Model yang merepresentasikan sebuah sub-kategori.
///
/// Setiap sub-kategori selalu berada di bawah sebuah [CategoryModel] induk.
class SubCategoryModel implements HasId {
  /// ID unik dari sub-kategori, biasanya dibuat menggunakan UUID.
  @override
  final String id;

  /// Nama dari sub-kategori.
  final String name;

  /// ID dari [CategoryModel] induk.
  final String categoryId;

  /// Waktu terakhir data ini diperbarui.
  final DateTime? updatedAt;

  /// Penanda untuk soft-delete (penghapusan sementara).
  final bool isDeleted;

  /// Waktu saat data ini diarsipkan.
  final DateTime? archivedAt;

  /// Konstruktor utama untuk membuat instance [SubCategoryModel].
  SubCategoryModel({
    final String? id,
    required this.name,
    required this.categoryId,
    this.updatedAt,
    this.isDeleted = false,
    this.archivedAt,
  }) : id = id ?? const Uuid().v4() {
    Log.info('SubCategoryModel dibuat: $name ($id)');
  }

  /// Membuat salinan dari instance [SubCategoryModel] ini dengan beberapa nilai yang diubah.
  SubCategoryModel copyWith({
    final String? id,
    final String? name,
    final String? categoryId,
    final DateTime? updatedAt,
    final bool? isDeleted,
    final DateTime? archivedAt,
  }) {
    return SubCategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      categoryId: categoryId ?? this.categoryId,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      archivedAt: archivedAt ?? this.archivedAt,
    );
  }

  /// Fungsi bantuan untuk mem-parsing nilai dinamis menjadi DateTime.
  static DateTime? parseDateTime(final dynamic date) {
    if (date == null) return null;
    if (date is Timestamp) return date.toDate();
    if (date is DateTime) return date;
    if (date is String) return DateTime.tryParse(date);
    if (date is int) return DateTime.fromMillisecondsSinceEpoch(date);
    return null;
  }

  /// Fungsi bantuan untuk mem-parsing nilai dinamis menjadi boolean secara aman.
  static bool parseBool(final dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value.toLowerCase() == 'true';
    return false;
  }

  /// Factory constructor untuk membuat [SubCategoryModel] dari data SQLite.
  factory SubCategoryModel.fromSqlite(final Map<String, dynamic> map) {
    Log.info('Membuat SubCategoryModel dari SQLite: ${map[ColumnNames.id]}');
    return SubCategoryModel(
      id: map[ColumnNames.id] as String? ?? '',
      name: map[ColumnNames.name] as String? ?? '',
      categoryId: map[ColumnNames.categoryId] as String? ?? '',
      updatedAt: parseDateTime(map[ColumnNames.updatedAt]),
      isDeleted: parseBool(map[ColumnNames.isDeleted]),
      archivedAt: parseDateTime(map[ColumnNames.archivedAt]),
    );
  }

  /// Mengonversi instance [SubCategoryModel] ini menjadi Map untuk disimpan di SQLite.
  Map<String, dynamic> toSqlite() {
    Log.info('Mengonversi SubCategoryModel ke format SQLite: $id');
    return {
      ColumnNames.id: id,
      ColumnNames.name: name,
      ColumnNames.categoryId: categoryId,
      ColumnNames.updatedAt: updatedAt?.millisecondsSinceEpoch,
      ColumnNames.isDeleted: isDeleted ? 1 : 0,
      ColumnNames.archivedAt: archivedAt?.millisecondsSinceEpoch,
    };
  }

  /// Factory constructor untuk membuat [SubCategoryModel] dari data Firebase.
  factory SubCategoryModel.fromFirebase(final String id, final Map<String, dynamic> data) {
    Log.info('Membuat SubCategoryModel dari Firebase: $id');
    return SubCategoryModel(
      id: id,
      name: data[ColumnNames.name] as String? ?? '',
      categoryId: data[ColumnNames.categoryId] as String? ?? '',
      updatedAt: parseDateTime(data[ColumnNames.updatedAt]),
      isDeleted: parseBool(data[ColumnNames.isDeleted]),
      archivedAt: parseDateTime(data[ColumnNames.archivedAt]),
    );
  }

  /// Mengonversi instance [SubCategoryModel] ini menjadi Map untuk disimpan di Firebase.
  /// ID disertakan karena sub-kategori disimpan sebagai daftar di dalam dokumen kategori.
  Map<String, dynamic> toFirebase() {
    Log.info('Mengonversi SubCategoryModel ke format Firebase: $id');
    return {
      ColumnNames.id: id,
      ColumnNames.name: name,
      ColumnNames.categoryId: categoryId,
      ColumnNames.updatedAt:
          Timestamp.fromDate((updatedAt ?? DateTime.now()).toUtc()),
      ColumnNames.isDeleted: isDeleted,
      ColumnNames.archivedAt:
          archivedAt != null ? Timestamp.fromDate(archivedAt!.toUtc()) : null,
    };
  }
}
// path: lib/shared/model/transaction_model.dart
// new file: Refactored from transaksi_model.dart to use English naming conventions.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:wifi/shared/constant/column_names.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/enum/duration_type_enum.dart';
import 'package:wifi/shared/enum/payment_status_enum.dart';
import 'package:wifi/shared/enum/transaction_type_enum.dart';
import 'package:wifi/shared/model/has_id.dart';

/// Model that represents a single transaction in the application.
class TransactionModel implements HasId {
  @override
  final String id;

  /// The date and time when the transaction was created.
  final DateTime date;

  /// A description or note about the transaction.
  final String description;

  /// The amount of the transaction.
  final double amount;

  /// The type of transaction (e.g., income, expense, transfer, subscription).
  final TransactionType type;

  /// The ID of the source wallet.
  final String walletId;

  /// The ID of the main category of the transaction.
  final String categoryId;

  /// The ID of the destination wallet, only used for transfer transactions.
  final String? destinationWalletId;

  /// The ID of the customer associated with this transaction.
  final String? customerId;

  /// The ID of the package, if this is a subscription activation.
  final String? packageId;

  /// The ID of the sub-category of the transaction.
  final String? subCategoryId;

  /// The payment status of the transaction (e.g., paid, unpaid).
  final PaymentStatus paymentStatus;

  /// The number of points earned from this transaction.
  final int earnedPoints;

  /// The number of points used in this transaction.
  final int usedPoints;

  /// The last time this data was updated.
  final DateTime? updatedAt;

  /// The time this data was archived.
  final DateTime? archivedAt;

  /// A flag indicating if this data has been deleted (soft delete).
  final bool isDeleted;

  /// The duration of the subscription package (e.g., 30).
  final int? packageDuration;

  /// The type of duration for the package (e.g., day, month).
  final DurationType? durationType;

  /// The start date of the subscription period.
  final DateTime? startDate;

  /// The end date of the subscription period.
  final DateTime? endDate;

  /// A flag indicating if this is a new package activation.
  final bool isActivated;

  /// Main constructor for creating a [TransactionModel] instance.
  TransactionModel({
    final String? id,
    required this.date,
    required this.description,
    required this.amount,
    required this.type,
    required this.walletId,
    required this.categoryId,
    this.destinationWalletId,
    this.customerId,
    this.packageId,
    this.subCategoryId,
    this.paymentStatus = PaymentStatus.unpaid,
    this.earnedPoints = 0,
    this.usedPoints = 0,
    this.updatedAt,
    this.archivedAt,
    this.isDeleted = false,
    this.packageDuration,
    this.durationType,
    this.startDate,
    this.endDate,
    this.isActivated = false,
  }) : id = id ?? const Uuid().v4() {
    Log.info('TransactionModel created: $id, type: ${type.name}');
  }

  /// Creates a copy of this [TransactionModel] with some modified values.
  TransactionModel copyWith({
    final String? id,
    final DateTime? date,
    final String? description,
    final double? amount,
    final TransactionType? type,
    final String? walletId,
    final String? categoryId,
    final String? destinationWalletId,
    final String? customerId,
    final String? packageId,
    final String? subCategoryId,
    final PaymentStatus? paymentStatus,
    final int? earnedPoints,
    final int? usedPoints,
    final DateTime? updatedAt,
    final DateTime? archivedAt,
    final bool? isDeleted,
    final int? packageDuration,
    final DurationType? durationType,
    final DateTime? startDate,
    final DateTime? endDate,
    final bool? isActivated,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      date: date ?? this.date,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      walletId: walletId ?? this.walletId,
      categoryId: categoryId ?? this.categoryId,
      destinationWalletId: destinationWalletId ?? this.destinationWalletId,
      customerId: customerId ?? this.customerId,
      packageId: packageId ?? this.packageId,
      subCategoryId: subCategoryId ?? this.subCategoryId,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      earnedPoints: earnedPoints ?? this.earnedPoints,
      usedPoints: usedPoints ?? this.usedPoints,
      updatedAt: updatedAt ?? this.updatedAt,
      archivedAt: archivedAt ?? this.archivedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      packageDuration: packageDuration ?? this.packageDuration,
      durationType: durationType ?? this.durationType,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActivated: isActivated ?? this.isActivated,
    );
  }

  /// Helper to parse DateTime from various formats.
  static DateTime? _parseDateTime(final dynamic dateValue) {
    if (dateValue == null) return null;
    if (dateValue is Timestamp) return dateValue.toDate();
    if (dateValue is DateTime) return dateValue;
    if (dateValue is String) return DateTime.tryParse(dateValue);
    if (dateValue is int) {
      return DateTime.fromMillisecondsSinceEpoch(dateValue);
    }
    return null;
  }

  /// Safe helper to parse an enum from a string.
  static T? _safeParseEnum<T extends Enum>(
    final List<T> values,
    final dynamic name,
  ) {
    if (name == null || name is! String) {
      return null;
    }
    for (final value in values) {
      if (value.name == name) {
        return value;
      }
    }
    Log.warning('Failed to parse enum for type $T', name);
    return null;
  }

  /// Helper to parse boolean from various formats.
  static bool _parseBool(final dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value.toLowerCase() == 'true';
    return false;
  }

  /// Factory constructor to create [TransactionModel] from SQLite data.
  factory TransactionModel.fromSqlite(final Map<String, dynamic> map) {
    Log.info('Creating TransactionModel from SQLite: ${map[ColumnNames.id]}');
    return TransactionModel(
      id: map[ColumnNames.id] as String? ?? '',
      date: _parseDateTime(map[ColumnNames.date]) ?? DateTime.now(),
      description: map[ColumnNames.description] as String? ?? '',
      amount: (map[ColumnNames.amount] as num? ?? 0).toDouble(),
      type: _safeParseEnum(TransactionType.values, map[ColumnNames.type]) ??
          TransactionType.expense,
      walletId: map[ColumnNames.walletId] as String? ?? '',
      categoryId: map[ColumnNames.categoryId] as String? ?? '',
      destinationWalletId: map[ColumnNames.destinationWalletId] as String?,
      customerId: map[ColumnNames.customerId] as String?,
      packageId: map[ColumnNames.packageId] as String?,
      subCategoryId: map[ColumnNames.subCategoryId] as String?,
      paymentStatus: _safeParseEnum(
            PaymentStatus.values,
            map[ColumnNames.paymentStatus],
          ) ??
          PaymentStatus.unpaid,
      earnedPoints: (map[ColumnNames.earnedPoints] as num? ?? 0).toInt(),
      usedPoints: (map[ColumnNames.usedPoints] as num? ?? 0).toInt(),
      updatedAt: _parseDateTime(map[ColumnNames.updatedAt]),
      archivedAt: _parseDateTime(map[ColumnNames.archivedAt]),
      isDeleted: _parseBool(map[ColumnNames.isDeleted]),
      packageDuration: (map[ColumnNames.packageDuration] as num?)?.toInt(),
      durationType:
          _safeParseEnum(DurationType.values, map[ColumnNames.durationType]),
      startDate: _parseDateTime(map[ColumnNames.startDate]),
      endDate: _parseDateTime(map[ColumnNames.endDate]),
      isActivated: _parseBool(map[ColumnNames.isActivated]),
    );
  }

  /// Converts this [TransactionModel] to a Map for SQLite storage.
  Map<String, dynamic> toSqlite() {
    return {
      ColumnNames.id: id,
      ColumnNames.date: date.millisecondsSinceEpoch, // INTEGER
      ColumnNames.description: description,
      ColumnNames.amount: amount,
      ColumnNames.type: type.name,
      ColumnNames.walletId: walletId,
      ColumnNames.categoryId: categoryId,
      ColumnNames.destinationWalletId: destinationWalletId,
      ColumnNames.customerId: customerId,
      ColumnNames.packageId: packageId,
      ColumnNames.subCategoryId: subCategoryId,
      ColumnNames.paymentStatus: paymentStatus.name,
      ColumnNames.earnedPoints: earnedPoints,
      ColumnNames.usedPoints: usedPoints,
      ColumnNames.updatedAt: updatedAt?.millisecondsSinceEpoch,
      ColumnNames.archivedAt: archivedAt?.millisecondsSinceEpoch,
      ColumnNames.isDeleted: isDeleted ? 1 : 0,
      ColumnNames.packageDuration: packageDuration,
      ColumnNames.durationType: durationType?.name,
      ColumnNames.startDate: startDate?.millisecondsSinceEpoch,
      ColumnNames.endDate: endDate?.millisecondsSinceEpoch,
      ColumnNames.isActivated: isActivated ? 1 : 0,
    };
  }

  /// Factory constructor to create [TransactionModel] from Firebase data.
  factory TransactionModel.fromFirebase(
      final String id, final Map<String, dynamic> data) {
    Log.info('Creating TransactionModel from Firebase: $id');
    return TransactionModel(
      id: id,
      date: _parseDateTime(data[ColumnNames.date]) ?? DateTime.now(),
      description: data[ColumnNames.description] as String? ?? '',
      amount: (data[ColumnNames.amount] as num? ?? 0).toDouble(),
      type: _safeParseEnum(TransactionType.values, data[ColumnNames.type]) ??
          TransactionType.expense,
      walletId: data[ColumnNames.walletId] as String? ?? '',
      categoryId: data[ColumnNames.categoryId] as String? ?? '',
      destinationWalletId: data[ColumnNames.destinationWalletId] as String?,
      customerId: data[ColumnNames.customerId] as String?,
      packageId: data[ColumnNames.packageId] as String?,
      subCategoryId: data[ColumnNames.subCategoryId] as String?,
      paymentStatus: _safeParseEnum(
            PaymentStatus.values,
            data[ColumnNames.paymentStatus],
          ) ??
          PaymentStatus.unpaid,
      earnedPoints: (data[ColumnNames.earnedPoints] as num? ?? 0).toInt(),
      usedPoints: (data[ColumnNames.usedPoints] as num? ?? 0).toInt(),
      updatedAt: _parseDateTime(data[ColumnNames.updatedAt]),
      archivedAt: _parseDateTime(data[ColumnNames.archivedAt]),
      isDeleted: data[ColumnNames.isDeleted] as bool? ?? false,
      packageDuration: (data[ColumnNames.packageDuration] as num?)?.toInt(),
      durationType:
          _safeParseEnum(DurationType.values, data[ColumnNames.durationType]),
      startDate: _parseDateTime(data[ColumnNames.startDate]),
      endDate: _parseDateTime(data[ColumnNames.endDate]),
      isActivated: data[ColumnNames.isActivated] as bool? ?? false,
    );
  }

  /// Converts this [TransactionModel] to a Map for Firebase storage.
  Map<String, dynamic> toFirebase() {
    return {
      // 'id' is not stored here as it is the document ID
      ColumnNames.date: Timestamp.fromDate(date),
      ColumnNames.description: description,
      ColumnNames.amount: amount,
      ColumnNames.type: type.name,
      ColumnNames.walletId: walletId,
      ColumnNames.categoryId: categoryId,
      ColumnNames.destinationWalletId: destinationWalletId,
      ColumnNames.customerId: customerId,
      ColumnNames.packageId: packageId,
      ColumnNames.subCategoryId: subCategoryId,
      ColumnNames.paymentStatus: paymentStatus.name,
      ColumnNames.earnedPoints: earnedPoints,
      ColumnNames.usedPoints: usedPoints,
      ColumnNames.updatedAt:
          updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      ColumnNames.archivedAt:
          archivedAt != null ? Timestamp.fromDate(archivedAt!) : null,
      ColumnNames.isDeleted: isDeleted,
      ColumnNames.packageDuration: packageDuration,
      ColumnNames.durationType: durationType?.name,
      ColumnNames.startDate:
          startDate != null ? Timestamp.fromDate(startDate!) : null,
      ColumnNames.endDate: endDate != null ? Timestamp.fromDate(endDate!) : null,
      ColumnNames.isActivated: isActivated,
    };
  }
}
// path: lib/shared/model/upload_status_model.dart

import 'package:wifi/shared/constant/column_names.dart';
import 'package:wifi/shared/debug/log.dart';

/// Model ini merepresentasikan satu baris tunggal dalam tabel `upload_status`.
/// Tujuannya adalah untuk bertindak sebagai "bendera" global yang menandakan
/// apakah ada perubahan lokal yang perlu diunggah ke server.
class UploadStatusModel {
  /// Nama tabel di database SQLite.
  static const String tableName = 'upload_status';

  /// Kunci unik untuk baris status `need_upload`.
  static const String idNeedUpload = 'need_upload';

  /// ID unik untuk baris ini, yang juga merupakan kuncinya (misalnya, 'need_upload').
  final String id;

  /// Bendera yang menandakan status. `true` jika ada data untuk diunggah,
  /// `false` jika tidak.
  final bool needUpload;

  /// Waktu terakhir kali status `needUpload` diubah, disimpan sebagai milidetik sejak epoch.
  final DateTime? updatedAt;

  /// Konstruktor untuk `UploadStatusModel`.
  const UploadStatusModel({
    required this.id,
    required this.needUpload,
    this.updatedAt,
  });

  /// Membuat instance UploadStatusModel dengan logging.
  factory UploadStatusModel.create({
    required final String id,
    required final bool needUpload,
    final DateTime? updatedAt,
  }) {
    Log.info('UploadStatusModel dibuat: id=$id, needUpload=$needUpload');
    return UploadStatusModel(
      id: id,
      needUpload: needUpload,
      updatedAt: updatedAt,
    );
  }

  /// Konversi dari Map (yang didapat dari database SQLite) ke model.
  factory UploadStatusModel.fromSqlite(final Map<String, dynamic> map) {
    Log.info('Memulai konversi dari SQLite Map ke UploadStatusModel');

    final updatedAtEpoch = map[ColumnNames.updatedAt] as int?;

    final model = UploadStatusModel(
      // Menggunakan ColumnNames.id untuk konsistensi
      id: map[ColumnNames.id] as String,
      // Database SQLite tidak punya tipe boolean, jadi kita simpan sebagai string ('0' atau '1') di kolom 'value'.
      needUpload: map[ColumnNames.value] == '1',
      // Konversi dari milidetik epoch kembali ke DateTime.
      updatedAt: updatedAtEpoch != null
          ? DateTime.fromMillisecondsSinceEpoch(updatedAtEpoch)
          : null,
    );

    Log.info(
        'Konversi ke UploadStatusModel berhasil: id=${model.id}, needUpload=${model.needUpload}');
    return model;
  }

  /// Konversi dari model ke Map untuk disimpan ke database SQLite.
  Map<String, dynamic> toSqlite() {
    Log.info('Memulai konversi UploadStatusModel ke SQLite Map: id=$id');

    final map = <String, dynamic>{
      ColumnNames.id: id,
      // Simpan sebagai string '0' atau '1' di kolom 'value'
      ColumnNames.value: needUpload ? '1' : '0',
      // Konversi DateTime ke milidetik sejak epoch agar bisa disimpan di SQLite sebagai INTEGER.
      ColumnNames.updatedAt: updatedAt?.millisecondsSinceEpoch,
    };

    Log.info('Konversi ke SQLite Map berhasil: $map');
    return map;
  }

  /// Membuat salinan dari model ini dengan nilai yang diperbarui.
  UploadStatusModel copyWith({
    final String? id,
    final bool? needUpload,
    final DateTime? updatedAt,
  }) {
    Log.info('UploadStatusModel.copyWith: id=$id, needUpload=$needUpload');

    return UploadStatusModel(
      id: id ?? this.id,
      needUpload: needUpload ?? this.needUpload,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'UploadStatusModel(id: $id, needUpload: $needUpload, updatedAt: $updatedAt)';
  }
}
// path: lib/shared/model/wallet_model.dart
// new file: Refactored from dompet_model.dart to use English naming conventions.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:wifi/shared/constant/column_names.dart';
import 'package:wifi/shared/model/has_id.dart';

/// Data model for a wallet entity in the application.
class WalletModel implements HasId {
  /// A unique ID for each wallet, generated automatically if not provided.
  @override
  final String id;

  /// The user-defined name for this wallet. This is required.
  final String name;

  /// The current balance of the wallet.
  final double balance;

  /// Timestamp of when this data was last updated on the server or locally.
  final DateTime? updatedAt;

  /// Soft delete status. If `true`, the wallet is considered deleted.
  final bool isDeleted;

  /// Timestamp of when this wallet was archived. `null` if not archived.
  final DateTime? archivedAt;

  /// Creates an instance of [WalletModel].
  WalletModel({
    final String? id,
    required this.name,
    required this.balance,
    this.updatedAt,
    this.isDeleted = false,
    this.archivedAt,
  }) : id = id ?? const Uuid().v4();

  /// Creates a copy of [WalletModel] with updated fields.
  WalletModel copyWith({
    final String? id,
    final String? name,
    final double? balance,
    final DateTime? updatedAt,
    final bool? isDeleted,
    final DateTime? archivedAt,
  }) {
    return WalletModel(
      id: id ?? this.id,
      name: name ?? this.name,
      balance: balance ?? this.balance,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      archivedAt: archivedAt ?? this.archivedAt,
    );
  }

  /// Internal helper to parse a date value from various formats.
  static DateTime? _parseDateTime(final dynamic dateValue) {
    if (dateValue == null) return null;
    if (dateValue is Timestamp) return dateValue.toDate();
    if (dateValue is DateTime) return dateValue;
    if (dateValue is int) {
      return DateTime.fromMillisecondsSinceEpoch(dateValue);
    }
    if (dateValue is String) return DateTime.tryParse(dateValue);
    return null;
  }

  /// Creates a [WalletModel] instance from a SQLite map.
  factory WalletModel.fromSqlite(final Map<String, dynamic> map) {
    return WalletModel(
      id: map[ColumnNames.id] as String?,
      name: (map[ColumnNames.name] as String?) ?? '',
      balance: (map[ColumnNames.balance] as num?)?.toDouble() ?? 0.0,
      updatedAt: _parseDateTime(map[ColumnNames.updatedAt]),
      isDeleted: map[ColumnNames.isDeleted] == 1,
      archivedAt: _parseDateTime(map[ColumnNames.archivedAt]),
    );
  }

  /// Converts this [WalletModel] instance into a map for SQLite storage.
  Map<String, dynamic> toSqlite() {
    return {
      ColumnNames.id: id,
      ColumnNames.name: name,
      ColumnNames.balance: balance,
      ColumnNames.updatedAt: updatedAt?.millisecondsSinceEpoch,
      ColumnNames.isDeleted: isDeleted ? 1 : 0,
      ColumnNames.archivedAt: archivedAt?.millisecondsSinceEpoch,
    };
  }

  /// Creates a [WalletModel] instance from a Firestore document.
  factory WalletModel.fromFirebase(final String id, final Map<String, dynamic> data) {
    return WalletModel(
      id: id,
      name: (data[ColumnNames.name] as String?) ?? '',
      balance: (data[ColumnNames.balance] as num?)?.toDouble() ?? 0.0,
      updatedAt: _parseDateTime(data[ColumnNames.updatedAt]),
      isDeleted: (data[ColumnNames.isDeleted] as bool?) ?? false,
      archivedAt: _parseDateTime(data[ColumnNames.archivedAt]),
    );
  }

  /// Converts this [WalletModel] instance into a map for Firestore storage.
  Map<String, dynamic> toFirebase() {
    return {
      ColumnNames.id: id,
      ColumnNames.name: name,
      ColumnNames.balance: balance,
      ColumnNames.isDeleted: isDeleted,
      ColumnNames.updatedAt:
          Timestamp.fromDate((updatedAt ?? DateTime.now()).toUtc()),
      ColumnNames.archivedAt:
          archivedAt != null ? Timestamp.fromDate(archivedAt!.toUtc()) : null,
    };
  }
}
