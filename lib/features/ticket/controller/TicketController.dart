import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
// Ensure this import path is correct in your actual project
import 'package:medicle_sales_rbsh/utils/local_storage/auth_manager.dart';

import '../model/ticketmodal.dart';
 // Importing the model file created above

class TicketController extends GetxController {
  RxList<TicketModel> tickets = <TicketModel>[].obs; // List of tickets
  RxBool isLoading = true.obs; // Loading state for tickets list

  final String _debugPrefix = '[TicketController]';

  @override
  void onInit() {
    super.onInit();
    fetchTickets(); // Fetch tickets on init
  }

  // Log function
  void _debug(String message) {
    print('$_debugPrefix $message');
  }

  // Fetch all tickets using Barrier Token
  Future<void> fetchTickets() async {
    try {
      isLoading.value = true;

      AuthManager authManager = AuthManager();
      final token = await authManager.getAuthToken();

      if (token == null || token.isEmpty) {
        _debug('Error: No token found!');
        isLoading.value = false;
        return;
      }

      String barrierToken = token.toString();

      _debug('Fetching tickets with token: $barrierToken');

      final response = await http.get(
        Uri.parse('https://test.gluckscare.com/api/tickets'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $barrierToken',
        },
      );

      _debug('Response Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final ticketsResponse = TicketsResponseModel.fromJson(data);

        // Update the reactive list of tickets
        tickets.value = ticketsResponse.data ?? [];
        _debug('Tickets fetched successfully. ${ticketsResponse.data?.length ?? 0} tickets found.');
      } else {
        _debug('Failed to load tickets, Status Code: ${response.statusCode}');
      }
    } catch (e) {
      _debug('Error fetching tickets: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Create a new ticket
  Future<bool> createTicket(String title, String description, String image) async {
    try {
      final token = await AuthManager().getAuthToken();
      if (token == null || token.isEmpty) {
        _debug('Error: No token found!');
        return false;
      }

      if (title.trim().isEmpty || description.trim().isEmpty) {
        _debug('Validation failed: Title/Description is empty');
        return false;
      }

      final payload = <String, dynamic>{
        'title': title.trim(),
        'description': description.trim(),
        if (image.trim().isNotEmpty) 'image': image.trim(),
      };

      _debug('Creating a new ticket...');

      final response = await http.post(
        Uri.parse('https://test.gluckscare.com/api/tickets'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(payload),
      );

      _debug('Response Status Code: ${response.statusCode}');
      _debug('Response bosy: ${response.body}');
      _debug('Response image: ${image.trim()}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Refresh list
        await fetchTickets();
        return true;
      }

      _debug('Failed to create ticket, Status Code: ${response.statusCode}');
      return false;
    } catch (e) {
      _debug('Error creating ticket: $e');
      return false;
    }
  }
}