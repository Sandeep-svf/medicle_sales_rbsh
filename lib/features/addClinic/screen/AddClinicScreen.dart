import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:medicle_sales_rbsh/utils/http/http_client.dart';
import 'dart:convert';
import '../../../utils/constants/colors.dart';
import '../../addStokist/widets/AnnualGTurnOverSection.dart';
import '../controllers/ClinicListController.dart';
import '../../addDoctor/screens/map.dart';

class AddClinicScreen extends StatefulWidget {
  final ClinicListController controller;
  const AddClinicScreen({super.key, required this.controller});

  @override
  State<AddClinicScreen> createState() => _AddClinicScreenState();
}

class _AddClinicScreenState extends State<AddClinicScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController firmNameController = TextEditingController();
  final TextEditingController contactPersonController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController designationController = TextEditingController();
  final TextEditingController drugLicenseNumberController = TextEditingController();
  final TextEditingController gstController = TextEditingController();
  final TextEditingController yearsInBusinessController = TextEditingController();

  String? selectedHeadOffice;
  String? selectedLocation;
  String? selectedlatitude;
  String? selectedlongitude;
  bool isLoading = false; // For form submission loading
  bool isLoadingHeadOffices = false; // For head office loading
  List<dynamic> headOffices = [];
  String baseurl = THttpHelper.baseUrl;
  List<Map<String, dynamic>> _annualTurnovers = List.generate(1,
        (index) => {
      "year": DateTime.now().year - index,
      "amount": 0,
    },
  );


  @override
  void initState() {
    super.initState();
    _fetchHeadOffices();
  }

  Future<void> _fetchHeadOffices() async {
    setState(() {
      isLoadingHeadOffices = true; // Show loader while fetching head offices
    });
    try {
      final response = await http.get(Uri.parse("$baseurl/headoffices"));
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        setState(() {
          headOffices = data;
          isLoadingHeadOffices = false; // Hide loader when data is fetched
        });
      } else {
        setState(() {
          isLoadingHeadOffices = false; // Hide loader on error
        });
        Get.snackbar("Error", "Failed to fetch head offices Status Code: ${response.statusCode}");
      }
    } catch (e) {
      setState(() {
        isLoadingHeadOffices = false; // Hide loader on exception
      });
      Get.snackbar("Error", "Failed to fetch head offices: $e", backgroundColor: Colors.red);
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true); // Show loading while submitting the form

    final body = {
      "firmName": firmNameController.text,
      "contactPersonName": contactPersonController.text,
      "mobileNo": phoneController.text,
      "address": addressController.text,
      "headOffice": selectedHeadOffice,
      "location": selectedLocation,
      "latitude": selectedlatitude,
      "longitude": selectedlongitude,
      "designation": designationController.text,
      "drugLicenseNumber": drugLicenseNumberController.text,
      "gstNo": gstController.text,
      "yearsInBusiness": int.tryParse(yearsInBusinessController.text) ?? 0,
    };

    try {
      final response = await http.post(
        Uri.parse("$baseurl/chemists"),
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
      setState(() => isLoading = false); // Hide loader after form submission
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add New Chemist"),
        backgroundColor: TColors.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Firm Name (Required)
                _buildTextField(firmNameController, "Firm Name", required: true),

                // Contact Person (Required)
                _buildTextField(contactPersonController, "Contact Person", required: true),

                // Mobile Number (Required)
                _buildTextField(phoneController, "Mobile Number", keyboardType: TextInputType.phone, required: true),

                // Head Office Dropdown (Required)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: isLoadingHeadOffices
                      ? const CircularProgressIndicator() // Show loader while fetching head offices
                      : DropdownButtonFormField<String>(
                    value: selectedHeadOffice,
                    decoration: const InputDecoration(
                      labelText: "Select Head Office",
                      border: OutlineInputBorder(),
                    ),
                    items: headOffices.map((headOffice) {
                      return DropdownMenuItem<String>(
                        value: headOffice['_id'],
                        child: Text(headOffice['name']),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedHeadOffice = value;
                      });
                    },
                    validator: (value) => value == null ? 'Head Office is required' : null,
                  ),
                ),

                // Designation (Optional)
                _buildTextField(designationController, "Designation", required: false),

                // Drug License Number (Optional)
                _buildTextField(drugLicenseNumberController, "Drug License Number", required: false),

                // GST No (Optional)
                _buildTextField(gstController, "GST No", required: false),



                const SizedBox(height: 10),
                _sectionTitle("Annual Turnover"),

                AnnualTurnoverSection(
                  turnovers: _annualTurnovers,
                  onChanged: (updatedList) {
                    setState(() {
                      _annualTurnovers = updatedList;
                    });
                  },
                ),
                // Select Location (Required)
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
                      selectedlatitude = result['latitude'];
                      selectedlongitude = result['longitude'];
                      selectedLocation = result['address'];

                      Get.snackbar(
                        "📍 Location Selected",
                        "$selectedLocation\nLat: $selectedlatitude, Lng: $selectedlongitude",
                        backgroundColor: Colors.green,
                        duration: const Duration(seconds: 4),
                      );


                    } else {
                      Get.snackbar(
                        "Location Not Selected",
                        "Please try again or cancel",
                        backgroundColor: Colors.orange,
                      );
                    }
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                    backgroundColor: TColors.primary, // Background color for the button
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 5, // Shadow for the button
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.location_on,
                        color: Colors.white,
                        size: 22,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Select Location',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                // Centered "Add Chemist" Button
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TColors.primary, // Background color
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      minimumSize: Size(double.infinity, 50), // Full-width button
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Add Chemist", style: TextStyle(fontSize: 18)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {TextInputType keyboardType = TextInputType.text, int maxLines = 1, bool required = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.black),
          border: OutlineInputBorder(),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: TColors.primary, width: 2),
          ),
        ),
        validator: (value) {
          if (required && (value == null || value.isEmpty)) {
            return 'This field is required';
          }
          return null;
        },
      ),
    );
  }
}

Widget _sectionTitle(String title) => Padding(
  padding: const EdgeInsets.only(bottom: 8.0),
  child: Align(
    alignment: Alignment.centerLeft, // Align the title to the left
    child: Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: TColors.primary,
      ),
    ),
  ),
);

