import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:http/http.dart' as http;
import '../../../utils/constants/colors.dart';
import '../../../utils/http/http_client.dart';
import '../../../utils/local_storage/auth_manager.dart';
import '../../../utils/loder/CircularLoaderController.dart';
import '../../addDoctor/screens/map.dart';
import '../widets/AnnualGTurnOverSection.dart';

class PharmaDistributorFormScreen extends StatefulWidget {
  const PharmaDistributorFormScreen({super.key});

  @override
  State<PharmaDistributorFormScreen> createState() => _PharmaDistributorFormScreenState();
}

class _PharmaDistributorFormScreenState extends State<PharmaDistributorFormScreen> {
  final _formKey = GlobalKey<FormState>();
  String? selectedHeadOfficeId;
  final TextEditingController firmName = TextEditingController();
  final TextEditingController businessName = TextEditingController();
  String? selectedBusinessType;
  String? selectedLocation;
  String? selectedlatitude;
  String? selectedlongitude;
  List<Map<String, String>> cities = [];
  String headOffice = "";
  final List<String> businessTypes = [
    'Proprietorship',
    'Partnership',
    'Private Ltd.',
    'Public Ltd.'
  ];
  final TextEditingController gstNumber = TextEditingController();
  final TextEditingController drugLicenseNumber = TextEditingController();
  final TextEditingController panNumber = TextEditingController();
  final TextEditingController officeAddress = TextEditingController();
  final TextEditingController contactPerson = TextEditingController();
  final TextEditingController designation = TextEditingController();
  final TextEditingController mobileNumber = TextEditingController();
  final TextEditingController emailAddress = TextEditingController();
  final TextEditingController website = TextEditingController();
  final TextEditingController yearsInBusiness = TextEditingController();
  final TextEditingController areasOfOperation = TextEditingController();
  final TextEditingController distributorships = TextEditingController();
  final TextEditingController storageSize = TextEditingController();
  final TextEditingController salesReps = TextEditingController();
  final TextEditingController bankName = TextEditingController();
  final TextEditingController branch = TextEditingController();
  final TextEditingController accountNumber = TextEditingController();
  final TextEditingController ifscCode = TextEditingController();

  bool warehouseFacility = false;
  bool coldStorageAvailable = false;
  List<HeadOffice1> _offices = [];
  String _selectedId = ''; // This will hold the selected ID
  String? _selectedName;

  List<Map<String, dynamic>> _annualTurnovers = List.generate(
    3,

        (index) => {
      "year": DateTime.now().year - index,
      "amount": 0,
    },
  );

  @override
  void initState() {
    super.initState();
    //_loadHeadOffice();
   // fetchCities();// Load head office from SharedPreferences
    fetchHeadOffices();
  }

  // Method to load head office from SharedPreferences
 /* Future<void> _loadHeadOffice() async {
    AuthManager authManager = AuthManager();
    final String? headOfficeValue = await authManager.getHeadOffice(); // Fetch the value using your method
    setState(() {
      headOffice = headOfficeValue ?? ""; // Default to empty string if no value is found
    });
  }*/

/*  Future<void> _fetchCities() async {
    // Show loading spinner while fetching head offices
    CircularLoaderController.showLoader(context);
    AuthManager authManager = AuthManager();

    try {
      // Retrieve the authorization token
      final token = await authManager.getAuthToken();
      print("[DEBUG] Token fetched: $token");

      // Make the GET request to fetch head offices
      final response = await http.get(
        Uri.parse('${THttpHelper.baseUrl}/users/my-head-offices'),
        headers: {
          "Authorization": "Bearer $token",  // Include Bearer token in the header
          "Accept": "application/json",  // Ensure the server expects JSON
        },
      );

      // Check if the response status code is OK (200)
      if (response.statusCode == 200) {
        CircularLoaderController.hideLoader();  // Hide loading spinner after successful response

        // Decode the response body as a Map<String, dynamic>
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        // Check if the 'success' key is true
        if (jsonResponse['success'] == true) {
          // Extract the 'data' list from the response
          final List<dynamic> cityList = jsonResponse['data'];

          print("[DEBUG] Response body decoded: $cityList");

          // Ensure the city list is not empty
          if (cityList.isNotEmpty) {
            setState(() {
              cities = cityList
                  .map((city) => {
                'id': city['_id']?.toString() ?? 'Unknown ID',  // Safe null check
                'name': city['name']?.toString() ?? 'Unknown Name',  // Safe null check
              })
                  .toList();
              print("[DEBUG] Cities list updated: $cities");
            });
          } else {
            print("[ERROR] No head offices found in response.");
            Get.snackbar("Error", "No head offices found in the response.",
                backgroundColor: Colors.red, duration: const Duration(seconds: 3));
          }
        } else {
          print("[ERROR] Response success is false.");
          Get.snackbar("Error", "Failed to load Head Office. Response success was false.",
              backgroundColor: Colors.red, duration: const Duration(seconds: 3));
        }
      } else {
        CircularLoaderController.hideLoader();  // Hide loader on failure
        print("[ERROR] Failed to load Head Office. Status code: ${response.statusCode}");
        Get.snackbar("Error", "Failed to load Head Office. Status Code: ${response.statusCode}",
            backgroundColor: Colors.red, duration: const Duration(seconds: 3));
      }
    } catch (e) {
      CircularLoaderController.hideLoader();  // Hide loader if an exception occurs
      print("[ERROR] Exception occurred: $e");
      Get.snackbar("Error", "Failed to load Head Office: $e", backgroundColor: Colors.red);
    }
  }*/

