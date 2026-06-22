import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:medicle_sales_rbsh/features/addDoctor/models/HeadofficeModel.dart';
import 'package:medicle_sales_rbsh/features/addDoctor/screens/add_doctro_new_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../utils/camera/CameraLocationResult.dart';
import '../../../utils/constants/text_strings.dart';
import '../../../utils/helpers/zoom_in_out_anim.dart';
import '../../../utils/constants/colors.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../utils/http/http_client.dart';
import '../../../utils/local_storage/auth_manager.dart';
import '../../../utils/loder/CircularLoaderController.dart';
import '../../../utils/sqlite_helper/GenericDatabaseHelper.dart';
import '../../addClinic/model/clinic.dart';
import '../../authentication/models/headoffice.dart';
import '../controllers/DoctroController.dart';
import '../controllers/addDoctorController.dart';
import '../models/CityOfflineModel.dart';
import '../models/DoctorModelList.dart';
import '../wigets/gps_image_preview_widget.dart';
import '../wigets/image_with_location_widget.dart';
import 'doctorDetails.dart';
import 'map.dart';

class AddDoctorScreen extends StatefulWidget {
  const AddDoctorScreen({super.key});

  @override
  _AddDoctorScreenState createState() => _AddDoctorScreenState();
}

class _AddDoctorScreenState extends State<AddDoctorScreen> {
  final DoctorListController _doctorListController =
      Get.put(DoctorListController());
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  String? selectedCityId; // Store the selected city ID
  String? selectedCityName; // Store the selected city name
  List<Map<String, String>> cities = [];

