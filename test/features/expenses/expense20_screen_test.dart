import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:medicle_sales_rbsh/features/expenses/screens/expense20/expense20_screen.dart';
import 'package:medicle_sales_rbsh/features/expenses/screens/expense20/expense20_claim_form.dart';
import 'package:medicle_sales_rbsh/features/expenses/screens/expense20/expense20_policy.dart';

final expense20Today = DateFormat('yyyy-MM-dd').format(DateTime.now());
final expense20PreviousMonth =
    DateTime(DateTime.now().year, DateTime.now().month - 1, 5);

Map<String, dynamic> expense20Fixture(
        String id, String category, String status, String amount,
        {String? date, int editCount = 0}) =>
    {
      'id': id,
      'user_id': 'user',
      'category': category,
      'status': status,
      'amount': amount,
      'date': date ?? expense20Today,
      'description': 'Visit expense $id',
      'rate_per_km': '2.4',
      'total_distance_km': '10',
      'edit_count': editCount,
      'daily_allowance_type': category == 'daily' ? 'headoffice' : null,
      'travel_details': category == 'travel'
          ? [
              {'from': 'Samastipur', 'to': 'Purnia', 'km': 10}
            ]
          : [],
    };

class Expense20ApiFixture {
  int expenseLoads = 0;
  int writes = 0;
  int uploads = 0;
  List<Map<String, dynamic>>? customExpenses;
  bool failVisits = false;
  bool duplicate = false;
  Map<String, dynamic>? payload;
  String? method;

  late final client = MockClient((request) async {
    final path = request.url.path;
    if (path.endsWith('/expenses/settings')) {
      return http.Response(
          jsonEncode({
            'ratePerKm': '2.4',
            'headOfficeAmount': '175',
            'exHeadquartersAmount': '200',
            'outsideHeadOfficeAmount': '300'
          }),
          200);
    }
    if (request.method == 'GET' && path.endsWith('/expenses')) {
      expenseLoads++;
      expect(request.url.queryParameters['userId'], 'user');
      return http.Response(
          jsonEncode(customExpenses ??
              [
                expense20Fixture('ta', 'travel', 'approved', '100'),
                expense20Fixture('da', 'daily', 'pending', '50'),
                expense20Fixture('other', 'extra', 'rejected', '25'),
                expense20Fixture('edited', 'travel', 'approved', '10',
                    editCount: 1),
                expense20Fixture('previous', 'extra', 'approved', '999',
                    date: DateFormat('yyyy-MM-dd')
                        .format(expense20PreviousMonth)),
              ]),
          200);
    }
    if (path.contains('-visits/user/user')) {
      expect(request.headers['Authorization'], 'Bearer test-token');
      expect(request.url.queryParameters,
          {'startDate': expense20Today, 'endDate': expense20Today});
      if (failVisits) return http.Response('{}', 500);
      final count = path.contains('doctor') ? 7 : 2;
      return http.Response(
          jsonEncode(List.generate(
              count,
              (i) => {
                    'id': '$i',
                    'date': expense20Today,
                    'user_id': 'user',
                    'confirmed': true,
                  })),
          200);
    }
    if (path.endsWith('/expenses/upload-bill')) {
      uploads++;
      expect(request.headers['Authorization'], 'Bearer test-token');
      expect(request.headers['Content-Type'], contains('multipart/form-data'));
      return http.Response(
          jsonEncode({'imageUrl': 'https://example.test/bill.jpg'}), 201);
    }
    if (request.method == 'POST' || request.method == 'PUT') {
      writes++;
      method = request.method;
      payload = jsonDecode(request.body) as Map<String, dynamic>;
      if (duplicate) {
        return http.Response(
            jsonEncode({
              'success': false,
              'message':
                  'You have already submitted a Travel Allowance (TA) expense for this date.'
            }),
            400);
      }
      return http.Response('{}', request.method == 'POST' ? 201 : 200);
    }
    throw StateError('Unexpected API ${request.method} $path');
  });
}

