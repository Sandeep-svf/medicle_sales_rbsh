import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';

import '../../../utils/constants/colors.dart';
import '../../../utils/constants/text_strings.dart';
import '../../../utils/helpers/zoom_in_out_anim.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  final List<Map<String, String>> _orderInfo = [
    {
      "amount": "₹15,97,400",
      "description": "Travel to clinic.",
      "Date" : "14/2/2024",
      "status" : "1"
    },
    {
      "amount": "₹15,97,400",
      "description": "Lunch with doctor.",
      "Date" : "14/2/2024",
      "status" : "0"
    },
    {
      "amount": "₹15,97,400",
      "description": "Park ticket for meeting.",
      "Date" : "14/2/2024",
      "status" : "1"
    },
  ];

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  void _showAddDoctorDialog() {
    TextEditingController amountController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();


    showDialog(

      context: context,
      builder: (BuildContext context) {
        return ZoomInOutDialog(
          child: AlertDialog(
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text(TTexts.scheduleVisitTitle),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number, // Numeric keyboard
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly], // Allows only numbers
                  decoration: const InputDecoration(
                    labelText: TTexts.amount,
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: TTexts.description,
                    border: OutlineInputBorder(),
                  ),
                ),

              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(TTexts.cancel),
              ),
              ElevatedButton(
                onPressed: () {
                  if (amountController.text.isNotEmpty &&
                      descriptionController.text.isNotEmpty
                     ) {

                    setState(() {
                      _orderInfo.add({
                        "amount": "₹${amountController.text}",
                        "description": descriptionController.text,
                        "status" : "0",
                        "Date" :DateFormat('dd/MM/yyyy').format(DateTime.now()),
                      });
                    });
                    Navigator.pop(context);
                  }else{
                    Get.snackbar("Error", "Field can not be empty.");
                  }
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0), // Adjust the value as needed
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
                  _orderInfo.removeAt(index);
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
    List<Map<String, String>> filteredDoctors = _orderInfo
        .where((doctor) =>
        doctor["amount"]!.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: TTexts.searchExpenses,
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
            child: filteredDoctors.isEmpty
                ? const Center(child: Text(TTexts.noRecentCallAvailable))
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredDoctors.length,
              itemBuilder: (context, index) {
                final doctor = filteredDoctors[index];
                String statusText = doctor["status"] == "1"
                    ? "Approved"
                    : "Pending";
                Color statusColor = doctor["status"] == "1"
                    ? Colors.green
                    : Colors.red;

                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          doctor["amount"] ?? "",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          doctor["description"] ?? "",
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              statusText,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: statusColor,
                              ),
                            ),
                            Text(
                              doctor["Date"] ?? "",
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );

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
}
