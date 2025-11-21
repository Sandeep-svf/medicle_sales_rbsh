import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medicle_sales_rbsh/features/ticket/screen/ticketdetailsscreen.dart';
import 'package:medicle_sales_rbsh/utils/constants/colors.dart';
import '../controller/TicketController.dart';

class TicketScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final TicketController ticketController = Get.find(); // Access the TicketController

    return Scaffold(

      body: Obx(() {
        if (ticketController.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        return ListView.builder(
          itemCount: ticketController.tickets.length,
          itemBuilder: (context, index) {
            final ticket = ticketController.tickets[index];

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: ListTile(
                  contentPadding: EdgeInsets.all(16),
                  title: Text(
                    ticket.title ?? "No Title",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  subtitle: Text(
                    ticket.description ?? "No Description",
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  trailing: Chip(
                    label: Text(
                      ticket.status ?? "No Status",
                      style: TextStyle(color: Colors.white),
                    ),
                    backgroundColor: ticket.status == 'IN PROGRESS'
                        ? Colors.orange
                        : ticket.status == 'COMPLETED'
                        ? Colors.green
                        : Colors.red,
                  ),
                  onTap: () {
                    // Navigate to the Ticket Details Screen when a ticket is tapped
                    Get.to(() => TicketDetailsScreen(ticket: ticket));
                  },
                ),
              ),
            );
          },
        );
      }),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showCreateTicketDialog(context);
        },
        backgroundColor: TColors.primary,
        child: const Icon(Icons.add,color: Colors.white,),
      ),
    );
  }

  // Show dialog to create a new ticket
  void _showCreateTicketDialog(BuildContext context) {
    final TicketController ticketController = Get.find();

    TextEditingController titleController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();
    TextEditingController imageController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Create a New Ticket',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Ticket Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Ticket Description',
                    border: OutlineInputBorder(),
                  ),
                ),
               /* SizedBox(height: 16),
                TextField(
                  controller: imageController,
                  decoration: InputDecoration(
                    labelText: 'Image URL (Optional)',
                    border: OutlineInputBorder(),
                  ),
                ),*/
                SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancel', style: TextStyle(color: Colors.grey)),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        ticketController.createTicket(
                          titleController.text,
                          descriptionController.text,
                          imageController.text,
                        );
                        Navigator.pop(context);
                      },
                      child: Text('Create Ticket'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
