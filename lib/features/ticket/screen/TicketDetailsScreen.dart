import 'package:flutter/material.dart';

import '../model/TicketsModel.dart';


class TicketDetailsScreen extends StatelessWidget {
  final TicketModel ticket;

  const TicketDetailsScreen({Key? key, required this.ticket}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(ticket.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              ticket.title,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              ticket.description,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 20),
            ticket.image != null
                ? Image.network(ticket.image!)
                : Image.asset('assets/default_image.png'), // Use default image if image is null
          ],
        ),
      ),
    );
  }
}