  // Function to fetch data from the API
  Future<void> fetchHeadOffices() async {
    try {
      AuthManager authManager = AuthManager();
      final token = await authManager.getAuthToken();
      final response = await http.get(
        Uri.parse('${THttpHelper.baseUrl}/users/my-head-offices'),
        headers: {
          "Authorization": "Bearer $token",  // Include Bearer token in the header
          "Accept": "application/json",  // Ensure the server expects JSON
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body)['data'];
        setState(() {
          _offices = data.map((json) => HeadOffice1.fromJson(json)).toList();
        });
      } else {
        // Handle error if response status is not 200
        print('Failed to load head offices');
      }
    } catch (e) {
      // Handle error for network or parsing
      print('Error fetching data: $e');
    }
  }

  // Fetch the head offices and update the cities list
  Future<void> fetchCities() async {

    print("[DEBUG] API is being called.");
    // Show loading spinner while fetching head offices
    CircularLoaderController.showLoader(context);
    AuthManager authManager = AuthManager();

    try {
      final token = await authManager.getAuthToken();
      final response = await http.get(
        Uri.parse('${THttpHelper.baseUrl}/users/my-head-offices'),
        headers: {
          "Authorization": "Bearer $token",  // Include Bearer token in the header
          "Accept": "application/json",  // Ensure the server expects JSON
        },
      );

      if (response.statusCode == 200) {
        CircularLoaderController.hideLoader();  // Hide loading spinner after successful response

        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse['success'] == true) {
          final List<dynamic> cityList = jsonResponse['data'] ?? [];  // Safe null check for data

          setState(() {
            cities = cityList.map((city) {
              return {
                'id': city['_id']?.toString() ?? 'Unknown ID', // Safe null check for '_id'
                'name': city['name']?.toString() ?? 'Unknown Name', // Safe null check for 'name'
              };
            }).toList();

            // Debugging the list of cities fetched
            print("[DEBUG] Cities list: $cities");
          });
        } else {
          Get.snackbar("Error", "Failed to load Head Office.", backgroundColor: Colors.red);
        }
      } else {
        CircularLoaderController.hideLoader();  // Hide loader on failure
        Get.snackbar("Error", "Failed to load Head Office.", backgroundColor: Colors.red);
      }
    } catch (e) {
      CircularLoaderController.hideLoader();  // Hide loader on exception
      Get.snackbar("Error", "Failed to load Head Office: $e", backgroundColor: Colors.red);
    }
  }



  // Validate that no turnover amount is zero, and that the first three items are required
  bool _validateTurnovers() {
    // Ensure that the first three turnover amounts are greater than zero
    for (int i = 0; i < 3; i++) {
      if (_annualTurnovers[i]['amount'] == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Amount for the year ${_annualTurnovers[i]['year']} cannot be zero.")),
        );
        return false; // Invalid if the amount for any of the first 3 years is zero
      }
    }

    // Ensure that no turnover amount is zero
    for (int i = 0; i < _annualTurnovers.length; i++) {
      if (_annualTurnovers[i]['amount'] == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Amount for year ${_annualTurnovers[i]['year']} cannot be zero.")),
        );
        return false; // Invalid if any amount is zero
      }
    }

    return true; // Valid if all turnovers are valid
  }

  Future<void> _submitDistributorForm() async {
    if (!_validateTurnovers()) {
      return; // Prevent submission if the turnover data is invalid
    }

    if (kDebugMode) {
      print("[DEBUG] headOffice: $headOffice");
    }

    final Uri apiUrl = Uri.parse("${THttpHelper.baseUrl}/stockists");

    Map<String, dynamic> requestBody = {
      "firmName": firmName.text,
      "registeredBusinessName": businessName.text,
      "natureOfBusiness": selectedBusinessType ?? "",
      "gstNumber": gstNumber.text.trim().isEmpty ? "" : gstNumber.text,
      "drugLicenseNumber": drugLicenseNumber.text.trim().isEmpty ? "" : drugLicenseNumber.text,
      "panNumber": panNumber.text.trim().isEmpty ? "" : panNumber.text,
      "registeredOfficeAddress": officeAddress.text,
      "latitude": selectedlatitude,
      "longitude": selectedlongitude,
      "contactPerson": contactPerson.text,
      "designation": designation.text.trim().isEmpty ? "" : designation.text,
      "mobileNumber": mobileNumber.text.trim().isEmpty ? "" : mobileNumber.text,
      "emailAddress": emailAddress.text.trim().isEmpty ? "" : emailAddress.text,
      "website": website.text.trim().isEmpty ? "" : website.text,
      "yearsInBusiness": int.tryParse(yearsInBusiness.text) ?? 0,
      "areasOfOperation": areasOfOperation.text.trim().isNotEmpty
          ? areasOfOperation.text.split(',').map((e) => e.trim()).toList()
          : [],
      "currentPharmaDistributorships": distributorships.text.trim().isNotEmpty
          ? distributorships.text.split(',').map((e) => e.trim()).toList()
          : [],
      "annualTurnover": _annualTurnovers.map((e) => {
        "year": e["year"],
        "amount": e["amount"]
      }).toList(),
      "warehouseFacility": warehouseFacility,
      "storageFacilitySize": int.tryParse(storageSize.text) ?? 0,
      "coldStorageAvailable": coldStorageAvailable,
      "numberOfSalesRepresentatives": int.tryParse(salesReps.text) ?? 0,
      "bankDetails": {
        "bankName": bankName.text.trim().isEmpty ? "" : bankName.text,
        "branch": branch.text.trim().isEmpty ? "" : branch.text,
        "accountNumber": accountNumber.text.trim().isEmpty ? "" : accountNumber.text,
        "ifscCode": ifscCode.text.trim().isEmpty ? "" : ifscCode.text,
      },
      "headOffice": selectedHeadOfficeId, // Use the fetched head office value here
    };

    try {
      print("AddStockController Sending POST request to: $apiUrl");
      print("AddStockController Request Body: ${jsonEncode(requestBody)}");

      AuthManager authManager = AuthManager();
      final token = await authManager.getAuthToken();

      final response = await http.post(
        apiUrl,
        headers: {"Content-Type": "application/json", "Authorization": "Bearer $token", },
        body: jsonEncode(requestBody),
      );

      print("AddStockController Response received");
      print("AddStockController Status Code: ${response.statusCode}");
      print("AddStockController Response Body: ${response.body}");

      if (response.statusCode == 201 || response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Distributor registered successfully")),
        );
        Navigator.pop(context,true);
      } else {
        print("AddStockController Server returned error");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed: ${response.statusCode} - ${response.body}")),
        );
      }
    } catch (e, stackTrace) {
      print("AddStockController Exception occurred during POST request");
      print("AddStockController Error: $e");
      print("AddStockController StackTrace: $stackTrace");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Distributor Registration", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: TColors.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle("Basic Details"),
              _requiredField(firmName, "Firm Name"),
              _requiredField(businessName, "Registered Business Name"),
              //_headOfficeDropdown(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: DropdownButtonFormField<String>(
              value: selectedHeadOfficeId,  // The selected head office ID
              decoration: const InputDecoration(
                labelText: "Head Office *", // Label for the field (required)
                border: OutlineInputBorder(),
              ),
              items: _offices.map((office) {
                return DropdownMenuItem<String>(
                  value: office.id, // Use the ID as the value
                  child: Text(office.name), // Display the name of the head office
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedHeadOfficeId = value; // Store the selected head office ID
                });
              },
              validator: (value) => value == null || value.isEmpty
                  ? 'Please select a head office' // Make the dropdown required
                  : null,
            ),
          ),


              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: "Nature of Business *",
                    border: OutlineInputBorder(),
                  ),
                  value: selectedBusinessType,
                  items: businessTypes.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedBusinessType = value;
                    });
                  },
                  validator: (value) => value == null || value.isEmpty
                      ? "Please select a business type"
                      : null,
                ),
              ),

              _requiredField(gstNumber, "GST Number"),
              _requiredField(drugLicenseNumber, "Drug License Number"),
              _requiredField(panNumber, "PAN Number"),
              _requiredField(officeAddress, "Registered Office Address", maxLines: 2),

              const SizedBox(height: 10),
              _sectionTitle("Contact Details"),
              _requiredField(contactPerson, "Contact Person"),
              _textField(designation, "Designation"),
              _requiredField(mobileNumber, "Mobile Number", inputType: TextInputType.phone),
              _requiredField(emailAddress, "Email Address", inputType: TextInputType.emailAddress),
              _textField(website, "Website"),

              const SizedBox(height: 10),
              _sectionTitle("Business Profile"),
              _requiredField(yearsInBusiness, "Years in Business", inputType: TextInputType.number),
              _textField(areasOfOperation, "Areas of Operation (comma separated)"),
              _textField(distributorships, "Current Pharma Distributorships (comma separated)"),

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

              const SizedBox(height: 10),
              _sectionTitle("Facilities"),
              _checkbox("Warehouse Facility", warehouseFacility, (val) => setState(() => warehouseFacility = val)),
              _textField(storageSize, "Storage Facility Size (in sqft)", inputType: TextInputType.number),
              _checkbox("Cold Storage Available", coldStorageAvailable, (val) => setState(() => coldStorageAvailable = val)),
              _textField(salesReps, "No. of Sales Representatives", inputType: TextInputType.number),

              const SizedBox(height: 10),
              _sectionTitle("Bank Details"),
              _requiredField(bankName, "Bank Name"),
              _requiredField(branch, "Branch"),
              _requiredField(accountNumber, "Account Number", inputType: TextInputType.number),
              _requiredField(ifscCode, "IFSC Code"),

              const SizedBox(height: 20),

              TextButton(
                onPressed: () async {



                  try {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => LocationPickerScreen()),
                    );

                    print(" Returned from Location Picker");
                    print("Result: $result");

                    if (result != null ) {
                      setState(() {
                        selectedlatitude = result['latitude'].toString();
                        selectedlongitude = result['longitude'].toString();
                        selectedLocation = result['address'].toString();
                      });

                      print("Location selected:");
                      print("Address: Lat: $selectedlatitude");
                      print("Address: Lng: $selectedlongitude");
                      print("Address: $selectedLocation");

                      Get.snackbar(
                        "📍 Location Selected",
                        "$selectedLocation\nLat: $selectedlatitude, Lng: $selectedlongitude",
                        backgroundColor: Colors.green,
                        duration: const Duration(seconds: 4),
                      );
                    } else {
                      print("❌ Location selection failed or cancelled.");
                      Get.snackbar(
                        "Location Not Selected",
                        "Please try again or cancel",
                        backgroundColor: Colors.orange,
                      );
                    }
                  } catch (e) {
                    print("Address: $e");
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

              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: TColors.primary),
                  onPressed: () {

                    if (_formKey.currentState!.validate()) {


                      if (selectedlatitude == null || selectedlongitude == null || selectedLocation == null) {
                        Get.snackbar(
                          "⚠️ Location Required",
                          "Please select a location before submitting.",
                          backgroundColor: Colors.redAccent,
                          colorText: Colors.white,
                          duration: const Duration(seconds: 3),
                        );
                        return; // Stop submission
                      }

                      _submitDistributorForm();
                    }
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 4),
                    child: Text("Submit", style: TextStyle(fontSize: 16)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 8.0),
    child: Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: TColors.primary),
    ),
  );

  Widget _headOfficeDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: DropdownButtonFormField<String>(
        value: selectedHeadOfficeId,  // The selected head office ID
        decoration: const InputDecoration(
          labelText: "Head Office *", // Label for the field (required)
          border: OutlineInputBorder(),
        ),
        items: cities.map((office) {
          return DropdownMenuItem<String>(
            value: office['id'], // Use the ID as the value
            child: Text(office['name']!), // Display the name of the head office
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            selectedHeadOfficeId = value; // Store the selected head office ID
          });
        },
        validator: (value) => value == null || value.isEmpty
            ? 'Please select a head office' // Make the dropdown required
            : null,
      ),
    );
  }


  Widget _requiredField(TextEditingController controller, String label,
      {TextInputType inputType = TextInputType.text, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: controller,
        keyboardType: inputType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: "$label *",
          border: const OutlineInputBorder(),
        ),
        validator: (value) => (value == null || value.isEmpty) ? 'Required' : null,
      ),
    );
  }

  Widget _textField(TextEditingController controller, String label,
      {TextInputType inputType = TextInputType.text, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: controller,
        keyboardType: inputType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _checkbox(String title, bool value, Function(bool) onChanged) {
    return CheckboxListTile(
      title: Text(title),
      value: value,
      activeColor: TColors.primary,
      onChanged: (val) => onChanged(val ?? false),
    );
  }
}
// Define a class for the response data
class HeadOffice1 {
  final String id;
  final String name;

  HeadOffice1({required this.id, required this.name});

  // Factory constructor to parse the response JSON
  factory HeadOffice1.fromJson(Map<String, dynamic> json) {
    return HeadOffice1(
      id: json['_id'],
      name: json['name'],
    );
  }
}