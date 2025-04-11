import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:medicle_sales_rbsh/utils/constants/colors.dart';

import '../controllers/ClinicListController.dart';
import '../widets/AddClinicDialog.dart';
import 'ClinicDetailsScreen.dart';

class ClinicListScreen extends StatelessWidget {
  final ClinicListController _clinicController = Get.put(ClinicListController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Clinics")),
      body: Obx(() {
        if (_clinicController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView.builder(
          itemCount: _clinicController.clinicList.length,
          padding: const EdgeInsets.all(16),
          itemBuilder: (context, index) {
            final clinic = _clinicController.clinicList[index];
            return Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: Icon(Icons.local_hospital, color: TColors.primary),
                title: Text(clinic.name, style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(clinic.city),
                onTap: () => Get.to(() => ClinicDetailScreen(clinic: clinic)),
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showDialog(
            context: context,
            builder: (_) => AddClinicDialog(controller: _clinicController)),
        child: Icon(Icons.add, color: Colors.white),
        backgroundColor: TColors.primary,
      ),
    );
  }
}
