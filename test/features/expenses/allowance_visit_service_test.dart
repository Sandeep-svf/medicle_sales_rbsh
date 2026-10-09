import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:medicle_sales_rbsh/features/expenses/services/allowance_visit_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({'token': 'test-token'}));

  test('counts confirmed visits for the selected day and user only', () async {
    var requests = 0;
    final visits = await http.runWithClient(
      () => AllowanceVisitService().fetchForDay('user', DateTime(2026, 10, 1)),
      () => MockClient((request) async {
        requests++;
        expect(request.url.queryParameters,
            {'startDate': '2026-10-01', 'endDate': '2026-10-01'});
        expect(request.headers['Authorization'], 'Bearer test-token');
        return http.Response(
            jsonEncode([
              {
                'id': 'a',
                'user_id': 'user',
                'date': '2026-10-01',
                'confirmed': true
              },
              {
                'id': 'a',
                'user_id': 'user',
                'date': '2026-10-01',
                'confirmed': true
              },
              {
                'id': 'b',
                'user_id': 'user',
                'date': '2026-10-01',
                'confirmed': false
              },
              {
                'id': 'c',
                'user_id': 'user',
                'date': '2026-09-30',
                'confirmed': true
              },
              {
                'id': 'd',
                'user_id': 'other',
                'date': '2026-10-01',
                'confirmed': true
              },
            ]),
            200);
      }),
    );
    expect(requests, 2);
    expect(visits.doctor!.confirmed, 1);
    expect(visits.chemist!.confirmed, 1);
    expect(visits.doctor!.total, 2);
    expect(visits.doctor!.scheduled, 1);
    expect(visits.chemist!.total, 2);
    expect(visits.chemist!.scheduled, 1);
    expect(visits.total, 4);
    expect(visits.scheduled, 2);
    expect(visits.confirmed, 2);
  });

  test('failed visit fetch is not treated as zero completed calls', () async {
    await http.runWithClient(() async {
      await expectLater(
          AllowanceVisitService().fetchForDay('user', DateTime(2026, 10, 1)),
          throwsA(isA<AllowanceVisitException>()));
    }, () => MockClient((_) async => http.Response('{}', 500)));
  });
}
