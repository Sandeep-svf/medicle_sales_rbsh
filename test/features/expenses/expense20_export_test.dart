import 'dart:async';
import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'expense20_screen_test.dart' as fixture;

class _SavePicker extends FilePicker {
  Uint8List? bytes;
  String? filename;
  Completer<String?>? pending;
  bool fail = false;
  bool cancel = false;
  int calls = 0;

  @override
  Future<String?> saveFile({
    String? dialogTitle,
    String? fileName,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    Uint8List? bytes,
    bool lockParentWindow = false,
  }) async {
    calls++;
    this.bytes = bytes;
    filename = fileName;
    expect(type, FileType.custom);
    expect(allowedExtensions, ['pdf']);
    if (fail) throw PlatformException(code: 'save-failed');
    if (pending != null) return pending!.future;
    return cancel ? null : '/downloads/$fileName';
  }
}

Future<void> _choose(WidgetTester tester, String section, String title) async {
  await fixture.expense20Tap(
      tester, find.byKey(ValueKey('expense20-export-$section')));
  await fixture.expense20Tap(tester, find.text(title));
  await _finishExport(tester);
}

Future<void> _finishExport(WidgetTester tester) async {
  for (var i = 0; i < 50; i++) {
    await tester
        .runAsync(() => Future<void>.delayed(const Duration(milliseconds: 10)));
    await tester.pump(const Duration(milliseconds: 10));
    if (find.text('Preparing PDF…').evaluate().isEmpty) break;
  }
  await tester.pumpAndSettle();
}

void _checkPdf(Uint8List? bytes) {
  expect(bytes, isNotNull);
  expect(ascii.decode(bytes!.take(5).toList()), '%PDF-');
  expect(bytes.length, greaterThan(1000));
}

