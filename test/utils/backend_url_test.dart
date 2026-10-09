import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:medicle_sales_rbsh/utils/http/http_client.dart';
import 'package:medicle_sales_rbsh/utils/local_storage/auth_manager.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    THttpHelper.resetCompany();
  });

  test('login persists the backend and normalizes API paths', () async {
    await THttpHelper.configureCompany(
      backendUrl: ' https://api.example.com/ ', logoUrl: '/logo.png');
    expect(await AuthManager().getBackendUrl(), 'https://api.example.com');
    expect(THttpHelper.baseUrl, 'https://api.example.com/api');
    expect(THttpHelper.companyLogoUrl, 'https://api.example.com/logo.png');
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(AuthManager.backendUrlKey), 'https://api.example.com');

    await THttpHelper.configureCompany(backendUrl: 'https://second.example.com/api/');
    expect(THttpHelper.baseUrl, 'https://second.example.com/api');
  });

  test('startup restores the dedicated backend ahead of legacy data', () async {
    SharedPreferences.setMockInitialValues({
      'backend_url': 'https://saved.example.com',
      'user_data': jsonEncode({'company': {'backendUrl': 'https://old.example.com'}}),
    });
    await THttpHelper.initialize();
    expect(THttpHelper.baseUrl, 'https://saved.example.com/api');
  });

  test('API requests use the saved backend after a restart', () async {
    await THttpHelper.configureCompany(backendUrl: 'https://saved.example.com');
    THttpHelper.resetCompany();
    await THttpHelper.initialize();
    await http.runWithClient(() async {
      await THttpHelper.post('expenses', {'category': 'travel'});
    }, () => MockClient((request) async {
      expect(request.url.toString(), 'https://saved.example.com/api/expenses');
      return http.Response('{"success":true}', 201);
    }));
  });

  test('existing login migrates its company backend on startup', () async {
    SharedPreferences.setMockInitialValues({
      'user_data': jsonEncode({'company': {'backendUrl': 'https://legacy.example.com'}}),
    });
    await THttpHelper.initialize();
    expect(await AuthManager().getBackendUrl(), 'https://legacy.example.com');
    expect(THttpHelper.baseUrl, 'https://legacy.example.com/api');
  });

  test('logout clears stored and active backend without restoring old login', () async {
    await THttpHelper.configureCompany(backendUrl: 'https://saved.example.com');
    await AuthManager().logout();
    expect(await AuthManager().getBackendUrl(), isNull);
    expect(THttpHelper.baseUrl, THttpHelper.defaultBaseUrl);
    await THttpHelper.initialize();
    expect(THttpHelper.baseUrl, THttpHelper.defaultBaseUrl);
  });

  test('new login without backend clears the previous company', () async {
    await THttpHelper.configureCompany(backendUrl: 'https://old.example.com');
    await THttpHelper.configureCompany();
    expect(await AuthManager().getBackendUrl(), isNull);
    expect(THttpHelper.baseUrl, THttpHelper.defaultBaseUrl);
  });
}
