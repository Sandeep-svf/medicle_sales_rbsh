import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medicle_sales_rbsh/features/dashboard/screen/home20/home20_screen.dart';
import 'package:medicle_sales_rbsh/features/dashboard/screen/home20/home20_widgets.dart';

Map<String, dynamic> response() => {
      'success': true,
      'data': {
        'user': {'name': 'Kshitiz Maurya', 'role': 'User'},
        'period': {'month': 10, 'year': 2026, 'monthName': 'October'},
        'targets': {
          'monthlyTarget': 60000,
          'achieved': 30000,
          'remaining': 30000,
          'achievementPercentage': 50,
          'targetPeriod': 'September 2025',
          'displayMessage': 'Latest target: September 2025'
        },
        'todayBeatAssigned': {
          'beat_name': 'Assigned test beat',
          'doctors_count': 17,
          'chemists_count': 0,
          'stockists_count': 0,
          'status': 'Approved',
          'day_type': 'Joint work'
        },
        'visits': {
          'doctor': {'confirmed': 0, 'total': 0},
          'chemist': {'confirmed': 0, 'total': 0},
          'stockist': {'confirmed': 0, 'total': 0},
          'confirmed': 0,
          'total': 0,
          'approved': 0
        },
        'expenses': {
          'total': 0,
          'pending': 0,
          'approved': 0,
          'rejected': 0,
          'pendingAmount': 0,
          'approvedAmount': 0,
          'rejectedAmount': 0
        },
      },
    };

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    final fonts = FontLoader('Poppins');
    fonts.addFont(rootBundle.load('assets/fonts/Poppins-Regular.ttf'));
    await fonts.load();
    final icons = FontLoader('MaterialIcons');
    icons.addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await icons.load();
  });
  for (final size in [
    const Size(1366, 1024),
    const Size(800, 1100),
    const Size(390, 844),
    const Size(844, 390)
  ]) {
    testWidgets('Home 2.0 renders API data and samples at $size',
        (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final key = GlobalKey();
      var calls = 0;
      await tester.pumpWidget(MaterialApp(
          theme: ThemeData(fontFamily: 'Poppins'),
          home: Scaffold(
              body: RepaintBoundary(
                  key: key,
                  child: Home20Screen(loadDashboard: () async {
                    calls++;
                    return response();
                  })))));
      await tester.pumpAndSettle();
      expect(calls, 1);
      expect(find.byKey(const ValueKey('home20-clock')), findsOneWidget);
      expect(
          tester
              .getRect(find.byKey(const ValueKey('home20-header-controls')))
              .right,
          closeTo(size.width - (size.width >= 650 ? 12 : 8), 0.1));
      expect(
          find.byWidgetPredicate((widget) =>
              widget is Image &&
              widget.semanticLabel == 'Sample pharmaceutical product'),
          findsNWidgets(6));
      await tester.tap(find.byTooltip('User profile'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Kshitiz Maurya'), findsOneWidget);
      expect(find.text('₹60,000'), findsWidgets);
      expect(find.text('Assigned test beat'), findsOneWidget);
      expect(find.text('0 / 0'), findsWidgets);
      expect(find.text('6 / 10'), findsNothing);
      expect(find.text('SAMPLE PREVIEW'), findsNothing);
      expect(find.byTooltip('Refresh dashboard'), findsNothing);
      if (Platform.environment['HOME20_CAPTURE'] == '1') {
        await tester.runAsync(() => precacheImage(
            const AssetImage('assets/images/home20_product.png'),
            key.currentContext!));
        await tester.pumpAndSettle();
        await tester.runAsync(() async {
          final boundary =
              key.currentContext!.findRenderObject() as RenderRepaintBoundary;
          final image = await boundary.toImage(pixelRatio: 1);
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          await File('/private/tmp/home20-${size.width.toInt()}.png')
              .writeAsBytes(bytes!.buffer.asUint8List());
          image.dispose();
        });
      }
      await tester
          .widget<RefreshIndicator>(find.byType(RefreshIndicator))
          .onRefresh();
      await tester.pumpAndSettle();
      expect(calls, 2);
      if (size.width >= 650) {
        Finder card(String title) => find.byWidgetPredicate(
            (widget) => widget is Home20Card && widget.title == title);
        await tester.ensureVisible(card('Important updates'));
        await tester.pumpAndSettle();
        final productsRect = tester.getRect(card('Top products'));
        final updatesRect = tester.getRect(card('Important updates'));
        expect(productsRect.top, closeTo(updatesRect.top, 0.1));
        expect(productsRect.bottom, closeTo(updatesRect.bottom, 0.1));
        expect(tester.getTopLeft(find.text('Top products')).dy,
            closeTo(tester.getTopLeft(find.text('Important updates')).dy, 0.1));
      }
      await tester.ensureVisible(find.text('My territory'));
      await tester.pumpAndSettle();
      Finder filter(String label) => find.descendant(
          of: find.byType(ChoiceChip), matching: find.text(label));
      final filterY = tester.getTopLeft(filter('Primary')).dy;
      expect(tester.getTopLeft(filter('Secondary')).dy, filterY);
      expect(tester.getTopLeft(filter('New launch')).dy, filterY);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    });
  }

  for (final size in [const Size(390, 844), const Size(844, 390)]) {
    testWidgets('menu greeting and notification-side actions fit $size',
        (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      Map<String, dynamic>? user;
      await tester.pumpWidget(MaterialApp(
          home: Scaffold(
        appBar: AppBar(
          leading: IconButton(onPressed: () {}, icon: const Icon(Icons.menu)),
          titleSpacing: 4,
          centerTitle: false,
          title: const Home20AppBarGreeting(
              user: {'name': 'Kshitiz Maurya', 'role': 'User'}),
          actions: [
            const Home20Clock(compact: true),
            const Home20ProfileButton(
                user: {'name': 'Kshitiz Maurya', 'role': 'User'}),
            IconButton(onPressed: () {}, icon: const Icon(Icons.notifications))
          ],
        ),
        body: Home20Screen(
            showHeader: false,
            onUserLoaded: (value) => user = value,
            loadDashboard: () async => response()),
      )));
      await tester.pumpAndSettle();
      expect(user?['name'], 'Kshitiz Maurya');
      expect(find.byType(Home20Header), findsNothing);
      expect(find.byTooltip('Refresh dashboard'), findsNothing);
      expect(find.text('SAMPLE PREVIEW'), findsNothing);
      expect(find.byType(Home20Clock), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.tap(find.byTooltip('User profile'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
      await tester.pumpWidget(const SizedBox());
    });
  }

  testWidgets('failed dashboard request shows retry, then loads data',
      (tester) async {
    var calls = 0;
    await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: Home20Screen(loadDashboard: () async {
      if (++calls == 1) throw const SocketException('offline');
      return response();
    }))));
    await tester.pumpAndSettle();
    expect(find.text('Unable to load Home 2.0'), findsOneWidget);
    expect(find.text('₹60,000'), findsNothing);
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    expect(find.text('₹60,000'), findsWidgets);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets(
      'refresh failure preserves live data instead of replacing with sample figures',
      (tester) async {
    var calls = 0;
    await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: Home20Screen(loadDashboard: () async {
      if (++calls > 1) throw const SocketException('offline');
      return response();
    }))));
    await tester.pumpAndSettle();
    await tester
        .widget<RefreshIndicator>(find.byType(RefreshIndicator))
        .onRefresh();
    await tester.pumpAndSettle();
    expect(find.textContaining('Showing last loaded data.'), findsOneWidget);
    expect(find.text('₹60,000'), findsWidgets);
    expect(find.text('₹25,000'), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets(
      'banner auto advances every three seconds and supports manual navigation',
      (tester) async {
    await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: Home20BannerSlider())));
    final pages = tester.widget<PageView>(find.byType(PageView)).controller!;
    expect(pages.page, 0);
    await tester.pump(const Duration(seconds: 3));
    await tester.pump(const Duration(milliseconds: 500));
    expect(pages.page, 1);
    await tester.tap(find.byTooltip('Next banner'));
    await tester.pumpAndSettle();
    expect(pages.page, 2);
    await tester.tap(find.byTooltip('Previous banner'));
    await tester.pumpAndSettle();
    expect(pages.page, 1);
    await tester.pumpWidget(const SizedBox());
    expect(tester.takeException(), isNull);
  });

  testWidgets('banner honors reduced motion and keeps manual controls',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(
        home: MediaQuery(
            data: MediaQueryData(disableAnimations: true),
            child: Scaffold(body: Home20BannerSlider()))));
    final pages = tester.widget<PageView>(find.byType(PageView)).controller!;
    await tester.pump(const Duration(seconds: 6));
    expect(pages.page, 0);
    await tester.tap(find.byTooltip('Next banner'));
    await tester.pump();
    expect(pages.page, 1);
    await tester.pumpWidget(const SizedBox());
    expect(tester.takeException(), isNull);
  });
}
