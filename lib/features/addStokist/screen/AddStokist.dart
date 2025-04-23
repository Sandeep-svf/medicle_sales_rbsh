import 'package:flutter/material.dart';
import 'package:medicle_sales_rbsh/utils/constants/colors.dart';

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
  final TextEditingController natureOfBusiness = TextEditingController();
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
              _textField(firmName, "Firm Name"),
              _textField(businessName, "Registered Business Name"),
              _textField(natureOfBusiness, "Nature of Business"),
              _textField(gstNumber, "GST Number"),
              _textField(drugLicenseNumber, "Drug License Number"),
              _textField(panNumber, "PAN Number"),
              _textField(officeAddress, "Registered Office Address", maxLines: 2),

              const SizedBox(height: 10),
              _sectionTitle("Contact Details"),
              _textField(contactPerson, "Contact Person"),
              _textField(designation, "Designation"),
              _textField(mobileNumber, "Mobile Number", inputType: TextInputType.phone),
              _textField(emailAddress, "Email Address", inputType: TextInputType.emailAddress),
              _textField(website, "Website"),

              const SizedBox(height: 10),
              _sectionTitle("Business Profile"),
              _textField(yearsInBusiness, "Years in Business", inputType: TextInputType.number),
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


              /*..._annualTurnovers.map((entry) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: entry["year"].toString(),
                        enabled: false,
                        decoration: const InputDecoration(
                          labelText: "Year",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        initialValue: entry["amount"].toString(),
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "Amount",
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (val) => entry["amount"] = int.tryParse(val) ?? 0,
                      ),
                    ),
                  ],
                ),
              )),*/

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
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Submitted successfully!")),
                      );
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

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: TColors.primary),
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
        validator: (value) => (value == null || value.isEmpty) ? 'Required' : null,
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
