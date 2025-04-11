import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/ClinicListController.dart';
import '../model/Clinic.dart';

class AddClinicDialog extends StatefulWidget {
  final ClinicListController controller;
  const AddClinicDialog({super.key, required this.controller});

  @override
  State<AddClinicDialog> createState() => _AddClinicDialogState();
}

class _AddClinicDialogState extends State<AddClinicDialog> {
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
              TextFormField(controller: nameController, decoration: InputDecoration(labelText: 'Clinic Name')),
              TextFormField(controller: addressController, decoration: InputDecoration(labelText: 'Address')),
              TextFormField(controller: cityController, decoration: InputDecoration(labelText: 'City')),
              TextFormField(controller: phoneController, decoration: InputDecoration(labelText: 'Phone')),
              TextFormField(controller: emailController, decoration: InputDecoration(labelText: 'Email')),
              TextFormField(controller: latController, decoration: InputDecoration(labelText: 'Latitude')),
              TextFormField(controller: lngController, decoration: InputDecoration(labelText: 'Longitude')),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final newClinic = Clinic(
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