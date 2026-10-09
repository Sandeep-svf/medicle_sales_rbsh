/*
import 'package:flutter_test/flutter_test.dart';
import 'package:medicle_sales_rbsh/features/SalesChartAnalysis/model/SalesChartDashboardModel.dart';
import 'package:medicle_sales_rbsh/features/expenses/models/allowance_deduction.dart';
import 'package:medicle_sales_rbsh/features/expenses/models/DailyAllowenceRequestModel.dart';
import 'package:medicle_sales_rbsh/features/expenses/models/TravelAllowenceRequestModel.dart';
import 'package:medicle_sales_rbsh/features/expenses/models/TravelDetails.dart';

AllowanceDeduction calculate(String category, int doctors, int chemists,
        {double fare = 1000}) =>
    AllowanceDeduction.calculate(
      category: category,
      date: '2026-10-01',
      grossAmount: fare,
      visits: Visits(
          doctor: VisitDetails(confirmed: doctors),
          chemist: VisitDetails(confirmed: chemists)),
    );

void main() {
  test(
      'scheduled and total visits are displayed but never increase eligibility',
      () {
    final value = AllowanceDeduction.calculate(
        category: 'travel',
        date: '2026-10-01',
        grossAmount: 240,
        visits: Visits(
            doctor: VisitDetails(total: 17, scheduled: 10, confirmed: 7),
            chemist: VisitDetails(total: 5, scheduled: 3, confirmed: 2)));
    expect(value.doctorTotal, 17);
    expect(value.doctorScheduled, 10);
    expect(value.chemistTotal, 5);
    expect(value.chemistScheduled, 3);
    expect(value.payableAmount, 120);
  });
  for (final row in [
    [12, 5, 100, 100],
    [10, 4, 100, 100],
    [11, 4, 100, 100],
    [8, 3, 100, 50],
    [9, 3, 100, 50],
    [7, 2, 50, 50],
    [6, 1, 0, 0],
    [17, 0, 0, 0],
    [0, 0, 0, 0],
    [12, 2, 50, 50],
    [7, 5, 50, 50],
  ]) {
    test('doctor ${row[0]} / chemist ${row[1]} daily eligibility', () {
      expect(calculate('travel', row[0], row[1]).payablePercent, row[2]);
      expect(calculate('daily', row[0], row[1]).payablePercent, row[3]);
    });
  }

  test('FLAG gets full fare and is visible in saved remark', () {
    final value = calculate('daily', 10, 4);
    expect(value.flagged, true);
    expect(value.payableAmount, 1000);
    expect(value.remark, contains('FLAG'));
    expect(calculate('daily', 12, 5).flagged, false);
  });

  test('rounding keeps original equal to payable plus deducted', () {
    final value = calculate('daily', 7, 2, fare: 175.01);
    expect(value.payableAmount, 87.51);
    expect(value.deductedAmount, 87.50);
    expect(value.remark, contains('Deduction: 50% (₹87.50)'));
  });

  test('editing replaces previous deduction and preserves manual remark', () {
    final first = calculate('daily', 7, 2).appendTo('DA for Ex');
    final next = calculate('daily', 12, 5).appendTo(first);
    expect(next, startsWith('DA for Ex\n'));
    expect('[DCR allowance]'.allMatches(next).length, 1);
    expect(next, contains('Deduction: 0%'));
  });

  test('TA payload cuts only final amount and preserves actual km', () {
    final value = calculate('travel', 7, 2, fare: 240);
    final request = TravelAllowanceRequest(
        userId: 'user',
        description: value.appendTo('Round Trip'),
        date: value.date,
        amount: value.payableAmount,
        travelDetails: [TravelDetail(from: 'A', to: 'B', km: 100)]);
    expect(request.toJson()['amount'], 120);
    expect(request.toJson()['travelDetails'], [
      {'from': 'A', 'to': 'B', 'km': 100.0}
    ]);
    expect(
        request.toJson()['description'], contains('Deduction: 50% (₹120.00)'));
  });

  for (final type in ['headoffice', 'ex-headquarters', 'outside']) {
    test('DA $type retains location type with reduced final amount', () {
      final request = DailyAllowanceRequest(
          userId: 'user',
          description: 'DA',
          dailyAllowanceType: type,
          date: '2026-10-01',
          amount: calculate('daily', 8, 3, fare: 175).payableAmount);
      expect(request.toJson()['amount'], 87.5);
      expect(request.toJson()['dailyAllowanceType'], type);
    });
  }

  test('legacy callers omit optional amount; other categories are excluded',
      () {
    final request = DailyAllowanceRequest(
        userId: 'user',
        description: 'DA',
        dailyAllowanceType: 'headoffice',
        date: '2026-10-01');
    expect(request.toJson().containsKey('amount'), false);
    expect(() => calculate('extra', 7, 2), throwsArgumentError);
  });
}
*/
import 'package:flutter_test/flutter_test.dart';
import 'package:medicle_sales_rbsh/features/SalesChartAnalysis/model/SalesChartDashboardModel.dart';
import 'package:medicle_sales_rbsh/features/expenses/models/allowance_deduction.dart';
import 'package:medicle_sales_rbsh/features/expenses/models/DailyAllowenceRequestModel.dart';
import 'package:medicle_sales_rbsh/features/expenses/models/TravelAllowenceRequestModel.dart';
import 'package:medicle_sales_rbsh/features/expenses/models/TravelDetails.dart';

