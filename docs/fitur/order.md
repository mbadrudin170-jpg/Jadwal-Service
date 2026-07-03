# Dokumentasi Fitur: order

## Daftar file

lib/fitur/order/enum/status_order_enum.dart
lib/fitur/order/model/order_model.dart
lib/fitur/order/operasi/order_op_firebase.dart
lib/fitur/order/operasi/order_op_global.dart
lib/fitur/order/operasi/order_op_sqlite.dart
lib/fitur/order/page/order_page.dart
lib/fitur/order/provider/order_provider.dart

## Isi file

### File: `lib/fitur/order/enum/status_order_enum.dart`
```dart
// path: lib/fitur/order/enum/status_order_enum.dart

enum StatusOrderEnum {
  baru,
  diproses,
  selesai,
  ditolak,
  arsip;

  String get displayName {
    switch (this) {
      case StatusOrderEnum.baru:
        return 'Baru';
      case StatusOrderEnum.diproses:
        return 'Diproses';
      case StatusOrderEnum.selesai:
        return 'Selesai';
      case StatusOrderEnum.ditolak:
        return 'Ditolak';
      case StatusOrderEnum.arsip:
        return 'Arsip';
    }
  }
}
```

### File: `lib/fitur/order/model/order_model.dart`
```dart
// path: lib/fitur/order/model/order_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/enum.dart';
import 'package:wifi/shared/model/has_id.dart';
import 'package:wifi/shared/utils/parser_util.dart';

part 'order_model.freezed.dart';

@freezed
abstract class OrderModel with _$OrderModel implements HasId {
  const OrderModel._();
  const factory OrderModel({
    required String id,
    required String idPelanggan,
    required String idPaket,
    required DateTime tanggal,
    required StatusOrderEnum status,
    DateTime? diperbaruiPada,
    @Default(false) bool diHapus,
    DateTime? diarsipkanPada,
  }) = _OrderModel;

  // ---------- SQLite ----------
  factory OrderModel.fromSqlite(Map<String, dynamic> map) {
    Log.info('Creating OrderModel from SQLite: ${map[NamaKolom.id]}');
    return OrderModel(
      id: map[NamaKolom.id] as String? ?? '',
      idPelanggan: map[NamaKolom.idPelanggan] as String? ?? '',
      idPaket: map[NamaKolom.idPaket] as String? ?? '',
      tanggal:
          ParserUtil.parseDateTime(map[NamaKolom.tanggal]) ?? DateTime.now(),
      status: _parseStatus(map[NamaKolom.status]),
      diperbaruiPada: ParserUtil.parseDateTime(map[NamaKolom.diperbaruiPada]),
      diHapus: ParserUtil.parseBool(map[NamaKolom.dihapus]),
      diarsipkanPada: ParserUtil.parseDateTime(map[NamaKolom.diarsipkanPada]),
    );
  }

  Map<String, dynamic> toSqlite() {
    return {
      NamaKolom.id: id,
      NamaKolom.idPelanggan: idPelanggan,
      NamaKolom.idPaket: idPaket,
      NamaKolom.tanggal: tanggal.millisecondsSinceEpoch,
      NamaKolom.status: status.name,
      NamaKolom.diperbaruiPada:
          (diperbaruiPada ?? DateTime.now()).millisecondsSinceEpoch,
      NamaKolom.dihapus: diHapus ? 1 : 0,
      NamaKolom.diarsipkanPada: diarsipkanPada?.millisecondsSinceEpoch,
    };
  }

  // ---------- Firebase ----------
  factory OrderModel.fromFirebase(String id, Map<String, dynamic> data) {
    Log.info('Creating OrderModel from Firebase: $id');
    return OrderModel(
      id: id,
      idPelanggan: data[NamaKolom.idPelanggan] as String? ?? '',
      idPaket: data[NamaKolom.idPaket] as String? ?? '',
      tanggal:
          (data[NamaKolom.tanggal] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: _parseStatus(data[NamaKolom.status]),
      diperbaruiPada: (data[NamaKolom.diperbaruiPada] as Timestamp?)?.toDate(),
      diHapus: data[NamaKolom.dihapus] as bool? ?? false,
      diarsipkanPada: (data[NamaKolom.diarsipkanPada] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirebase() {
    return {
      NamaKolom.id: id,
      NamaKolom.idPelanggan: idPelanggan,
      NamaKolom.idPaket: idPaket,
      NamaKolom.tanggal: Timestamp.fromDate(tanggal),
      NamaKolom.status: status.name,
      NamaKolom.diperbaruiPada: Timestamp.fromDate(
        (diperbaruiPada ?? DateTime.now()),
      ),
      NamaKolom.dihapus: diHapus,
      NamaKolom.diarsipkanPada: diarsipkanPada != null
          ? Timestamp.fromDate(diarsipkanPada!)
          : null,
    };
  }

  // Helper enum parser (sama seperti milik Anda)
  static StatusOrderEnum _parseStatus(dynamic name) {
    if (name is! String) return StatusOrderEnum.baru;
    return StatusOrderEnum.values.firstWhere(
      (e) => e.name == name,
      orElse: () => StatusOrderEnum.baru,
    );
  }
}
```

