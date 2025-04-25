import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../utils/constants/colors.dart';
import '../widets/AnnualGTurnOverSection.dart';

class PharmaDistributorFormScreen extends StatefulWidget {
  const PharmaDistributorFormScreen({super.key});

  @override
  State<PharmaDistributorFormScreen> createState() => _PharmaDistributorFormScreenState();
}

class _PharmaDistributorFormScreenState extends State<PharmaDistributorFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController firmName = TextEditingController();
  final TextEditingController businessName = TextEditingController();
  String? selectedBusinessType;
  final List<String> businessTypes = [
    'Proprietorship',
    'Partnership',
    'Private Ltd.',
    'Public Ltd.'
  ];
  final TextEditingController gstNumber = TextEditingController();
  final TextEditingController drugLicenseNumber = TextEditingController();
  final TextEditingController panNumber = TextEditingController();
  final TextEditingController officeAddress = TextEditingController();
  final TextEditingController contactPerson = TextEditingController();
  final TextEditingController designation = TextEditingController();
  final TextEditingController mobileNumber = TextEditingController();
  final TextEditingController emailAddress = TextEditingController();
  final TextEditingController website = TextEditingController();
  final TextEditingController yearsInBusiness = TextEditingController();
  final TextEditingController areasOfOperation = TextEditingController();
  final TextEditingController distributorships = TextEditingController();
  final TextEditingController storageSize = TextEditingController();
  final TextEditingController salesReps = TextEditingController();
  final TextEditingController bankName = TextEditingController();
  final TextEditingController branch = TextEditingController();
  final TextEditingController accountNumber = TextEditingController();
  final TextEditingController ifscCode = TextEditingController();

  bool warehouseFacility = false;
  bool coldStorageAvailable = false;

  List<Map<String, dynamic>> _annualTurnovers = List.generate(
    3,
        (index) => {
      "year": DateTime.now().year - index,
      "amount": 0,
    },
  );

  Future<void> _submitDistributorForm() async {
    final Uri apiUrl = Uri.parse("https://medi-glucks-erp.onrender.com/api/stockists");

    Map<String, dynamic> requestBody = {
      "firmName": firmName.text,
      "registeredBusinessName": businessName.text,
      "natureOfBusiness": selectedBusinessType ?? "",
      "gstNumber": gstNumber.text.trim().isEmpty ? "" : gstNumber.text,
      "drugLicenseNumber": drugLicenseNumber.text.trim().isEmpty ? "" : drugLicenseNumber.text,
      "panNumber": panNumber.text.trim().isEmpty ? "" : panNumber.text,
      "registeredOﬁceAddress": officeAddress.text,
      "contactPerson": contactPerson.text,
      "designation": designation.text.trim().isEmpty ? "" : designation.text,
      "mobileNumber": mobileNumber.text.trim().isEmpty ? "" : mobileNumber.text,
      "emailAddress": emailAddress.text.trim().isEmpty ? "" : emailAddress.text,
      "website": website.text.trim().isEmpty ? "" : website.text,
      "yearsInBusiness": int.tryParse(yearsInBusiness.text) ?? 0,
      "areasOfOperation": areasOfOperation.text.trim().isNotEmpty
          ? areasOfOperation.text.split(',').map((e) => e.trim()).toList()
          : [],
      "currentPharmaDistributorships": distributorships.text.trim().isNotEmpty
          ? distributorships.text.split(',').map((e) => e.trim()).toList()
          : [],
      "annualTurnover": _annualTurnovers.map((e) => {
        "year": e["year"],
        "amount": e["amount"]
      }).toList(),
      "warehouseFacility": warehouseFacility,
      "storageFacilitySize": int.tryParse(storageSize.text) ?? 0,
      "coldStorageAvailable": coldStorageAvailable,
      "numberOfSalesRepresentatives": int.tryParse(salesReps.text) ?? 0,
      "bankDetails": {
        "bankName": bankName.text.trim().isEmpty ? "" : bankName.text,
        "branch": branch.text.trim().isEmpty ? "" : branch.text,
        "accountNumber": accountNumber.text.trim().isEmpty ? "" : accountNumber.text,
        "ifscCode": ifscCode.text.trim().isEmpty ? "" : ifscCode.text,
      }
    };

    try {
      final response = await http.post(
        apiUrl,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Distributor registered successfully")),
        );
        Navigator.pop(context);
      } else {
        print("Server responded with: ${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed: ${response.statusCode}")),
        );
      }
    } catch (e) {
      print("Error submitting form: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Distributor Registration", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: TColors.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle("Basic Details"),
              _requiredField(firmName, "Firm Name"),
              _requiredField(businessName, "Registered Business Name"),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: "Nature of Business *",
                    border: OutlineInputBorder(),
                  ),
                  value: selectedBusinessType,
                  items: businessTypes.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedBusinessType = value;
                    });
                  },
                  validator: (value) => value == null || value.isEmpty
                      ? "Please select a business type"
                      : null,
                ),
              ),

              _textField(gstNumber, "GST Number"),
              _textField(drugLicenseNumber, "Drug License Number"),
              _textField(panNumber, "PAN Number"),
              _requiredField(officeAddress, "Registered Office Address", maxLines: 2),

              const SizedBox(height: 10),
              _sectionTitle("Contact Details"),
              _requiredField(contactPerson, "Contact Person"),
              _textField(designation, "Designation"),
              _textField(mobileNumber, "Mobile Number", inputType: TextInputType.phone),
              _textField(emailAddress, "Email Address", inputType: TextInputType.emailAddress),
              _textField(website, "Website"),

              const SizedBox(height: 10),
              _sectionTitle("Business Profile"),
              _requiredField(yearsInBusiness, "Years in Business", inputType: TextInputType.number),
              _textField(areasOfOperation, "Areas of Operation (comma separated)"),
              _textField(distributorships, "Current Pharma Distributorships (comma separated)"),

              const SizedBox(height: 10),
              _sectionTitle("Annual Turnover"),
              AnnualTurnoverSection(
                turnovers: _annualTurnovers,
                onChanged: (updatedList) {
                  setState(() {
                    _annualTurnovers = updatedList;
                  });
                },
              ),

              const SizedBox(height: 10),
              _sectionTitle("Facilities"),
              _checkbox("Warehouse Facility", warehouseFacility, (val) => setState(() => warehouseFacility = val)),
              _textField(storageSize, "Storage Facility Size (in sqft)", inputType: TextInputType.number),
              _checkbox("Cold Storage Available", coldStorageAvailable, (val) => setState(() => coldStorageAvailable = val)),
              _textField(salesReps, "No. of Sales Representatives", inputType: TextInputType.number),

              const SizedBox(height: 10),
              _sectionTitle("Bank Details"),
              _textField(bankName, "Bank Name"),
              _textField(branch, "Branch"),
              _textField(accountNumber, "Account Number", inputType: TextInputType.number),
              _textField(ifscCode, "IFSC Code"),

              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: TColors.primary),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _submitDistributorForm();
                    }
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 4),
                    child: Text("Submit", style: TextStyle(fontSize: 16)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 8.0),
    child: Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: TColors.primary),
    ),
  );

  Widget _requiredField(TextEditingController controller, String label,
      {TextInputType inputType = TextInputType.text, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: controller,
        keyboardType: inputType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: "$label *",
          border: const OutlineInputBorder(),
        ),
        validator: (value) => (value == null || value.isEmpty) ? 'Required' : null,
      ),
    );
  }

  Widget _textField(TextEditingController controller, String label,
      {TextInputType inputType = TextInputType.text, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: controller,
        keyboardType: inputType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _checkbox(String title, bool value, Function(bool) onChanged) {
    return CheckboxListTile(
      title: Text(title),
      value: value,
      activeColor: TColors.primary,
      onChanged: (val) => onChanged(val ?? false),
    );
  }
}
