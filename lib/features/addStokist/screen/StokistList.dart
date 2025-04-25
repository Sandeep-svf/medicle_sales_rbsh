import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:medicle_sales_rbsh/utils/constants/colors.dart';
import '../controllers/StokistListController.dart';
import '../widets/AddStokistDialog.dart';
import 'AddStokist.dart';
import 'StokistDetailsScreen.dart';

class StokistListScreen extends StatelessWidget {
  final StokistListController _stokistController = Get.put(StokistListController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Obx(() {
        if (_stokistController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView.builder(
          itemCount: _stokistController.StokistList.length,
          padding: const EdgeInsets.all(16),
          itemBuilder: (context, index) {
            final clinic = _stokistController.StokistList[index];
            return Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: const Icon(Icons.local_hospital, color: TColors.primary),
                title: Text(clinic.firmName, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(clinic.emailAddress?? ""),
                onTap: () => Get.to(() => StokistDetailScreen(stokist: clinic)),
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>  Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const PharmaDistributorFormScreen(),
          ),
        ),
        child: Icon(Icons.add, color: Colors.white),
        backgroundColor: TColors.primary,
      ),
    );
  }
}