### File: `lib/fitur/order/operasi/order_op_firebase.dart`
```dart
// path: lib/fitur/order/operasi/order_op_firebase.dart

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wifi/fitur/order/model/order_model.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/constant/nama_tabel.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/enum.dart';
import 'package:wifi/shared/operasi/firebase_operasi/base_op_firebase.dart';

class OrderOpFirebase {
  final BaseOpFirebase _baseOp;
  final FirebaseFirestore _firestore;
  final String _koleksiOrder = NamaTabel.pesananPelanggan;

  OrderOpFirebase({
    required FirebaseFirestore firestore,
    required BaseOpFirebase baseOp,
  }) : _firestore = firestore,
       _baseOp = baseOp {
    Log.info('OrderOpFirebase diinisialisasi.');
  }

  /// 1. Menambahkan pesanan baru
  Future<void> tambahOrder(OrderModel order) async {
    Log.info('Menambahkan pesanan baru: ${order.id}');
    await _baseOp.sisipkan(_koleksiOrder, order.id, order.toFirebase());
  }

  /// 2. Memperbarui pesanan yang ada
  Future<void> perbarui(OrderModel order) async {
    Log.info('Memperbarui pesanan: ${order.id}');
    await _baseOp.update(_koleksiOrder, order.id, order.toFirebase());
  }

  /// 3. Menghapus pesanan (soft delete)
  Future<void> softDeleteOrder(String orderId) async {
    Log.info('Menghapus pesanan: $orderId');
    await _baseOp.softDelete(_koleksiOrder, orderId);
  }

  Future<void> softDeleteAll() async {
    Log.info('Melakukan soft delete untuk semua pesanan.');
    try {
      final snapshot = await _firestore
          .collection(_koleksiOrder)
          .where(NamaKolom.dihapus, isEqualTo: false)
          .get();

      if (snapshot.docs.isEmpty) {
        Log.info('Tidak ada pesanan untuk dihapus.');
        return;
      }

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.update(doc.reference, {NamaKolom.dihapus: true});
      }

      await batch.commit();
      Log.info('Berhasil soft delete ${snapshot.docs.length} pesanan.');
    } on Exception catch (e, s) {
      Log.error('Gagal melakukan soft delete semua pesanan.', e: e, s: s);
      rethrow;
    }
  }

  Future<List<OrderModel>> ambilSemua() async {
    Log.info('Mengambil semua data pesanan dari Firebase');
    try {
      final querySnapshot = await _firestore
          .collection(_koleksiOrder)
          .where(NamaKolom.dihapus, isEqualTo: false)
          .orderBy(NamaKolom.diperbaruiPada, descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => OrderModel.fromFirebase(doc.id, doc.data()))
          .toList();
    } on Exception catch (e, st) {
      Log.error('Gagal mengambil semua data pesanan', e: e, s: st);
      return [];
    }
  }

  /// 5. Mendapatkan satu pesanan berdasarkan ID
  Future<OrderModel?> ambilBerdasarkanId(String id) async {
    Log.info('Mendapatkan pesanan by ID: $id');
    try {
      final doc = await _firestore.collection(_koleksiOrder).doc(id).get();
      if (doc.exists) {
        return OrderModel.fromFirebase(doc.id, doc.data()!);
      }
      return null;
    } catch (e, st) {
      Log.error(
        'Error mendapatkan pesanan by ID',
        e: e,
        s: st,
        data: {'orderId': id},
      );
      return null;
    }
  }

  /// Mendapatkan stream pesanan berdasarkan ID pengguna.
  Stream<List<OrderModel>> ambilBerdasarkanIdPelanggan(String idPelanggan) {
    try {
      return _firestore
          .collection(_koleksiOrder)
          .where(NamaKolom.dihapus, isEqualTo: false)
          .where(NamaKolom.idPelanggan, isEqualTo: idPelanggan)
          .snapshots()
          .map(
            (snapshot) => snapshot.docs
                .map((doc) => OrderModel.fromFirebase(doc.id, doc.data()))
                .toList(),
          );
    } catch (e, st) {
      Log.error(
        'Error mendapatkan stream pesanan by User ID',
        e: e,
        s: st,
        data: {'idPelanggan': idPelanggan},
      );
      return Stream.value([]);
    }
  }

  /// 6. Mendapatkan stream pesanan berdasarkan status
  Stream<List<OrderModel>> ambilStreamBerdasarkanStatus(
    StatusOrderEnum status,
  ) {
    return _firestore
        .collection(_koleksiOrder)
        .where(NamaKolom.status, isEqualTo: status.name)
        .where(NamaKolom.dihapus, isEqualTo: false)
        .orderBy(NamaKolom.diperbaruiPada, descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => OrderModel.fromFirebase(doc.id, doc.data()))
              .toList(),
        )
        .handleError((Object e, StackTrace st) {
          Log.error(
            'Error mendapatkan stream pesanan berdasarkan status',
            e: e,
            s: st,
            data: {'status': status.name},
          );
          return <OrderModel>[];
        });
  }

  /// 7. Mendapatkan list pesanan berdasarkan status (satu kali panggil)
  Future<List<OrderModel>> getOrdersByStatus(StatusOrderEnum status) async {
    Log.info('Mendapatkan pesanan sekali panggil by status: ${status.name}');
    try {
      final snapshot = await _firestore
          .collection(_koleksiOrder)
          .where(NamaKolom.status, isEqualTo: status.name)
          .where(NamaKolom.dihapus, isEqualTo: false)
          .orderBy(NamaKolom.diperbaruiPada, descending: true)
          .get();
      return snapshot.docs
          .map((doc) => OrderModel.fromFirebase(doc.id, doc.data()))
          .toList();
    } catch (e, st) {
      Log.error(
        'Error mendapatkan list pesanan by status',
        e: e,
        s: st,
        data: {'status': status.name},
      );
      return [];
    }
  }

  /// 8. Menghitung jumlah pesanan berdasarkan status untuk pengguna tertentu
  Future<int> countOrdersByStatus(StatusOrderEnum status, String userId) async {
    Log.info(
      'Menghitung pesanan by status: ${status.name} untuk user: $userId',
    );
    try {
      Query query = _firestore
          .collection(_koleksiOrder)
          .where(NamaKolom.status, isEqualTo: status.name)
          .where(NamaKolom.dihapus, isEqualTo: false);

      // Jika userId disediakan (bukan admin), filter berdasarkan customerId
      if (userId.isNotEmpty) {
        query = query.where(NamaKolom.idPelanggan, isEqualTo: userId);
      }

      final snapshot = await query.count().get();
      final count = snapshot.count ?? 0;
      Log.info(
        'Berhasil menghitung $count pesanan dengan status ${status.name}',
        {'status': status.name, 'userId': userId, 'jumlah': count},
      );
      return count;
    } catch (e, st) {
      Log.error(
        'Error menghitung pesanan by status',
        e: e,
        s: st,
        data: {'status': status.name, 'userId': userId},
      );
      return 0;
    }
  }
}
```

