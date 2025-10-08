import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:medicle_sales_rbsh/utils/loder/CircularLoaderController.dart';

import '../../../utils/http/http_client.dart';
import '../../../utils/local_storage/auth_manager.dart';
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
    required String selectedAddress,
  }) async {
    const apiUrl = '$_baseUrl/doctors';


    final annDate;
    final dobDate;
    final yearOfExp;
    annDate       = anniversaryController.text.isEmpty ? null : anniversaryController.text;
    dobDate       = dobController.text.isEmpty ? null : dobController.text;
    yearOfExp     = experienceController.text.isEmpty ? null : experienceController.text;



    final Map<String, dynamic> doctorData = {
      "name": nameController.text,
      "specialization": specializationController.text,
      "location": selectedAddress,
      "latitude": selectedLatitude,
      "longitude": selectedLongitude,
      "email": emailController.text,
      "phone": phoneController.text,
      "registration_number": registrationController.text,
      "years_of_experience": yearOfExp,
      "date_of_birth": dobDate,
      "gender": selectedGender,
      "anniversary": annDate,
      "headOfficeId": selectedCityId, // Using the same head office ID here
    };


    if (kDebugMode) {
      print('Doctor Data - Name: ${nameController.text}');
      print('Doctor Data - Specialization: ${specializationController.text}');
      print('Doctor Data - Location: $selectedAddress');
      print('Doctor Data - Latitude: $selectedLatitude');
      print('Doctor Data - Longitude: $selectedLongitude');
      print('Doctor Data - Email: ${emailController.text}');
      print('Doctor Data - Phone: ${phoneController.text}');
      print('Doctor Data - Registration Number: ${registrationController.text}');
      print('Doctor Data - Years of Experience: ${yearOfExp}');
      print('Doctor Data - Date of Birth: ${dobDate}');
      print('Doctor Data - Gender: $selectedGender');
      print('Doctor Data - Anniversary: ${annDate}');
      print('Doctor Data - Head Office ID: $selectedCityId');
    }


    try {
      CircularLoaderController.showLoader(context);

      // Get token from AuthManager
      String? token = await AuthManager().getAuthToken();
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json",
          "Authorization": "Bearer $token",},

        body: json.encode(doctorData),
      );

      if (kDebugMode) {
        print('[AddDoctorController]Response Status: ${response.statusCode}');
        print('[AddDoctorController]Response Body: ${response.body}');
      }

      if (response.statusCode == 201) {
        CircularLoaderController.hideLoader();

        DoctorListController doctorListController = Get.find();
        await doctorListController.fetchDoctorList();

        // If the response is successful, show success snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Doctor added successfully!')),

        );
        // Close the dialog
        Navigator.pop(context);
      } else {
        CircularLoaderController.hideLoader();
        // If there's an error, show error snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Something went wrong.')),
        );
      }
    } catch (e) {
      CircularLoaderController.hideLoader();
      // Catch any error and show error snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }
}
