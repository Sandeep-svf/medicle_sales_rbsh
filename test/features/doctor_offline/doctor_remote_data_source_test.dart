import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:medicle_sales_rbsh/features/doctor_offline/data/remote/doctor_remote_data_source.dart';

import 'doctor_test_fixtures.dart';

void main() {
  test('bootstrap uses the project API prefix once and no page parameter',
      () async {
    late http.Request captured;
    final client = MockClient((request) async {
      captured = request;
      return http.Response(
        jsonEncode({
          'success': true,
          'snapshotVersion': 1,
          'currentServerVersion': 1,
          'nextCursor': null,
          'hasMore': false,
          'doctors': [fullDoctorJson()],
        }),
        200,
        headers: {'content-type': 'application/json'},
      );
    });
    final remote = HttpDoctorRemoteDataSource(
      tokenProvider: const _TokenProvider('secret-token'),
      client: client,
      baseUrl: 'https://example.test/api',
    );

    final page = await remote.fetchBootstrap();

    expect(captured.url.path, '/api/doctors/sync/bootstrap');
    expect(captured.url.queryParameters, {'limit': '500'});
    expect(captured.url.queryParameters, isNot(contains('page')));
    expect(captured.headers['Authorization'], 'Bearer secret-token');
    expect(page.doctors.single.name, 'sam 123');
    await remote.close();
  });

  test('bootstrap continuation sends the opaque cursor unchanged', () async {
    const cursor = 'eyJsYXN0SWQiOiJhL2I9PSIsInNuYXBzaG90IjoyfQ==';
    late Uri captured;
    final remote = HttpDoctorRemoteDataSource(
      tokenProvider: const _TokenProvider('token'),
      client: MockClient((request) async {
        captured = request.url;
        return http.Response(
          jsonEncode({
            'success': true,
            'snapshotVersion': 2,
            'currentServerVersion': 2,
            'nextCursor': null,
            'hasMore': false,
            'doctors': <Object>[],
          }),
          200,
        );
      }),
      baseUrl: 'https://example.test',
    );

    await remote.fetchBootstrap(cursor: cursor);

    expect(captured.path, '/api/doctors/sync/bootstrap');
    expect(captured.queryParameters['cursor'], cursor);
    expect(captured.queryParameters['limit'], '500');
    await remote.close();
  });

  test('delta sends the exact version string and optional head office',
      () async {
    late Uri captured;
    final requestedVersion = BigInt.parse('900719925474099312345');
    final remote = HttpDoctorRemoteDataSource(
      tokenProvider: const _TokenProvider('token'),
      client: MockClient((request) async {
        captured = request.url;
        return http.Response(
          jsonEncode({
            'success': true,
            'currentServerVersion': requestedVersion.toString(),
            'afterVersion': requestedVersion.toString(),
            'nextAfterVersion': requestedVersion.toString(),
            'hasMore': false,
            'upserts': <Object>[],
            'deletes': <Object>[],
          }),
          200,
        );
      }),
      baseUrl: 'https://example.test/api/',
    );

    final page = await remote.fetchDelta(
      afterVersion: requestedVersion,
      headOfficeId: 'head-office-1',
    );

    expect(captured.path, '/api/doctors/sync');
    expect(
        captured.queryParameters['afterVersion'], requestedVersion.toString());
    expect(captured.queryParameters['headOfficeId'], 'head-office-1');
    expect(page.afterVersion, requestedVersion);
    await remote.close();
  });
}

class _TokenProvider implements DoctorAuthTokenProvider {
  const _TokenProvider(this.token);

  final String? token;

  @override
  Future<String?> readToken() async => token;
}
