import 'dart:convert';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../utils/http/http_client.dart';
import 'DoctroController.dart';

class AddDoctorController {

  static const String _baseUrl = THttpHelper.baseUrl;


  static Future<void> addDoctor({
    required BuildContext context,
    required TextEditingController nameController,
    required TextEditingController specializationController,
    required TextEditingController emailController,
    required TextEditingController phoneController,
    required TextEditingController registrationController,
    required TextEditingController experienceController,
    required TextEditingController dobController,
    required TextEditingController anniversaryController,
    required String selectedCityId,
    required String selectedGender,
    required String selectedLatitude,
    required String selectedLongitude,
  }) async {
    const apiUrl = '$_baseUrl/doctors';

    final Map<String, dynamic> doctorData = {
      "name": nameController.text,
      "specialization": specializationController.text,
      "location": selectedCityId,  // Assuming you are sending head office ID
      "email": emailController.text,
      "phone": phoneController.text,
      "registration_number": registrationController.text,
      "years_of_experience": experienceController.text,
      "date_of_birth": dobController.text,
      "gender": selectedGender,
      "anniversary": anniversaryController.text,
      "head_office": selectedCityId, // Using the same head office ID here
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode(doctorData),
      );

      if (response.statusCode == 201) {

        //_doctorListController.fetchDoctorList();

        // If the response is successful, show success snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Doctor added successfully!')),
        );
        // Close the dialog
        Navigator.pop(context);
      } else {
        // If there's an error, show error snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Something went wrong.')),
        );
      }
    } catch (e) {
      // Catch any error and show error snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }
}
