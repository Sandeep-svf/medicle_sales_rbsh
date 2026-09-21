import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';
import 'package:medicle_sales_rbsh/features/order/database/order_database.dart';
import 'package:medicle_sales_rbsh/features/order/models/order_models.dart';
import 'package:medicle_sales_rbsh/features/order/repositories/order_repository.dart';
import 'package:medicle_sales_rbsh/features/order/screens/order_create.dart';
import 'package:medicle_sales_rbsh/features/order/services/order_sync_service.dart';
import 'package:medicle_sales_rbsh/features/order/widgets/order_doctor_picker.dart';
import 'package:medicle_sales_rbsh/features/order/widgets/order_product_picker.dart';
import 'package:medicle_sales_rbsh/features/product/model/ProductModel.dart';
import '../doctor_offline/doctor_test_fixtures.dart';

class _UnusedDatabase implements Database {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw StateError('Unexpected storage access: ${invocation.memberName}');
}

class _RecordingRepository extends OrderRepository {
  _RecordingRepository()
      : super(database: OrderDatabase.fromDatabase(_UnusedDatabase()));
  OrderDraft? saved;
  @override
  Future<String> create(OrderDraft draft) async {
    saved = draft;
    return 'saved-order';
  }

  @override
  Future<LocalOrder?> findById(String id) async => null;
}

void main() {
  test(
      'missing order API preserves queue without touching storage or connectivity',
      () async {
    final service = OrderSyncService(
      repository: OrderRepository(
          database: OrderDatabase.fromDatabase(_UnusedDatabase())),
      remote: HttpOrderRemoteDataSource(endpoint: ''),
      isOnline: () async => throw StateError('Connectivity must not be needed'),
    );
    addTearDown(service.dispose);
    final result = await service.syncPending();
    expect(result.unavailable, isTrue);
    expect(result.sent, 0);
    expect(result.failed, 0);
  });

  testWidgets(
      'doctor search combines specialty and address without displaying IDs',
      (tester) async {
    final doctor = fixtureDoctor(name: 'Dr. Meera').copyWith(
        specialization: 'Cardiology',
        clinicAddress: '22 Park Road',
        phone: '9800000000');
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: OrderDoctorPicker(doctors: [doctor]))));
    await tester.enterText(find.byType(TextField), 'park cardiology');
    await tester.pump();
    expect(find.text('Dr. Meera'), findsOneWidget);
    expect(find.text(doctor.localId), findsNothing);
    await tester.enterText(find.byType(TextField), 'no match');
    await tester.pump();
    expect(find.text('Dr. Meera'), findsNothing);
    expect(find.textContaining('No matching doctors'), findsOneWidget);
  });

  for (final width in [360.0, 800.0]) {
    testWidgets('doctor selection autofills order fields at $width width',
        (tester) async {
      tester.view.physicalSize = Size(width, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final doctor = fixtureDoctor(name: 'Dr. Meera').copyWith(
          clinicName: 'Park Clinic',
          clinicAddress: '22 Park Road',
          phone: '9800000000',
          areaName: 'Central',
          headOfficeName: 'Delhi');
      final repository = _RecordingRepository();
      await tester.pumpWidget(MaterialApp(
          home: OrderCreateScreen(
        repository: repository,
        products: [Product(id: 'p1', name: 'Cefixime 200')],
        loadDoctors: () async => [doctor],
      )));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Search saved doctors'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Dr. Meera'));
      await tester.pumpAndSettle();
      final fields = tester
          .widgetList<TextFormField>(find.byType(TextFormField))
          .map((field) => field.controller?.text)
          .toList();
      expect(
          fields,
          containsAll([
            'Dr. Meera',
            'Park Clinic',
            '22 Park Road',
            '9800000000',
            'Central',
            'Delhi'
          ]));
      await tester.tap(find.byKey(const Key('order-next')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add products'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cefixime 200'));
      await tester.pump();
      await tester.tap(find.text('Add 1 product'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('order-next')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('order-next')));
      await tester.pumpAndSettle();
      expect(repository.saved, isNotNull);
      expect(repository.saved!.doctorId, doctor.localId);
      expect(repository.saved!.deliveryAddress, '22 Park Road');
      expect(repository.saved!.items.single.productId, 'p1');
      expect(repository.saved!.attachmentBytes, isEmpty);
      expect(repository.saved!.validate(), isNull);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
      'product selection supports multiple medicines and word-order independent search',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: OrderProductPicker(
      products: [
        Product(id: 'p1', name: 'Cefixime', dosage: '200 mg'),
        Product(id: 'p2', name: 'Vitamin C')
      ],
      selectedIds: const {},
    ))));
    await tester.enterText(find.byType(TextField), '200 cefixime');
    await tester.pump();
    expect(find.text('Cefixime'), findsOneWidget);
    expect(find.text('Vitamin C'), findsNothing);
    await tester.tap(find.text('Cefixime'));
    await tester.enterText(find.byType(TextField), '');
    await tester.pump();
    await tester.tap(find.text('Vitamin C'));
    await tester.pump();
    expect(find.text('Add 2 products'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
