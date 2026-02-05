import 'dart:developer';
import 'package:flutter_appauth/flutter_appauth.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final FlutterAppAuth _appAuth = const FlutterAppAuth();

  static const String _clientId =
      'f8737deb-e699-47ca-9cba-4d3e930f7a10';

  static const String _redirectUrl =
      'msauth://com.rbsh.medicle_sales_rbsh/auth';

  static const String _discoveryUrl =
      'https://login.microsoftonline.com/common/v2.0/.well-known/openid-configuration';

  static const List<String> _scopes = [
    'openid',
    'profile',
    'offline_access',
    'https://graph.microsoft.com/User.Read',
    'https://graph.microsoft.com/Mail.Read',
    'https://graph.microsoft.com/Mail.Send',
  ];

  Future<String?> signIn() async {
    try {
      print('SAMTEST: Starting Microsoft login');

      final result = await _appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          _clientId,
          _redirectUrl,
          discoveryUrl: _discoveryUrl,
          scopes: _scopes,
          promptValues: ['select_account'],
        ),
      );

      if (result == null) {
        print('SAMTEST: result is null');
        return null;
      }

      print('SAMTEST: ACCESS TOKEN RECEIVED');
      return result.accessToken;
    } catch (e, s) {
      log('AUTH ERROR', error: e, stackTrace: s);
      print('AUTH ERROR $e $s');
      return null;
    }
  }
}
