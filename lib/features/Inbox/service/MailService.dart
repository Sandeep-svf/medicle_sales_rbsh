import 'dart:convert';
import 'package:http/http.dart' as http;

class MailService {

  /// 📥 READ INBOX
  static Future<List<dynamic>> getInbox(String token) async {
    final response = await http.get(
      Uri.parse('https://graph.microsoft.com/v1.0/me/messages'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return data['value'] ?? [];
    } else {
      throw Exception("Error fetching emails: ${response.body}");
    }
  }

  /// 📤 SEND EMAIL
  static Future<bool> sendMail({
    required String token,
    required String to,
    required String subject,
    required String body,
  }) async {
    final response = await http.post(
      Uri.parse('https://graph.microsoft.com/v1.0/me/sendMail'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "message": {
          "subject": subject,
          "body": {
            "contentType": "Text",
            "content": body,
          },
          "toRecipients": [
            {
              "emailAddress": {
                "address": to,
              }
            }
          ]
        },
        "saveToSentItems": true
      }),
    );

    return response.statusCode == 202;
  }
}