### File: `lib/fitur/order/operasi/order_op_global.dart`
```dart
// path lib/fitur/order/operasi/order_op_global.dart

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/app_role/role_util.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/order/model/order_model.dart';
import 'package:wifi/fitur/order/operasi/order_op_firebase.dart';
import 'package:wifi/fitur/order/operasi/order_op_sqlite.dart';
import 'package:wifi/fitur/order/provider/order_provider.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/operasi/firebase_operasi/firebase_operation_provider/firebase_operation_provider.dart';

class OrderOpGlobal {
  final Ref ref;

  OrderOpGlobal({required this.ref});

  OrderOpSqlite get _orderOpSqlite => ref.read(orderOpSqliteProvider);
  OrderOpFirebase get _orderOpFirebase => ref.read(orderOpFirebaseProvider);

  Future<void> tambah(OrderModel order) async {
    try {
      if (RoleUtil.isAdmin(ref)) {
        await _orderOpSqlite.tambahOrder(order);
      } else {
        await _orderOpFirebase.tambahOrder(order);
      }
    } on Exception catch (e, s) {
      Log.error('Error ditambah: $e', e: e, s: s);
      // Error handling opsional
      rethrow;
    }
  }

  Future<void> perbarui(OrderModel order) async {
    try {
      if (RoleUtil.isAdmin(ref)) {
        await _orderOpSqlite.perbarui(order);
      } else {
        await _orderOpFirebase.perbarui(order);
      }
    } on Exception catch (e, s) {
      Log.error('Error diperbarui: $e', e: e, s: s);
      // Error handling opsional
      rethrow;
    }
  }

  Future<void> softDelete(String id) async {
    try {
      if (RoleUtil.isAdmin(ref)) {
        await _orderOpSqlite.softDeleteorder(id);
      } else {
        await _orderOpFirebase.softDeleteOrder(id);
      }
    } on Exception catch (e, s) {
      Log.error('Error di softDelete: $e', e: e, s: s);
      // Error handling opsional
      rethrow;
    }
  }

  Future<void> softDeleteAll() async {
    try {
      if (RoleUtil.isAdmin(ref)) {
        await _orderOpSqlite.softDeleteAll();
      } else {
        await _orderOpFirebase.softDeleteAll();
      }
      ref.invalidate(orderProvider);
    } on Exception catch (e, s) {
      Log.error('Error di softDeleteAll: $e', e: e, s: s);
      rethrow;
    }
  }

  Future<List<OrderModel>> ambilSemua() async {
    try {
      Log.info('fungsi ambil semua dijalankan');
      if (RoleUtil.isAdmin(ref)) {
        return await _orderOpSqlite.ambilSemua();
      } else {
        return await _orderOpFirebase.ambilSemua();
      }
    } on Exception catch (e, s) {
      Log.error('Error diambilSemua: $e', e: e, s: s);
      rethrow;
    }
  }
}

final orderOpGlobalProvider = Provider<OrderOpGlobal>((ref) {
  return OrderOpGlobal(ref: ref);
});
```

