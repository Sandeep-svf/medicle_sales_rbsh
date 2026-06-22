import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:medicle_sales_rbsh/utils/constants/colors.dart';
import 'package:medicle_sales_rbsh/utils/constants/sizes.dart';
import 'package:medicle_sales_rbsh/utils/local_storage/auth_manager.dart';

import '../controllers/AllowenceController.dart';
import '../controllers/other_expense_controller.dart';
import '../models/DailyAllowenceRequestModel.dart';
import '../models/TravelAllowenceRequestModel.dart';
import '../models/TravelDetails.dart';
import '../models/other_expense_request.dart';

class AddAllowanceScreen extends StatefulWidget {
  final bool isEditMode;
  final String? expenseId;
  final Map<String, dynamic>? existingData;


  const AddAllowanceScreen({super.key, this.isEditMode = false, this.expenseId, this.existingData});

  @override
  State<AddAllowanceScreen> createState() => _AddAllowanceScreenState();
}

class _AddAllowanceScreenState extends State<AddAllowanceScreen> {
  bool isLoading = false;
  Map<String, dynamic> payload = {};

  final List<String> categories = ['Travel Allowance', 'Daily Allowance','Other Expense'];
  String? selectedCategory = 'Travel Allowance';
  String tripType = 'One Way';
  DateTime? selectedExpenseDate;

  final otherAmountController =
  TextEditingController();

  final otherDescriptionController =
  TextEditingController();

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
    _prefillDataIfEditing();
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
    final picker = ImagePicker();

    final image = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (image != null) {
      setState(() {
        billImagePath = image.path;
      });
    }
  }

  void _prefillDataIfEditing() {
    if (widget.isEditMode && widget.existingData != null) {
      final data = widget.existingData!;
      selectedCategory = data['category'] == 'daily' ? 'Daily Allowance' : 'Travel Allowance';

      if (selectedCategory == 'Travel Allowance') {
        final travelDetails = List<Map<String, dynamic>>.from(data['travelDetails'] ?? []);
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
        selectedDAType = data['dailyAllowanceType'] == 'headoffice' ? 'Headquarter' : 'Other Headquarter';
        daAmountController.text = selectedDAType == 'Headquarter' ? '150.00' : '175.00';
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

    final multiplier = tripType == 'Round Trip' ? 2 : 1;
    final fare = km * farePerKm * multiplier;

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

        final travelDetails = trips.map((t) => {
          'from': t['from'],
          'to': t['to'],
          'km': t['tripType'] == 'Round Trip' ? (t['km'] * 2) : t['km'],
        }).toList();

        final payload = {
          'userId': userId,
          'category': 'travel',
          'description': remarkController.text.trim().isEmpty
              ? "$tripType: Travel Allowance submission"
              : "$tripType: ${remarkController.text.trim()}",
          'bill': '',
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
            category: "travel", //added
            bill: "", //added
            travelDetails: travelDetails.map((t) => TravelDetail(
              from: t['from'],
              to: t['to'],
              km: t['km'],
            )).toList(),
          );
          success = await AllowanceController.submitTravelAllowance(travelRequest);
        }

        if (success) {
          Fluttertoast.showToast(msg: widget.isEditMode ? "Updated Successfully" : "Travel Allowance submitted successfully");
          setState(() {
            trips.clear();
            fromController.clear();
            toController.clear();
            kmController.clear();
            remarkController.clear();
          });
          Navigator.pop(context,true);
        }

      } else if (selectedCategory == 'Daily Allowance') {
        if (selectedDAType == null) {
          Fluttertoast.showToast(msg: "Please select DA location type");
          setState(() => isLoading = false);
          return;
        }

        final payload = {
          'userId': userId,
          'category': 'daily',
          'description': daDescriptionController.text.trim(),
          'bill': '',
          'dailyAllowanceType': selectedDAType == 'Headquarter' ? 'headoffice' : 'outside',
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
            dailyAllowanceType: (payload['dailyAllowanceType'] as String?) ?? 'headoffice',
          );
          success = await AllowanceController.submitDailyAllowance(daRequest);
        }

        if (success) {
          Fluttertoast.showToast(msg: widget.isEditMode ? "Updated Successfully" : "Daily Allowance submitted successfully");
          setState(() {
            selectedDAType = null;
            daAmountController.clear();
            daDescriptionController.clear();
          });
          Navigator.pop(context,true);
        }
      }else if (selectedCategory == 'Other Expense') {




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
        billImageUrl =
        await OtherExpenseController.uploadBill(
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
          description:
          otherDescriptionController.text.trim(),
          bill: billImageUrl!, date: selectedExpenseDate.toString(),
        );

        // 3. Call API
        success =
        await OtherExpenseController
            .createOtherExpense(request);

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
              decoration: const InputDecoration(labelText: "Category", border: OutlineInputBorder()),
              items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: widget.isEditMode ? null : (val) => setState(() => selectedCategory = val),
            ),

            const SizedBox(height: 16),
            if (selectedCategory == 'Travel Allowance') ...[
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      DropdownButtonFormField<String>(
                        value: tripType,
                        decoration: const InputDecoration(labelText: 'Trip Type', border: OutlineInputBorder()),
                        items: ['One Way', 'Round Trip']
                            .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                            .toList(),
                        onChanged: (val) => setState(() => tripType = val!),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: fromController,
                              decoration: const InputDecoration(labelText: 'From', border: OutlineInputBorder()),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              controller: toController,
                              decoration: const InputDecoration(labelText: 'To', border: OutlineInputBorder()),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      TextFormField(
                        controller: kmController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: const InputDecoration(labelText: 'Distance (km)', border: OutlineInputBorder()),
                        onFieldSubmitted: (_) => _addTrip(),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: remarkController,

                        decoration:  InputDecoration(labelText: "Remark:", border: OutlineInputBorder(),prefixText: "$tripType: "),
                      ),


                      const SizedBox(height: TSizes.spaceBtwItems,),

                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: widget.isEditMode && editingIndex == null ? null : _addTrip,

                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 15),
                                child: Text(editingIndex == null ? 'Add Trip' : 'Update Trip'),
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
                                    ' | ₹${trip['fare'].toStringAsFixed(2)}'
                            ),

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
                                icon: const Icon(Icons.delete, color: Colors.red),
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
              Text('Total Fare: ₹${totalFare.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
            ] else if (selectedCategory == 'Daily Allowance') ...[
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(labelText: "Select DA Location", border: OutlineInputBorder()),
                        value: selectedDAType,
                        items: ['Other Headquarter', 'Headquarter']
                            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (val) {
                          setState(() {
                            selectedDAType = val;
                            if (val == 'Other Headquarter') {
                              daAmountController.text = '175.00';
                              daDescriptionController.text = 'DA for Other Headquarter';
                            } else {
                              daAmountController.text = '150.00';
                              daDescriptionController.text = 'DA for Headquarter';
                            }
                          });
                        },
                      ),




                      const SizedBox(height: 12),
                      TextFormField(
                        controller: daAmountController,
                        readOnly: true,
                        decoration: const InputDecoration(labelText: 'Amount', border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: daDescriptionController,
                        decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
                      ),
                    ],
                  ),
                ),
              ),
            ]
    else if (selectedCategory == 'Other Expense') ...[
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
    ? "Upload Bill"
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
                style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
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
}
