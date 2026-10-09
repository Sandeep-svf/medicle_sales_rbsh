import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medicle_sales_rbsh/utils/constants/colors.dart';
import 'package:medicle_sales_rbsh/features/Tour & Plans/TeritoryModule/model/area_model.dart';
import 'package:medicle_sales_rbsh/features/Tour & Plans/TeritoryModule/screen/map_beat_management/map_beat_creation_page.dart';

final areas = [
  for (var i = 0; i < 20; i++)
    AreaModel(
        id: 'area-$i',
        headquarterId: 'hq',
        postOffice: 'Post office $i',
        pincode: '$i',
        latitude: 0,
        longitude: 0)
];

MapBeatCreationPage page(
        {String name = '',
        bool editing = false,
        Future<bool> Function(String, String)? save,
        void Function(String, String)? changed}) =>
    MapBeatCreationPage(
        areas: areas,
        initialName: name,
        initialColor: '#E6194B',
        editing: editing,
        onSave: save ?? (_, __) async => false,
        onDraftChanged: changed);

void main() {
  for (final size in [
    const Size(390, 844),
    const Size(844, 390),
    const Size(1366, 1024)
  ]) {
    testWidgets('creation page fits $size and offers exactly 15 colors',
        (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(MaterialApp(home: page()));
      expect(find.byType(ChoiceChip), findsNWidgets(15));
      expect(TColors.mapBeatPalette.values.toSet(), hasLength(15));
      await tester.scrollUntilVisible(find.text('Post office 19'), 250,
          scrollable: find.byType(Scrollable).first);
      expect(find.text('Post office 19'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets('empty name never submits, save failure keeps name and areas',
      (tester) async {
    var calls = 0;
    await tester.pumpWidget(MaterialApp(home: page(save: (_, __) async {
      calls++;
      return false;
    })));
    await tester
        .tap(find.byWidgetPredicate((widget) => widget is FilledButton));
    await tester.pump();
    expect(calls, 0);
    expect(find.text('Enter a beat name.'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField), 'Darbhanga beat');
    await tester
        .tap(find.byWidgetPredicate((widget) => widget is FilledButton));
    await tester.pumpAndSettle();
    expect(calls, 1);
    expect(find.text('Darbhanga beat'), findsOneWidget);
    await tester.scrollUntilVisible(
        find.text(
            'Unable to save. Your selected areas are retained; please retry.'),
        200,
        scrollable: find.byType(Scrollable).first);
    expect(
        find.text(
            'Unable to save. Your selected areas are retained; please retry.'),
        findsOneWidget);
  });
  testWidgets('draft changes retain chosen name and color for return to map',
      (tester) async {
    String? draftName;
    String? draftColor;
    await tester.pumpWidget(MaterialApp(home: page(changed: (name, color) {
      draftName = name;
      draftColor = color;
    })));
    await tester.enterText(find.byType(TextFormField), 'Morning beat');
    await tester.ensureVisible(find.widgetWithText(ChoiceChip, 'Blue'));
    await tester.tap(find.widgetWithText(ChoiceChip, 'Blue'));
    await tester.pump();
    expect(draftName, 'Morning beat');
    expect(draftColor, '#4363D8');
  });
  testWidgets(
      'in-flight save blocks repeat submissions and success returns to map',
      (tester) async {
    final completed = Completer<bool>();
    var calls = 0;
    await tester.pumpWidget(MaterialApp(
        home: Builder(
            builder: (context) => Scaffold(
                body: TextButton(
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                            builder: (_) => page(
                                name: 'Existing draft',
                                save: (_, __) {
                                  calls++;
                                  return completed.future;
                                }))),
                    child: const Text('Map selection'))))));
    await tester.tap(find.text('Map selection'));
    await tester.pumpAndSettle();
    await tester
        .tap(find.byWidgetPredicate((widget) => widget is FilledButton));
    await tester.pump();
    expect(calls, 1);
    expect(
        tester
            .widget<FilledButton>(
                find.byWidgetPredicate((widget) => widget is FilledButton))
            .onPressed,
        isNull);
    completed.complete(true);
    await tester.pumpAndSettle();
    expect(find.text('Map selection'), findsOneWidget);
    expect(find.byType(MapBeatCreationPage), findsNothing);
  });
}
