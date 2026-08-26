import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:medicle_sales_rbsh/utils/constants/colors.dart';
import 'package:medicle_sales_rbsh/utils/constants/sizes.dart';
import 'package:medicle_sales_rbsh/utils/local_storage/auth_manager.dart';

import '../controllers/AllowenceController.dart';
import '../controllers/ExpanseDefaultValueController.dart';
import '../controllers/other_expense_controller.dart';
import '../models/DailyAllowenceRequestModel.dart';
import '../models/TravelAllowenceRequestModel.dart';
import '../models/TravelDetails.dart';
import '../models/other_expense_request.dart';

class AddAllowanceScreen extends StatefulWidget {
  final bool isEditMode;
  final String? expenseId;
  final Map<String, dynamic>? existingData;

  const AddAllowanceScreen(
      {super.key, this.isEditMode = false, this.expenseId, this.existingData});

  @override
  State<AddAllowanceScreen> createState() => _AddAllowanceScreenState();
}

class _AddAllowanceScreenState extends State<AddAllowanceScreen> {
  bool isLoading = false;
  Map<String, dynamic> payload = {};

  final ScraperSettingsController settingsController = new ScraperSettingsController();

  final List<String> categories = [
    'Travel Allowance',
    'Daily Allowance',
    'Other Expense'
  ];
  String? selectedCategory = 'Travel Allowance';
  String tripType = 'One Way';
  DateTime? selectedExpenseDate;

  final otherAmountController = TextEditingController();

  final otherDescriptionController = TextEditingController();

  String? billImagePath;
  String? billImageUrl;

  // Travel Allowance
  final fromController = TextEditingController();
  final toController = TextEditingController();
  final kmController = TextEditingController();
  final remarkController = TextEditingController();
  List<Map<String, dynamic>> trips = [];
  int? editingIndex;
  final double farePerKm = 2.4;

  // Daily Allowance
  final daAmountController = TextEditingController();
  final daDescriptionController = TextEditingController();
  String? selectedDAType;

