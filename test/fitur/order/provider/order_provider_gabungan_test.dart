// path: test/fitur/order/provider/order_provider_gabungan_test.dart
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/order/model/order_model.dart';
import 'package:wifi/fitur/order/operasi/order_op_firebase.dart';
import 'package:wifi/fitur/order/provider/order_provider_gabungan.dart';
import 'package:wifi/shared/enum/app_role_enum.dart';
import 'package:wifi/shared/operasi/firebase_operasi/firebase_operation_provider/firebase_operation_provider.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/order_op_sqlite.dart';
import 'package:wifi/shared/providers/shared_providers.dart';
import 'package:wifi/user/providers/user_providers.dart';

class MockOrderOpSqlite extends Mock implements OrderOpSqlite {}

class MockOrderOpFirebase extends Mock implements OrderOpFirebase {}

void main() {
  late MockOrderOpSqlite mockOrderOpSqlite;
  late MockOrderOpFirebase mockOrderOpFirebase;
  late ProviderContainer container;

  final tOrder1 = OrderModel(
    id: '1',
    userId: 'user1',
    name: 'Order 1',
    tanggal: DateTime.now(),
    total: 100,
  );
  final tOrder2 = OrderModel(
    id: '2',
    userId: 'user1',
    name: 'Order 2',
    tanggal: DateTime.now(),
    total: 200,
  );

  group('Order Provider (Admin)', () {
    setUp(() {
      mockOrderOpSqlite = MockOrderOpSqlite();
      container = ProviderContainer(
        overrides: [
          appRoleProvider.overrideWithValue(AppRole.admin),
          orderOperationProvider.overrideWithValue(mockOrderOpSqlite),
        ],
      );
    });

    test('01. harus memuat pesanan untuk admin', () async {
      when(() => mockOrderOpSqlite.ambilSemuaOrder())
          .thenAnswer((_) async => [tOrder1, tOrder2]);

      final state = await container.read(orderProvider.future);

      expect(state.orders, [tOrder1, tOrder2]);
      expect(state.totalDaftar, 2);
      verify(() => mockOrderOpSqlite.ambilSemuaOrder()).called(1);
    });
  });

  group('Order Provider (User)', () {
    setUp(() {
      mockOrderOpFirebase = MockOrderOpFirebase();
      container = ProviderContainer(
        overrides: [
          appRoleProvider.overrideWithValue(AppRole.user),
          userIdProvider.overrideWith((ref) => 'user1'),
          orderOpFirebaseProvider.overrideWithValue(mockOrderOpFirebase),
        ],
      );
    });

    test('02. harus memuat pesanan untuk pengguna', () async {
      when(() => mockOrderOpFirebase.getAllByUserId('user1'))
          .thenAnswer((_) => Stream.value([tOrder1, tOrder2]));

      final state = await container.read(orderProvider.future);

      expect(state.orders, [tOrder1, tOrder2]);
      expect(state.totalDaftar, 2);
      verify(() => mockOrderOpFirebase.getAllByUserId('user1')).called(1);
    });
  });
}
