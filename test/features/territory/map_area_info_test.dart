import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medicle_sales_rbsh/features/Tour & Plans/TeritoryModule/screen/map_beat_management/map_area_hold.dart';
import 'package:medicle_sales_rbsh/features/Tour & Plans/TeritoryModule/screen/map_beat_management/map_area_info_dialog.dart';
import 'package:medicle_sales_rbsh/utils/constants/colors.dart';

void main() {
  testWidgets('hold waits 1.5 seconds and cancels dragging', (tester) async {
    var holds = 0;
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: MapAreaHold(
      onHold: (_) => holds++,
      onRelease: () {},
      child: const SizedBox.expand(),
    ))));
    final gesture = await tester.startGesture(const Offset(100, 100));
    await tester.pump(const Duration(milliseconds: 1499));
    expect(holds, 0);
    await tester.pump(const Duration(milliseconds: 1));
    expect(holds, 1);
    await gesture.up();
    final drag = await tester.startGesture(const Offset(100, 100));
    await drag.moveBy(const Offset(30, 0));
    await tester.pump(const Duration(seconds: 2));
    expect(holds, 1);
    await drag.up();
  });
  testWidgets(
      'animated details show counts and beat colors with explicit close',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: Builder(
                builder: (context) => TextButton(
                    onPressed: () => showMapAreaInfo(
                          context,
                          title: 'Darbhanga HO',
                          pincode: '846004',
                          doctors: 5,
                          chemists: 3,
                          stockists: 2,
                          dataAvailable: true,
                          beats: [
                            (
                              id: 'b',
                              name: 'Market beat',
                              color: TColors.primary,
                              areas: <String>[]
                            )
                          ],
                        ),
                    child: const Text('Open'))))));
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    for (final text in [
      'Darbhanga HO',
      'Pincode 846004',
      'Doctors',
      'Chemists',
      'Stockists',
      '5',
      '3',
      '2',
      'Market beat',
      'Close'
    ]) {
      expect(find.text(text), findsOneWidget);
    }
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    expect(find.text('Darbhanga HO'), findsNothing);
  });
}