### File: `lib/fitur/order/operasi/order_op_sqlite.dart`
```dart
// path: lib/fitur/order/operasi/order_op_sqlite.dart

import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/fitur/order/model/order_model.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/constant/nama_tabel.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/enum.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/base_op_sqlite.dart';

class OrderOpSqlite {
  final SqliteDatabase sqliteDb;
  final BaseOpSqlite baseOpSqlite;
  OrderOpSqlite({required this.sqliteDb, required this.baseOpSqlite});

  String get _namaTabel => NamaTabel.pesananPelanggan;
  DateTime? get _nowUtc => DateTime.now().toUtc();

  Future<void> tambahOrder(
    final OrderModel order, {
    final bool dariServer = false,
  }) async {
    Log.info('Menyimpan pesanan baru ID: ${order.id}');
    try {
      final dataOrderBaru = order.copyWith(diperbaruiPada: _nowUtc);
      await baseOpSqlite.sisipkan(
        _namaTabel,
        dataOrderBaru.toSqlite(),
        dariServer: dariServer,
      );
      Log.info('Berhasil menyimpan pesanan ID: ${order.id}');
    } on Exception catch (e, s) {
      Log.error('Gagal menyimpan pesanan.', e: e, s: s);
      rethrow;
    }
  }

  Future<void> perbarui(OrderModel order, {bool dariServer = false}) async {
    try {
      final dataBaru = order.copyWith(diperbaruiPada: _nowUtc);
      await baseOpSqlite.update(
        _namaTabel,
        dataBaru.toSqlite(),
        order.id,
        dariServer: dariServer,
      );
      Log.info(
        'Status pesanan ID: $order berhasil diperbarui beserta timestamp-nya.',
      );
    } on Exception catch (e, s) {
      Log.error('Gagal memperbarui status pesanan.', e: e, s: s);
      rethrow;
    }
  }

  Future<int> ambilTotalDataPerStatus(StatusOrderEnum status) async {
    Log.info('Menghitung pesanan dengan status: ${status.name}');
    try {
      final db = await sqliteDb.database;
      final result = await db.rawQuery(
        'SELECT COUNT(*) FROM $_namaTabel WHERE ${NamaKolom.status} = ? AND ${NamaKolom.dihapus} = 0',
        [status.name],
      );
      final count = result.first.values.first as int? ?? 0;
      Log.info(
        'Berhasil menghitung $count data pesanan aktif berstatus ${status.name}.',
      );
      return count;
    } on Exception catch (e, s) {
      Log.error('Gagal menghitung pesanan berdasarkan status.', e: e, s: s);
      rethrow;
    }
  }

  Future<List<OrderModel>> ambilSemua({
    bool tampilkanYangDiarsip = false,
  }) async {
    Log.info('Mengambil semua pesanan dari database.');
    try {
      final db = await sqliteDb.database;
      final query = tampilkanYangDiarsip ? null : '${NamaKolom.dihapus} = 0';
      final List<Map<String, dynamic>> maps = await db.query(
        _namaTabel,
        where: query,
        orderBy: '${NamaKolom.tanggal} DESC',
      );
      Log.info('Berhasil mengambil ${maps.length} data pesanan.');

      return maps.map(OrderModel.fromSqlite).toList();
    } catch (e, s) {
      Log.error('Gagal mengambil semua pesanan.', e: e, s: s);
      rethrow;
    }
  }

  Stream<List<OrderModel>> ambilStreamSemuaOrderAktif() async* {
    Log.info('Mengambil semua pesanan aktif dari database (stream sekali).');
    try {
      final db = await sqliteDb.database;
      final List<Map<String, dynamic>> maps = await db.query(
        _namaTabel,
        where: '${NamaKolom.dihapus} = 0',
        orderBy: '${NamaKolom.tanggal} DESC',
      );
      Log.info('Berhasil mengambil ${maps.length} data pesanan aktif.');
      yield maps.map(OrderModel.fromSqlite).toList();
    } on Exception catch (e, s) {
      Log.error('Gagal mengambil semua pesanan aktif.', e: e, s: s);
      rethrow;
    }
  }

  Future<List<OrderModel>> ambilOrderBerdasarkanStatus(
    StatusOrderEnum status,
  ) async {
    Log.info('Mengambil pesanan dengan status: ${status.name}');
    try {
      final db = await sqliteDb.database;
      final List<Map<String, dynamic>> maps = await db.query(
        _namaTabel,
        where: '${NamaKolom.status} = ? AND ${NamaKolom.dihapus} = 0',
        whereArgs: [status.name],
        orderBy: '${NamaKolom.tanggal} DESC',
      );
      Log.info(
        'Berhasil mengambil ${maps.length} data pesanan aktif berstatus ${status.name}.',
      );
      return maps.map(OrderModel.fromSqlite).toList();
    } on Exception catch (e, s) {
      Log.error('Gagal mengambil pesanan berdasarkan status.', e: e, s: s);
      rethrow;
    }
  }

  Future<void> softDeleteorder(
    final String id, {
    final bool dariServer = false,
  }) async {
    Log.info('Memulai soft delete untuk pesanan ID: $id');
    try {
      await baseOpSqlite.softDelete(_namaTabel, id, dariServer: dariServer);
      Log.info('Berhasil soft delete pesanan ID: $id.');
    } on Exception catch (e, st) {
      Log.error('Gagal saat soft delete pesanan ID: $id', e: e, s: st);
      rethrow;
    }
  }

  Future<int> softDeleteAll({final bool fromServer = false}) async {
    Log.info('Memulai soft delete untuk semua pesanan');
    try {
      final count = await baseOpSqlite.softDeleteAll(
        _namaTabel,
        dariServer: fromServer,
      );
      Log.info('Berhasil soft delete semua pesanan. Total: $count item.');
      return count;
    } on Exception catch (e, st) {
      Log.error('Gagal saat soft delete semua pesanan', e: e, s: st);
      rethrow;
    }
  }

  Future<void> sisipkanAtauPerbaruiBatch(
    final List<OrderModel> items, {
    final bool dariServer = false,
  }) async {
    Log.info('Memulai batch insert/update untuk ${items.length} pesanan.');
    if (items.isEmpty) {
      Log.warning('List item kosong, menghentikan batch pesanan.');
      return;
    }
    try {
      final data = items
          .map(
            (item) => item
                .copyWith(diperbaruiPada: DateTime.now().toUtc())
                .toSqlite(),
          )
          .toList();
      await baseOpSqlite.sisipkanAtauPerbaruiBatch(
        _namaTabel,
        data,
        dariServer: dariServer,
      );
      Log.info('Batch pesanan selesai diproses.');
    } on Exception catch (e, s) {
      Log.error('Gagal menjalankan operasi batch pesanan.', e: e, s: s);
      rethrow;
    }
  }

  Future<List<OrderModel>> ambilOrderBerdasarkanIds(
    final List<String> ids,
  ) async {
    Log.info('Mengambil pesanan untuk ${ids.length} ID.');
    if (ids.isEmpty) {
      Log.warning('List ID kosong, mengembalikan list kosong.');
      return [];
    }
    try {
      final db = await sqliteDb.database;
      final List<Map<String, dynamic>> maps = await db.query(
        _namaTabel,
        where:
            '${NamaKolom.id} IN (${List.filled(ids.length, '?').join(',')}) AND ${NamaKolom.dihapus} = 0',
        whereArgs: ids,
      );
      Log.info(
        'Berhasil mengambil ${maps.length} data pesanan berdasarkan daftar ID.',
      );
      return List.generate(maps.length, (final i) {
        return OrderModel.fromSqlite(maps[i]);
      });
    } on Exception catch (e, s) {
      Log.error(
        'Gagal mengambil data pesanan berdasarkan daftar ID.',
        e: e,
        s: s,
      );
      rethrow;
    }
  }
}
```

