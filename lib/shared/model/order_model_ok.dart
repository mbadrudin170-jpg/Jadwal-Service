// // path: lib/shared/model/order_model.dart

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:uuid/uuid.dart';
// import 'package:wifi/shared/constant/column_names.dart';
// import 'package:wifi/shared/debug/log.dart';
// import 'package:wifi/shared/export/enum.dart';
// import 'package:wifi/shared/model/has_id.dart';
// import 'package:wifi/shared/utils/parser_util.dart';

// class OrderModelO implements HasId {
//   @override
//   final String id;
//   final String customerId;
//   final String packageId;
//   final DateTime date;
//   final StatusOrderEnum status;
//   final DateTime? updatedAt;
//   final bool isDeleted;
//   final DateTime? archivedAt;

//   OrderModel({
//     final String? id,
//     required this.customerId,
//     required this.packageId,
//     required this.date,
//     required this.status,
//     this.updatedAt,
//     this.isDeleted = false,
//     this.archivedAt,
//   }) : id = id ?? const Uuid().v4() {
//     Log.info('OrderModel created: $id for customer $customerId');
//   }

//   OrderModel copyWith({
//     final String? id,
//     final String? customerId,
//     final String? packageId,
//     final DateTime? date,
//     final StatusOrderEnum? status,
//     final DateTime? updatedAt,
//     final bool? isDeleted,
//     final DateTime? archivedAt,
//   }) {
//     return OrderModel(
//       id: id ?? this.id,
//       customerId: customerId ?? this.customerId,
//       packageId: packageId ?? this.packageId,
//       date: date ?? this.date,
//       status: status ?? this.status,
//       updatedAt: updatedAt ?? this.updatedAt,
//       isDeleted: isDeleted ?? this.isDeleted,
//       archivedAt: archivedAt ?? this.archivedAt,
//     );
//   }

//   static T? _safeParseEnum<T extends Enum>(
//     final List<T> values,
//     final dynamic name,
//   ) {
//     if (name == null || name is! String) {
//       return null;
//     }
//     for (final value in values) {
//       if (value.name == name) {
//         return value;
//       }
//     }
//     Log.warning('Failed to parse enum for type $T', name);
//     return null;
//   }

//   factory OrderModel.fromSqlite(final Map<String, dynamic> map) {
//     Log.info('Creating OrderModel from SQLite: ${map[ColumnNames.id]}');
//     return OrderModel(
//       id: map[ColumnNames.id] as String? ?? '',
//       customerId: map[ColumnNames.customerId] as String? ?? '',
//       packageId: map[ColumnNames.packageId] as String? ?? '',
//       date: ParserUtil.parseDateTime(map[ColumnNames.date]) ?? DateTime.now(),
//       status: _safeParseEnum(StatusOrderEnum.values, map[ColumnNames.status]) ??
//           StatusOrderEnum.baru,
//       updatedAt: ParserUtil.parseDateTime(map[ColumnNames.updatedAt]),
//       isDeleted: ParserUtil.parseBool(map[ColumnNames.isDeleted]),
//       archivedAt: ParserUtil.parseDateTime(map[ColumnNames.archivedAt]),
//     );
//   }

//   Map<String, dynamic> toSqlite() {
//     return {
//       ColumnNames.id: id,
//       ColumnNames.customerId: customerId,
//       ColumnNames.packageId: packageId,
//       ColumnNames.date: date.millisecondsSinceEpoch,
//       ColumnNames.status: status.name,
//       ColumnNames.updatedAt:
//           (updatedAt ?? DateTime.now()).millisecondsSinceEpoch,
//       ColumnNames.isDeleted: isDeleted ? 1 : 0,
//       ColumnNames.archivedAt: archivedAt?.millisecondsSinceEpoch,
//     };
//   }

//   factory OrderModel.fromFirebase(
//       final String id, final Map<String, dynamic> data) {
//     Log.info('Creating OrderModel from Firebase: $id');
//     return OrderModel(
//       id: id,
//       customerId: data[ColumnNames.customerId] as String? ?? '',
//       packageId: data[ColumnNames.packageId] as String? ?? '',
//       date: ParserUtil.parseDateTime(data[ColumnNames.date]) ?? DateTime.now(),
//       status:
//           _safeParseEnum(StatusOrderEnum.values, data[ColumnNames.status]) ??
//               StatusOrderEnum.baru,
//       updatedAt: ParserUtil.parseDateTime(data[ColumnNames.updatedAt]),
//       isDeleted: ParserUtil.parseBool(data[ColumnNames.isDeleted]),
//       archivedAt: ParserUtil.parseDateTime(data[ColumnNames.archivedAt]),
//     );
//   }

//   Map<String, dynamic> toFirebase() {
//     return {
//       ColumnNames.id: id,
//       ColumnNames.customerId: customerId,
//       ColumnNames.packageId: packageId,
//       ColumnNames.date: Timestamp.fromDate(date.toUtc()),
//       ColumnNames.status: status.name,
//       ColumnNames.updatedAt:
//           Timestamp.fromDate((updatedAt ?? DateTime.now()).toUtc()),
//       ColumnNames.isDeleted: isDeleted,
//       ColumnNames.archivedAt:
//           archivedAt != null ? Timestamp.fromDate(archivedAt!.toUtc()) : null,
//     };
//   }
// }
