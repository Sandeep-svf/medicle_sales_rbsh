import 'package:flutter/material.dart';
import '../model/ticketmodal.dart';

class TicketDetailsScreen extends StatelessWidget {
  final TicketModel ticket;

  TicketDetailsScreen({required this.ticket});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        elevation: 8, // A bit more elevation for modern look
        title: Text(
          'Ticket Details',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(  // Allow scrolling if content overflows
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Ticket Title'),
              _buildCard(ticket.title ?? "No Title"),
              SizedBox(height: 16),

              _buildSectionTitle('Description'),
              _buildCard(ticket.description ?? "No Description", isMultiline: true),
              SizedBox(height: 16),

              _buildSectionTitle('Status'),
              _buildStatusChip(ticket.status ?? "No Status"),
              SizedBox(height: 16),

              _buildSectionTitle('Image'),
              _buildCard(ticket.image ?? "No Image", isMultiline: true),
              SizedBox(height: 16),

              _buildSectionTitle('Created At'),
              _buildCard(ticket.createdAt ?? "No Date"),
              SizedBox(height: 16),

              _buildSectionTitle('Updated At'),
              _buildCard(ticket.updatedAt ?? "No Date"),
              SizedBox(height: 16),

              if (ticket.user != null) ...[
                _buildSectionTitle('User Information'),
                SizedBox(height: 8),
                _buildUserInfo(ticket.user!),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // Section title builder with modern styling
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 18,
          color: Colors.black87,
        ),
      ),
    );
  }

  // Card style content builder with updated visual hierarchy
  Widget _buildCard(String content, {bool isMultiline = false}) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: isMultiline
          ? Text(
        content,
        style: TextStyle(color: Colors.black54, fontSize: 16),
      )
          : Text(
        content,
        style: TextStyle(fontSize: 16, color: Colors.black87),
      ),
    );
  }

  // Status chip with improved look and smoother design
  Widget _buildStatusChip(String status) {
    Color chipColor;
    if (status == "IN PROGRESS") {
      chipColor = Colors.orangeAccent;
    } else if (status == "COMPLETED") {
      chipColor = Colors.greenAccent;
    } else {
      chipColor = Colors.redAccent;
    }

    return Chip(
      label: Text(
        status,
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      backgroundColor: chipColor,
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: StadiumBorder(),
    );
  }

  // User information display with added spacing and styling
  Widget _buildUserInfo(UserModel user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildUserInfoRow("Name", user.name ?? "No Name"),
        _buildUserInfoRow("Email", user.email ?? "No Email"),
        _buildUserInfoRow("Employee Code", user.employeeCode ?? "No Code"),
      ],
    );
  }

  // User info row with refined typography
  Widget _buildUserInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Text(
            '$label:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.black54, fontSize: 16),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
