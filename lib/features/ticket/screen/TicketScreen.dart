import 'dart:convert';
import 'package:flutter/material.dart';
import '../controller/TicketController.dart';
import '../model/TicketsModel.dart';
import 'TicketDetailsScreen.dart';
import 'package:timeago/timeago.dart' as timeago; // Import timeago package

// Enum for ComplaintStatus
enum ComplaintStatus {
  PENDING,
  IN_PROGRESS,
  RESOLVED,
  REJECTED,
  CLOSED,
}

// Helper method to map status to color
Color getStatusColor(ComplaintStatus status) {
  switch (status) {
    case ComplaintStatus.PENDING:
      return Colors.orange;
    case ComplaintStatus.IN_PROGRESS:
      return Colors.blue;
    case ComplaintStatus.RESOLVED:
      return Colors.green;
    case ComplaintStatus.REJECTED:
      return Colors.redAccent;
    case ComplaintStatus.CLOSED:
      return Colors.grey;
    default:
      return Colors.grey;
  }
}

class TicketScreen extends StatefulWidget {
  @override
  _TicketScreenState createState() => _TicketScreenState();
}

class _TicketScreenState extends State<TicketScreen> {
  late TicketController _ticketController;
  List<TicketModel> tickets = [];
  List<TicketModel> filteredTickets = [];
  bool isLoading = false;
  final String userId = "67d56a35a2227082ae9282b2";
  final String token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY3ZDU2YTM1YTIyMjcwODJhZTkyODJiMiIsInJvbGUiOiJVc2VyIiwiaWF0IjoxNzQ2MTY2ODM1LCJleHAiOjE3NDY3NzE2MzV9.RHujLS1ivUOQQskwQuWzqkyIuT5lti8gRBZeaNsnZCc ";  // Replace with actual token

  // TextEditingController for search
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _ticketController = TicketController(userId: userId, token: token);
    fetchTickets();
  }

  // Fetch tickets
  Future<void> fetchTickets() async {
    setState(() {
      isLoading = true;
    });
    try {
      final fetchedTickets = await _ticketController.fetchTickets();
      setState(() {
        tickets = fetchedTickets;
        filteredTickets = fetchedTickets; // Initially show all tickets
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Error fetching tickets: $e");
    }
  }

  // Search functionality
  void searchTickets(String query) {
    setState(() {
      filteredTickets = tickets
          .where((ticket) => ticket.title.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tickets'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () async {
              await showSearch(
                context: context,
                delegate: TicketSearchDelegate(filteredTickets),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : filteredTickets.isEmpty
            ? Center(child: Text('No Tickets Found'))
            : ListView.builder(
          itemCount: filteredTickets.length,
          itemBuilder: (context, index) {
            final ticket = filteredTickets[index];
            return TicketCard(
              ticket: ticket,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TicketDetailsScreen(ticket: ticket),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showTicketDialog(context),
        child: Icon(Icons.add),
      ),
    );
  }

  // Open ticket creation dialog
  void showTicketDialog(BuildContext context) {
    TextEditingController titleController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();
    String? selectedImage;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Create New Ticket"),
          content: Column(
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: "Title"),
              ),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: "Description"),
              ),
              selectedImage != null
                  ? Image.memory(base64Decode(selectedImage))
                  : SizedBox.shrink(),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (titleController.text.isNotEmpty && descriptionController.text.isNotEmpty) {
                  String base64Image = selectedImage ?? '';
                  await _ticketController.createTicket(
                      titleController.text, descriptionController.text, base64Image);
                  Navigator.pop(context);
                } else {
                  print("Title and Description are required.");
                }
              },
              child: Text('Generate Ticket'),
            ),
          ],
        );
      },
    );
  }
}

class TicketCard extends StatelessWidget {
  final TicketModel ticket;
  final VoidCallback onTap;
  final String statusw = "IN_PROGRESS";

  const TicketCard({required this.ticket, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Get status color based on the status
    ComplaintStatus status = ComplaintStatus.values.firstWhere(
          (e) => e.toString().split('.').last == statusw.toUpperCase(),
      orElse: () => ComplaintStatus.PENDING, // Default to PENDING if status is unknown
    );
    Color statusColor = getStatusColor(status);

    // Convert the createdAt timestamp to a relative time
    String formattedDate = timeago.format(DateTime.parse(ticket.createdAt));

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      elevation: 12, // Increased elevation for a more dramatic shadow
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20), // More rounded corners
      ),
      shadowColor: Colors.black.withOpacity(0.25), // Subtle shadow for card
      color: Colors.white, // White background for the card
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        splashColor: Colors.grey.withOpacity(0.2), // Splash effect on tap
        highlightColor: Colors.transparent, // Transparent highlight when tapped
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Image section
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: ticket.image != null
                    ? Image.network(
                  ticket.image!,
                  width: 110,
                  height: 110,
                  fit: BoxFit.cover,
                )
                    : Image.asset(
                  'assets/logos/glucks_care_logo.jpg', // Default image if null
                  width: 110,
                  height: 110,
                  fit: BoxFit.cover,
                ),
              ),
              // Spacer between image and text
              SizedBox(width: 20),
              // Text section
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ticket.title,
                      style: TextStyle(
                        fontSize: 20, // Larger font size for title
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 10),
                    Text(
                      ticket.description,
                      style: TextStyle(
                        fontSize: 16, // Slightly larger description text
                        color: Colors.grey[700], // Darker gray for better contrast
                        height: 1.5,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 12),
                    // CreatedAt section with icon
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                        SizedBox(width: 5),
                        Text(
                          'Created at: $formattedDate', // Show relative time here
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Status section on the top-right of the card
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusw ?? "",
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TicketSearchDelegate extends SearchDelegate {
  final List<TicketModel> tickets;
  TicketSearchDelegate(this.tickets);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final filteredTickets = tickets
        .where((ticket) => ticket.title.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: filteredTickets.length,
      itemBuilder: (context, index) {
        final ticket = filteredTickets[index];
        return TicketCard(
          ticket: ticket,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TicketDetailsScreen(ticket: ticket),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final filteredTickets = tickets
        .where((ticket) => ticket.title.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: filteredTickets.length,
      itemBuilder: (context, index) {
        final ticket = filteredTickets[index];
        return TicketCard(
          ticket: ticket,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TicketDetailsScreen(ticket: ticket),
              ),
            );
          },
        );
      },
    );
  }
}
