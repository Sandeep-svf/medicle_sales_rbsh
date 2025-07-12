import 'dart:convert';

import 'package:date_picker_plus/date_picker_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:medicle_sales_rbsh/common/Model/SMResponseModel.dart';

import 'package:medicle_sales_rbsh/utils/constants/sizes.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import '../../../../../../utils/LocationHelper/LocationHelper.dart';
import '../../../../../../utils/constants/colors.dart';
import '../../../../../../utils/constants/text_strings.dart';
import '../../../../../../utils/helpers/zoom_in_out_anim.dart';
import '../../../../../../utils/local_storage/auth_manager.dart';
import '../../../../utils/http/http_client.dart';
import '../../../addDoctor/controllers/DoctroController.dart';
import '../../../addStokist/controllers/StokistListController.dart';
import '../controllers/ScheduleVisitcontroller.dart';
import '../controllers/visitListController.dart';
import '../models/stockistvisitConfirm.dart';
import '../models/visitSalesData.dart';

class VisitStockistScreen extends StatefulWidget {
  const VisitStockistScreen({super.key});

  @override
  State<VisitStockistScreen> createState() => _VisitStockistScreenState();
}

class _VisitStockistScreenState extends State<VisitStockistScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

 // DoctorListController _doctorListController = Get.put(DoctorListController());
  StokistListController _stokistListController = Get.put(StokistListController());

  String? selectedDoctorId; // This will store the selected doctor's ID
  String? selectedDoctorName; // This will store the selected doctor's name

  late VisitListController _visitListController;
  final AuthManager authManager = AuthManager(); // Initialize AuthManager

  //location helper
  String _location = 'Fetching location...';
  // Instance of LocationHelper
  LocationHelper locationHelper = LocationHelper();

  // sam

  @override
  void initState() {
    super.initState();
    _stokistListController.fetchStokist();
    _visitListController = VisitListController();
    _visitListController
        .fetchSalesList(); // Fetch the visit data when screen loads
  }

  void _showAddDoctorDialog() {
    TextEditingController nameController = TextEditingController();
    TextEditingController dateController = TextEditingController();
    TextEditingController callNotesController = TextEditingController();
    String selectedDate = "";
    final _formKey = GlobalKey<FormState>();

    Future<void> _pickDate() async {
      final pickedDate = await showDatePickerDialog(
        context: context,
        minDate: DateTime(2020),
        maxDate: DateTime(2034),
        initialDate: DateTime.now(),
        selectedCellDecoration: const BoxDecoration(
          color: Colors.blue,
          shape: BoxShape.circle,
        ),
        selectedCellTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        leadingDateTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        highlightColor: Colors.blue,
        splashColor: Colors.blueAccent,
        splashRadius: 20.0,
      );

      if (pickedDate != null) {
        setState(() {
          dateController.text =
          "${pickedDate.day}-${pickedDate.month}-${pickedDate.year}";
        });
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ZoomInOutDialog(
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(TTexts.scheduleVisitTitle),
            content: Form(
              key: _formKey, // Add Form Key for validation
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: "Select Stockist",
                        border: OutlineInputBorder(),
                      ),
                      value: selectedDoctorName,
                      items: _stokistListController.stokistList.map((doctor) {
                        return DropdownMenuItem<String>(
                          value: doctor.firmName,
                          child: Text(doctor.firmName??''),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedDoctorName = value;
                          selectedDoctorId = _stokistListController.stokistList
                              .firstWhere((doctor) => doctor.firmName == value)
                              .sId;
                        });
                      },
                      hint: const Text("Please select"),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a stockist';
                        }
                        return null;
                      },
                      isExpanded: true,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: dateController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: TTexts.date,
                      hintText: "Date (DD-MM-YYYY)",
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    onTap: _pickDate,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a date';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: callNotesController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: TTexts.notes,
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter notes';
                      }
                      return null;
                    },
                  ),
                ],
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
                    String formattedTime = DateFormat('hh:mm a').format(DateTime.now());

                    setState(() {
                      // Call the controller to create a doctor visit
                      StockistVisitController.createDoctorVisit(
                        doctorId: selectedDoctorId,
                        date: dateController.text,
                        notes: callNotesController.text,
                        context: context,
                        authManager: authManager,  // Pass AuthManager instance here
                      ).then((_) {
                        // After adding, fetch the updated sales list
                        _visitListController.fetchSalesList().then((_) {
                          setState(() {
                            // This ensures the UI is updated after fetching the data
                          });
                        });
                      });
                    });

                    Navigator.pop(context);
                  } else {
                    Get.snackbar("Error", "Please fill all required fields.");
                  }
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(TTexts.submit),
                ),
              ),
            ],
          ),
        );
      },
    );

  }

  void _showDeleteConfirmationDialog(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          title: const Text(TTexts.confirmDeletion),
          content: const Text(TTexts.areYouSureYouWantToDeleteThisLog),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                  TTexts.no, style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _visitListController.salesList.removeAt(index);
                });
                Navigator.pop(context);
              },
              child: const Text(TTexts.yes),
            ),
          ],
        );
      },
    );
  }

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
                labelText: "Search Stockist",
                border: OutlineInputBorder(),
                prefixIcon: const Icon(Icons.search, color: TColors.primary),
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
            child: FutureBuilder(
              future: _visitListController.fetchSalesList(),
              // Fetch sales list here
              builder: (context, AsyncSnapshot<void> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator()); // Show loading indicator
                } else if (snapshot.hasError) {
                  return Center(child: Text(
                      'Error: ${snapshot.error}')); // Show error message if any
                } else if (_visitListController.salesList.isEmpty) {
                  return const Center(child: Text(
                      TTexts.noRecentCallAvailable)); // No data available
                } else {
                  // Filter the stockist based on the search query
                  List<StockistVisit> filteredDoctors = _visitListController
                      .salesList
                      .where((doctor) =>
                  doctor.stockist?.firmName?.toLowerCase().contains(
                      _searchQuery.toLowerCase()) ?? false).cast<StockistVisit>()
                      .toList();

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredDoctors.length,
                    itemBuilder: (context, index) {
                      final doctorVisit = filteredDoctors[index];
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          title: Text(
                            doctorVisit.stockist?.firmName ?? "Unknown Doctor",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Sales Rep: ${doctorVisit.stockist?.firmName ?? ""}"),
                              Text(
                                "Time: ${DateFormat('hh:mm a').format(doctorVisit.date ?? DateTime.now())}",
                              ),

                              Text("Call Notes: ${doctorVisit.notes ??
                                  "No Notes"}"),
                              const SizedBox(height: TSizes.spaceBtwText),
                              Center(
                                child: ElevatedButton(
                                  onPressed: doctorVisit.confirmed == true
                                      ? () {
                                    // Show a snackbar if the visit is already confirmed
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('You have already marked this visit confirmed.'),
                                        backgroundColor: Colors.orange,
                                      ),
                                    );
                                  }
                                      : () {
                                    // Show confirmation dialog
                                    QuickAlert.show(
                                      context: context,
                                      type: QuickAlertType.confirm,
                                      title: "Confirm Visit",
                                      text: "Are you sure you want to mark this visit as confirmed?",
                                      confirmBtnText: "Yes",
                                      cancelBtnText: "Cancel",
                                      confirmBtnColor: TColors.primary,
                                      width: 300,
                                      onConfirmBtnTap: () async {
                                        // Close the confirmation QuickAlert dialog first
                                        Navigator.of(context).pop();

                                        // Get the doctor visit ID
                                        final visitId = doctorVisit.id;
                                        String _message = '';
                                        double? userLatitude;
                                        double? userLongitude;

                                        // Fetch current latitude and longitude
                                        // Request location permission
                                        var permission = await Permission
                                            .location
                                            .request();

                                        if (!permission.isGranted) {
                                          QuickAlert.show(
                                            context: context,
                                            type: QuickAlertType.error,
                                            text:
                                            "Location permission is required to confirm the visit.",
                                            confirmBtnColor:
                                            TColors.primary,
                                            width: 300,
                                          );
                                          return;
                                        }

                                        // Fetch current location
                                        try {
                                          Position position =
                                          await Geolocator
                                              .getCurrentPosition(
                                            desiredAccuracy:
                                            LocationAccuracy.high,
                                          );
                                          userLatitude =
                                              position.latitude;
                                          userLongitude =
                                              position.longitude;
                                          print(
                                              'LOCATION IS: $userLatitude, $userLongitude');
                                        } catch (e) {
                                          QuickAlert.show(
                                            context: context,
                                            type: QuickAlertType.error,
                                            text:
                                            "Unable to fetch location. Try again.",
                                            confirmBtnColor:
                                            TColors.primary,
                                            width: 300,
                                          );
                                          return;
                                        }

                                        if (kDebugMode) {
                                          print('LOCATION IS: $_location');
                                        }

                                        // Make a PUT request to update the confirmation status
                                        final response = await http.put(
                                          Uri.parse(
                                              '${THttpHelper.baseUrl}/stockists/visits/$visitId/confirm'),
                                          headers: {
                                            'Content-Type': 'application/json',
                                          },
                                          body: json.encode({
                                            'userLatitude': userLatitude,
                                            'userLongitude': userLongitude,
                                          }),
                                        );



                                        print("Stockist Visit : reponseStatusCodeStockist: ${response.statusCode}");
                                        print("Stockist Visit reponseStatusCodeStockist: ${response.body}");
                                        print("Stockist Visit reponseStatusCodeStockist: ${THttpHelper.baseUrl}/stockists/visits/$visitId/confirm");

                                        if (response.statusCode == 200) {
                                          final responseBody = json.decode(response.body);

                                          print("Stockist Visit Confirm response data: $responseBody");



                                          // Parse the response using the VisitResponse model
                                          VisitConfirmationResponse visitResponse = VisitConfirmationResponse.fromJson(responseBody);

                                          print("Stockist Visit status ${visitResponse.status}");
                                          print("Stockist Visit message ${visitResponse.message}");

                                          if (visitResponse.status==true) {
                                            // If status is true, handle success
                                            setState(() {
                                              _message = visitResponse.message!; // Set the correct message
                                            });

                                            print("Success message: $_message");

                                            // Show a success message using QuickAlert
                                            QuickAlert.show(
                                              context: context,
                                              type: QuickAlertType.success,
                                              text: _message,
                                              confirmBtnColor: TColors.primary,
                                              width: 300,
                                            );
                                          } else {
                                            // If status is false, handle failure
                                            setState(() {
                                              _message = visitResponse.message!;
                                            });

                                            print("Failure message: $_message");

                                            // Show an error message using QuickAlert
                                            QuickAlert.show(
                                              context: context,
                                              type: QuickAlertType.error,
                                              text: _message,
                                              backgroundColor: Colors.blue.shade50,
                                              confirmBtnColor: TColors.primary,
                                              width: 300,
                                            );
                                          }

                                          // Refresh the visit list to reflect the changes
                                          await _visitListController.fetchSalesList();

                                          // Ensure the UI gets updated
                                          setState(() {});
                                        } else {
                                          // Handle the case when the PUT request fails
                                          QuickAlert.show(
                                            context: context,
                                            type: QuickAlertType.error,
                                            text: "Failed to confirm the visit",
                                            backgroundColor: TColors.primary,
                                            confirmBtnColor: TColors.primary,
                                            width: 300,
                                          );
                                        }


                                        /*if (response.statusCode == 200) {
                                          final responseBody = json.decode(response.body);

                                          print("Stockist Visit Confirm response data: $responseBody");


                                          // Parse the response using the VisitResponse model
                                          SMResponse visitResponse =
                                          SMResponse.fromJson(responseBody);

                                          print("Stockist Visit Confirm response data: ${visitResponse.status}");

                                          if (visitResponse.status) {
                                            // If status is true, handle success
                                            setState(() {
                                              _message = 'Visit confirmed successfully!';
                                            });

                                            // Show a success message using QuickAlert
                                            QuickAlert.show(
                                              context: context,
                                              type: QuickAlertType.success,
                                              text: _message,
                                              confirmBtnColor: TColors.primary,
                                              width: 300,
                                            );
                                          } else {
                                            // If status is false, handle failure (e.g., too far from the doctor)
                                            setState(() {
                                              _message = visitResponse.message;
                                            });

                                            // Show an error message using QuickAlert
                                            QuickAlert.show(
                                              context: context,
                                              type: QuickAlertType.error,
                                              text: _message,
                                              backgroundColor: Colors.blue.shade50,
                                              confirmBtnColor: TColors.primary,
                                              width: 300,
                                            );
                                          }

                                          // Refresh the visit list to reflect the changes
                                          await _visitListController.fetchSalesList();

                                          // Ensure the UI gets updated
                                          setState(() {});
                                        } else {
                                          // Handle the case when the PUT request fails
                                          QuickAlert.show(
                                            context: context,
                                            type: QuickAlertType.error,
                                            text: "Failed to confirm the visit",
                                            backgroundColor: TColors.primary,
                                            confirmBtnColor: TColors.primary,
                                            width: 300,
                                          );
                                        }*/
                                      },
                                      onCancelBtnTap: () {
                                        // If user clicks "Cancel", dismiss the QuickAlert dialog
                                        Navigator.of(context).pop();
                                      },
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: doctorVisit.confirmed == true
                                        ? TColors.success
                                        : TColors.primary,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                    child: Text(
                                      doctorVisit.confirmed == true
                                          ? TTexts.visitConfirmed
                                          : TTexts.confirmVisit,
                                    ),
                                  ),
                                )
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
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

  // Function to get location and update UI
  Future<void> _fetchLocation() async {
    try {
      String? location = await locationHelper.getCurrentLocation();
      setState(() {
        _location = location ?? 'Location not found';
      });
    } catch (e) {
      setState(() {
        _location = 'Error: $e';
      });
    }
  }
}