import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Material app shell renders in the test environment',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Text('Medicle Sales'),
        ),
      ),
    );

    expect(find.text('Medicle Sales'), findsOneWidget);
  });
}
