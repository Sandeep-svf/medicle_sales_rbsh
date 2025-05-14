import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:medicle_sales_rbsh/utils/http/http_client.dart';
import '../model/TicketsModel.dart';


class TicketController {
  final String userId;
  final String token;

  final String baseUrl = THttpHelper.baseUrl;

  TicketController({required this.userId, required this.token});

  // Fetch tickets from the API
  Future<List<TicketModel>> fetchTickets() async {
    final url = Uri.parse('$baseUrl/tickets/user?userId=$userId');
    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => TicketModel.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load tickets');
    }
  }

  // Create a new ticket
  Future<void> createTicket(String title, String description, String? imageBase64) async {
    final url = Uri.parse('${THttpHelper.baseUrl}/tickets');
    final response = await http.post(url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'title': title,
          'description': description,
          'userName': 'Refer in DB',
          'userId': userId,
          'image': imageBase64 ?? '',
        }));

    if (response.statusCode != 200) {
      throw Exception('Failed to create ticket');
    }
  }

  // Convert image to Base64
  Future<String> convertImageToBase64(XFile imageFile) async {
    final bytes = await imageFile.readAsBytes();
    return base64Encode(bytes);
  }
}