  double? selectedLatitude;
  double? selectedLongitude;
  String? selectedAddress;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      // await to wait for the async operations
      await _doctorListController.fetchDoctorList();
      //await fetchCities();
      // cities = (await getHeadOffices()).cast<Map<String, String>>();
    } catch (e) {
      // Handle any errors here
      if (kDebugMode) {
        print("Error during initialization: $e");
      }
    }
  }

  /* Future<void> fetchCities() async {
    CircularLoaderController.showLoader(context);
    AuthManager authManager = AuthManager();
    final token = await authManager.getAuthToken();
    final response = await http.get(
        Uri.parse('${THttpHelper.baseUrl}/users/my-head-offices'),
        headers: {
          "Authorization": "Bearer $token",  // Include Bearer token in the header
          "Accept": "application/json",  // Ensure the server expects JSON
        },);
    if (response.statusCode == 200) {
      CircularLoaderController.hideLoader();
      List<dynamic> cityList = json.decode(response.body);
      setState(() {
        cities = cityList
            .map((city) =>
        {
          'id': city['_id'].toString(),
          'name': city['name'].toString()
        })
            .toList();

        print("city lsit: $cities");
      });
    }else{
      CircularLoaderController.hideLoader();
      Get.snackbar("Error", "Failed to load Head Office.",
          backgroundColor: Colors.red, duration: const Duration(seconds: 3));
    }
  }*/

  // without saving in db...
  /*Future<void> fetchCities() async {
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

          // Map the data and set the state
          setState(() {
            cities = cityList
                .map((city) => {
              'id': city['_id'].toString(),
              'name': city['name'].toString(),
            })
                .toList();

            // Debug log showing the list of cities after mapping
            print("[DEBUG] Cities list updated: $cities");
          });
        } else {
          // If 'success' is false, show an error message
          print("[ERROR] Response success is false.");
          Get.snackbar("Error", "Failed to load Head Office. Response success was false.",
              backgroundColor: Colors.red, duration: const Duration(seconds: 3));
        }
      } else {
        CircularLoaderController.hideLoader();  // Hide loader on failure

        // Log and show an error message if the response status code is not 200
        print("[ERROR] Failed to load Head Office. Status code: ${response.statusCode}");
        Get.snackbar("Error", "Failed to load Head Office. Status Code: ${response.statusCode}",
            backgroundColor: Colors.red, duration: const Duration(seconds: 3));
      }
    } catch (e) {
      // Hide loader if an exception occurs
      CircularLoaderController.hideLoader();

      // Log the error and show the error message
      print("[ERROR] Exception occurred: $e");
      Get.snackbar("Error", "Failed to load Head Office: $e", backgroundColor: Colors.red);
    }
  }*/

  Future<void> fetchCities() async {
    CircularLoaderController.showLoader(context);
    AuthManager authManager = AuthManager();
    final dbHelper = GenericDatabaseHelper<CityOfflineModel>();

    try {
      //  Get Auth token
      final token = await authManager.getAuthToken();
      print("[DEBUG] Token fetched: $token");

      //  Fetch from API
      final response = await http.get(
        Uri.parse('${THttpHelper.baseUrl}/users/my-head-offices'),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      CircularLoaderController.hideLoader();

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse['success'] == true) {
          final List<dynamic> cityList = jsonResponse['data'];

          //  Convert to CityOfflineModel
          final citiesData = cityList
              .map((e) => CityOfflineModel(
                    id: e['id'].toString(),
                    name: e['name'].toString(),
                  ))
              .toList();

          print("[DEBUG] API returned ${citiesData.length} cities.");

          //  Refresh DB (delete all + insert new)
          await dbHelper.deleteAll('cities');
          for (var city in citiesData) {
            await dbHelper.insert(city);
          }
          print("[DEBUG] Cities saved to local DB.");

          //  Update UI from local DB (for display)
          final localCities = await dbHelper.getAll(
            'cities',
            (json) => CityOfflineModel.fromJson(json),
          );

          setState(() {
            cities = localCities
                .map((city) => {'id': city.id, 'name': city.name})
                .toList();
          });

          print("[DEBUG] Loaded ${cities.length} cities from local DB.");
        } else {
          Get.snackbar("Error", "Failed to load cities (success=false)",
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3));
        }
      } else {
        print(
            "[ERROR] Failed to load Head Office. Status: ${response.statusCode}");
        Get.snackbar("Error",
            "Failed to load cities. Status Code: ${response.statusCode}",
            backgroundColor: Colors.red);
      }
    } catch (e) {
      CircularLoaderController.hideLoader();
      print("[ERROR] Exception: $e");

      //  Fallback to local DB
      final localCities = await dbHelper.getAll(
        'cities',
        (json) => CityOfflineModel.fromJson(json),
      );

      if (localCities.isNotEmpty) {
        setState(() {
          cities = localCities
              .map((city) => {'id': city.id, 'name': city.name})
              .toList();
        });
        print("[DEBUG] Loaded cached cities (offline mode).");
      } else {
        Get.snackbar("Error",
            "No cached data available. Please connect to the internet.",
            backgroundColor: Colors.red);
      }
    }
  }

  void _showAddDoctorDialog() {
    TextEditingController nameController = TextEditingController();
    TextEditingController specializationController = TextEditingController();
    TextEditingController emailController = TextEditingController();
    TextEditingController phoneController = TextEditingController();
    TextEditingController registrationController = TextEditingController();
    TextEditingController experienceController = TextEditingController();
    TextEditingController dobController = TextEditingController();
    TextEditingController anniversaryController = TextEditingController();

    DateTime? selectedDob;
    DateTime? selectedAnniversary;
    String? selectedGender = 'Male';
    String? selectedCityId;
    String? selectedCityName = 'Head Office';

    final _formKey = GlobalKey<FormState>();

    void _selectDate(BuildContext context, bool isAnniversary) async {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1900),
        lastDate: DateTime.now(), // Restrict future dates
      );
      if (picked != null) {
        if (isAnniversary) {
          selectedAnniversary = picked;
          anniversaryController.text = DateFormat('yyyy-MM-dd').format(picked);
        } else {
          selectedDob = picked;
          dobController.text = DateFormat('yyyy-MM-dd').format(picked);
        }
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Get the screen width to decide the dialog width
        double screenWidth = MediaQuery.of(context).size.width;
        bool isTablet = screenWidth > 600;

        return SingleChildScrollView(
          child: ZoomInOutDialog(
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              title: const Text(TTexts.addDoctorTitle),
              content: Container(
                width: isTablet ? screenWidth * 0.8 : double.maxFinite,
                // Set 80% width on tablets

                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: TTexts.doctorName,
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => value == null || value.isEmpty
                            ? 'This field is required'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: specializationController,
                        decoration: const InputDecoration(
                          labelText: TTexts.specialization,
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: selectedCityId,
                        decoration: const InputDecoration(
                          labelText: "Select Head Office",
                          border: OutlineInputBorder(),
                        ),
                        items: cities.map((city) {
                          return DropdownMenuItem(
                            value: city['id'],
                            child: Text(city['name']!),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedCityId = value;
                            selectedCityName = cities.firstWhere(
                                (city) => city['id'] == value)['name'];
                          });
                        },
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please select a head office'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: phoneController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        decoration: const InputDecoration(
                          labelText: 'Phone Number',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: registrationController,
                        decoration: const InputDecoration(
                          labelText: 'Registration Number',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: experienceController,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^\d*\.?\d{0,2}')),
                        ],
                        decoration: const InputDecoration(
                          labelText: 'Years of Experience',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () => _selectDate(context, false),
                        child: AbsorbPointer(
                          child: TextFormField(
                            controller: dobController,
                            decoration: const InputDecoration(
                              labelText: 'Date of Birth',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () => _selectDate(context, true),
                        child: AbsorbPointer(
                          child: TextFormField(
                            controller: anniversaryController,
                            decoration: const InputDecoration(
                              labelText: 'Anniversary',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: selectedGender,
                        decoration: const InputDecoration(
                          labelText: "Gender",
                          border: OutlineInputBorder(),
                        ),
                        items: ['Male', 'Female', 'Other'].map((gender) {
                          return DropdownMenuItem(
                            value: gender,
                            child: Text(gender),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedGender = value;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a gender';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => LocationPickerScreen()),
                          );

                          if (result != null &&
                              result['latitude'] != null &&
                              result['longitude'] != null &&
                              result['address'] != null) {
                            selectedLatitude = result['latitude'];
                            selectedLongitude = result['longitude'];
                            selectedAddress = result['address'];

                            Get.snackbar(
                              "📍 Location Selected",
                              "$selectedAddress\nLat: $selectedLatitude, Lng: $selectedLongitude",
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
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 20),
                          backgroundColor: TColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 5,
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
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(TTexts.cancel),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      if (selectedLatitude == null ||
                          selectedLongitude == null ||
                          selectedAddress == null) {
                        // Show error message if location is not selected
                        Get.snackbar("Error", "Please select a location",
                            backgroundColor: Colors.red,
                            duration: const Duration(seconds: 3));
                      } else {
                        // Call the addDoctor API
                        AddDoctorController.addDoctor(
                          context: context,
                          nameController: nameController,
                          specializationController: specializationController,
                          emailController: emailController,
                          phoneController: phoneController,
                          registrationController: registrationController,
                          experienceController: experienceController,
                          dobController: dobController,
                          anniversaryController: anniversaryController,
                          selectedCityId: selectedCityId!,
                          selectedGender: selectedGender!,
                          selectedLatitude: selectedLatitude.toString(),
                          selectedLongitude: selectedLongitude.toString(),
                          selectedAddress: selectedAddress.toString(),
                        );
                      }
                    } else {
                      HapticFeedback.vibrate();
                      // Get.snackbar("Error",
                      //     "Please fill all required fields correctly.");
                    }
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(TTexts.submit),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /*void _showAddDoctorDialog() {
    TextEditingController nameController = TextEditingController();
    TextEditingController specializationController = TextEditingController();
    TextEditingController emailController = TextEditingController();
    TextEditingController phoneController = TextEditingController();
    TextEditingController registrationController = TextEditingController();
    TextEditingController experienceController = TextEditingController();
    TextEditingController dobController = TextEditingController();
    TextEditingController anniversaryController = TextEditingController();


    DateTime? selectedDob;
    DateTime? selectedAnniversary;
    String? selectedGender = 'Male';
    String? selectedCityId;
    String? selectedCityName = 'Head Office';



    // Static Latitude and Longitude
    double selectedLatitude = 40.748817;
    double selectedLongitude = -73.985428;

    void _selectDate(BuildContext context, bool isAnniversary) async {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1900),
        lastDate: DateTime.now(), // 👈 restrict to today or earlier
      );
      if (picked != null) {
        if (isAnniversary) {
          selectedAnniversary = picked;
          anniversaryController.text = DateFormat('yyyy-MM-dd').format(picked); // 👈 update controller
        } else {
          selectedDob = picked;
          dobController.text = DateFormat('yyyy-MM-dd').format(picked); // 👈 update controller
        }
      }
    }


    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: ZoomInOutDialog(
            child: AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text(TTexts.addDoctorTitle),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Existing Doctor Name and Specialization TextFields
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: TTexts.doctorName,
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: specializationController,
                    decoration: const InputDecoration(
                      labelText: TTexts.specialization,
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Existing Dropdown for City
                  DropdownButtonFormField<String>(
                    value: selectedCityId,
                    decoration: const InputDecoration(
                      labelText: "Select Head Office",
                      border: OutlineInputBorder(),
                    ),
                    items: cities.map((city) {
                      return DropdownMenuItem(
                        value: city['id'],
                        child: Text(city['name']!),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedCityId = value;
                        selectedCityName = cities.firstWhere((city) => city['id'] == value)['name'];
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  // New Email TextField
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // New Phone Number TextField
                  TextField(
                    controller: phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // New Registration Number TextField
                  TextField(
                    controller: registrationController,
                    decoration: const InputDecoration(
                      labelText: 'Registration Number',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // New Experience Years TextField
                  TextField(
                    controller: experienceController,
                    decoration: const InputDecoration(
                      labelText: 'Years of Experience',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Date of Birth (DOB) Picker
                  */

  /*GestureDetector(
                    onTap: () => _selectDate(context, false),
                    child: AbsorbPointer(
                      child: TextField(
                        controller: TextEditingController(
                          text: selectedDob != null ? DateFormat('yyyy-MM-dd').format(selectedDob!) : '',
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Date of Birth',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ),*/ /*

                  GestureDetector(
                    onTap: () => _selectDate(context, false),
                    child: AbsorbPointer(
                      child: TextField(
                        controller: dobController,
                        decoration: const InputDecoration(
                          labelText: 'Date of Birth',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ),


                  const SizedBox(height: 12),

                  GestureDetector(
                    onTap: () => _selectDate(context, true),
                    child: AbsorbPointer(
                      child: TextField(
                        controller: anniversaryController,
                        decoration: const InputDecoration(
                          labelText: 'Anniversary',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),
                  // Gender Dropdown
                  DropdownButtonFormField<String>(
                    value: selectedGender,
                    decoration: const InputDecoration(
                      labelText: "Gender",
                      border: OutlineInputBorder(),
                    ),
                    items: ['Male', 'Female', 'Other'].map((gender) {
                      return DropdownMenuItem(
                        value: gender,
                        child: Text(gender),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedGender = value;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  // Location Selector
                  TextButton(
                    onPressed: () async {
                      // Open map screen and select location
                      final selectedLocation = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MapScreen()),
                      );
                      if (selectedLocation != null) {
                        setState(() {
                          selectedLatitude = selectedLocation['lat'];
                          selectedLongitude = selectedLocation['long'];
                        });
                      }
                    },
                    child: const Text('Select Location'),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(TTexts.cancel),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Handle submission logic
                    Get.snackbar("Note", "This feature is in maintenance.");
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(TTexts.submit),
                  ),
                ),
              ],
            ),
          ),

        );
      },
    );
  }*/

  /* @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: "Search Doctors",
                border: OutlineInputBorder(),
                prefixIcon: const Icon(Icons.search, color: TColors.primary,),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      _searchController.clear();
                      _searchQuery = "";
                    });
                  },
                )
                    : null,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: Obx(() {
              if (_doctorListController.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              // Filtering the doctor list
              var filteredDoctors = _doctorListController.doctorList.where(
                      (doctor) => doctor.name.toLowerCase().contains(
                      _searchQuery.toLowerCase())
              ).toList();

              return filteredDoctors.isEmpty
                  ? const Center(child: Text("No doctors available"))
                  : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filteredDoctors.length,
                itemBuilder: (context, index) {
                  final doctor = filteredDoctors[index];
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue.shade100,
                        child: const Icon(Icons.person, color: TColors.primary),
                      ),
                      title: Text(
                        doctor.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(doctor.specialization),
                      onTap: () {
                        // Navigate to the doctor details screen and pass doctor data
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                DoctorDetailsScreen(doctor: doctor),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),

    );
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // --- Search Bar ---
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: TTexts.searchDoctor,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.search, color: TColors.primary),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() {
                          _searchController.clear();
                          _searchQuery = "";
                        }),
                      )
                    : null,
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),

          // --- Doctor List ---
          Expanded(
            child: Obx(() {
              if (_doctorListController.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              final filteredDoctors = _doctorListController.doctorList
                  .where((doctor) => doctor.name
                      .toLowerCase()
                      .contains(_searchQuery.toLowerCase()))
                  .toList();

              if (filteredDoctors.isEmpty) {
                return const Center(child: Text(TTexts.noDoctorAvailable));
              }

              return LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  final bool isMobile = width < 650;
                  final bool isTabletPortrait = width >= 650 && width < 950;

                  // --- Card Builder ---
                  Widget buildDoctorCard(Doctor doctor,
                      {required bool isTablet}) {
                    final String initials = doctor.name.trim().isNotEmpty
                        ? doctor.name.trim()[0].toUpperCase()
                        : "?";
                    const Color themeColor = TColors.primary;

                    // Priority Logic
                    String priorityValue = doctor.priority;
                    Color priorityColor;
                    String priorityLabel;

                    if (priorityValue.isEmpty ||
                        priorityValue.toLowerCase() == 'null') {
                      priorityColor = Colors.grey;
                      priorityLabel = "Not Added";
                    } else {
                      switch (priorityValue) {
                        case 'A':
                          priorityColor = Colors.red;
                          priorityLabel = "Priority A";
                          break;
                        case 'B':
                          priorityColor = Colors.orange;
                          priorityLabel = "Priority B";
                          break;
                        case 'C':
                          priorityColor = Colors.blueGrey;
                          priorityLabel = "Priority C";
                          break;
                        default:
                          priorityColor = Colors.grey;
                          priorityLabel = "Not Added";
                          break;
                      }
                    }

                    // Geo Image Logic
                    bool showImageWarning = doctor.geoImageStatus != true;
                    final double? lat = double.tryParse(doctor.latitude);
                    final double? lng = double.tryParse(doctor.longitude);
                    final bool isValidMap = lat != null && lng != null;

                    Widget cardContent = Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(width: 5, color: themeColor),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Header
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: themeColor.withOpacity(0.04),
                                  border: Border(
                                      bottom: BorderSide(
                                          color: Colors.grey.shade100)),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                              color:
                                                  themeColor.withOpacity(0.3),
                                              width: 2)),
                                      child: CircleAvatar(
                                          radius: 24,
                                          backgroundColor: Colors.white,
                                          child: Text(initials,
                                              style: const TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                  color: themeColor))),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                  child: Text(doctor.name,
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                          fontSize: 16,
                                                          fontWeight: FontWeight
                                                              .bold))),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 4),
                                                decoration: BoxDecoration(
                                                    color: priorityColor
                                                        .withOpacity(0.12),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            6),
                                                    border: Border.all(
                                                        color: priorityColor
                                                            .withOpacity(
                                                                0.35))),
                                                child: Text(priorityLabel,
                                                    style: TextStyle(
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: priorityColor)),
                                              ),
                                            ],
                                          ),

                                          // --- GEO IMAGE TAG ---
                                         /* if (showImageWarning) ...[
                                            const SizedBox(height: 6),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4),
                                              decoration: BoxDecoration(
                                                  color: Colors.red
                                                      .withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                  border: Border.all(
                                                      color: Colors.red
                                                          .withOpacity(0.3))),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: const [
                                                  Icon(
                                                      Icons
                                                          .add_a_photo_outlined,
                                                      size: 12,
                                                      color: Colors.red),
                                                  SizedBox(width: 4),
                                                  Text("Add Image from Details",
                                                      style: TextStyle(
                                                          fontSize: 10,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.red)),
                                                ],
                                              ),
                                            ),
                                          ],*/

                                          // --- DYNAMIC AREA STATUS CONDITION CHECK ---
                                          const SizedBox(height: 6),

                                          if ((doctor.areaId ?? '')
                                              .trim()
                                              .isEmpty)
                                            GestureDetector(
                                              onTap: () => _showAssignAreaSheet(
                                                doctor,
                                              ),
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 4,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.amber
                                                      .withOpacity(0.15),
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                  border: Border.all(
                                                    color: Colors.amber.shade700
                                                        .withOpacity(0.4),
                                                  ),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      Icons
                                                          .add_location_alt_outlined,
                                                      size: 12,
                                                      color:
                                                          Colors.amber.shade900,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      "Add Area Missing",
                                                      style: TextStyle(
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors
                                                            .amber.shade900,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),

                                          const SizedBox(height: 4),
                                          Text(doctor.specialization,
                                              style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.grey[800])),

                                          const SizedBox(height: 4),
                                          Text(doctor.specialization,
                                              style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.grey[800])),
                                          const SizedBox(height: 4),
                                          Row(children: [
                                            Icon(Icons.location_on_rounded,
                                                size: 12,
                                                color: Colors.grey[600]),
                                            const SizedBox(width: 4),
                                            Expanded(
                                                child: Text(doctor.location,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        color:
                                                            Colors.grey[600])))
                                          ]),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Body
                              _buildBodyContent(context, doctor, isValidMap,
                                  themeColor, isTablet),
                            ],
                          ),
                        ),
                      ],
                    );

                    return Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border:
                              Border.all(color: themeColor.withOpacity(0.35)),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 12,
                                offset: const Offset(0, 6))
                          ]),
                      clipBehavior: Clip.antiAlias,
                      child: isTablet
                          ? cardContent
                          : IntrinsicHeight(child: cardContent),
                    );
                  }

                  if (isMobile) {
                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredDoctors.length,
                      itemBuilder: (_, i) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: buildDoctorCard(filteredDoctors[i],
                              isTablet: false)),
                    );
                  } else {
                    // --- TABLET GRID CONFIGURATION ---
                    final int crossAxisCount = isTabletPortrait ? 2 : 3;

                    // FIX: Adjusted ratio to 1.2 to remove excess space but keep content safe
                    //  final double ratio = isTabletPortrait ? 1.2 : 1.2;

                    // FIX: Dropping below 1.0 significantly increases card height capacity for heavy text rows
                    final double ratio = isTabletPortrait ? 1.08 : 1.12;

                    return GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: ratio,
                      ),
                      itemCount: filteredDoctors.length,
                      itemBuilder: (_, i) =>
                          buildDoctorCard(filteredDoctors[i], isTablet: true),
                    );
                  }
                },
              );
            }),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(() => AddDoctorNewScreen());
        },
        backgroundColor: TColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    Doctor doctor,
    bool isValidMap, {
    required bool isTablet,
  }) {
    const Color themeColor = TColors.primary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Icon(Icons.work_history_rounded, size: 16, color: Colors.grey[700]),
            const SizedBox(width: 6),
            Text(
              "${doctor.yearsOfExperience} Years Exp.",
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            if (doctor.gender.isNotEmpty)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  doctor.gender,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
              ),
          ],
        ),

        //  ONLY tablet needs spacing push
        if (isTablet) const Spacer(),

        const SizedBox(height: 16),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DoctorDetailsScreen(doctor: doctor),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: themeColor,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              "View Profile",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),

        if (isValidMap) ...[
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DoctorDetailsScreen(doctor: doctor),
                  ),
                );
              },
              icon: const Icon(Icons.map_outlined, size: 18),
              label: const Text("Locate on Map"),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: themeColor.withOpacity(0.5)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  // PLACE THIS INSIDE YOUR _AddDoctorScreenState CLASS
  void _showAddAreaDialog(
    Doctor doctor,
  ) {
    final pinController = TextEditingController();

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(28),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 90,
                width: 90,
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.location_searching,
                  size: 50,
                  color: TColors.primary,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Create New Area",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Enter pincode and we'll automatically fetch all available areas and post offices.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.blue,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "No need to enter Post Office manually. We will fetch it automatically.",
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: pinController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 5,
                ),
                decoration: InputDecoration(
                  counterText: "",
                  hintText: "201306",
                  prefixIcon: const Icon(
                    Icons.pin_drop,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.search),
                  label: const Text(
                    "Verify & Fetch Areas",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () async {
                    final pin = pinController.text.trim();

                    if (pin.length != 6) {
                      Get.snackbar(
                        "Invalid Pincode",
                        "Please enter a valid 6 digit pincode",
                      );
                      return;
                    }

                    final response = await http.get(
                      Uri.parse(
                        "https://api.postalpincode.in/pincode/$pin",
                      ),
                    );

                    final data = jsonDecode(response.body);

                    if (data.isEmpty ||
                        data[0]['Status'] != 'Success' ||
                        data[0]['PostOffice'] == null) {
                      Get.snackbar(
                        "Error",
                        "Invalid Pincode",
                      );
                      return;
                    }

                    final offices = data[0]['PostOffice'];

                    Get.back();

                    _showAreaSelectionSheet(
                      doctor,
                      pin,
                      offices,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildBodyContent(BuildContext context, Doctor doctor, bool isValidMap,
      Color themeColor, bool isTablet) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        // Keep min so it doesn't stretch empty space
        children: [
          Row(
            children: [
              Icon(Icons.work_history_rounded,
                  size: 16, color: Colors.grey[700]),
              const SizedBox(width: 6),
              Text(
                "${doctor.yearsOfExperience} Years Exp.",
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (doctor.gender.isNotEmpty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    doctor.gender,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
            ],
          ),

          // Fixed spacing
          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            height: 40,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DoctorDetailsScreen(doctor: doctor),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: themeColor,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "View Profile",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),

          if (isValidMap) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DoctorDetailsScreen(doctor: doctor),
                    ),
                  );
                },
                icon: const Icon(Icons.map_outlined, size: 18),
                label: const Text(
                  "Locate on Map",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: BorderSide(color: themeColor.withOpacity(0.5)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showAreaSelectionSheet(
    Doctor doctor,
    String pincode,
    List offices,
  ) {
    int selectedIndex = 0;

    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setState) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Select Area",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 300,
                  child: ListView.builder(
                    itemCount: offices.length,
                    itemBuilder: (_, index) {
                      final office = offices[index];

                      return RadioListTile<int>(
                        value: index,
                        groupValue: selectedIndex,
                        title: Text(
                          office['Name'],
                        ),
                        subtitle: Text(
                          office['Block'] ?? '',
                        ),
                        onChanged: (value) {
                          setState(() {
                            selectedIndex = value!;
                          });
                        },
                      );
                    },
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    child: const Text(
                      "Continue",
                    ),
                    onPressed: () {
                      Get.back();

                      final office = offices[selectedIndex];

                      _showCreateAreaForm(
                        doctor,
                        office,
                        pincode,
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showCreateAreaForm(
    Doctor doctor,
    Map office,
    String pincode,
  ) {
    final areaController = TextEditingController(
      text: office['Name'],
    );

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          constraints: const BoxConstraints(
            maxWidth: 500,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 90,
                  width: 90,
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.location_city,
                    color: Colors.green,
                    size: 50,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Confirm New Area",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Review the detected area information before creating it.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: areaController,
                  decoration: InputDecoration(
                    labelText: "Area Name",
                    prefixIcon: const Icon(Icons.edit_location_alt),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.grey.shade300,
                    ),
                  ),
                  child: Column(
                    children: [
                      _infoRow(
                        Icons.pin_drop,
                        "Pincode",
                        pincode,
                      ),
                      const Divider(),
                      _infoRow(
                        Icons.local_post_office,
                        "Post Office",
                        office['Name'] ?? '',
                      ),
                      const Divider(),
                      _infoRow(
                        Icons.location_city,
                        "Block",
                        office['Block'] ?? '-',
                      ),
                      const Divider(),
                      _infoRow(
                        Icons.map,
                        "District",
                        office['District'] ?? '-',
                      ),
                      const Divider(),
                      _infoRow(
                        Icons.flag,
                        "State",
                        office['State'] ?? '-',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
                        child: const Text(
                          "Cancel",
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        icon: const Icon(
                          Icons.check_circle,
                        ),
                        label: const Text(
                          "Create Area",
                        ),
                        onPressed: () async {
                          final createdAreaId =
                              await _doctorListController.createNewArea(
                            name: areaController.text.trim(),
                            pincode: pincode,
                            postOffice: office['Name'],
                            headOfficeId: doctor.headOfficeId,
                          );

                          if (createdAreaId != null) {
                            await _doctorListController.assignAreaToDoctor(
                              doctorId: doctor.id,
                              areaId: createdAreaId,
                            );

                            Get.back();
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoRow(
    IconData icon,
    String title,
    String value,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: TColors.primary,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  void _showAssignAreaSheet(
    Doctor doctor,
  ) async {
    final areas = await _doctorListController.fetchAreas();

    final searchController = TextEditingController();

    List<dynamic> filteredAreas = List.from(areas);

    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setState) {
          return Container(
            height: Get.height * .80,
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                const Text(
                  "Assign Area",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: "Search Area",
                    prefixIcon: const Icon(
                      Icons.search,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        12,
                      ),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      filteredAreas = areas
                          .where(
                            (area) => (area["name"] ?? "")
                                .toString()
                                .toLowerCase()
                                .contains(
                                  value.toLowerCase(),
                                ),
                          )
                          .toList();
                    });
                  },
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredAreas.length,
                    itemBuilder: (_, index) {
                      final area = filteredAreas[index];

                      return ListTile(
                        leading: const Icon(
                          Icons.location_on,
                        ),
                        title: Text(
                          area["name"] ?? "",
                        ),
                        subtitle: Text(
                          area["pincode"] ?? "",
                        ),
                        onTap: () async {
                          Get.back();

                          await _doctorListController.assignAreaToDoctor(
                            doctorId: doctor.id,
                            areaId: area["id"],
                          );
                        },
                      );
                    },
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(
                      Icons.add,
                    ),
                    label: const Text(
                      "Create New Area",
                    ),
                    onPressed: () {
                      Get.back();

                      _showAddAreaDialog(
                        doctor,
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
      isScrollControlled: true,
    );
  }
}

/*
class MapScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Static map view (replace with actual map logic later)
    return Scaffold(
      appBar: AppBar(title: const Text('Select Location')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Map will be displayed here'),
            ElevatedButton(
              onPressed: () {
                // After selecting the location, return back
                Navigator.pop(context, {'lat': 40.748817, 'long': -73.985428});
              },
              child: const Text('Select Location'),
            ),
          ],
        ),
      ),
    );
  }
}*/
