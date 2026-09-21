import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:medicle_sales_rbsh/features/addDoctor/controllers/DoctroController.dart';
import 'package:medicle_sales_rbsh/features/addDoctor/models/DoctorModelList.dart';
import 'package:medicle_sales_rbsh/features/visit/Doctor/screens/ScheduleVisitScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late DoctorListController doctorController;

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    if (Get.isRegistered<DoctorListController>()) {
      await Get.delete<DoctorListController>(force: true);
    }
    doctorController = Get.put(DoctorListController());
    doctorController.doctorList.assignAll(<Doctor>[
      testDoctor(
        id: 'doctor-1',
        name: 'Dr. Anil Sharma',
        address: '12 MG Road, Delhi',
      ),
      testDoctor(
        id: 'doctor-2',
        name: 'Dr. Beena Kapoor',
        address: '45 Park Street, Delhi',
      ),
    ]);
    doctorController.filteredDoctors.assignAll(doctorController.doctorList);
  });

  tearDown(() async {
    if (Get.isRegistered<DoctorListController>()) {
      await Get.delete<DoctorListController>(force: true);
    }
  });

  testWidgets(
      'selecting multiple doctors immediately shows the selection preview',
      (tester) async {
    await pumpScheduleScreen(tester);

    await tester.tap(
      find.text('Tap to search and select one or more doctors...'),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Dr. Anil Sharma').first);
    await tester.pump();
    expect(find.text('Select doctors (1 selected)'), findsOneWidget);
    expect(find.text('Selected doctors'), findsOneWidget);

    await tester.tap(find.text('Dr. Beena Kapoor').first);
    await tester.pump();
    expect(find.text('Select doctors (2 selected)'), findsOneWidget);
    expect(find.text('Dr. Anil Sharma'), findsWidgets);
    expect(find.text('Dr. Beena Kapoor'), findsWidgets);
  });

  testWidgets(
      'customize each doctor shows the selected date and separate fields',
      (tester) async {
    await pumpScheduleScreen(tester);
    await selectDoctors(tester);

    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(find.text('2 doctors selected'), findsOneWidget);
    expect(
      find.text(
        'One date and note will be applied to every selected doctor.',
      ),
      findsOneWidget,
    );
    expect(find.byType(TextFormField), findsNWidgets(2));

    await tester.ensureVisible(find.text('Customize each'));
    await tester.tap(find.text('Customize each'));
    await tester.pumpAndSettle();

    final today = DateFormat('dd-MM-yyyy').format(DateTime.now());
    expect(find.text(today, skipOffstage: false), findsNWidgets(2));
    expect(find.byType(TextFormField), findsNWidgets(4));
  });

  testWidgets('doctor details popup has one standardized Close button',
      (tester) async {
    await pumpScheduleScreen(tester);
    await selectDoctors(tester);
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Tap here to add or remove doctors'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.info_outline_rounded).first);
    await tester.pumpAndSettle();

    expect(find.widgetWithText(FilledButton, 'Close'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is RichText &&
            widget.text.toPlainText().startsWith('Address\n') &&
            widget.text.toPlainText().contains('12 MG Road, Delhi'),
        description: 'doctor address detail',
      ),
      findsOneWidget,
    );

    await tester.tap(find.widgetWithText(FilledButton, 'Close'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(FilledButton, 'Close'), findsNothing);
  });
}

Future<void> pumpScheduleScreen(WidgetTester tester) async {
  await tester.pumpWidget(
    const MaterialApp(
      home: ScheduleVisitScreen(),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> selectDoctors(WidgetTester tester) async {
  await tester.tap(
    find.text('Tap to search and select one or more doctors...'),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.text('Dr. Anil Sharma').first);
  await tester.pump();
  await tester.tap(find.text('Dr. Beena Kapoor').first);
  await tester.pump();
}

Doctor testDoctor({
  required String id,
  required String name,
  required String address,
}) {
  return Doctor.fromJson({
    '_id': id,
    'name': name,
    'specialization': 'Cardiology',
    'clinic_name': 'City Care Clinic',
    'clinic_address': address,
    'qualification': 'MBBS, MD',
    'phone': '9876543210',
    'priority': 'A',
    'createdAt': '2026-09-21T00:00:00.000Z',
    'updatedAt': '2026-09-21T00:00:00.000Z',
  });
}