Future<void> expense20Pump(WidgetTester tester,
    {Size size = const Size(1366, 1050)}) async {
  await tester.binding.setSurfaceSize(size);
  await tester.pumpWidget(const MaterialApp(home: Expense20Screen()));
  await tester.pumpAndSettle();
  expect(find.text('Where are you working?'), findsNothing);
  expect(find.byType(Expense20ClaimForm), findsNothing);
  await tester
      .ensureVisible(find.byKey(const ValueKey('expense20-add-expense')));
  await tester.tap(find.byKey(const ValueKey('expense20-add-expense')));
  await tester.pumpAndSettle();
  expect(find.text('Where are you working?'), findsOneWidget);
  await tester.tap(find.text('X Station'));
  await tester.pump();
  await tester.pumpAndSettle();
}

Future<void> expense20Tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  // The submission loader stays active while the review dialog waits for input.
  for (var frame = 0; frame < 6; frame++) {
    await tester.pump(const Duration(milliseconds: 150));
  }
}

Future<void> expense20AddLeg(
    WidgetTester tester, String from, String to, String km) async {
  for (final entry in {'from': from, 'to': to, 'km': km}.entries) {
    final field = expense20TravelField(entry.key).last;
    await tester.ensureVisible(field);
    await tester.enterText(field, entry.value);
  }
  await expense20Tap(tester, find.byKey(const ValueKey('expense20-add-leg')));
}

Finder expense20TravelField(String field) => find.byWidgetPredicate((widget) =>
    widget is TextField &&
    widget.key is ValueKey<String> &&
    (widget.key! as ValueKey<String>).value.startsWith('expense20-$field-'));