### File: `lib/fitur/order/page/order_page.dart`
```dart
// path: lib/fitur/order/page/order_page.dart

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/app_role/role_util.dart';
import 'package:wifi/fitur/order/model/order_model.dart';
import 'package:wifi/fitur/order/operasi/order_op_global.dart';
import 'package:wifi/fitur/order/provider/order_provider.dart';
import 'package:wifi/shared/common/teks.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/enum.dart';
import 'package:wifi/shared/export/theme.dart';
import 'package:wifi/shared/utils/toast_util.dart';
import 'package:wifi/shared/widget/nama_paket_widget.dart';

class OrderPage extends ConsumerStatefulWidget {
  const OrderPage({super.key});

  @override
  ConsumerState<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends ConsumerState<OrderPage> {
  String _filterAktif = StatusOrderEnum.baru.name;
  bool _sedangMenghapus = false;

  @override
  void initState() {
    super.initState();
    Log.info('OrderPage initState dipanggil');
  }

  @override
  void dispose() {
    Log.info('OrderPage dispose dipanggil');
    super.dispose();
  }

  /// ✅ PERBAIKAN 1: Fungsi konfirmasi sekarang pakai await dengan benar
  Future<bool?> _konfirmasiOpsi(BuildContext context) async {
    Log.info('_konfirmasiOpsi dipanggil');
    return await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Konfirmasi'),
          content: const Text('Apakah Anda yakin ingin melanjutkan?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Log.info('_konfirmasiOpsi: pengguna memilih Batal');
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                Log.info('_konfirmasiOpsi: pengguna memilih Iya');
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text('Iya'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _softDeleteAll() async {
    if (_sedangMenghapus) return;

    // ✅ 1. Tampilkan dialog konfirmasi
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus Semua'),
          content: const Text(
            'Apakah Anda yakin ingin menghapus SEMUA pesanan? '
            'Tindakan ini tidak dapat dibatalkan.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Hapus Semua'),
            ),
          ],
        );
      },
    );

    if (konfirmasi != true) {
      Log.info('Penghapusan semua pesanan dibatalkan oleh pengguna');
      return;
    }

    // Baca provider sebelum masuk ke bagian async
    final orderOp = ref.read(orderOpGlobalProvider);

    if (!mounted) return;

    // ✅ 2. Tampilkan loading
    setState(() {
      _sedangMenghapus = true;
    });

    try {
      Log.info('Memulai proses penghapusan semua pesanan');

      // ✅ 3. Tampilkan dialog loading
      unawaited(
        showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (context) => const AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Menghapus semua pesanan...'),
              ],
            ),
          ),
        ),
      );

      // ✅ 4. Eksekusi penghapusan
      await orderOp.softDeleteAll();

      if (!mounted) return;

      // ✅ 6. Tutup loading dialog dan tampilkan sukses
      Navigator.pop(context); // Tutup loading dialog
      ToastUtil.success(context, 'Semua pesanan berhasil dihapus');
    } on Exception catch (e, s) {
      Log.error('Gagal menghapus semua pesanan', e: e, s: s);

      if (!mounted) return;

      // ✅ 7. Tutup loading dialog dan tampilkan error
      Navigator.pop(context); // Tutup loading dialog
      ToastUtil.error(context, 'Gagal menghapus semua pesanan: $e');
    } finally {
      if (mounted) {
        setState(() {
          _sedangMenghapus = false;
        });
      }
    }
  }

  /// ✅ PERBAIKAN 2: Fungsi ubah status sekarang pakai await dengan benar
  Future<void> _ubahStatus(
    BuildContext context,
    OrderModel order,
    WidgetRef ref,
  ) async {
    Log.info('_ubahStatus dipanggil untuk orderId: ${order.id}');
    try {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) {
          return Dialog(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _tombolOpsiUbahStatus(
                    pageContext: context,
                    dialogContext: dialogContext,
                    label: StatusOrderEnum.selesai.displayName,
                    order: order,
                    status: StatusOrderEnum.selesai,
                  ),
                  _tombolOpsiUbahStatus(
                    pageContext: context,
                    dialogContext: dialogContext,
                    label: StatusOrderEnum.baru.displayName,
                    order: order,
                    status: StatusOrderEnum.baru,
                  ),
                  _tombolOpsiUbahStatus(
                    pageContext: context,
                    dialogContext: dialogContext,
                    label: StatusOrderEnum.diproses.displayName,
                    order: order,
                    status: StatusOrderEnum.diproses,
                  ),
                  _tombolOpsiUbahStatus(
                    pageContext: context,
                    dialogContext: dialogContext,
                    label: StatusOrderEnum.ditolak.displayName,
                    order: order,
                    status: StatusOrderEnum.ditolak,
                  ),
                ],
              ),
            ),
          );
        },
      );
    } on Exception catch (e, st) {
      Log.error('Gagal menampilkan dialog ubah status', e: e, s: st);
      if (context.mounted) {
        ToastUtil.error(context, 'Gagal membuka dialog ubah status');
      }
    }
  }

  Future<bool?> _showDialog(BuildContext context, OrderModel order) async {
    try {
      return await showDialog<bool>(
        context: context,
        builder: (dialogContext) {
          return Dialog(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (ref.isAdmin)
                    TextButton(
                      onPressed: () {
                        Log.info(
                          '_showDialog: admin memilih Ubah Status untuk orderId: ${order.id}',
                        );
                        Navigator.of(dialogContext).pop();
                        try {
                          _ubahStatus(context, order, ref);
                        } on Exception catch (e, st) {
                          Log.error('Gagal memanggil _ubahStatus', e: e, s: st);
                        }
                      },
                      child: const Text('Ubah Status'),
                    ),
                  TextButton(
                    child: const Text('Hapus'),
                    onPressed: () async {
                      Log.info(
                        '_showDialog: pengguna memilih Hapus untuk orderId: ${order.id}',
                      );
                      Navigator.of(dialogContext).pop();
                      final dikonfirmasi = await _konfirmasiOpsi(context);
                      if (context.mounted) {
                        if (dikonfirmasi == true) {
                          Log.info(
                            '_showDialog: konfirmasi hapus disetujui untuk orderId: ${order.id}',
                          );
                          try {
                            await ref
                                .read(orderOpGlobalProvider)
                                .softDelete(order.id);
                            Log.info(
                              '_showDialog: order berhasil dihapus orderId: ${order.id}',
                            );
                            ref.invalidate(orderProvider);

                            if (dialogContext.mounted) {
                              ToastUtil.success(
                                context,
                                'Data berhasil dihapus',
                              );
                            }
                          } on Exception catch (e, st) {
                            Log.error(
                              '_showDialog: gagal menghapus order',
                              e: e,
                              s: st,
                            );
                            if (dialogContext.mounted) {
                              ToastUtil.error(
                                context,
                                'Gagal menghapus pesanan',
                              );
                            }
                          }
                        } else {
                          Log.info(
                            '_showDialog: konfirmasi hapus dibatalkan untuk orderId: ${order.id}',
                          );
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        },
      );
    } on Exception catch (e, st) {
      Log.error('Gagal menampilkan dialog opsi', e: e, s: st);
      if (context.mounted) {
        ToastUtil.error(context, 'Gagal membuka opsi');
      }
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    Log.info('OrderPage build dipanggil, filterAktif: $_filterAktif');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pesanan Saya'),
        actions: [
          if (kDebugMode)
            IconButton(
              onPressed: _softDeleteAll,
              icon: const Icon(TIcons.delete),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _daftarTombolFilter(),
            Expanded(child: _daftarPesanan()),
          ],
        ),
      ),
    );
  }

  Widget _daftarTombolFilter() {
    Log.info('_listTombolFilter dipanggil');
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Wrap(
          spacing: 12.0,
          children: [
            _tombolTipe(
              StatusOrderEnum.baru,
              sedangAktif: _filterAktif == StatusOrderEnum.baru.name,
            ),
            _tombolTipe(
              StatusOrderEnum.diproses,
              sedangAktif: _filterAktif == StatusOrderEnum.diproses.name,
            ),
            _tombolTipe(
              StatusOrderEnum.selesai,
              sedangAktif: _filterAktif == StatusOrderEnum.selesai.name,
            ),
            _tombolTipe(
              StatusOrderEnum.ditolak,
              sedangAktif: _filterAktif == StatusOrderEnum.ditolak.name,
            ),
          ],
        ),
      ),
    );
  }

  Widget _tombolTipe(StatusOrderEnum status, {required bool sedangAktif}) {
    final orderAsync = ref.watch(orderProvider);
    final label = status.displayName;

    Log.info(
      '_tombolTipe dipanggil untuk status: ${status.name}, sedangAktif: $sedangAktif',
    );

    return InkWell(
      onTap: () {
        if (!sedangAktif) {
          Log.info(
            '_tombolTipe: mengubah filter dari $_filterAktif menjadi ${status.name}',
          );
          setState(() {
            _filterAktif = status.name;
            Log.info(
              '_tombolTipe: filter berhasil diubah menjadi $_filterAktif',
            );
          });
        } else {
          Log.info('_tombolTipe: filter ${status.name} sudah aktif');
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: sedangAktif
              ? Theme.of(context).primaryColor
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: sedangAktif
                ? Theme.of(context).primaryColor
                : Colors.grey.shade400,
          ),
        ),
        child: Wrap(
          spacing: 6.0,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            orderAsync.when(
              skipLoadingOnReload: true,
              loading: () => const CircularProgressIndicator(),
              error: (e, s) {
                Log.error(
                  '_tombolTipe: error loading data untuk status ${status.name}',
                  e: e,
                  s: s,
                );
                return Text('Error: $e $s');
              },
              data: (orderState) {
                final jumlah = orderState.daftarOrder
                    .where((o) => o.status == status)
                    .length;
                Log.info(
                  '_tombolTipe: jumlah order untuk status ${status.name}: $jumlah',
                );
                if (jumlah == 0) return const SizedBox.shrink();
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: sedangAktif
                        ? Theme.of(context).colorScheme.onPrimary
                        : Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TeksIsiKecil(
                    jumlah > 99 ? '99+' : jumlah.toString(),
                    warna: sedangAktif
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onPrimary,
                  ),
                );
              },
            ),
            TeksIsiBesar(
              label,
              warna: sedangAktif
                  ? Colors.white
                  : (Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black),
              tebalFont: FontWeight.bold,
            ),
          ],
        ),
      ),
    );
  }

  Widget _daftarPesanan() {
    final orderAsync = ref.watch(orderProvider);
    Log.info('_daftarPesanan dipanggil, filterAktif: $_filterAktif');
    return orderAsync.when(
      skipLoadingOnReload: true,
      loading: () {
        Log.info('_daftarPesanan: loading data');
        return const Center(child: CircularProgressIndicator());
      },
      error: (err, stack) {
        Log.error('_daftarPesanan: error loading data', e: err, s: stack);
        return Center(child: Text('Terjadi kesalahan: $err'));
      },
      data: (orderState) {
        final semuaOrder = orderState.daftarOrder;
        Log.info('_daftarPesanan: total semua order: ${semuaOrder.length}');
        final orderDifilter = semuaOrder.where((order) {
          if (_filterAktif == StatusOrderEnum.selesai.name) {
            return order.status == StatusOrderEnum.selesai;
          }
          if (_filterAktif == StatusOrderEnum.diproses.name) {
            return order.status == StatusOrderEnum.diproses;
          }
          if (_filterAktif == StatusOrderEnum.baru.name) {
            return order.status == StatusOrderEnum.baru;
          }
          if (_filterAktif == StatusOrderEnum.ditolak.name) {
            return order.status == StatusOrderEnum.ditolak;
          }
          return true;
        }).toList();

        Log.info(
          '_daftarPesanan: total order setelah filter: ${orderDifilter.length}',
        );

        if (orderDifilter.isEmpty) {
          Log.info(
            '_daftarPesanan: tidak ada order dengan filter $_filterAktif',
          );
          return const Center(child: Text('Belum ada pesanan ditemukan.'));
        }

        return ListView.builder(
          itemCount: orderDifilter.length,
          itemBuilder: (context, index) {
            final order = orderDifilter[index];
            Log.info(
              '_daftarPesanan: membangun item ke-$index dengan orderId: ${order.id}',
            );
            return ListTile(
              key: ValueKey(order.id),
              onLongPress: () {
                Log.info(
                  '_daftarPesanan: long press pada orderId: ${order.id}',
                );
                try {
                  _showDialog(context, order);
                } on Exception catch (e, st) {
                  Log.error('Gagal memanggil _showDialog', e: e, s: st);
                  if (context.mounted) {
                    ToastUtil.error(context, 'Gagal membuka opsi');
                  }
                }
              },
              title: Row(
                children: [
                  const Text('Paket: '),
                  NamaPaketWidget(idPaket: order.idPaket),
                ],
              ),
              subtitle: Text('Status: ${order.status.displayName}'),
            );
          },
        );
      },
    );
  }

  Widget _tombolOpsiUbahStatus({
    required String label,
    required OrderModel order,
    required BuildContext dialogContext,
    required BuildContext pageContext,
    required StatusOrderEnum status,
  }) {
    return TextButton(
      onPressed: () async {
        Log.info(
          '_tombolOpsiUbahStatus: tombol $label ditekan untuk orderId: ${order.id}',
        );
        Navigator.of(dialogContext).pop();
        final dikonfirmasi = await _konfirmasiOpsi(pageContext);
        if (dikonfirmasi == true) {
          try {
            final updatedOrder = order.copyWith(status: status);
            await ref.read(orderOpGlobalProvider).perbarui(updatedOrder);
            Log.info(
              '_tombolOpsiUbahStatus: status berhasil diubah untuk orderId: ${order.id}',
            );
            ref.invalidate(orderProvider);
            Log.info('_tombolOpsiUbahStatus: orderProvider di-invalidate');

            if (pageContext.mounted) {
              ToastUtil.success(pageContext, 'Data berhasil diperbarui');
            }
          } on Exception catch (e, st) {
            Log.error(
              '_tombolOpsiUbahStatus: gagal mengubah status orderId: ${order.id}',
              e: e,
              s: st,
            );
            if (pageContext.mounted) {
              ToastUtil.error(
                pageContext,
                'Terjadi kesalahan saat memperbarui status pesanan.',
              );
            }
          }
        } else {
          Log.info(
            '_tombolOpsiUbahStatus: konfirmasi dibatalkan untuk orderId: ${order.id}',
          );
        }
      },
      child: TeksIsiSedang(label),
    );
  }
}
```

