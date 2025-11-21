import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:medicle_sales_rbsh/utils/loder/CircularLoaderController.dart';

import '../../../utils/http/http_client.dart';
import '../../../utils/local_storage/auth_manager.dart';
import '../services/DoctorService.dart';
import 'DoctroController.dart';

/*class AddDoctorController {

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
}*/


import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/DoctorOfflineModel.dart';



class AddDoctorController {
  static const String _baseUrl = THttpHelper.baseUrl;
  static final DoctorService _doctorService = DoctorService();

  /// Simple debug logger for consistent output
  static void _debug(String message) {
    if (kDebugMode) {
      // ignore: avoid_print
      print('[AddDoctorController] $message');
    }
  }

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
    final String apiUrl = '$_baseUrl/doctors';
    _debug('Preparing doctor data for submission...');

    final annDate = anniversaryController.text.isEmpty ? null : anniversaryController.text;
    final dobDate = dobController.text.isEmpty ? null : dobController.text;
    final yearOfExp = experienceController.text.isEmpty ? null : experienceController.text;

    final doctorModel = DoctorOfflineModel(
      name: nameController.text,
      specialization: specializationController.text,
      location: selectedAddress,
      latitude: double.tryParse(selectedLatitude) ?? 0.0,
      longitude: double.tryParse(selectedLongitude) ?? 0.0,
      email: emailController.text,
      phone: phoneController.text,
      registrationNumber: registrationController.text,
      yearsOfExperience: yearOfExp != null ? int.tryParse(yearOfExp) : null,
      dateOfBirth: dobDate,
      gender: selectedGender,
      anniversary: annDate,
      headOfficeId: selectedCityId,
    );

    _debug('Doctor data prepared: ${doctorModel.toJson()}');

    try {
      CircularLoaderController.showLoader(context);
      _debug('Checking internet connectivity...');

      bool hasInternet = await isInternetAvailable();
      if (!hasInternet) {
        _debug('No internet detected. Saving doctor offline...');
        await _doctorService.saveOfflineDoctor(doctorModel);
        CircularLoaderController.hideLoader();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No Internet. Doctor saved offline.')),
        );
        Navigator.pop(context);
        return;
      }

      _debug('Internet available. Proceeding with online API call...');


      _debug('Internet available. Proceeding with online API call...');
      final token = await AuthManager().getAuthToken();
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: json.encode(doctorModel.toJson()),
      );

      _debug('Response Status: ${response.statusCode}');
      _debug('Response Body: ${response.body}');

      CircularLoaderController.hideLoader();

      if (response.statusCode == 201) {
        _debug('Doctor added successfully online.');
        DoctorListController doctorListController = Get.find();
        await doctorListController.fetchDoctorList();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Doctor added successfully!')),
        );
        Navigator.pop(context);
      } else {
        _debug('Failed to add doctor. Server responded with ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Something went wrong.')),
        );
      }
    } catch (e, stack) {
      _debug('Error occurred while adding doctor: $e');
      _debug('StackTrace: $stack');
      CircularLoaderController.hideLoader();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }



  static Future<bool> isInternetAvailable() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        return false;
      }

      // Try pinging a known domain to confirm DNS & reachability
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 3));
      if (result.isNotEmpty && result.first.rawAddress.isNotEmpty) {
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

}

