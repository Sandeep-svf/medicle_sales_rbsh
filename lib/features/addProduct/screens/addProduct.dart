import 'package:date_picker_plus/date_picker_plus.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/constants/text_strings.dart';
import '../../../utils/helpers/zoom_in_out_anim.dart';

class AddproductScreen extends StatefulWidget {
  const AddproductScreen({super.key});

  @override
  State<AddproductScreen> createState() => _AddproductScreenState();
}

class _AddproductScreenState extends State<AddproductScreen> {
  final List<Map<String, String>> _productInfo = [
    {
      "productName": "Paracetamol",
      "description":
          "Paracetamol is a medicine used for mild to moderate pain.",
      "dosage":
          "he usual dose of paracetamol is one or two 500mg tablets at a time, up to 4 times in 24 hours.",
      "brochureUrl": "www.google.com",
    },
    {
      "productName": "Paracetamol",
      "description":
          "Paracetamol is a medicine used for mild to moderate pain.",
      "dosage":
          "he usual dose of paracetamol is one or two 500mg tablets at a time, up to 4 times in 24 hours.",
      "brochureUrl": "www.google.com",
    },
    {
      "productName": "Paracetamol",
      "description":
          "Paracetamol is a medicine used for mild to moderate pain.",
      "dosage":
          "he usual dose of paracetamol is one or two 500mg tablets at a time, up to 4 times in 24 hours.",
      "brochureUrl": "www.google.com",
    },
  ];

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  void _showAddDoctorDialog() {
    TextEditingController productNameController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();
    TextEditingController dosesController = TextEditingController();
    TextEditingController brochureController = TextEditingController();


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
                  controller: productNameController,
                  decoration: const InputDecoration(
                    labelText: TTexts.productName,
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
                const SizedBox(height: 12),
                TextField(
                  controller: dosesController,
                  decoration: const InputDecoration(
                    labelText: TTexts.dosage,
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: brochureController,
                  decoration: const InputDecoration(
                    labelText: TTexts.brochure,
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
                  if (productNameController.text.isNotEmpty &&
                      descriptionController.text.isNotEmpty &&
                      dosesController.text.isNotEmpty &&
                      brochureController.text.isNotEmpty) {

                    setState(() {
                      _productInfo.add({
                        "productName": productNameController.text,
                        "description": descriptionController.text,
                        "dosage": dosesController.text,
                        "brochureUrl": brochureController.text,
                      });
                    });
                    Navigator.pop(context);
                  }
                },
                child: const Text(TTexts.submit),
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
                  _productInfo.removeAt(index);
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
    List<Map<String, String>> filteredDoctors = _productInfo
        .where((doctor) =>
            doctor["productName"]!.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

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
                prefixIcon: const Icon(Icons.search),
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
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          title: Text(
                            doctor["name"] ?? "",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(" ${doctor["productName"] ?? ""}"),
                              Text(" ${doctor["description"] ?? ""}"),
                              Text(" ${doctor["dosage"] ?? ""}"),
                              Text(" ${doctor["brochureUrl"] ?? ""}"),
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
