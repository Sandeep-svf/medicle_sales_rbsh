import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medicle_sales_rbsh/features/SalesChartAnalysis/model/SalesChartDashboardModel.dart';
import 'package:medicle_sales_rbsh/features/expenses/models/allowance_deduction.dart';
import 'package:medicle_sales_rbsh/features/expenses/screens/widgets/allowance_review_dialog.dart';
import 'package:medicle_sales_rbsh/utils/constants/colors.dart';

void main() {
  for (final submit in [false, true]) {
    testWidgets(
        'review ${submit ? 'confirms' : 'cancels'} with correct amounts',
        (tester) async {
      bool? result;
      await tester.pumpWidget(MaterialApp(
          home: Scaffold(
              body: Builder(
        builder: (context) => TextButton(
            child: const Text('Review'),
            onPressed: () async {
              result = await showDialog<bool>(
                  context: context,
                  builder: (_) => AllowanceReviewDialog(
                          deduction: AllowanceDeduction.calculate(
                        category: 'travel',
                        date: '2026-10-01',
                        grossAmount: 240,
                        visits: Visits(
                            doctor: VisitDetails(confirmed: 7),
                            chemist: VisitDetails(confirmed: 2)),
                      )));
            }),
      ))));
      await tester.tap(find.text('Review'));
      await tester.pumpAndSettle();
      expect(find.text('Deduction (50%)'), findsOneWidget);
      expect(find.text('Daily call eligibility rules'), findsOneWidget);
      expect(find.text('Total'), findsNothing);
      expect(find.text('Scheduled'), findsNothing);
      expect(find.text('Confirmed'), findsNothing);
      expect(find.text('PARTIAL ALLOWANCE'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      expect(find.text('12 or more'), findsOneWidget);
      expect(find.text('100% · FLAG'), findsOneWidget);
      expect(find.text('Less than 7'), findsOneWidget);
      expect(find.text('₹120.00'), findsNWidgets(2));
      expect(find.textContaining('Deduction: 50% (₹120.00)'), findsOneWidget);
      await tester.tap(find.text(submit ? 'Submit claim' : 'Back'));
      await tester.pumpAndSettle();
      expect(result, submit);
      expect(tester.takeException(), isNull);
    });
  }

  for (final size in [const Size(360, 740), const Size(1200, 900)]) {
    testWidgets(
        'rules and actions fit ${size.width} wide screen with larger text',
        (tester) async {
      await tester.binding.setSurfaceSize(size);
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(MaterialApp(
        builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(1.5)),
            child: child!),
        home: Scaffold(
            body: AllowanceReviewDialog(
          deduction: AllowanceDeduction.calculate(
              category: 'daily',
              date: '2026-10-01',
              grossAmount: 175,
              visits: Visits(
                  doctor: VisitDetails(confirmed: 10),
                  chemist: VisitDetails(confirmed: 4))),
        )),
      ));
      await tester.pumpAndSettle();
      expect(find.text('Daily call eligibility rules'), findsOneWidget);
      expect(find.text('Submit claim').hitTestable(), findsOneWidget);
      expect(find.text('FLAGGED'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  for (final calls in [0, 7, 12]) {
    testWidgets(
        'status stamp and completed counts display for $calls confirmed doctors',
        (tester) async {
      final chemists = calls == 12
          ? 5
          : calls == 7
              ? 2
              : 0;
      await tester.pumpWidget(MaterialApp(
        builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(disableAnimations: true),
            child: child!),
        home: Scaffold(
            body: AllowanceReviewDialog(
                deduction: AllowanceDeduction.calculate(
          category: 'daily',
          date: '2026-10-01',
          grossAmount: 175,
          visits: Visits(
              doctor: VisitDetails(
                  total: 17, scheduled: 17 - calls, confirmed: calls),
              chemist: VisitDetails(
                  total: 5, scheduled: 5 - chemists, confirmed: chemists)),
        ))),
      ));
      await tester.pumpAndSettle();
      final status = tester.widget<Container>(
          find.byKey(const ValueKey('allowance-payable-status')));
      expect(
          (status.decoration! as BoxDecoration).color,
          calls == 0
              ? TColors.errorBg
              : calls == 7
                  ? TColors.allowancePartialBg
                  : TColors.allowanceFullBg);
      expect(
          tester
              .widget<Text>(find.byKey(const ValueKey('Doctor visits-count')))
              .data,
          '$calls');
      expect(
          tester
              .widget<Text>(find.byKey(const ValueKey('Chemist visits-count')))
              .data,
          '$chemists');
      expect(find.byType(LinearProgressIndicator), findsNothing);
      expect(find.byKey(const ValueKey('allowance-eligibility-stamp')),
          findsOneWidget);
      expect(
          find.text(calls == 0
              ? 'NOT ELIGIBLE'
              : calls == 7
                  ? 'PARTIAL ALLOWANCE'
                  : 'FULL ALLOWANCE'),
          findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