void main() {
  testWidgets('history defaults to current month and can show all months',
      (tester) async {
    final api = Expense20ApiFixture();
    await tester.binding.setSurfaceSize(const Size(1366, 1050));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await http.runWithClient(() async {
      await tester.pumpWidget(const MaterialApp(home: Expense20Screen()));
      await tester.pumpAndSettle();
      final current = DateFormat('yyyy-MM').format(DateTime.parse(expense20Today));
      final filter = find.byKey(ValueKey('expense20-history-month-$current'));
      expect(filter, findsOneWidget);
      expect(find.text('Showing all 4 expenses'), findsOneWidget);
      await expense20Tap(tester, filter);
      await expense20Tap(tester, find.text('All months').last);
      expect(find.text('Showing all 5 expenses'), findsOneWidget);
      expect(api.writes, 0);
      expect(tester.takeException(), isNull);
    }, () => api.client);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('HQ hides TA and changing to X restores travel creation',
      (tester) async {
    final api = Expense20ApiFixture();
    await http.runWithClient(() async {
      await expense20Pump(tester);
      await expense20Tap(tester, find.text('Change').first);
      await tester.tap(find.text('Headquarter (HQ)'));
      await tester.pump();
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('expense20-category-travel')),
          findsNothing);
      expect(find.textContaining('Add TA is unavailable'), findsOneWidget);
      expect(find.text('Original DA amount'), findsOneWidget);
      await expense20Tap(tester, find.text('Change').first);
      await tester.tap(find.text('X Station'));
      await tester.pump();
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('expense20-category-travel')),
          findsOneWidget);
      expect(api.writes, 0);
    }, () => api.client);
    await tester.pumpWidget(const SizedBox());
    await tester.binding.setSurfaceSize(null);
  });

  setUp(() => SharedPreferences.setMockInitialValues(
      {'user_id': 'user', 'token': 'test-token'}));

  for (final size in [
    const Size(1366, 1050),
    const Size(1024, 768),
    const Size(800, 1100),
    const Size(390, 844)
  ]) {
    testWidgets('real model data and policy fit ${size.width} wide',
        (tester) async {
      final api = Expense20ApiFixture();
      await http.runWithClient(() async {
        await expense20Pump(tester, size: size);
        expect(find.byKey(const ValueKey('expense20-summary-total')),
            findsOneWidget);
        expect(
            tester
                .widget<Text>(
                    find.byKey(const ValueKey('expense20-summary-total')))
                .data,
            '₹185.00');
        expect(
            tester
                .widget<Text>(
                    find.byKey(const ValueKey('expense20-summary-approved')))
                .data,
            '₹110.00');
        expect(find.text('Local Conveyance'), findsNothing);
        final from = expense20TravelField('from').first;
        final to = expense20TravelField('to').first;
        final distance = expense20TravelField('km').first;
        expect(tester.getTopLeft(from).dy, tester.getTopLeft(to).dy);
        expect(tester.getTopLeft(to).dy, tester.getTopLeft(distance).dy);
        final plus = find.byKey(const ValueKey('expense20-add-leg'));
        expect(tester.getTopLeft(plus).dy,
            greaterThan(tester.getBottomLeft(distance).dy));
        expect(tester.getTopLeft(find.text('Rate per KM')).dy,
            greaterThan(tester.getBottomLeft(plus).dy));
        expect(tester.getTopLeft(find.text('Original TA fare')).dy,
            greaterThan(tester.getBottomLeft(plus).dy));
        await expense20Tap(tester, plus);
        expect(expense20TravelField('from'), findsNWidgets(2));
        expect(expense20TravelField('to'), findsNWidgets(2));
        expect(expense20TravelField('km'), findsNWidgets(2));
        expect(tester.takeException(), isNull);
        await expense20Tap(
            tester, find.byKey(const ValueKey('expense20-close-add')));
        await expense20Tap(tester, find.byTooltip('Expense Policy'));
        expect(find.byType(Expense20Policy), findsOneWidget);
        expect(find.text('100% · FLAG'), findsOneWidget);
        expect(tester.takeException(), isNull);
        await expense20Tap(tester, find.text('Understood'));
        expect(api.writes, 0);
      }, () => api.client);
      await tester.pumpWidget(const SizedBox());
      await tester.binding.setSurfaceSize(null);
    });
  }

  testWidgets('multiple one-way legs retain km and cut only final fare',
      (tester) async {
    final api = Expense20ApiFixture();
    await http.runWithClient(() async {
      await expense20Pump(tester);
      await expense20AddLeg(tester, 'A', 'B', '10');
      await expense20AddLeg(tester, 'B', 'C', '20');
      await expense20Tap(
          tester, find.byKey(const ValueKey('expense20-submit')));
      expect(find.text('Deduction (50%)'), findsOneWidget);
      expect(api.writes, 0);
      await expense20Tap(tester, find.text('Submit claim'));
      expect(api.payload!['category'], 'travel');
      expect(api.payload!['amount'], 36);
      expect(api.payload!['travelDetails'], [
        {'from': 'A', 'to': 'B', 'km': 10.0},
        {'from': 'B', 'to': 'C', 'km': 20.0}
      ]);
      expect(api.payload!['description'], contains('Deduction: 50% (₹36.00)'));
      expect(api.writes, 1);
      expect(api.expenseLoads, 2);
      expect(find.byType(Expense20ClaimForm), findsNothing);
      expect(find.byKey(const ValueKey('expense20-close-add')), findsNothing);
      expect(tester.takeException(), isNull);
    }, () => api.client);
    await tester.pumpWidget(const SizedBox());
    await tester.binding.setSurfaceSize(null);
  });

  testWidgets(
      'inline row edits, swaps and removal update the original fare and payload',
      (tester) async {
    final api = Expense20ApiFixture();
    await http.runWithClient(() async {
      await expense20Pump(tester);
      await expense20AddLeg(tester, 'A', 'B', '10');
      await expense20AddLeg(tester, 'B', 'C', '20');
      await expense20AddLeg(tester, 'C', 'D', '30');
      expect(find.text('₹144.00'), findsOneWidget);
      await expense20Tap(
          tester, find.byKey(const ValueKey('expense20-remove-1')));
      expect(find.text('₹96.00'), findsOneWidget);
      final distance = find.byKey(const ValueKey('expense20-km-0'));
      await tester.ensureVisible(distance);
      await tester.enterText(distance, '15');
      await tester.pump();
      expect(find.text('₹108.00'), findsOneWidget);
      await expense20Tap(
          tester, find.byKey(const ValueKey('expense20-swap-0')));
      expect(
          tester
              .widget<TextField>(find.byKey(const ValueKey('expense20-from-0')))
              .controller!
              .text,
          'B');
      expect(
          tester
              .widget<TextField>(find.byKey(const ValueKey('expense20-to-0')))
              .controller!
              .text,
          'A');
      await expense20Tap(
          tester, find.byKey(const ValueKey('expense20-submit')));
      await expense20Tap(tester, find.text('Submit claim'));
      expect(api.payload!['amount'], 54);
      expect(api.payload!['travelDetails'], [
        {'from': 'B', 'to': 'A', 'km': 15.0},
        {'from': 'C', 'to': 'D', 'km': 30.0},
      ]);
      expect(api.writes, 1);
      expect(tester.takeException(), isNull);
    }, () => api.client);
    await tester.pumpWidget(const SizedBox());
    await tester.binding.setSurfaceSize(null);
  });

  testWidgets(
      'partially filled additional travel row blocks submission until completed',
      (tester) async {
    final api = Expense20ApiFixture();
    await http.runWithClient(() async {
      await expense20Pump(tester);
      await expense20AddLeg(tester, 'A', 'B', '10');
      final from = expense20TravelField('from').last;
      await tester.ensureVisible(from);
      await tester.enterText(from, 'B');
      await expense20Tap(
          tester, find.byKey(const ValueKey('expense20-submit')));
      expect(find.text('Enter From, To and a valid distance in travel row 2.'),
          findsOneWidget);
      expect(find.text('Submit claim'), findsNothing);
      expect(api.writes, 0);
      await tester.ensureVisible(expense20TravelField('to').last);
      await tester.enterText(expense20TravelField('to').last, 'C');
      await tester.enterText(expense20TravelField('km').last, '20');
      await expense20Tap(
          tester, find.byKey(const ValueKey('expense20-submit')));
      await expense20Tap(tester, find.text('Submit claim'));
      expect(api.payload!['amount'], 36);
      expect(api.payload!['travelDetails'], hasLength(2));
      expect(tester.takeException(), isNull);
    }, () => api.client);
    await tester.pumpWidget(const SizedBox());
    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('inline rows retain separate one-way and round-trip distances',
      (tester) async {
    final api = Expense20ApiFixture();
    await http.runWithClient(() async {
      await expense20Pump(tester);
      await expense20AddLeg(tester, 'A', 'B', '10');
      await expense20Tap(tester, find.text('Round Trip'));
      await expense20AddLeg(tester, 'B', 'C', '20');
      expect(find.text('₹120.00'), findsOneWidget);
      expect(find.text('Journey 1 · One Way'), findsOneWidget);
      expect(find.text('Journey 2 · Round Trip'), findsOneWidget);
      await expense20Tap(
          tester, find.byKey(const ValueKey('expense20-submit')));
      await expense20Tap(tester, find.text('Submit claim'));
      expect(api.payload!['amount'], 60);
      expect(api.payload!['travelDetails'], [
        {'from': 'A', 'to': 'B', 'km': 10.0},
        {'from': 'B', 'to': 'C', 'km': 40.0},
      ]);
      expect(tester.takeException(), isNull);
    }, () => api.client);
    await tester.pumpWidget(const SizedBox());
    await tester.binding.setSurfaceSize(null);
  });

  testWidgets(
      'round trip doubles submitted km and cancelling review does not write',
      (tester) async {
    final api = Expense20ApiFixture();
    await http.runWithClient(() async {
      await expense20Pump(tester);
      await expense20Tap(tester, find.text('Round Trip'));
      await expense20AddLeg(tester, 'A', 'B', '10');
      await expense20Tap(
          tester, find.byKey(const ValueKey('expense20-submit')));
      await expense20Tap(tester, find.text('Back'));
      expect(api.writes, 0);
      await expense20Tap(
          tester, find.byKey(const ValueKey('expense20-submit')));
      await expense20Tap(tester, find.text('Submit claim'));
      expect(api.payload!['travelDetails'][0]['km'], 20);
      expect(api.payload!['amount'], 24);
    }, () => api.client);
    await tester.pumpWidget(const SizedBox());
    await tester.binding.setSurfaceSize(null);
  });

  for (final da in {
    'Headquarter': ['headoffice', 87.5],
    'Ex headquarters': ['ex-headquarters', 100.0],
    'Out of Station': ['outside', 150.0]
  }.entries) {
    testWidgets('${da.key} uses saved rates and same DA submission model',
        (tester) async {
      final api = Expense20ApiFixture();
      await http.runWithClient(() async {
        await expense20Pump(tester);
        await expense20Tap(
            tester, find.byKey(const ValueKey('expense20-category-daily')));
        await expense20Tap(tester, find.text('Change').first);
        final locationLabel = switch (da.value[0]) {
          'headoffice' => 'Headquarter (HQ)',
          'ex-headquarters' => 'X Station',
          _ => 'Out of Station',
        };
        await tester.ensureVisible(find.text(locationLabel).last);
        await tester.tap(find.text(locationLabel).last);
        await tester.pumpAndSettle();
        await tester.pumpAndSettle();
        expect(find.byKey(const ValueKey('expense20-da-selected-location')),
            findsOneWidget);
        expect(
            find.byWidgetPredicate((widget) =>
                widget is DropdownButtonFormField<String> &&
                widget.key.toString().contains('expense20-da-type')),
            findsNothing);
        await expense20Tap(
            tester, find.byKey(const ValueKey('expense20-submit')));
        await expense20Tap(tester, find.text('Submit claim'));
        expect(api.payload!['category'], 'daily');
        expect(api.payload!['dailyAllowanceType'], da.value[0]);
        expect(api.payload!['amount'], da.value[1]);
      }, () => api.client);
      await tester.pumpWidget(const SizedBox());
      await tester.binding.setSurfaceSize(null);
    });
  }

  testWidgets('draft survives orientation changes and popup closes to history',
      (tester) async {
    final api = Expense20ApiFixture();
    await http.runWithClient(() async {
      await expense20Pump(tester);
      await expense20AddLeg(tester, 'Keep A', 'Keep B', '10');
      await tester.binding.setSurfaceSize(const Size(800, 1100));
      await tester.pumpAndSettle();
      expect(find.text('Keep A'), findsOneWidget);
      expect(find.text('Keep B'), findsOneWidget);
      await expense20Tap(
          tester, find.byKey(const ValueKey('expense20-close-add')));
      expect(find.byType(Expense20ClaimForm), findsNothing);
      expect(tester.takeException(), isNull);
    }, () => api.client);
    await tester.pumpWidget(const SizedBox());
    await tester.binding.setSurfaceSize(null);
  });

  testWidgets(
      'visit failure prevents posting and duplicate error preserves draft',
      (tester) async {
    final api = Expense20ApiFixture()..failVisits = true;
    await http.runWithClient(() async {
      await expense20Pump(tester);
      await expense20AddLeg(tester, 'A', 'B', '10');
      await expense20Tap(
          tester, find.byKey(const ValueKey('expense20-submit')));
      expect(api.writes, 0);
      expect(
          find.textContaining('Unable to load doctor visits'), findsOneWidget);
      api.failVisits = false;
      api.duplicate = true;
      await expense20Tap(
          tester, find.byKey(const ValueKey('expense20-submit')));
      await expense20Tap(tester, find.text('Submit claim'));
      expect(
          find.text(
              'You have already submitted a Travel Allowance (TA) expense for this date.'),
          findsOneWidget);
      expect(find.text('A'), findsOneWidget);
      expect(find.text('B'), findsOneWidget);
    }, () => api.client);
    await tester.pumpWidget(const SizedBox());
    await tester.binding.setSurfaceSize(null);
  });

  testWidgets(
      'history search filters data and extra expenses have no edit action',
      (tester) async {
    final api = Expense20ApiFixture();
    await http.runWithClient(() async {
      await expense20Pump(tester);
      await expense20Tap(
          tester, find.byKey(const ValueKey('expense20-close-add')));
      await tester.enterText(find.byKey(const ValueKey('expense20-search')),
          'Visit expense other');
      await tester.pumpAndSettle();
      expect(find.text('Showing all 1 expense'), findsOneWidget);
      await expense20Tap(tester, find.text('View'));
      expect(find.text('Edit Expense'), findsNothing);
      await expense20Tap(tester, find.text('Close'));
      await tester.enterText(
          find.byKey(const ValueKey('expense20-search')), 'Samastipur');
      await tester.pumpAndSettle();
      expect(find.text('Showing all 2 expenses'), findsOneWidget);
      expect(api.writes, 0);
    }, () => api.client);
    await tester.pumpWidget(const SizedBox());
    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('month, type and status filters use loaded expense records',
      (tester) async {
    final api = Expense20ApiFixture();
    await http.runWithClient(() async {
      await expense20Pump(tester);
      await expense20Tap(
          tester, find.byKey(const ValueKey('expense20-close-add')));
      await expense20Tap(
          tester, find.byKey(const ValueKey('expense20-type-filter-all')));
      await expense20Tap(tester, find.text('DA').last);
      await expense20Tap(
          tester, find.byKey(const ValueKey('expense20-status-filter-all')));
      await expense20Tap(tester, find.text('Pending').last);
      expect(find.text('Showing all 1 expense'), findsOneWidget);
      await expense20Tap(tester, find.byTooltip('Clear filters'));
      await expense20Tap(
          tester, find.byType(DropdownButtonFormField<DateTime>));
      await expense20Tap(
          tester,
          find
              .text(DateFormat('MMMM yyyy').format(expense20PreviousMonth))
              .last);
      expect(
          tester
              .widget<Text>(
                  find.byKey(const ValueKey('expense20-summary-total')))
              .data,
          '₹999.00');
      // The summary period does not hide expenses from the history list.
      expect(find.text('Showing all 5 expenses'), findsOneWidget);
      await expense20Tap(
          tester, find.byKey(const ValueKey('expense20-history-month-all')));
      await expense20Tap(
          tester,
          find
              .text(DateFormat('MMM yyyy').format(expense20PreviousMonth))
              .last);
      expect(find.text('Showing all 1 expense'), findsOneWidget);
      await expense20Tap(tester, find.byTooltip('Clear filters'));
      expect(find.text('Showing all 5 expenses'), findsOneWidget);
      expect(api.expenseLoads, 1);
    }, () => api.client);
    await tester.pumpWidget(const SizedBox());
    await tester.binding.setSurfaceSize(null);
  });

  for (final size in [
    const Size(1366, 1050),
    const Size(800, 1100),
    const Size(390, 844)
  ]) {
    testWidgets(
        'history scrolls to every API expense across months without paging at ${size.width}',
        (tester) async {
      final api = Expense20ApiFixture()
        ..customExpenses = List.generate(
            32,
            (i) => expense20Fixture('row-$i', 'extra', 'pending', '10',
                date: i < 16
                    ? expense20Today
                    : DateFormat('yyyy-MM-dd').format(expense20PreviousMonth)));
      await http.runWithClient(() async {
        await expense20Pump(tester, size: size);
        await expense20Tap(
            tester, find.byKey(const ValueKey('expense20-close-add')));
        expect(find.text('Showing all 32 expenses'), findsOneWidget);
        expect(find.byTooltip('Next page'), findsNothing);
        final list = find.byKey(const ValueKey('expense20-history-list'));
        final viewport =
            find.byKey(const ValueKey('expense20-history-viewport'));
        await tester.ensureVisible(viewport);
        await tester.dragUntilVisible(
            find.byKey(const ValueKey('expense20-history-row-row-31')),
            viewport,
            const Offset(0, -250));
        await tester.pumpAndSettle();
        expect(find.text('Visit expense row-31'), findsOneWidget);
        final controller = tester.widget<ListView>(list).controller!;
        expect(controller.offset, greaterThan(0));
        expect(
            tester
                .widget<SizedBox>(
                    find.byKey(const ValueKey('expense20-summary-reveal')))
                .height,
            0);
        final headerBefore =
            tester.getTopLeft(find.text('My Expense History')).dy;
        await tester.drag(list, const Offset(0, 80));
        await tester.pumpAndSettle();
        expect(
            tester
                .widget<SizedBox>(
                    find.byKey(const ValueKey('expense20-summary-reveal')))
                .height,
            isNull);
        expect(tester.getTopLeft(find.text('My Expense History')).dy,
            greaterThan(headerBefore));
        await tester.dragUntilVisible(
            find.byKey(const ValueKey('expense20-history-row-row-31')),
            viewport,
            const Offset(0, -250));
        await tester.pumpAndSettle();
        // The heading remains in place while the history body scrolls.
        expect(find.text('Amount (₹)'), findsOneWidget);
        final lastRow =
            find.byKey(const ValueKey('expense20-history-row-row-31'));
        await expense20Tap(
            tester, find.descendant(of: lastRow, matching: find.text('View')));
        expect(
            find.descendant(
                of: find.byType(Dialog),
                matching: find.text('Visit expense row-31')),
            findsWidgets);
        await expense20Tap(tester, find.text('Close'));
        await expense20Tap(tester, find.byTooltip('Clear filters'));
        expect(controller.offset, 0);
        expect(find.text('Visit expense row-0'), findsOneWidget);
        if (size.width == 390) {
          await tester.ensureVisible(viewport);
          final mainScroll = tester
              .widget<SingleChildScrollView>(
                  find.byType(SingleChildScrollView).first)
              .controller!;
          expect(mainScroll.offset, greaterThan(0));
          final before = mainScroll.offset;
          await tester.drag(list, const Offset(0, 300));
          await tester.pumpAndSettle();
          expect(mainScroll.offset, lessThan(before));
        }
        expect(api.expenseLoads, 1);
        expect(api.writes, 0);
        expect(tester.takeException(), isNull);
      }, () => api.client);
      await tester.pumpWidget(const SizedBox());
      await tester.binding.setSurfaceSize(null);
    });
  }

  testWidgets('TA edit uses existing PUT contract and one-edit restriction',
      (tester) async {
    final api = Expense20ApiFixture();
    await http.runWithClient(() async {
      await expense20Pump(tester);
      await expense20Tap(
          tester, find.byKey(const ValueKey('expense20-close-add')));
      await tester.enterText(find.byKey(const ValueKey('expense20-search')),
          'Visit expense edited');
      await tester.pumpAndSettle();
      await expense20Tap(tester, find.text('View'));
      expect(find.text('Edit Expense'), findsNothing);
      await expense20Tap(tester, find.text('Close'));
      await tester.enterText(
          find.byKey(const ValueKey('expense20-search')), 'Visit expense ta');
      await tester.pumpAndSettle();
      await expense20Tap(tester, find.text('View'));
      await expense20Tap(tester, find.text('Edit Expense'));
      await expense20Tap(
          tester, find.byKey(const ValueKey('expense20-submit')));
      await expense20Tap(tester, find.text('Submit claim'));
      expect(api.method, 'PUT');
      expect(api.payload!['date'], expense20Today);
      expect(api.payload!['amount'], 12);
      expect(api.payload!['travelDetails'][0]['km'], 10);
      expect(api.expenseLoads, 2);
    }, () => api.client);
    await tester.pumpWidget(const SizedBox());
    await tester.binding.setSurfaceSize(null);
  });

  testWidgets(
      'Other Expense requires bill, uploads it, and keeps original amount',
      (tester) async {
    final api = Expense20ApiFixture();
    final temp = await tester.runAsync(
        () => Directory.systemTemp.createTemp('expense20-bill-test-'));
    final bill = File('${temp!.path}/bill.png');
    await tester.runAsync(() => bill.writeAsBytes(base64Decode(
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=')));
    const channel = MethodChannel('plugins.flutter.io/image_picker');
    tester.binding.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async => bill.path);
    addTearDown(() async {
      tester.binding.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
      await temp.delete(recursive: true);
    });
    await http.runWithClient(() async {
      await expense20Pump(tester);
      await expense20Tap(
          tester, find.byKey(const ValueKey('expense20-category-extra')));
      await tester.enterText(
          find.byKey(const ValueKey('expense20-other-amount')), '123.45');
      await expense20Tap(
          tester, find.byKey(const ValueKey('expense20-submit')));
      expect(api.writes, 0);
      expect(find.text('Please attach a bill photo.'), findsOneWidget);
      await expense20Tap(tester, find.text('Capture bill / invoice photo'));
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 100));
      });
      await tester.pump();
      await tester
          .ensureVisible(find.byKey(const ValueKey('expense20-submit')));
      await tester.runAsync(() async {
        await tester.tap(find.byKey(const ValueKey('expense20-submit')));
        await Future<void>.delayed(const Duration(milliseconds: 200));
      });
      await tester.pumpAndSettle();
      expect(api.uploads, 1);
      expect(api.writes, 1);
      expect(api.payload!['category'], 'extra');
      expect(api.payload!['amount'], 123.45);
      expect(api.payload!['bill'], 'https://example.test/bill.jpg');
      expect(api.payload!['description'], isNot(contains('[DCR allowance]')));
      expect(tester.takeException(), isNull);
    }, () => api.client);
    await tester.pumpWidget(const SizedBox());
    await tester.binding.setSurfaceSize(null);
  });
}