/// Common helper used by all test cases.
AllowanceDeduction calculate(
    String category,
    int doctors,
    int chemists, {
      double fare = 1000,
    }) {
  return AllowanceDeduction.calculate(
    category: category,
    date: '2026-10-01',
    grossAmount: fare,
    visits: Visits(
      doctor: VisitDetails(confirmed: doctors),
      chemist: VisitDetails(confirmed: chemists),
    ),
  );
}

/// Prints a clear calculation result in the test console.
void printAllowanceResult({
  required String category,
  required int doctors,
  required int chemists,
  required double grossAmount,
  required AllowanceDeduction result,
}) {
  print('');
  print('============================================================');
  print('ALLOWANCE CALCULATION');
  print('============================================================');
  print('Category          : ${category.toUpperCase()}');
  print('Date              : ${result.date}');
  print('Doctor Confirmed  : $doctors');
  print('Chemist Confirmed : $chemists');
  print('Gross Amount      : ₹${grossAmount.toStringAsFixed(2)}');
  print('------------------------------------------------------------');
  print('Payable Percent   : ${result.payablePercent}%');
  print('Payable Amount    : ₹${result.payableAmount.toStringAsFixed(2)}');
  print(
      'Deducted Amount   : ₹${result.deductedAmount.toStringAsFixed(2)}');
  print('Flagged           : ${result.flagged}');
  print('------------------------------------------------------------');
  print('Remark:');
  print(result.remark);
  print('============================================================');
  print('');
}

