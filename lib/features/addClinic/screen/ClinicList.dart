import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:medicle_sales_rbsh/features/addClinic/screen/ClinicDetailsScreen.dart';

import '../../../utils/constants/colors.dart';
import '../controllers/ClinicListController.dart';
import '../model/clinic.dart';
import '../widets/AddClinicDialog.dart';
import 'AddClinicScreen.dart';

class ClinicListScreen extends StatefulWidget {
  const ClinicListScreen({super.key});

  @override
  State<ClinicListScreen> createState() => _ClinicListScreenState();
}

class _ClinicListScreenState extends State<ClinicListScreen> {
  final ClinicListController _clinicListController =
      Get.put(ClinicListController());
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  bool _isLoading = true;
  List<Clinic> _clinics = [];

  @override
  void initState() {
    super.initState();
    _clinicListController.fetchClinicList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredClinics = _clinics.where((clinic) {
      return clinic.name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: "Search Chemist",
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.search, color: Colors.blue),
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

          // In your build method
          Expanded(
            child: Obx(() {
              if (_clinicListController.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              final filteredClinics =
              _clinicListController.clinicList.where((clinic) {
                return clinic.name
                    .toLowerCase()
                    .contains(_searchQuery.toLowerCase());
              }).toList();

              return filteredClinics.isEmpty
                  ? const Center(child: Text("No chemist available"))
                  : ListView.builder(
                      itemCount: filteredClinics.length,
                      padding: const EdgeInsets.all(16),
                      itemBuilder: (context, index) {
                        final clinic = filteredClinics[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ClinicDetailScreen(clinic: clinic),
                              ),
                            );
                          },
                          child: Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  const CircleAvatar(
                                    radius: 24,
                                    backgroundColor: TColors.primary_shade100,
                                    child: Icon(Icons.local_hospital, color: TColors.primary, size: 24),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          clinic.name,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(Icons.location_on, size: 16, color: TColors.primary),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                clinic.address,
                                                style: const TextStyle(color: Colors.grey),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );

                      },
                    );
            }),
          ),


        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final shouldRefresh = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddClinicScreen(controller: _clinicListController),
            ),
          );

          if (shouldRefresh == true) {
            _clinicListController.fetchClinicList(); // Refresh clinic list
          }
        },

        child: const Icon(Icons.add, color: Colors.white),
        backgroundColor: TColors.primary,
      ),
    );
  }

  void _loadClinics() {}
}