void main() {
  late _SavePicker picker;
  FilePicker? original;
  setUp(() {
    SharedPreferences.setMockInitialValues(
        {'user_id': 'user', 'token': 'test-token'});
    try {
      original = FilePicker.platform;
    } catch (_) {
      original = null;
    }
    picker = _SavePicker();
    FilePicker.platform = picker;
  });
  tearDown(() {
    if (original != null) FilePicker.platform = original!;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
            const MethodChannel('net.nfet.printing'), null);
  });

  testWidgets('history download includes every month', (tester) async {
    final api = fixture.Expense20ApiFixture();
    await http.runWithClient(() async {
      await fixture.expense20Pump(tester);
      await fixture.expense20Tap(
          tester, find.byKey(const ValueKey('expense20-close-add')));
      await fixture.expense20Tap(
          tester, find.byKey(const ValueKey('expense20-export-history')));
      expect(find.text('5 saved expenses, every month'), findsNWidgets(2));
      expect(find.text('5 matching expenses'), findsNWidgets(2));
      await fixture.expense20Tap(
          tester, find.text('Download PDF - all expenses'));
      await _finishExport(tester);
      _checkPdf(picker.bytes);
      expect(picker.filename, startsWith('expenses_all_'));
      expect(find.text('Expense PDF saved successfully.'), findsOneWidget);

      expect(api.writes, 0);
      expect(api.expenseLoads, 1);
    }, () => api.client);
    await tester.pumpWidget(const SizedBox());
    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('history shares all filtered results beyond the visible page',
      (tester) async {
    final api = fixture.Expense20ApiFixture()
      ..customExpenses = [
        ...List.generate(
            15,
            (i) =>
                fixture.expense20Fixture('ta-$i', 'travel', 'approved', '10')),
        fixture.expense20Fixture('other', 'extra', 'rejected', '20'),
        fixture.expense20Fixture('da', 'daily', 'pending', '30'),
      ];
    final shares = <MethodCall>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('net.nfet.printing'),
            (call) async {
      if (call.method == 'sharePdf') shares.add(call);
      return 1;
    });
    await http.runWithClient(() async {
      await fixture.expense20Pump(tester, size: const Size(800, 1100));
      await fixture.expense20Tap(
          tester, find.byKey(const ValueKey('expense20-close-add')));
      await tester.enterText(
          find.byKey(const ValueKey('expense20-search')), 'Visit expense ta-');
      await tester.pump();
      await fixture.expense20Tap(
          tester, find.byKey(const ValueKey('expense20-export-history')));
      expect(find.text('15 matching expenses'), findsNWidgets(2));
      await fixture.expense20Tap(
          tester, find.text('Share PDF - current selection'));
      await _finishExport(tester);
      expect(shares, hasLength(1));
      final arguments = shares.single.arguments as Map;
      _checkPdf(arguments['doc'] as Uint8List);
      expect(arguments['name'], endsWith('.pdf'));
      expect(arguments['subject'], contains('Expense statement'));
      expect(arguments['subject'], contains('Search: Visit expense ta-'));
      expect(arguments['w'], greaterThan(0));
      expect(arguments['h'], greaterThan(0));
      expect(picker.calls, 0);
      expect(api.writes, 0);
      expect(api.expenseLoads, 1);
    }, () => api.client);
    await tester.pumpWidget(const SizedBox());
    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('cancel and save failure preserve expenses and allow retry',
      (tester) async {
    final api = fixture.Expense20ApiFixture();
    picker.cancel = true;
    await http.runWithClient(() async {
      await fixture.expense20Pump(tester);
      await fixture.expense20Tap(
          tester, find.byKey(const ValueKey('expense20-close-add')));
      await _choose(tester, 'history', 'Download PDF - current selection');
      _checkPdf(picker.bytes);
      expect(find.text('Expense PDF saved successfully.'), findsNothing);
      expect(find.textContaining('Unable to save'), findsNothing);
      picker.cancel = false;
      picker.fail = true;
      await _choose(tester, 'history', 'Download PDF - current selection');
      expect(find.text('Unable to save the expense PDF. Please try again.'),
          findsOneWidget);
      picker.fail = false;
      await _choose(tester, 'history', 'Download PDF - current selection');
      expect(find.text('Expense PDF saved successfully.'), findsOneWidget);
      expect(picker.calls, 3);
      expect(api.writes, 0);
      expect(api.expenseLoads, 1);
      expect(tester.takeException(), isNull);
    }, () => api.client);
    await tester.pumpWidget(const SizedBox());
    await tester.binding.setSurfaceSize(null);
  });

  testWidgets(
      'empty selection disables selection export but keeps all expenses',
      (tester) async {
    final api = fixture.Expense20ApiFixture();
    await http.runWithClient(() async {
      await fixture.expense20Pump(tester);
      await fixture.expense20Tap(
          tester, find.byKey(const ValueKey('expense20-close-add')));
      await tester.enterText(
          find.byKey(const ValueKey('expense20-search')), 'no matching claim');
      await tester.pump();
      await fixture.expense20Tap(
          tester, find.byKey(const ValueKey('expense20-export-history')));
      final items = tester.widgetList<PopupMenuItem>(
          find.byWidgetPredicate((widget) => widget is PopupMenuItem));
      expect(items.map((item) => item.enabled).toList(),
          [true, true, false, false]);
      expect(find.text('0 matching expenses'), findsNWidgets(2));
      expect(api.writes, 0);
    }, () => api.client);
    await tester.pumpWidget(const SizedBox());
    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('pending save disables duplicate exports in both sections',
      (tester) async {
    final api = fixture.Expense20ApiFixture();
    picker.pending = Completer<String?>();
    await http.runWithClient(() async {
      await fixture.expense20Pump(tester);
      await fixture.expense20Tap(
          tester, find.byKey(const ValueKey('expense20-close-add')));
      await _choose(tester, 'history', 'Download PDF - all expenses');
      expect(picker.calls, 1);
      final menus = tester.widgetList<PopupMenuButton>(
          find.byWidgetPredicate((widget) => widget is PopupMenuButton));
      expect(menus.map((menu) => menu.enabled), everyElement(false));
      picker.pending!.complete(null);
      await _finishExport(tester);
      expect(find.text('Preparing PDF…'), findsNothing);
      expect(api.writes, 0);
      expect(api.expenseLoads, 1);
    }, () => api.client);
    await tester.pumpWidget(const SizedBox());
    await tester.binding.setSurfaceSize(null);
  });
}
