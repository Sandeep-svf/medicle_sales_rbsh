import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../../utils/http/http_client.dart';
import '../../addDoctor/screens/map.dart';
import '../controllers/ClinicListController.dart';

class AddClinicDialog extends StatefulWidget {
  final ClinicListController controller;
  const AddClinicDialog({super.key, required this.controller});

  @override
  State<AddClinicDialog> createState() => _AddClinicDialogState();
}

class _AddClinicDialogState extends State<AddClinicDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController firmNameController = TextEditingController();
  final TextEditingController contactPersonController = TextEditingController();
  final TextEditingController designationController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController gstController = TextEditingController();
  final TextEditingController drugLicenseNumberController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController latitudeController = TextEditingController();
  final TextEditingController longitudeController = TextEditingController();
  final TextEditingController yearsInBusinessController = TextEditingController();
  final TextEditingController turnoverController = TextEditingController();

  bool isLoading = false;

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    final body = {
      "firmName": firmNameController.text,
      "contactPersonName": contactPersonController.text,
      "designation": designationController.text,
      "mobileNo": phoneController.text,
      "emailId": emailController.text,
      "gstNo": gstController.text,
      "drugLicenseNumber": drugLicenseNumberController.text,
      "address": addressController.text,
      "latitude": latitudeController.text,
      "longitude": longitudeController.text,
      "headOffice": "",
      "yearsInBusiness": int.tryParse(yearsInBusinessController.text) ?? 0,
      "annualTurnover": int.tryParse(turnoverController.text) ?? 0,
    };

    try {
      final response = await http.post(
        Uri.parse("${THttpHelper.baseUrl}/chemists"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode == 201) {
        await widget.controller.fetchClinicList(); // Refresh list
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Clinic added successfully")),
          );
        }
      } else {
        throw Exception("Failed with status: ${response.statusCode}");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to submit: $e")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Add New Chemist"),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(firmNameController, "Firm Name"),
              _buildTextField(contactPersonController, "Contact Person"),
              _buildTextField(designationController, "Designation"),
              _buildTextField(phoneController, "Phone Number", keyboardType: TextInputType.phone),
              _buildTextField(emailController, "Email", keyboardType: TextInputType.emailAddress),
              _buildTextField(drugLicenseNumberController, "DrugLicenseNumber"),
              _buildTextField(gstController, "GST No"),
              _buildTextField(addressController, "Address", maxLines: 2),
              _buildTextField(yearsInBusinessController, "Years in Business", keyboardType: TextInputType.number),
              _buildTextField(turnoverController, "Annual Turnover", keyboardType: TextInputType.number),
              TextButton(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => LocationPickerScreen()),
                  );

                  if (result != null &&
                      result['latitude'] != null &&
                      result['longitude'] != null &&
                      result['address'] != null) {
                    final lat = result['latitude'];
                    final lng = result['longitude'];
                    final address = result['address'];

                    Get.snackbar(
                      "📍 Location Selected",
                      "$address\nLat: $lat, Lng: $lng",
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 4),
                    );
                  } else {
                    Get.snackbar(
                      "Location Not Selected",
                      "Please try again or cancel",
                      backgroundColor: Colors.orange,
                    );
                  }
                },
                child: const Text('Select Location'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
        ElevatedButton(
          onPressed: isLoading ? null : _submitForm,
          child: isLoading
              ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text("Submit"),
        ),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {TextInputType keyboardType = TextInputType.text, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) => (value == null || value.isEmpty) ? 'Required' : null,
      ),
    );
  }
}
