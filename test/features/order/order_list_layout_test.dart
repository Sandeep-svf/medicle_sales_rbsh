import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';
import 'package:medicle_sales_rbsh/features/order/database/order_database.dart';
import 'package:medicle_sales_rbsh/features/order/models/order_models.dart';
import 'package:medicle_sales_rbsh/features/order/repositories/order_repository.dart';
import 'package:medicle_sales_rbsh/features/order/screens/order.dart';
import 'package:medicle_sales_rbsh/features/order/services/order_sync_service.dart';

class _Database implements Database {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Repository extends OrderRepository {
  _Repository() : super(database: OrderDatabase.fromDatabase(_Database()));
  @override
  Future<List<LocalOrder>> recentOrders({required DateTime cutoff}) async => [
        for (var i = 0; i < 4; i++)
          LocalOrder(
            localId: '$i',
            clientGeneratedId: 'order-000$i',
            doctorName: 'Doctor $i',
            clinicName: 'City Medical Clinic',
            area: 'Central',
            orderDate: DateTime(2026, 9, 21),
            createdAt: DateTime(2026, 9, 21),
            updatedAt: DateTime(2026, 9, 21),
            syncState: OrderSyncState.pending,
            priority: i == 0 ? 'Urgent' : 'Normal',
            attachmentName: 'order.pdf',
            attachmentMime: 'application/pdf',
            attachmentPath: '/unused.pdf',
            items: const [
              LocalOrderItem(
                  productId: 'p',
                  productName: 'Example medicine',
                  quantity: 12,
                  unit: 'Boxes',
                  freeSample: false)
            ],
          ),
      ];
}

void main() {
  for (final config in [
    (size: const Size(360, 800), scale: 1.0, columns: 1),
    (size: const Size(900, 500), scale: 1.0, columns: 2),
    (size: const Size(900, 600), scale: 2.0, columns: 1),
  ]) {
    testWidgets(
        'order list adapts to ${config.size} at text scale ${config.scale}',
        (tester) async {
      tester.view.physicalSize = config.size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final repository = _Repository();
      final sync = OrderSyncService(
          repository: repository,
          remote: HttpOrderRemoteDataSource(endpoint: ''));
      addTearDown(sync.dispose);
      await tester.pumpWidget(MaterialApp(
        builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(config.scale),
                disableAnimations: true),
            child: child!),
        home: OrderScreen(
            repository: repository, products: const [], syncService: sync),
      ));
      await tester.pumpAndSettle();
      expect(find.text('Care in every order.'), findsOneWidget);
      final firstCard = find.byWidgetPredicate(
          (widget) => widget is OrderListCard && widget.order.localId == '0');
      await tester.scrollUntilVisible(firstCard, 180,
          scrollable: find.byType(Scrollable).first);
      await tester.pumpAndSettle();
      final width = tester.getSize(firstCard).width;
      expect(
          width,
          config.columns == 2
              ? lessThan(450)
              : greaterThan(config.size.width - 80));
      expect(tester.takeException(), isNull);
    });
  }
}
