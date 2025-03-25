import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../../utils/constants/colors.dart';
import '../../../utils/constants/text_strings.dart';
import '../../../utils/helpers/zoom_in_out_anim.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  final List<Map<String, String>> _orderInfo = [
    {
      "doctorName": "Dr Aarav Maurya",
      "productName": "Paracetamol",
      "quantity": "15",
      "orderNotes": "Bulk Order",
    },
    {
      "doctorName": "Dr Aarav Maurya",
      "productName": "Paracetamol",
      "quantity": "15",
      "orderNotes": "Bulk Order",
    },
    {
      "doctorName": "Dr Aarav Maurya",
      "productName": "Paracetamol",
      "quantity": "15",
      "orderNotes": "Bulk Order",
    },
  ];

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  void _showAddDoctorDialog() {
    TextEditingController doctorNameController = TextEditingController();
    TextEditingController productNameController = TextEditingController();
    TextEditingController quantityController = TextEditingController();
    TextEditingController orderNotesController = TextEditingController();


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
                  controller: doctorNameController,
                  decoration: const InputDecoration(
                    labelText: TTexts.doctorName,
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: productNameController,
                  decoration: const InputDecoration(
                    labelText: TTexts.productName,
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: quantityController,
                  decoration: const InputDecoration(
                    labelText: TTexts.quantity,
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: orderNotesController,
                  decoration: const InputDecoration(
                    labelText: TTexts.orderNotes,
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
                  if (doctorNameController.text.isNotEmpty &&
                      productNameController.text.isNotEmpty &&
                      quantityController.text.isNotEmpty &&
                      orderNotesController.text.isNotEmpty) {

                    setState(() {
                      _orderInfo.add({
                        "doctorName": doctorNameController.text,
                        "productName": productNameController.text,
                        "orderNotes": quantityController.text,
                        "quantity": orderNotesController.text,
                      });
                    });
                    Navigator.pop(context);
                  }else{
                    Get.snackbar("Error", "Field can not be empty.");
                  }
                },
                child:const Padding(
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
        doctor["doctorName"]!.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: TTexts.searchOrder,
                border: OutlineInputBorder(),
                prefixIcon: const Icon(Icons.search,color: TColors.primary),
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

                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Doctor Icon
                        CircleAvatar(
                          backgroundColor: Colors.blueAccent.shade100,
                          child: const Icon(Icons.person, color: TColors.primary),
                        ),
                        const SizedBox(width: 12),

                        // Doctor & Product Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                doctor["doctorName"] ?? "Unknown Doctor",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.medical_services, size: 16, color: TColors.primary),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      doctor["productName"] ?? "No Product",
                                      style: const TextStyle(fontSize: 14, color: Colors.black87),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.notes, size: 16, color: TColors.primary),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      doctor["orderNotes"] ?? "No Notes",
                                      style: const TextStyle(fontSize: 14, color: Colors.black54),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.format_list_numbered, size: 16, color: TColors.primary),
                                  const SizedBox(width: 4),
                                  Text(
                                    "Qty: ${doctor["quantity"] ?? "0"}",
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ],
                          ),
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
