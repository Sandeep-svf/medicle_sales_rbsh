import 'package:flutter/material.dart';
import '../model/TicketsModel.dart';

class TicketDetailsScreen extends StatelessWidget {
  final TicketModel ticket;

  const TicketDetailsScreen({Key? key, required this.ticket}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Determine the screen width for responsive design
    double screenWidth = MediaQuery.of(context).size.width;
    bool isLargeScreen = screenWidth > 600; // Check if it's a tablet

    return Scaffold(
      appBar: AppBar(
        title: Text(ticket.title),
        elevation: isLargeScreen ? 4 : 2, // Slightly more elevation on tablet
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isLargeScreen ? 40 : 16, // More padding for larger screens
          vertical: 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Text
            Text(
              ticket.title,
              style: TextStyle(
                fontSize: isLargeScreen ? 28 : 24, // Larger font size on tablets
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),

            // Description Text
            Text(
              ticket.description,
              style: TextStyle(
                fontSize: isLargeScreen ? 18 : 16, // Adjust font size based on screen size
                color: Colors.grey[700],
                height: 1.6,
              ),
            ),
            SizedBox(height: 20),

            // Image Section (with adjusted size)
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: ticket.image != null
                    ? Image.network(
                  ticket.image!,
                  width: isLargeScreen ? 400 : 300, // Adjust image size for tablets
                  height: isLargeScreen ? 250 : 200, // Adjust image size for tablets
                  fit: BoxFit.cover,
                )
                    : Image.asset(
                  'assets/default_image.png',
                  width: isLargeScreen ? 400 : 300, // Adjust image size for tablets
                  height: isLargeScreen ? 250 : 200, // Adjust image size for tablets
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
