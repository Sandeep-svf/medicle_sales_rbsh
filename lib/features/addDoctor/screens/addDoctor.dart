import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../utils/constants/text_strings.dart';
import '../../../utils/helpers/zoom_in_out_anim.dart';
import '../../../utils/constants/colors.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../controllers/DoctroController.dart';

class AddDoctorScreen extends StatefulWidget {
  const AddDoctorScreen({super.key});

  @override
  _AddDoctorScreenState createState() => _AddDoctorScreenState();
}

class _AddDoctorScreenState extends State<AddDoctorScreen> {
  final DoctorListController _doctorListController = Get.put(DoctorListController());
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  String? selectedCity;
  List<Map<String, String>> cities = [];

  @override
  void initState() {
    super.initState();
    _doctorListController.fetchDoctorList();
    fetchCities();
  }

  Future<void> fetchCities() async {
    final response = await http.get(Uri.parse('https://medi-glucks-erp.onrender.com/api/headoffices'));
    if (response.statusCode == 200) {
      List<dynamic> cityList = json.decode(response.body);
      setState(() {
        cities = cityList
            .map((city) => {'id': city['id'].toString(), 'name': city['name'].toString()})
            .toList();
      });
    }
  }

  void _showAddDoctorDialog() {
    TextEditingController nameController = TextEditingController();
    TextEditingController specializationController = TextEditingController();
    TextEditingController phoneController = TextEditingController();

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
                  DropdownButtonFormField<String>(
                    value: selectedCity,
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
                        selectedCity = value;
                      });
                    },
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
                   /* if (nameController.text.isNotEmpty && specializationController.text.isNotEmpty) {
                      _doctorListController.addDoctor(
                        nameController.text,
                        specializationController.text,
                        selectedCity,
                      );
                      Navigator.pop(context);
                    }*/
                  },
                  child: const Text(TTexts.submit),
                ),
              ],
            ),
          ),
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
            child: Obx(() {
              if (_doctorListController.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
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
