import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:medicle_sales_rbsh/features/addStokist/model/Stokist.dart';

import '../../addDoctor/screens/map.dart';
import '../controllers/StokistListController.dart';


class AddStokistDialog extends StatefulWidget {
  final StokistListController controller;
  const AddStokistDialog({super.key, required this.controller});

  @override
  State<AddStokistDialog> createState() => _AddClinicDialogState();
}

class _AddClinicDialogState extends State<AddStokistDialog> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final addressController = TextEditingController();
  final cityController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final latController = TextEditingController();
  final lngController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Add Clinic"),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(controller: nameController, decoration: InputDecoration(labelText: 'Stokist Name')),
              TextFormField(controller: addressController, decoration: InputDecoration(labelText: 'Address')),
              TextFormField(controller: cityController, decoration: InputDecoration(labelText: 'City')),
              TextFormField(controller: phoneController, decoration: InputDecoration(labelText: 'Phone')),
              TextFormField(controller: emailController, decoration: InputDecoration(labelText: 'Email')),
              TextButton(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => LocationPickerScreen()),
                  );

                  if (result != null &&
                      result['latitude'] != null &&
                      result['longitude'] != null &&
                      result['address'] != null) {
                    final lat = result['latitude'];
                    final lng = result['longitude'];
                    final address = result['address'];

                    Get.snackbar(
                      "📍 Location Selected",
                      "$address\nLat: $lat, Lng: $lng",
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 4),
                    );

                    // Optional: save to local variables or form
                    // setState(() {
                    //   _selectedLat = lat;
                    //   _selectedLng = lng;
                    //   _selectedAddress = address;
                    // });
                  } else {
                    Get.snackbar(
                      "Location Not Selected",
                      "Please try again or cancel",
                      backgroundColor: Colors.orange,
                    );
                  }
                },
                child: const Text('Select Location'),
              ),
              //TextFormField(controller: latController, decoration: InputDecoration(labelText: 'Location On Map')),
             // TextFormField(controller: lngController, decoration: InputDecoration(labelText: 'Longitude')),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final newClinic = Stokist(
                name: nameController.text,
                address: addressController.text,
                city: cityController.text,
                phone: phoneController.text,
                email: emailController.text,
                latitude: double.tryParse(latController.text) ?? 0.0,
                longitude: double.tryParse(lngController.text) ?? 0.0,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              );
              widget.controller.addClinic(newClinic);
              Navigator.pop(context);
            }
          },
          child: const Text("Submit"),
        ),
      ],
    );
  }
}