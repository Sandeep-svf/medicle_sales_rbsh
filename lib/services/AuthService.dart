// services/mailInbox/auth_service.dart


import 'outlook_auth.dart';

class AuthService {
  static final OutlookAuth _auth = OutlookAuth();

  static Future<void> initMSAL() async {
    await _auth.init();
  }

  static Future<String?> signIn() async {
    final token = await _auth.signIn();
    return token.contains("eyJ") ? token : null; // crude JWT check
  }

  static Future<void> signOut() async {
    await _auth.signOut();
  }
}