### File: `lib/fitur/order/provider/order_provider.dart`
```dart
// path: lib/fitur/order/provider/order_provider.dart

import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wifi/fitur/order/model/order_model.dart';
import 'package:wifi/fitur/order/operasi/order_op_global.dart';
import 'package:wifi/shared/debug/log.dart';

part 'order_provider.g.dart';
part 'order_provider.freezed.dart';

@freezed
abstract class OrderState with _$OrderState {
  const factory OrderState({
    @Default([]) List<OrderModel> daftarOrder,
    @Default(0) int totalDaftar,
  }) = _OrderState;
}

@riverpod
class Order extends _$Order {
  OrderOpGlobal get _orderOp => ref.read(orderOpGlobalProvider);

  @override
  FutureOr<OrderState> build() async {
    Log.info('build orderProvider');
    final daftarOrder = await _orderOp.ambilSemua();
    Log.info('Mengambil data dari database');
    return OrderState(
      daftarOrder: daftarOrder,
      totalDaftar: daftarOrder.length,
    );
  }

  Future<OrderState> _loadData() async {
    try {
      Log.info('Fungsi _loadData di jalankan');
      final daftarOrder = await _orderOp.ambilSemua();
      Log.info('Mengambil data dari database');
      return OrderState(
        daftarOrder: daftarOrder,
        totalDaftar: daftarOrder.length,
      );
    } on Exception catch (e, s) {
      Log.error('Error di _loadData: $e', e: e, s: s);
      rethrow;
    }
  }

  Future<void> tambah(OrderModel order) async {
    try {
      await _orderOp.tambah(order);
      await refresh();
    } on Exception catch (e, s) {
      Log.error('Error ditambah: $e', e: e, s: s);
      await refresh();
      rethrow;
    }
  }

  Future<List<OrderModel>> ambilBerdasarkanIdPelanggan(String id) async {
    try {
      var daftarBaru = <OrderModel>[];
      final daftar = state.asData?.value.daftarOrder;
      if (daftar != null) {
        daftarBaru = daftar.where((o) => o.idPelanggan == id).toList();
      }
      return daftarBaru;
    } on Exception catch (e, s) {
      Log.error('Error diambilBerdasarkanIdPelanggan: $e', e: e, s: s);
      return [];
    }
  }

  Future<void> refresh() async {
    try {
      state = await AsyncValue.guard(_loadData);
    } on Exception catch (e, s) {
      Log.error('Error direfresh: $e', e: e, s: s);
      rethrow;
    }
  }

  void invalidate() {
    ref.invalidateSelf();
  }
}
```

