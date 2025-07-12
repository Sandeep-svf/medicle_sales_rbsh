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
import '../../../product/controller/ProductController.dart';
import '../controllers/ScheduleVisitcontroller.dart';
import '../controllers/visitListController.dart';
import '../models/visitSalesData.dart';

class VisitDoctorScreen extends StatefulWidget {
  const VisitDoctorScreen({super.key});

  @override
  State<VisitDoctorScreen> createState() => _VisitDoctorScreenState();
}

class _VisitDoctorScreenState extends State<VisitDoctorScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  DoctorListController _doctorListController = Get.put(DoctorListController());

  String? selectedDoctorId; // This will store the selected doctor's ID
  String? selectedDoctorName; // This will store the selected doctor's name

  late VisitListController _visitListController;
  final AuthManager authManager = AuthManager(); // Initialize AuthManager

  late ProductController productController;

  //location helper
  String _location = 'Fetching location...';

  // Instance of LocationHelper
  LocationHelper locationHelper = LocationHelper();

  @override
  void initState() {
    super.initState();
    _doctorListController.fetchDoctorList();
    _visitListController = VisitListController();
    _visitListController.fetchSalesList(); // Fetch the visit data when screen loads

    productController = Get.put(ProductController());
    productController.fetchProducts();
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
                        labelText: "Select Doctor",
                        border: OutlineInputBorder(),
                      ),
                      value: selectedDoctorName,
                      items: _doctorListController.doctorList.map((doctor) {
                        return DropdownMenuItem<String>(
                          value: doctor.name,
                          child: Text(doctor.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedDoctorName = value;
                          selectedDoctorId = _doctorListController.doctorList
                              .firstWhere((doctor) => doctor.name == value)
                              .id;
                        });
                      },
                      hint: const Text("Please select"),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a doctor';
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
                    String formattedTime =
                        DateFormat('hh:mm a').format(DateTime.now());

                    setState(() {
                      // Call the controller to create a doctor visit
                      DoctorVisitController.createDoctorVisit(
                        doctorId: selectedDoctorId,
                        date: dateController.text,
                        notes: callNotesController.text,
                        context: context,
                        authManager:
                            authManager, // Pass AuthManager instance here
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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(TTexts.confirmDeletion),
          content: const Text(TTexts.areYouSureYouWantToDeleteThisLog),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child:
                  const Text(TTexts.no, style: TextStyle(color: Colors.grey)),
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
                labelText: TTexts.searchDoctor,
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
                      child:
                          CircularProgressIndicator()); // Show loading indicator
                } else if (snapshot.hasError) {
                  return Center(
                      child: Text(
                          'Error: ${snapshot.error}')); // Show error message if any
                } else if (_visitListController.salesList.isEmpty) {
                  return const Center(
                      child: Text(
                          TTexts.noRecentCallAvailable)); // No data available
                } else {
                  // Filter the doctors based on the search query
                  List<VisitSalesLogModel> filteredDoctors =
                      _visitListController.salesList
                          .where((doctor) =>
                              doctor.doctor?.name
                                  ?.toLowerCase()
                                  .contains(_searchQuery.toLowerCase()) ??
                              false)
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
                            doctorVisit.doctor?.name ?? "Unknown Doctor",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Sales Rep: ${doctorVisit.user.name ?? ""}"),
                              Text(
                                  "Time: ${DateFormat('hh:mm a').format(doctorVisit.date)}"),
                              Text(
                                  "Call Notes: ${doctorVisit.notes ?? "No Notes"}"),
                              const SizedBox(height: TSizes.spaceBtwText),
                              Center(
                                child: ElevatedButton(
                                  onPressed: doctorVisit.confirmed
                                      ? () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('You have already marked this visit confirmed.'),
                                        backgroundColor: Colors.orange,
                                      ),
                                    );
                                  }
                                      : () async {
                                    List<String> selectedProducts = await _showProductSelectionDialog(context);
                                    _confirmVisit(context, doctorVisit.id, selectedProducts);
                                  },

                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                    doctorVisit.confirmed ? TColors.success : TColors.primary,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                    child: Text(
                                      doctorVisit.confirmed
                                          ? TTexts.visitConfirmed
                                          : TTexts.confirmVisit,
                                    ),
                                  ),
                                ),

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

  void _showProductSelectionBeforeConfirm(BuildContext context, String visitId) async {
    final ProductController productController = Get.put(ProductController());
    await productController.fetchProducts();
    final RxList<String> selectedProductIds = <String>[].obs;

    await showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Obx(() {
                if (productController.isLoading.value) {
                  return const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                return Container(
                  padding: const EdgeInsets.all(20),
                  constraints: const BoxConstraints(maxHeight: 500),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Select Products (Optional)",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: ListView.separated(
                          itemCount: productController.productList.length,
                          separatorBuilder: (_, __) => const Divider(height: 16),
                          itemBuilder: (_, i) {
                            final product = productController.productList[i];
                            final isSelected = selectedProductIds.contains(product.id);

                            return InkWell(
                              onTap: () {
                                setState(() {
                                  if (isSelected) {
                                    selectedProductIds.remove(product.id);
                                  } else {
                                    selectedProductIds.add(product.id);
                                  }
                                });
                              },
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      product.image ?? '',
                                      width: 48,
                                      height: 48,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          product.name,
                                          style: const TextStyle(fontWeight: FontWeight.w600),
                                        ),
                                        if ((product.description ?? '').isNotEmpty)
                                          Padding(
                                            padding: const EdgeInsets.only(top: 4),
                                            child: Text(
                                              product.description ?? '',
                                              style: const TextStyle(fontSize: 13, color: Colors.black54),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  Checkbox(
                                    value: isSelected,
                                    onChanged: (val) {
                                      setState(() {
                                        if (val == true) {
                                          selectedProductIds.add(product.id);
                                        } else {
                                          selectedProductIds.remove(product.id);
                                        }
                                      });
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text("Cancel"),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              _confirmVisit(context, visitId, selectedProductIds.toList());
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: TColors.primary,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            ),
                            child: const Text("Next"),
                          ),
                        ],
                      )
                    ],
                  ),
                );
              }),
            );
          },
        );
      },
    );


  }
  void _confirmVisit(BuildContext context, String visitId, List<String> selectedProducts) async {
    bool confirmed = false;

    await QuickAlert.show(
      context: context,
      type: QuickAlertType.confirm,
      title: "Confirm Visit",
      text: "Are you sure you want to mark this visit as confirmed?",
      confirmBtnText: "Yes",
      cancelBtnText: "Cancel",
      confirmBtnColor: TColors.primary,
      width: 300,
      onConfirmBtnTap: () {
        confirmed = true;
        Navigator.of(context, rootNavigator: true).pop(); // ensure dialog closes
      },
      onCancelBtnTap: () {
        confirmed = false;
        Navigator.of(context, rootNavigator: true).pop(); // ensure dialog closes
      },
    );

    if (!confirmed) return;

    try {
      var permission = await Permission.location.request();
      if (!permission.isGranted) {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          text: "Location permission is required.",
          confirmBtnColor: TColors.primary,
          width: 300,
        );
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final response = await http.put(
        Uri.parse('${THttpHelper.baseUrl}/doctor-visits/$visitId/confirm'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userLatitude': position.latitude,
          'userLongitude': position.longitude,
          'products': selectedProducts,
        }),
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        final visitResponse = SMResponse.fromJson(responseBody);

        QuickAlert.show(
          context: context,
          type: visitResponse.status ? QuickAlertType.success : QuickAlertType.error,
          text: visitResponse.message,
          confirmBtnColor: TColors.primary,
          width: 300,
        );

        if (visitResponse.status) {
          await _visitListController.fetchSalesList();
          if (context.mounted) setState(() {});
        }
      } else {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          text: "Failed to confirm the visit",
          confirmBtnColor: TColors.primary,
          width: 300,
        );
      }
    } catch (e) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        text: "Unexpected error: $e",
        confirmBtnColor: TColors.primary,
        width: 300,
      );
    }
  }

  Future<List<String>> _showProductSelectionDialog(BuildContext context) async {
    final RxList<String> selectedProductIds = <String>[].obs;
    final RxString searchQuery = "".obs;
    final productController = Get.put(ProductController());

    await productController.fetchProducts();

    return await showDialog<List<String>>(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Select Products (Optional)"),
              content: SizedBox(
                height: 500,
                width: double.maxFinite,
                child: Obx(() {
                  if (productController.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (productController.productList.isEmpty) {
                    return const Center(child: Text("No products available."));
                  }

                  final filteredList = productController.productList.where((product) {
                    return product.name.toLowerCase().contains(searchQuery.value);
                  }).toList();

                  return Column(
                    children: [
                      // Search Field
                      TextField(
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.search),
                          hintText: "Search products...",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onChanged: (value) {
                          searchQuery.value = value.toLowerCase();
                        },
                      ),
                      const SizedBox(height: 10),

                      // Filtered List
                      Expanded(
                        child: filteredList.isEmpty
                            ? const Center(child: Text("No matching products found."))
                            : ListView.builder(
                          itemCount: filteredList.length,
                          itemBuilder: (_, i) {
                            final product = filteredList[i];
                            final isSelected = selectedProductIds.contains(product.id);

                            return CheckboxListTile(
                              value: isSelected,
                              title: Text(product.name),
                              subtitle: Text(product.description ?? ""),
                              secondary: GestureDetector(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (_) => Dialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Stack(
                                        alignment: Alignment.topRight,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(16.0),
                                            child: Image.network(
                                              product.image ?? '',
                                              fit: BoxFit.contain,
                                              errorBuilder: (_, __, ___) =>
                                              const Icon(Icons.broken_image, size: 80),
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.close),
                                            onPressed: () => Navigator.of(context).pop(),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    product.image ?? '',
                                    width: 40,
                                    height: 40,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                    const Icon(Icons.image_not_supported),
                                  ),
                                ),
                              ),
                              onChanged: (val) {
                                setState(() {
                                  if (val == true) {
                                    selectedProductIds.add(product.id);
                                  } else {
                                    selectedProductIds.remove(product.id);
                                  }
                                });
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  );
                }),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, <String>[]),
                  child: const Text("Skip"),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, selectedProductIds.toList()),
                  style: ElevatedButton.styleFrom(backgroundColor: TColors.primary),
                  child: const Text("Next"),
                ),
              ],
            );
          },
        );
      },
    ) ?? <String>[]; // fallback if dialog dismissed
  }






}
