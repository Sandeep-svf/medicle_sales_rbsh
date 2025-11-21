import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:medicle_sales_rbsh/utils/local_storage/auth_manager.dart';  // Make sure AuthManager is working
import '../model/ticketmodal.dart';
import '../model/ticketsresponsemodel.dart';

class TicketController extends GetxController {
  RxList<TicketModel> tickets = <TicketModel>[].obs; // List of tickets
  RxBool isLoading = true.obs; // Loading state for tickets list

  final String _debugPrefix = '[TicketController]';

  @override
  void onInit() {
    super.onInit();
    fetchTickets(); // Fetch tickets on init
  }

  // Log function to prefix the debug message with class and context
  void _debug(String message) {
    print('$_debugPrefix $message');
  }

  // Fetch all tickets using Barrier Token for authentication
  Future<void> fetchTickets() async {
    try {
      // Fetch the token
      AuthManager authManager = AuthManager();
      final token = await authManager.getAuthToken();  // Ensure token is fetched correctly

      if (token == null || token.isEmpty) {
        _debug('Error: No token found!');
        isLoading.value = false;
        return;
      }

      String barrierToken = token.toString(); // Replace with actual token fetching logic

      _debug('Fetching tickets with token: $barrierToken');

      final response = await http.get(
        Uri.parse('https://test.gluckscare.com/api/tickets'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $barrierToken',  // Adding the Bearer token in headers
        },
      );

      // Log the status code and the body of the response
      _debug('Response Status Code: ${response.statusCode}');
      _debug('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final ticketsResponse = TicketsResponseModel.fromJson(data);

        // Update the reactive list of tickets
        tickets.value = ticketsResponse.data ?? [];
        isLoading.value = false;

        _debug('Tickets fetched successfully. ${ticketsResponse.data?.length ?? 0} tickets found.');
      } else {
        _debug('Failed to load tickets, Status Code: ${response.statusCode}');
        throw Exception('Failed to load tickets');
      }
    } catch (e) {
      _debug('Error fetching tickets: $e');
      isLoading.value = false;
    }
  }

  // Create a new ticket using Barrier Token for authentication
  /// Create a new ticket and refresh the list. Returns true on success.
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

      _debug('Creating a new ticket with title: ${payload['title']}');

      final response = await http.post(
        Uri.parse('https://test.gluckscare.com/api/tickets'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(payload),
      );

      _debug('Response Status Code: ${response.statusCode}');
      _debug('Response Body: ${response.body}');

      //  Treat 200 OK and 201 Created as success
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Optional: optimistic insert from response for instant UI feedback
        try {
          final decoded = json.decode(response.body) as Map<String, dynamic>;
          final data = decoded['data'] as Map<String, dynamic>?;
          if (data != null) {
            final created = TicketModel.fromJson(data);
            // Put it at the top if it’s not already there
            final exists = tickets.any((t) => t.id == created.id);
            if (!exists) tickets.insert(0, created);
          }
        } catch (_) {
          // If parsing fails, we’ll still do a full refresh below.
        }

        // Always refresh from server to stay authoritative
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
