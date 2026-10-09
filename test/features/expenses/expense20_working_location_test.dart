import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medicle_sales_rbsh/features/expenses/screens/expense20/expense20_working_location.dart';

void main() {
  for (final size in [const Size(390, 844), const Size(844, 390)]) {
    testWidgets('location popup fits $size and returns Out of Station',
        (tester) async {
      await tester.binding.setSurfaceSize(size);
      addTearDown(() => tester.binding.setSurfaceSize(null));
      String? result;
      await tester.pumpWidget(MaterialApp(
          home: Scaffold(
              body: Builder(
                  builder: (context) => TextButton(
                        onPressed: () async => result =
                            await chooseExpense20WorkingLocation(context),
                        child: const Text('Open'),
                      )))));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('Where are you working?'), findsOneWidget);
      expect(find.text('Continue'), findsNothing);
      await tester.ensureVisible(find.text('Out of Station'));
      await tester.tap(find.text('Out of Station'));
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();
      expect(result, 'outside');
      expect(tester.takeException(), isNull);
    });
  }
}
