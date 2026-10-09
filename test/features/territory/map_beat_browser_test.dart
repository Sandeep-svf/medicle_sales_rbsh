import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medicle_sales_rbsh/features/Tour & Plans/TeritoryModule/screen/map_beat_management/map_beat_browser.dart';

void main() {
  testWidgets(
      'compact browser expands areas, scrolls all beats and collapses on focus',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    String? viewed;
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: Align(
                alignment: Alignment.bottomCenter,
                child: MapBeatBrowser(
                  beats: List.generate(
                      20,
                      (i) => (
                            id: '$i',
                            name: 'Beat $i',
                            color: Colors.blue,
                            areas: ['Office $i (847101)']
                          )),
                  onView: (id) => viewed = id,
                )))));
    expect(find.text('Your beats (20)'), findsOneWidget);
    expect(find.text('Office 0 (847101)'), findsNothing);
    await tester.tap(find.text('Browse'));
    await tester.pumpAndSettle();
    expect(find.text('Office 0 (847101)'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Office 19 (847101)'), 150,
        scrollable: find.byType(Scrollable).first);
    await tester.ensureVisible(find.text('Show beat on map').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Show beat on map').last);
    await tester.pumpAndSettle();
    expect(viewed, '19');
    expect(find.text('Browse'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
