/*
import 'package:flutter/services.dart';
import 'package:msal_flutter/msal_flutter.dart';

class OutlookAuth {
  late PublicClientApplication pca;
  bool _initialized = false;

  static const String authority =
      "https://login.microsoftonline.com/afa6d619-1ff5-4eb5-b37d-6177c2313faa";
  static const String redirectUri =
      "msalc183fe08-328a-4ca4-b7e9-79215949e831://auth";
  static const String clientId = "c183fe08-328a-4ca4-b7e9-79215949e831";

  final List<String> scopes = [
    "User.Read",
    "Mail.Read",
    "Mail.Send",
    "Mail.ReadWrite",
  ];

  Future<void> init() async {
    if (_initialized) return;
    pca = await PublicClientApplication.createPublicClientApplication(
      clientId,
      authority: authority,
      iosRedirectUri: redirectUri,
    );
    _initialized = true;
  }

  Future<String> signIn() async {
    await init();
    try {
      final result = await pca.acquireToken(scopes);
      return result;
    } on MsalUserCancelledException {
      return " User cancelled";
    } on MsalNoAccountException {
      return " No account";
    } on MsalInvalidConfigurationException {
      return " Invalid configuration";
    } on MsalInvalidScopeException {
      return " Invalid scope";
    } on MsalException catch (e) {
      return " MSAL error: ${e.toString()}";
    } catch (e) {
      return " Unexpected error: $e";
    }
  }

  Future<String> signInSilent() async {
    await init();
    try {
      final result = await pca.acquireTokenSilent(scopes);
      return result;
    } catch (e) {
      return "❌ Silent token error: $e";
    }
  }

  Future<String> signOut() async {
    await init();
    try {
      await pca.logout();
      return "✅ Logged out";
    } catch (e) {
      return "❌ Logout error: $e";
    }
  }
}
*/
