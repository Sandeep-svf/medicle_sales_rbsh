// services/mailInbox/mail_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class MailService {
  static Future<List<dynamic>> getEmails(String token) async {
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
      print("Error fetching emails: ${response.body}");
      return [];
    }
  }

  static Future<bool> sendEmail(String token, String to, String subject, String body) async {
    final emailPayload = {
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
        ],
      },
      "saveToSentItems": "true"
    };

    final response = await http.post(
      Uri.parse("https://graph.microsoft.com/v1.0/me/sendMail"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: json.encode(emailPayload),
    );

    return response.statusCode == 202;
  }
}
