import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medicle_sales_rbsh/features/Tour & Plans/TeritoryModule/model/area_model.dart';
import 'package:medicle_sales_rbsh/features/Tour & Plans/TeritoryModule/screen/map_beat_management/beat_area_table.dart';

AreaModel area(int index, {String? id}) => AreaModel(
      id: id ?? 'area-$index',
      headquarterId: 'hq',
      postOffice: 'Office ${index.toString().padLeft(2, '0')}',
      pincode: '${800000 + index}',
      latitude: 25,
      longitude: 85,
      doctorCount: index,
      chemistCount: 2,
      stockistCount: 1,
    );

void main() {
  for (final width in [1366.0, 390.0]) {
    testWidgets('table keeps selections across pages and search at width $width',
        (tester) async {
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final selected = <String>{};
      Set<String>? submitted;
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: StatefulBuilder(
        builder: (context, update) => BeatAreaTable(
          areas: [for (var i = 0; i < 20; i++) area(i), area(99, id: '')],
          selectedIds: selected,
          busy: false,
          editing: false,
          onSelection: (ids, value) => update(() {
            value ? selected.addAll(ids) : selected.removeAll(ids);
          }),
          onDetails: (_) {},
          onCreate: () => submitted = Set.of(selected),
          onClear: () => update(selected.clear),
        ),
      ))));
      expect(find.text('20 registered areas'), findsOneWidget);
      expect(find.text('Office 99'), findsNothing);
      await tester.ensureVisible(find.text('Office 00'));
      await tester.tap(find.text('Office 00'));
      await tester.pump();
      expect(selected, {'area-0'});
      await tester.ensureVisible(find.byTooltip('Next page'));
      await tester.tap(find.byTooltip('Next page'));
      await tester.pump();
      await tester.ensureVisible(find.text('Office 15'));
      await tester.tap(find.text('Office 15'));
      await tester.pump();
      expect(selected, {'area-0', 'area-15'});
      await tester.ensureVisible(find.byType(TextField));
      await tester.enterText(find.byType(TextField), '800000');
      await tester.pump();
      expect(find.text('Office 00'), findsOneWidget);
      expect(find.text('Office 15'), findsNothing);
      expect(find.text('Office 15 (800015)'), findsOneWidget);
      await tester.tap(find.text('Create beat'));
      expect(submitted, {'area-0', 'area-15'});
      await tester.ensureVisible(find.text('Office 00'));
      await tester.tap(find.text('Office 00'));
      await tester.pump();
      expect(selected, {'area-15'});
      await tester.tap(find.text('Clear selection'));
      await tester.pump();
      expect(selected, isEmpty);
      expect(tester.takeException(), isNull);
    });
  }
}