void main() {
  group('Allowance Deduction Tests', () {
    test(
      'scheduled and total visits are displayed but never increase eligibility',
          () {
        final value = AllowanceDeduction.calculate(
          category: 'travel',
          date: '2026-10-01',
          grossAmount: 240,
          visits: Visits(
            doctor: VisitDetails(
              total: 17,
              scheduled: 10,
              confirmed: 7,
            ),
            chemist: VisitDetails(
              total: 5,
              scheduled: 3,
              confirmed: 2,
            ),
          ),
        );

        print('');
        print('============================================================');
        print('SCHEDULED / TOTAL VISIT TEST');
        print('============================================================');
        print('Doctor Total      : ${value.doctorTotal}');
        print('Doctor Scheduled  : ${value.doctorScheduled}');
        print('Doctor Confirmed  : 7');
        print('');
        print('Chemist Total     : ${value.chemistTotal}');
        print('Chemist Scheduled : ${value.chemistScheduled}');
        print('Chemist Confirmed : 2');
        print('');
        print('Gross Amount      : ₹240.00');
        print('Payable Percent   : ${value.payablePercent}%');
        print(
            'Payable Amount    : ₹${value.payableAmount.toStringAsFixed(2)}');
        print(
            'Deducted Amount   : ₹${value.deductedAmount.toStringAsFixed(2)}');
        print('Flagged           : ${value.flagged}');
        print('Remark            : ${value.remark}');
        print('============================================================');

        expect(value.doctorTotal, 17);
        expect(value.doctorScheduled, 10);
        expect(value.chemistTotal, 5);
        expect(value.chemistScheduled, 3);

        expect(value.payableAmount, 120);
      },
    );

    // ---------------------------------------------------------
    // Eligibility scenarios
    // ---------------------------------------------------------

    final scenarios = [
      [12, 5, 100, 100],
      [10, 4, 100, 100],
      [11, 4, 100, 100],
      [8, 3, 100, 50],
      [9, 3, 100, 50],
      [7, 2, 50, 50],
      [6, 1, 0, 0],
      [17, 0, 0, 0],
      [0, 0, 0, 0],
      [12, 2, 50, 50],
      [7, 5, 50, 50],
    ];

    for (final row in scenarios) {
      final doctors = row[0];
      final chemists = row[1];
      final expectedTravel = row[2];
      final expectedDaily = row[3];

      test(
        'doctor $doctors / chemist $chemists allowance eligibility',
            () {
          final travel = calculate(
            'travel',
            doctors,
            chemists,
          );

          final daily = calculate(
            'daily',
            doctors,
            chemists,
          );

          print('');
          print('');
          print('############################################################');
          print('SCENARIO');
          print('Doctors : $doctors');
          print('Chemists: $chemists');
          print('############################################################');

          printAllowanceResult(
            category: 'travel',
            doctors: doctors,
            chemists: chemists,
            grossAmount: 1000,
            result: travel,
          );

          printAllowanceResult(
            category: 'daily',
            doctors: doctors,
            chemists: chemists,
            grossAmount: 1000,
            result: daily,
          );

          print('EXPECTED RESULTS');
          print('Travel Expected : $expectedTravel%');
          print('Daily Expected  : $expectedDaily%');
          print('');
          print('ACTUAL RESULTS');
          print('Travel Actual   : ${travel.payablePercent}%');
          print('Daily Actual    : ${daily.payablePercent}%');
          print('############################################################');
          print('');

          expect(
            travel.payablePercent,
            expectedTravel,
            reason:
            'Travel allowance incorrect for Doctors=$doctors, Chemists=$chemists',
          );

          expect(
            daily.payablePercent,
            expectedDaily,
            reason:
            'Daily allowance incorrect for Doctors=$doctors, Chemists=$chemists',
          );
        },
      );
    }

    // ---------------------------------------------------------
    // FLAG
    // ---------------------------------------------------------

    test(
      'FLAG gets full fare and is visible in saved remark',
          () {
        final value = calculate(
          'daily',
          10,
          4,
        );

        printAllowanceResult(
          category: 'daily - FLAG test',
          doctors: 10,
          chemists: 4,
          grossAmount: 1000,
          result: value,
        );

        expect(value.flagged, true);
        expect(value.payableAmount, 1000);
        expect(value.remark, contains('FLAG'));

        final normalValue = calculate(
          'daily',
          12,
          5,
        );

        printAllowanceResult(
          category: 'daily - Normal test',
          doctors: 12,
          chemists: 5,
          grossAmount: 1000,
          result: normalValue,
        );

        expect(normalValue.flagged, false);
      },
    );

    // ---------------------------------------------------------
    // Rounding
    // ---------------------------------------------------------

    test(
      'rounding keeps original equal to payable plus deducted',
          () {
        final value = calculate(
          'daily',
          7,
          2,
          fare: 175.01,
        );

        printAllowanceResult(
          category: 'daily - rounding',
          doctors: 7,
          chemists: 2,
          grossAmount: 175.01,
          result: value,
        );

        print('ROUNDING CHECK');
        print('Original : ₹175.01');
        print('Payable  : ₹${value.payableAmount.toStringAsFixed(2)}');
        print('Deducted : ₹${value.deductedAmount.toStringAsFixed(2)}');
        print(
          'Total     : ₹${(value.payableAmount + value.deductedAmount).toStringAsFixed(2)}',
        );

        expect(value.payableAmount, 87.51);
        expect(value.deductedAmount, 87.50);

        expect(
          value.remark,
          contains('Deduction: 50% (₹87.50)'),
        );
      },
    );

    // ---------------------------------------------------------
    // Editing existing remark
    // ---------------------------------------------------------

    test(
      'editing replaces previous deduction and preserves manual remark',
          () {
        final firstCalculation = calculate(
          'daily',
          7,
          2,
        );

        final first = firstCalculation.appendTo('DA for Ex');

        print('');
        print('============================================================');
        print('FIRST SAVED REMARK');
        print('============================================================');
        print(first);

        final secondCalculation = calculate(
          'daily',
          12,
          5,
        );

        final next = secondCalculation.appendTo(first);

        print('');
        print('============================================================');
        print('UPDATED SAVED REMARK');
        print('============================================================');
        print(next);
        print('============================================================');

        expect(
          next,
          startsWith('DA for Ex\n'),
        );

        expect(
          '[DCR allowance]'.allMatches(next).length,
          1,
        );

        expect(
          next,
          contains('Deduction: 0%'),
        );
      },
    );

    // ---------------------------------------------------------
    // Travel Allowance Payload
    // ---------------------------------------------------------

    test(
      'TA payload cuts only final amount and preserves actual km',
          () {
        final value = calculate(
          'travel',
          7,
          2,
          fare: 240,
        );

        final request = TravelAllowanceRequest(
          userId: 'user',
          description: value.appendTo('Round Trip'),
          date: value.date,
          amount: value.payableAmount,
          travelDetails: [
            TravelDetail(
              from: 'A',
              to: 'B',
              km: 100,
            ),
          ],
        );

        final json = request.toJson();

        printAllowanceResult(
          category: 'travel - payload',
          doctors: 7,
          chemists: 2,
          grossAmount: 240,
          result: value,
        );

        print('');
        print('============================================================');
        print('TRAVEL API PAYLOAD');
        print('============================================================');
        print(json);
        print('============================================================');

        expect(
          json['amount'],
          120,
        );

        expect(
          json['travelDetails'],
          [
            {
              'from': 'A',
              'to': 'B',
              'km': 100.0,
            }
          ],
        );

        expect(
          json['description'],
          contains('Deduction: 50% (₹120.00)'),
        );
      },
    );

    // ---------------------------------------------------------
    // Daily Allowance Types
    // ---------------------------------------------------------

    for (final type in [
      'headoffice',
      'ex-headquarters',
      'outside',
    ]) {
      test(
        'DA $type retains location type with reduced final amount',
            () {
          final allowance = calculate(
            'daily',
            8,
            3,
            fare: 175,
          );

          final request = DailyAllowanceRequest(
            userId: 'user',
            description: 'DA',
            dailyAllowanceType: type,
            date: '2026-10-01',
            amount: allowance.payableAmount,
          );

          final json = request.toJson();

          printAllowanceResult(
            category: 'daily - $type',
            doctors: 8,
            chemists: 3,
            grossAmount: 175,
            result: allowance,
          );

          print('');
          print('============================================================');
          print('DA API PAYLOAD');
          print('============================================================');
          print('Type   : $type');
          print('Amount : ${json['amount']}');
          print('Payload: $json');
          print('============================================================');

          expect(
            json['amount'],
            87.5,
          );

          expect(
            json['dailyAllowanceType'],
            type,
          );
        },
      );
    }

    // ---------------------------------------------------------
    // Legacy caller
    // ---------------------------------------------------------

    test(
      'legacy callers omit optional amount; other categories are excluded',
          () {
        final request = DailyAllowanceRequest(
          userId: 'user',
          description: 'DA',
          dailyAllowanceType: 'headoffice',
          date: '2026-10-01',
        );

        final json = request.toJson();

        print('');
        print('============================================================');
        print('LEGACY REQUEST');
        print('============================================================');
        print('Payload: $json');
        print('Contains amount: ${json.containsKey('amount')}');
        print('============================================================');

        expect(
          json.containsKey('amount'),
          false,
        );

        print('');
        print('Testing unsupported category: extra');

        expect(
              () => calculate(
            'extra',
            7,
            2,
          ),
          throwsArgumentError,
        );
      },
    );
  });
}