  @override
  void initState() {
    super.initState();
    selectedExpenseDate = DateTime.now();
    _loadSettingsAndPrefill();

    // Show DCR policy every time user lands on this screen.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _showDcrPolicyDialog();
      }
    });
  }

  Future<void> _loadSettingsAndPrefill() async {
    await settingsController.fetchSettings();
    _prefillDataIfEditing();

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> pickExpenseDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedExpenseDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        selectedExpenseDate = picked;
      });
    }
  }

  Future<void> pickBillImage() async {
    try {
      final picker = ImagePicker();

      final image = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (image != null) {
        setState(() {
          billImagePath = image.path;
        });
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Camera permission denied",
      );
    }
  }

  void _prefillDataIfEditing() {
    final settings = settingsController.scraperSettings.value;
    if (widget.isEditMode && widget.existingData != null) {
      final data = widget.existingData!;
      selectedCategory =
          data['category'] == 'daily' ? 'Daily Allowance' : 'Travel Allowance';

      if (selectedCategory == 'Travel Allowance') {
        final travelDetails =
            List<Map<String, dynamic>>.from(data['travelDetails'] ?? []);
        trips = travelDetails.map((t) {
          final km = (t['km'] as num).toDouble();
          final fare = km * farePerKm;
          return {
            'from': t['from'],
            'to': t['to'],
            'km': km,
            'fare': fare,
            'tripType': 'One Way',
            'remark': data['description'],
          };
        }).toList();
        remarkController.text = data['description'] ?? '';
      } else if (selectedCategory == 'Daily Allowance') {
        switch (data['dailyAllowanceType']) {
          case 'headoffice':
            selectedDAType = 'Headquarter';
            break;

          case 'ex-headquarters':
            selectedDAType = 'Ex';
            break;

          case 'outside':
            selectedDAType = 'Out Of Station';
            break;

          default:
            selectedDAType = null;
        }
        if (selectedDAType == 'Headquarter') {
          daAmountController.text =
              (settings?.headOfficeAmount ?? 0).toStringAsFixed(2);
        } else if (selectedDAType == 'Ex') {
          daAmountController.text =
              (settings?.exHeadquartersAmount ?? 0).toStringAsFixed(2);
        } else if (selectedDAType == 'Out Of Station') {
          daAmountController.text =
              (settings?.outsideHeadOfficeAmount ?? 0).toStringAsFixed(2);
        }

        daDescriptionController.text = data['description'] ?? '';
      }
    }
  }

  void _addTrip() {
    final from = fromController.text.trim();
    final to = toController.text.trim();
    final km = double.tryParse(kmController.text.trim());
    final remark = remarkController.text.trim();

    if (from.isEmpty || to.isEmpty || km == null) {
      Fluttertoast.showToast(
        msg: "Field(s) cannot be empty",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return;
    }

    final ratePerKm =
        settingsController.scraperSettings.value?.ratePerKm ?? 0.0;

    final multiplier = tripType == 'Round Trip' ? 2 : 1;

    final fare = km * ratePerKm * multiplier;

    final trip = {
      'from': from,
      'to': to,
      'km': km,
      'fare': fare,
      'tripType': tripType,
      'remark': remark,
    };

    setState(() {
      if (editingIndex != null) {
        trips[editingIndex!] = trip;
        editingIndex = null;
      } else {
        trips.add(trip);
      }
      fromController.clear();
      toController.clear();
      kmController.clear();
      remarkController.clear();
    });
  }

  void _editTrip(int index) {
    final trip = trips[index];
    setState(() {
      editingIndex = index;
      fromController.text = trip['from'];
      toController.text = trip['to'];
      kmController.text = trip['km'].toString();
      remarkController.text = trip['remark'] ?? '';
      tripType = trip['tripType'];
    });
  }

  void _cancelEdit() {
    setState(() {
      editingIndex = null;
      fromController.clear();
      toController.clear();
      kmController.clear();
      remarkController.clear();
    });
  }

  void _deleteTrip(int index) {
    setState(() {
      trips.removeAt(index);
    });
  }

  double get totalFare => trips.fold(0, (sum, t) => sum + t['fare']);

  void _submitData() async {
    debugPrint("Submit button clicked");

    setState(() => isLoading = true);

    try {
      AuthManager authManager = AuthManager();
      String? userId = await authManager.getUserId();

      debugPrint("User ID: $userId");

      if (userId == null || userId.isEmpty) {
        Fluttertoast.showToast(msg: "User ID is missing");
        setState(() => isLoading = false);
        return;
      }

      bool success = false;

      if (selectedCategory == 'Travel Allowance') {
        if (trips.isEmpty) {
          Fluttertoast.showToast(msg: "Please add at least one trip");
          setState(() => isLoading = false);
          return;
        }

        final travelDetails = trips
            .map((t) => {
                  'from': t['from'],
                  'to': t['to'],
                  'km': t['tripType'] == 'Round Trip' ? (t['km'] * 2) : t['km'],
                })
            .toList();

        final payload = {
          'userId': userId,
          'category': 'travel',
          'description': remarkController.text.trim().isEmpty
              ? "$tripType: Travel Allowance submission"
              : "$tripType: ${remarkController.text.trim()}",
          'bill': '',
          'date': DateFormat('yyyy-MM-dd')
              .format(selectedExpenseDate ?? DateTime.now()),
          'travelDetails': travelDetails,
        };

        if (widget.isEditMode && widget.expenseId != null) {
          success = await AllowanceController.updateExpense(
            expenseId: widget.expenseId!,
            data: payload,
          );
        } else {
          final travelRequest = TravelAllowanceRequest(
            userId: userId,
            description: payload['description']?.toString() ?? '',
            category: "travel",
            //added
            bill: "",
            date: DateFormat('yyyy-MM-dd')
                .format(selectedExpenseDate ?? DateTime.now()),

            //added
            travelDetails: travelDetails
                .map((t) => TravelDetail(
                      from: t['from'],
                      to: t['to'],
                      km: t['km'],
                    ))
                .toList(),
          );
          success =
              await AllowanceController.submitTravelAllowance(travelRequest);
        }

        if (success) {
          Fluttertoast.showToast(
              msg: widget.isEditMode
                  ? "Updated Successfully"
                  : "Travel Allowance submitted successfully");
          setState(() {
            trips.clear();
            fromController.clear();
            toController.clear();
            kmController.clear();
            remarkController.clear();
          });
          Navigator.pop(context, true);
        }
      } else if (selectedCategory == 'Daily Allowance') {
        if (selectedDAType == null) {
          Fluttertoast.showToast(msg: "Please select DA location type");
          setState(() => isLoading = false);
          return;
        }

        String dailyAllowanceType;
        switch (selectedDAType) {
          case 'Headquarter':
            dailyAllowanceType = 'headoffice';
            break;

          case 'Ex':
            dailyAllowanceType = 'ex-headquarters';
            break;

          case 'Out Of Station':
            dailyAllowanceType = 'outside';
            break;

          default:
            dailyAllowanceType = 'headoffice';
        }

        final payload = {
          'userId': userId,
          'category': 'daily',
          'description': daDescriptionController.text.trim(),
          'bill': '',
          'dailyAllowanceType': dailyAllowanceType,
          'date': DateFormat('yyyy-MM-dd')
              .format(selectedExpenseDate ?? DateTime.now()),
        };

        if (widget.isEditMode && widget.expenseId != null) {
          success = await AllowanceController.updateExpense(
            expenseId: widget.expenseId!,
            data: payload,
          );
        } else {
          final daRequest = DailyAllowanceRequest(
            userId: userId,
            description: (payload['description'] as String?) ?? '',
            dailyAllowanceType:
                (payload['dailyAllowanceType'] as String?) ?? 'headoffice',
            date: DateFormat('yyyy-MM-dd')
                .format(selectedExpenseDate ?? DateTime.now()),
          );
          success = await AllowanceController.submitDailyAllowance(daRequest);
        }

        if (success) {
          Fluttertoast.showToast(
              msg: widget.isEditMode
                  ? "Updated Successfully"
                  : "Daily Allowance submitted successfully");
          setState(() {
            selectedDAType = null;
            daAmountController.clear();
            daDescriptionController.clear();
          });
          Navigator.pop(context, true);
        }
      } else if (selectedCategory == 'Other Expense') {
        if (otherAmountController.text.trim().isEmpty) {
          Fluttertoast.showToast(
            msg: "Please enter amount",
          );
          return;
        }

        if (billImagePath == null) {
          Fluttertoast.showToast(
            msg: "Please upload bill image",
          );
          return;
        }

        // 1. Upload bill
        billImageUrl = await OtherExpenseController.uploadBill(
          billImagePath!,
        );

        if (billImageUrl == null) {
          Fluttertoast.showToast(
            msg: "Bill upload failed",
          );
          return;
        }

        // 2. Create request model
        final request = OtherExpenseRequest(
          userId: userId,
          amount: double.parse(
            otherAmountController.text.trim(),
          ),
          description: otherDescriptionController.text.trim(),
          bill: billImageUrl!,
          date: selectedExpenseDate.toString(),
        );

        // 3. Call API
        success = await OtherExpenseController.createOtherExpense(request);

        if (success) {
          Fluttertoast.showToast(
            msg: "Other Expense Submitted",
          );

          Navigator.pop(
            context,
            true,
          );
        }
      }

      if (!success) {
        Fluttertoast.showToast(
          msg: widget.isEditMode
              ? "You can not updated expense more than once."
              : "Failed to submit ${selectedCategory!.toLowerCase()}",
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Exception: ${e.toString()}",
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Allowance"),
        backgroundColor: TColors.primary, // Set background color as needed
        titleTextStyle: TextStyle(
          color: Colors.white, // Set title text color to white
          fontSize: 20, // Adjust font size if needed
          fontWeight: FontWeight.bold, // Adjust font weight if needed
        ),
        iconTheme: IconThemeData(
          color: Colors.white, // Set back arrow (leading icon) color to white
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: selectedCategory,
              decoration: const InputDecoration(
                  labelText: "Category", border: OutlineInputBorder()),
              items: categories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: widget.isEditMode
                  ? null
                  : (val) => setState(() => selectedCategory = val),
            ),
            const SizedBox(height: 16),
            if (selectedCategory == 'Travel Allowance') ...[
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [

                      InkWell(
                        onTap: pickExpenseDate,
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: "Travel Date",
                            border: OutlineInputBorder(),
                          ),
                          child: Text(
                            DateFormat('dd MMM yyyy').format(
                              selectedExpenseDate ?? DateTime.now(),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      DropdownButtonFormField<String>(
                        value: tripType,
                        decoration: const InputDecoration(
                            labelText: 'Trip Type',
                            border: OutlineInputBorder()),
                        items: ['One Way', 'Round Trip']
                            .map((type) => DropdownMenuItem(
                                value: type, child: Text(type)))
                            .toList(),
                        onChanged: (val) => setState(() => tripType = val!),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: fromController,
                              decoration: const InputDecoration(
                                  labelText: 'From',
                                  border: OutlineInputBorder()),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              controller: toController,
                              decoration: const InputDecoration(
                                  labelText: 'To',
                                  border: OutlineInputBorder()),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: kmController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        decoration: const InputDecoration(
                            labelText: 'Distance (km)',
                            border: OutlineInputBorder()),
                        onFieldSubmitted: (_) => _addTrip(),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: remarkController,
                        decoration: InputDecoration(
                            labelText: "Remark:",
                            border: OutlineInputBorder(),
                            prefixText: "$tripType: "),
                      ),
                      const SizedBox(
                        height: TSizes.spaceBtwItems,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed:
                                  widget.isEditMode && editingIndex == null
                                      ? null
                                      : _addTrip,
                              style: ElevatedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                              ),
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 15),
                                child: Text(editingIndex == null
                                    ? 'Add Trip'
                                    : 'Update Trip'),
                              ),
                            ),
                          ),
                          if (editingIndex != null) ...[
                            const SizedBox(width: 10),
                            TextButton(
                              onPressed: _cancelEdit,
                              child: const Text("Cancel"),
                            ),
                          ]
                        ],
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: trips.isEmpty
                    ? const Center(child: Text('No trips added.'))
                    : ListView.builder(
                        itemCount: trips.length,
                        itemBuilder: (_, i) {
                          final trip = trips[i];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            child: ListTile(
                              title: Text('${trip['from']} → ${trip['to']}'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      '${trip['tripType'] == 'Round Trip' ? (trip['km'] * 2).toStringAsFixed(2) : trip['km'].toString()} km'
                                      ' | ₹${trip['fare'].toStringAsFixed(2)}'),
                                  Text('Trip Type: ${trip['tripType']}'),
                                  if ((trip['remark'] ?? '').isNotEmpty)
                                    Text('Remark: ${trip['remark']}'),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () => _editTrip(i),
                                  ),
                                  if (!widget.isEditMode)
                                    IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red),
                                      onPressed: () => _deleteTrip(i),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 10),
              Text('Total Fare: ₹${totalFare.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ] else if (selectedCategory == 'Daily Allowance') ...[
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [

                      InkWell(
                        onTap: pickExpenseDate,
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: "Allowance Date",
                            border: OutlineInputBorder(),
                          ),
                          child: Text(
                            DateFormat('dd MMM yyyy').format(
                              selectedExpenseDate ?? DateTime.now(),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),


                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                            labelText: "Select DA Location",
                            border: OutlineInputBorder()),
                        value: selectedDAType,
                        items: ['Ex', 'Headquarter', 'Out Of Station']
                            .map((e) =>
                                DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (val) {
                          setState(() {
                            selectedDAType = val;
                            final settings = settingsController.scraperSettings.value;

                            if (val == 'Ex') {
                              daAmountController.text =
                                  (settings?.exHeadquartersAmount ?? 0).toStringAsFixed(2);

                              daDescriptionController.text = 'DA for Ex';
                            } else if (val == 'Headquarter') {
                              daAmountController.text =
                                  (settings?.headOfficeAmount ?? 0).toStringAsFixed(2);

                              daDescriptionController.text = 'DA for Headquarter';
                            } else {
                              daAmountController.text =
                                  (settings?.outsideHeadOfficeAmount ?? 0).toStringAsFixed(2);

                              daDescriptionController.text = 'DA for Out Of Station';
                            }
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: daAmountController,
                        readOnly: true,
                        decoration: const InputDecoration(
                            labelText: 'Amount', border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: daDescriptionController,
                        decoration: const InputDecoration(
                            labelText: 'Description',
                            border: OutlineInputBorder()),
                      ),
                    ],
                  ),
                ),
              ),
            ] else if (selectedCategory == 'Other Expense') ...[
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      InkWell(
                        onTap: pickExpenseDate,
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: "Expense Date",
                            border: OutlineInputBorder(),
                          ),
                          child: Text(
                            selectedExpenseDate == null
                                ? "Select Date"
                                : DateFormat(
                                    'dd MMM yyyy',
                                  ).format(
                                    selectedExpenseDate!,
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: otherAmountController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "Amount",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: otherDescriptionController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: "Description",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: pickBillImage,
                        icon: const Icon(Icons.upload),
                        label: Text(
                          billImagePath == null
                              ? "Capture Bill"
                              : "Bill Selected",
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : _submitData,
                style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48)),
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(widget.isEditMode ? "Update" : "Submit"),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> _showDcrPolicyDialog() async {
    if (!mounted) return;

    await showDialog<void>(
      context: context,

      // User can close using the X button.
      // Prevent accidental close by tapping outside.
      barrierDismissible: false,

      builder: (dialogContext) {
        final screenSize = MediaQuery.of(dialogContext).size;

        return Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 24,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          clipBehavior: Clip.antiAlias,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 920,
              maxHeight: screenSize.height * 0.88,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ====================================================
                // HEADER
                // ====================================================
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(
                    24,
                    18,
                    12,
                    18,
                  ),
                  color: TColors.primary,
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.assessment_outlined,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),

                      const SizedBox(width: 14),

                      const Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(
                              'DCR (Daily Call Report)',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 21,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 3),
                            Text(
                              'Daily call performance and allowance eligibility',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),

                      IconButton(
                        tooltip: 'Close',
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                        },
                        icon: const Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                    ],
                  ),
                ),

                // ====================================================
                // CONTENT
                // ====================================================
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.blueGrey
                                .withOpacity(0.06),
                            borderRadius:
                            BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.blueGrey
                                  .withOpacity(0.12),
                            ),
                          ),
                          child: const Row(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.info_outline_rounded,
                                size: 20,
                                color: Colors.blueGrey,
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Allowance eligibility is calculated '
                                      'based on the number of Doctor and '
                                      'Chemist calls completed during the day.',
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    height: 1.4,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Horizontally scrollable for smaller devices.
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Container(
                            width: 800,
                            decoration: BoxDecoration(
                              borderRadius:
                              BorderRadius.circular(14),
                              border: Border.all(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Column(
                              children: [
                                _buildDcrTableHeader(),

                                _buildDcrRow(
                                  doctorCall: '12 or more',
                                  chemistCall: '5 or more',
                                  ta: '100%',
                                  da: '100%',
                                  backgroundColor:
                                  const Color(0xFFE8F5E1),
                                  statusColor:
                                  const Color(0xFF2E7D32),
                                ),

                                _buildDcrRow(
                                  doctorCall: '10 - 11',
                                  chemistCall: '4',
                                  ta: '100%',
                                  da: '100%',
                                  daNote:
                                  'Recorded as FLAG',
                                  backgroundColor:
                                  const Color(0xFFE5F1FB),
                                  statusColor:
                                  const Color(0xFF1565C0),
                                ),

                                _buildDcrRow(
                                  doctorCall: '8 - 9',
                                  chemistCall: '3',
                                  ta: '100%',
                                  da: '50%',
                                  backgroundColor:
                                  const Color(0xFFFFF5D6),
                                  statusColor:
                                  const Color(0xFFF9A825),
                                ),

                                _buildDcrRow(
                                  doctorCall: '7',
                                  chemistCall: '2',
                                  ta: '50%',
                                  da: '50%',
                                  backgroundColor:
                                  const Color(0xFFFFE9DA),
                                  statusColor:
                                  const Color(0xFFEF6C00),
                                ),

                                _buildDcrRow(
                                  doctorCall: 'Less than 7',
                                  chemistCall: '1',
                                  ta: '0%',
                                  da: '0%',
                                  backgroundColor:
                                  const Color(0xFFFFE2E2),
                                  statusColor:
                                  const Color(0xFFC62828),
                                  isLast: true,
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),

                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber
                                .withOpacity(0.10),
                            borderRadius:
                            BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.amber
                                  .withOpacity(0.30),
                            ),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.flag_outlined,
                                color: Color(0xFFB7791F),
                                size: 20,
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  '10 - 11 Doctor calls with 4 Chemist '
                                      'calls receives 100% DA, but the entry '
                                      'is recorded as FLAG.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF744210),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ====================================================
                // FOOTER
                // ====================================================
                Container(
                  padding: const EdgeInsets.fromLTRB(
                    24,
                    14,
                    24,
                    18,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    border: Border(
                      top: BorderSide(
                        color: Colors.grey.shade200,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Please review the DCR criteria before '
                              'submitting your allowance.',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: Colors.black54,
                          ),
                        ),
                      ),

                      const SizedBox(width: 20),

                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: TColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 22,
                            vertical: 13,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(10),
                          ),
                        ),
                        icon: const Icon(
                          Icons.check_rounded,
                          size: 18,
                        ),
                        label: const Text(
                          'Understood',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDcrTableHeader() {
    return Container(
      color: const Color(0xFFF1F3F5),
      padding: const EdgeInsets.symmetric(
        vertical: 15,
        horizontal: 12,
      ),
      child: const Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              "Doctor's Call",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF263238),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              'Chemist Call',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF263238),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'TA',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF263238),
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(
              'DA',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF263238),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDcrRow({
    required String doctorCall,
    required String chemistCall,
    required String ta,
    required String da,
    required Color backgroundColor,
    required Color statusColor,
    String? daNote,
    bool isLast = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 14,
        horizontal: 12,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: isLast
            ? null
            : Border(
          bottom: BorderSide(
            color: Colors.black.withOpacity(0.06),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              doctorCall,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF263238),
              ),
            ),
          ),

          Expanded(
            flex: 3,
            child: Text(
              chemistCall,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF263238),
              ),
            ),
          ),

          Expanded(
            flex: 2,
            child: Center(
              child: _buildPercentageBadge(
                ta,
                statusColor,
              ),
            ),
          ),

          Expanded(
            flex: 4,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildPercentageBadge(
                  da,
                  statusColor,
                ),

                if (daNote != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    daNote,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPercentageBadge(
      String value,
      Color color,
      ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.25),
        ),
      ),
      child: Text(
        value,
        style: TextStyle(
          color: color,
          fontSize: 13.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }


}
