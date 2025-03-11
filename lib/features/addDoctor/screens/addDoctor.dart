import 'package:flutter/material.dart';
import 'package:medicle_sales_rbsh/utils/constants/text_strings.dart';
import 'package:medicle_sales_rbsh/utils/helpers/zoom_in_out_anim.dart';
import '../../../utils/constants/colors.dart';

class AddDoctorScreen extends StatefulWidget {
  const AddDoctorScreen({super.key});


  @override
  _DoctorListScreenState createState() => _DoctorListScreenState();
}

class _DoctorListScreenState extends State<AddDoctorScreen> {
  final List<Map<String, String>> _doctors = [
    {"name": "Dr. John Doe", "specialization": "Cardiologist"},
    {"name": "Dr. Emily Smith", "specialization": "Neurologist"},
    {"name": "Dr. Michael Brown", "specialization": "Orthopedic"},
  ];

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  void _showAddDoctorDialog() {
    TextEditingController nameController = TextEditingController();
    TextEditingController specializationController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ZoomInOutDialog(
          child: AlertDialog(
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text(TTexts.addDoctorTitle),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
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
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(TTexts.cancel),
              ),
              ElevatedButton(
                onPressed: () {
                  if (nameController.text.isNotEmpty &&
                      specializationController.text.isNotEmpty) {
                    setState(() {
                      _doctors.add({
                        "name": nameController.text,
                        "specialization": specializationController.text,
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
          content: const Text(TTexts.areYouSureYouWantToDeleteThisDoctor),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(TTexts.no, style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _doctors.removeAt(index);
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
    List<Map<String, String>> filteredDoctors = _doctors
        .where((doctor) =>
        doctor["name"]!.toLowerCase().contains(_searchQuery.toLowerCase()))
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
                ? const Center(child: Text(TTexts.noDoctorAvailable))
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredDoctors.length,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue.shade100,
                      child: const Icon(Icons.person, color: Colors.blue),
                    ),
                    title: Text(filteredDoctors[index]["name"]!,
                        style:
                        const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle:
                    Text(filteredDoctors[index]["specialization"]!),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: TColors.primary),
                      onPressed: () =>
                          _showDeleteConfirmationDialog(index),
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
