import 'package:flutter/material.dart';
import '../model/ticketmodal.dart';
import 'package:medicle_sales_rbsh/utils/constants/text_strings.dart';
import 'package:medicle_sales_rbsh/utils/constants/sizes.dart';
import 'package:medicle_sales_rbsh/utils/constants/colors.dart';

class TicketDetailsScreen extends StatelessWidget {
  final TicketModel ticket;

  TicketDetailsScreen({required this.ticket});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: TColors.materialBlueAccent,
        elevation: TSizes.v8, // A bit more elevation for modern look
        title: Text(
          TTexts.uiTextTicketDetails,
          style: TextStyle(fontSize: TSizes.v20, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          // Allow scrolling if content overflows
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Ticket Title'),
              _buildCard(ticket.title ?? "No Title"),
              SizedBox(height: TSizes.v16),
              _buildSectionTitle('Description'),
              _buildCard(ticket.description ?? "No Description",
                  isMultiline: true),
              SizedBox(height: TSizes.v16),
              _buildSectionTitle('Status'),
              _buildStatusChip(ticket.status ?? "No Status"),
              SizedBox(height: TSizes.v16),
              _buildSectionTitle('Image'),
              _buildCard(ticket.image ?? "No Image", isMultiline: true),
              SizedBox(height: TSizes.v16),
              _buildSectionTitle('Created At'),
              _buildCard(ticket.createdAt ?? "No Date"),
              SizedBox(height: TSizes.v16),
              _buildSectionTitle('Updated At'),
              _buildCard(ticket.updatedAt ?? "No Date"),
              SizedBox(height: TSizes.v16),
              if (ticket.user != null) ...[
                _buildSectionTitle('User Information'),
                SizedBox(height: TSizes.v8),
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
          fontSize: TSizes.v18,
          color: TColors.black87,
        ),
      ),
    );
  }

  // Card style content builder with updated visual hierarchy
  Widget _buildCard(String content, {bool isMultiline = false}) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: TColors.black12,
            blurRadius: TSizes.v6,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: isMultiline
          ? Text(
              content,
              style: TextStyle(color: TColors.black54, fontSize: TSizes.v16),
            )
          : Text(
              content,
              style: TextStyle(fontSize: TSizes.v16, color: TColors.black87),
            ),
    );
  }

  // Status chip with improved look and smoother design
  Widget _buildStatusChip(String status) {
    Color chipColor;
    if (status == "IN PROGRESS") {
      chipColor = TColors.materialOrangeAccent;
    } else if (status == "COMPLETED") {
      chipColor = TColors.materialGreenAccent;
    } else {
      chipColor = TColors.materialRedAccent;
    }

    return Chip(
      label: Text(
        status,
        style: TextStyle(color: TColors.white, fontWeight: FontWeight.bold),
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
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: TSizes.v16,
                color: TColors.black87),
          ),
          SizedBox(width: TSizes.v8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: TColors.black54, fontSize: TSizes.v16),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
