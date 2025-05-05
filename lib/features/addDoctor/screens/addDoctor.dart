import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../utils/constants/text_strings.dart';
import '../../../utils/helpers/zoom_in_out_anim.dart';
import '../../../utils/constants/colors.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../utils/loder/CircularLoaderController.dart';
import '../controllers/DoctroController.dart';
import '../controllers/addDoctorController.dart';
import 'doctorDetails.dart';
import 'map.dart';

class AddDoctorScreen extends StatefulWidget {
  const AddDoctorScreen({super.key});

  @override
  _AddDoctorScreenState createState() => _AddDoctorScreenState();
}

class _AddDoctorScreenState extends State<AddDoctorScreen> {
  final DoctorListController _doctorListController = Get.put(
      DoctorListController());
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  String? selectedCityId; // Store the selected city ID
  String? selectedCityName; // Store the selected city name
  List<Map<String, String>> cities = [];
  double? selectedLatitude;
  double? selectedLongitude;
  String? selectedAddress;

  @override
  void initState()  {
    super.initState();
    _initializeData();

  }

  Future<void> _initializeData() async {
    try {
      // await to wait for the async operations
      await _doctorListController.fetchDoctorList();
      await fetchCities();
    } catch (e) {
      // Handle any errors here
      if (kDebugMode) {
        print("Error during initialization: $e");
      }
    }
  }
  Future<void> fetchCities() async {
    CircularLoaderController.showLoader(context);
    final response = await http.get(
        Uri.parse('https://medi-glucks-erp.onrender.com/api/headoffices'));
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
                width: isTablet ? screenWidth * 0.8 : double.maxFinite, // Set 80% width on tablets

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
                      validator: (value) =>
                      value == null || value.isEmpty
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
                      validator: (value) =>
                      value == null || value.isEmpty
                          ? 'This field is required'
                          : null,
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
                          selectedCityName =
                          cities.firstWhere((city) =>
                          city['id'] == value)['name'];
                        });
                      },
                      validator: (value) =>
                      value == null || value.isEmpty
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
                      /*validator: (value) {
                        if (value == null || value.isEmpty)
                          return 'This field is required';
                        final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                        if (!emailRegex.hasMatch(value))
                          return 'Enter a valid email';
                        return null;
                      },*/
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: phoneController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                      value == null || value.isEmpty
                          ? 'This field is required'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: registrationController,
                      decoration: const InputDecoration(
                        labelText: 'Registration Number',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                      value == null || value.isEmpty
                          ? 'This field is required'
                          : null,
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
                      validator: (value) =>
                      value == null || value.isEmpty
                          ? 'This field is required'
                          : null,
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
                          return 'Please select a gender'; // Validation message
                        }
                        return null;
                      },

                    ),
                    const SizedBox(height: 12),
                   /* TextButton(
                      onPressed: () async {
                        Get.snackbar("Notice",
                            "This feature is optional and currently under development. Kindly disregard it for now.");
                      },
                      child: const Text('Select Location'),
                    ),*/


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
                          selectedLatitude = result['latitude'];
                          selectedLongitude = result['longitude'];
                          selectedAddress = result['address'];

                          Get.snackbar(
                            "📍 Location Selected",
                            "$selectedAddress\nLat: $selectedLatitude, Lng: $selectedLongitude",
                            backgroundColor: Colors.green,
                            duration: const Duration(seconds: 4),
                          );

                          // Optional: save to local variables or form
                          // setState(() {
                          //   _selectedLat = lat;
                          //   _selectedLng = lng;
                          //   _selectedAddress = address;
                          // });
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

        if (selectedLatitude == null || selectedLongitude == null || selectedAddress == null) {
        // Show error message if location is not selected
        Get.snackbar("Error", "Please select a location",
        backgroundColor: Colors.red, duration: const Duration(seconds: 3));
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
                  */ /*GestureDetector(
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: TTexts.searchDoctor,
                border: OutlineInputBorder(),
                prefixIcon: const Icon(Icons.search,color: TColors.primary,),
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

              // Debugging log to check the doctor list
              print("Doctors List: ${_doctorListController.doctorList}");

              var filteredDoctors = _doctorListController.doctorList.where(
                    (doctor) => doctor.name.toLowerCase().contains(_searchQuery.toLowerCase()),
              ).toList();

              return filteredDoctors.isEmpty
                  ? const Center(child: Text(TTexts.noDoctorAvailable))
                  : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filteredDoctors.length,
                itemBuilder: (context, index) {
                  final doctor = filteredDoctors[index];
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDoctorDialog,
        backgroundColor: TColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
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
