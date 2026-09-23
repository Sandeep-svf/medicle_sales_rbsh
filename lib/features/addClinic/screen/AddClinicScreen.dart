import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:medicle_sales_rbsh/utils/constants/colors.dart';
import '../../addStokist/widets/AnnualGTurnOverSection.dart';
import '../controllers/AddChemistController.dart';
import 'package:medicle_sales_rbsh/features/authentication/controllers/AuthController.dart';
import 'package:medicle_sales_rbsh/utils/http/http_client.dart';
import 'package:medicle_sales_rbsh/utils/local_storage/auth_manager.dart';
import 'dart:convert';
import '../../authentication/models/headoffice.dart';
import '../controllers/ClinicListController.dart';
import '../../addDoctor/screens/map.dart';
import 'package:medicle_sales_rbsh/utils/constants/text_strings.dart';
import 'package:medicle_sales_rbsh/utils/constants/sizes.dart';

class AddChemistScreen extends StatelessWidget {
  const AddChemistScreen({Key? key}) : super(key: key);

  final String _bannerAsset = "assets/logos/chemist_banner.png";

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AddChemistController());

    return Scaffold(
      backgroundColor: TColors.hex_FFF4F6F9,
      body: CustomScrollView(
        slivers: [
          // 1. SLIVER APP BAR
          SliverAppBar(
            expandedHeight: 160.0,
            floating: false,
            pinned: true,
            backgroundColor: TColors.primary,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                    color: TColors.black26, shape: BoxShape.circle),
                child: const Icon(Icons.arrow_back,
                    color: TColors.white, size: TSizes.v20),
              ),
              onPressed: () => Get.back(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: const Text(
                TTexts.uiTextAddNewChemist,
                style: TextStyle(
                  color: TColors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: TSizes.v16,
                  shadows: [
                    Shadow(
                        offset: Offset(0, 1),
                        blurRadius: TSizes.v3,
                        color: TColors.black45)
                  ],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    _bannerAsset,
                    fit: BoxFit.fill,
                    errorBuilder: (_, __, ___) =>
                        Container(color: TColors.primary),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          TColors.black38,
                          TColors.transparent,
                          TColors.primary.withOpacity(0.9)
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. BODY CONTENT
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // --- TOP: IMAGE & LOCATION (Mandatory) ---
                  Row(
                    children: [
                      Expanded(child: _buildImagePicker(controller, context)),
                      const SizedBox(width: TSizes.v15),
                      Expanded(child: _buildLocationPicker(controller)),
                    ],
                  ),
                  const SizedBox(height: TSizes.v25),

                  // --- FORM CARD ---
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: TColors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                            color: TColors.materialGrey.withOpacity(0.08),
                            blurRadius: TSizes.v15,
                            offset: const Offset(0, 5)),
                      ],
                    ),
                    child: Form(
                      key: controller.formKey,
                      child: Column(
                        children: [
                          _buildSectionHeader("01", "Basic Details"),
                          const SizedBox(height: TSizes.v15),

                          // --- REQUIRED FIELDS ---
                          _buildTextField(controller.firmNameController,
                              "Firm Name", Icons.store,
                              required: true),
                          const SizedBox(height: TSizes.v15),
                          _buildTextField(controller.contactPersonController,
                              "Contact Person", Icons.person,
                              required: true),
                          const SizedBox(height: TSizes.v15),

                          // Head Office Dropdown (Required)
                          Obx(() => DropdownButtonFormField<String>(
                                value: controller.selectedHeadOfficeId.value,
                                icon: const Icon(
                                    Icons.keyboard_arrow_down_rounded),
                                decoration: _inputDecoration(
                                    "Select Head Office *", Icons.domain),
                                items: controller.headOffices.map((office) {
                                  return DropdownMenuItem<String>(
                                    value: office['id'],
                                    child: Text(office['name'] ?? "Unknown",
                                        style: const TextStyle(
                                            fontSize: TSizes.v14)),
                                  );
                                }).toList(),
                                onChanged: (val) =>
                                    controller.selectedHeadOfficeId.value = val,
                                validator: (v) => v == null ? "Required" : null,
                              )),
                          const SizedBox(height: TSizes.v15),

                          // --- OPTIONAL FIELDS (Default "") ---
                          _buildTextField(controller.phoneController,
                              "Mobile Number", Icons.phone,
                              isNumber: true, required: false),
                          const SizedBox(height: TSizes.v15),
                          _buildTextField(controller.emailController,
                              "Email ID", Icons.email,
                              keyboardType: TextInputType.emailAddress,
                              required: false),
                          const SizedBox(height: TSizes.v15),
                          _buildTextField(controller.addressController,
                              "Full Address", Icons.location_on_outlined,
                              maxLines: 2, required: false),

                          const SizedBox(height: TSizes.v30),
                          _buildSectionHeader("02", "Business Details"),
                          const SizedBox(height: TSizes.v15),

                          _buildTextField(controller.designationController,
                              "Designation", Icons.badge_outlined,
                              required: false),
                          const SizedBox(height: TSizes.v15),
                          _buildTextField(
                              controller.drugLicenseNumberController,
                              "Drug License No.",
                              Icons.description_outlined,
                              required: false),
                          const SizedBox(height: TSizes.v15),
                          _buildTextField(controller.gstController, "GST No.",
                              Icons.receipt_long,
                              required: false),
                          const SizedBox(height: TSizes.v15),

                          // Optional Int (Default 0)
                          _buildTextField(controller.yearsInBusinessController,
                              "Years in Business", Icons.history,
                              isNumber: true, required: false),

                          const SizedBox(height: TSizes.v30),
                          _buildSectionHeader("03", "Turnover"),
                          const SizedBox(height: TSizes.v10),

                          Obx(() => AnnualTurnoverSection(
                                turnovers: controller.annualTurnovers.toList(),
                                onChanged: (updatedList) {
                                  controller.updateTurnovers(updatedList);
                                },
                              )),

                          const SizedBox(height: TSizes.v40),

                          // --- SUBMIT BUTTON ---
                          SizedBox(
                            width: double.infinity,
                            height: TSizes.v55,
                            child: Obx(() => ElevatedButton(
                                  onPressed: controller.isLoading.value
                                      ? null
                                      : controller.submitForm,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: TColors.primary,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    elevation: TSizes.v5,
                                    shadowColor:
                                        TColors.primary.withOpacity(0.4),
                                  ),
                                  child: controller.isLoading.value
                                      ? const CircularProgressIndicator(
                                          color: TColors.white)
                                      : const Text(
                                          TTexts.uiTextCOMPLETEREGISTRATION,
                                          style: TextStyle(
                                              fontSize: TSizes.v15,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 1.0,
                                              color: TColors.white),
                                        ),
                                )),
                          ),
                          const SizedBox(height: TSizes.v20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= HELPER WIDGETS =================

  // 1. Image Picker
  Widget _buildImagePicker(
      AddChemistController controller, BuildContext context) {
    return Container(
      height: TSizes.v160,
      decoration: BoxDecoration(
        color: TColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: TColors.pureBlack.withOpacity(0.05),
              blurRadius: TSizes.v10)
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Obx(() {
          if (controller.isImageProcessing.value) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(color: TColors.primary),
                const SizedBox(height: TSizes.v8),
                Text(TTexts.uiTextProcessing_272bc02e,
                    style: TextStyle(
                        fontSize: TSizes.v10, color: TColors.materialGrey600))
              ],
            );
          }

          if (controller.chemistImage.value != null) {
            return Stack(
              fit: StackFit.expand,
              children: [
                Image.file(controller.chemistImage.value!, fit: BoxFit.cover),
                Container(color: TColors.black12),
                Center(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: TColors.pureBlack.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: () => _showFullImage(
                              context, controller.chemistImage.value!),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: TColors.white.withOpacity(0.9),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.visibility,
                                color: TColors.primary, size: TSizes.v20),
                          ),
                        ),
                        const SizedBox(width: TSizes.v15),
                        GestureDetector(
                          onTap: controller.captureImage,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: TColors.primary.withOpacity(0.9),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.refresh,
                                color: TColors.white, size: TSizes.v20),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            );
          }

          return InkWell(
            onTap: controller.captureImage,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_a_photo_outlined,
                    size: TSizes.v40, color: TColors.primary.withOpacity(0.6)),
                const SizedBox(height: TSizes.v10),
                Text(TTexts.uiTextCapturePhoto,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: TColors.materialRed400,
                        fontSize: TSizes.v13,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          );
        }),
      ),
    );
  }

  // 2. Location Picker
  Widget _buildLocationPicker(AddChemistController controller) {
    return InkWell(
      onTap: controller.pickLocation,
      child: Container(
        height: TSizes.v160,
        decoration: BoxDecoration(
          color: TColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: TColors.primary.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
                color: TColors.pureBlack.withOpacity(0.05),
                blurRadius: TSizes.v10)
          ],
        ),
        child: Obx(() {
          bool isSet = controller.latitude.value != 0.0;
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSet
                      ? TColors.materialGreen.withOpacity(0.1)
                      : TColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.location_on,
                    size: TSizes.v30,
                    color: isSet ? TColors.materialGreen : TColors.primary),
              ),
              const SizedBox(height: TSizes.v12),
              Text(
                isSet ? "Location Set" : "Select Location *",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: TSizes.v14,
                    color: isSet ? TColors.pureBlack : TColors.materialRed400),
              ),
              if (isSet)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    "Lat: ${controller.latitude.value.toStringAsFixed(4)}",
                    style: const TextStyle(
                        fontSize: TSizes.v11, color: TColors.materialGrey),
                  ),
                )
            ],
          );
        }),
      ),
    );
  }

  Widget _buildSectionHeader(String number, String title) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
              color: TColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6)),
          child: Text(number,
              style: const TextStyle(
                  color: TColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: TSizes.v12)),
        ),
        const SizedBox(width: TSizes.v10),
        Text(title,
            style: const TextStyle(
                fontSize: TSizes.v16,
                fontWeight: FontWeight.bold,
                color: TColors.black87)),
      ],
    );
  }

  // Updated Helper: required flag controls the validator and asterisk
  Widget _buildTextField(
      TextEditingController ctrl, String label, IconData icon,
      {bool isNumber = false,
      bool required = false,
      int maxLines = 1,
      TextInputType? keyboardType}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboardType ??
          (isNumber ? TextInputType.number : TextInputType.text),
      maxLines: maxLines,
      style: const TextStyle(fontSize: TSizes.v14, fontWeight: FontWeight.w500),
      decoration: _inputDecoration(required ? "$label *" : label, icon),
      validator: (v) {
        if (required && (v == null || v.trim().isEmpty))
          return "$label is required";
        return null;
      },
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon:
          Icon(icon, size: TSizes.v18, color: TColors.primary.withOpacity(0.7)),
      labelStyle:
          TextStyle(color: TColors.materialGrey500, fontSize: TSizes.v13),
      filled: true,
      fillColor: TColors.hex_FFFAFAFA,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: TColors.materialGrey200)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: TColors.materialGrey200)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: TColors.primary, width: TSizes.v1_5)),
    );
  }

  void _showFullImage(BuildContext context, File imageFile) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: TColors.transparent,
        insetPadding: const EdgeInsets.all(12),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: InteractiveViewer(
                panEnabled: true,
                minScale: 1.0,
                maxScale: 4.0,
                child: Image.file(imageFile, fit: BoxFit.contain),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: TColors.pureBlack.withOpacity(0.6),
                    shape: BoxShape.circle,
                    border:
                        Border.all(color: TColors.white, width: TSizes.v1_5),
                  ),
                  child: const Icon(Icons.close,
                      color: TColors.white, size: TSizes.v22),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// old working code without geo_image
/*
class AddClinicScreen extends StatefulWidget {
  final ClinicListController controller;
  const AddClinicScreen({super.key, required this.controller});

  @override
  State<AddClinicScreen> createState() => _AddClinicScreenState();
}

class _AddClinicScreenState extends State<AddClinicScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController firmNameController = TextEditingController();
  final TextEditingController contactPersonController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController designationController = TextEditingController();
  final TextEditingController drugLicenseNumberController = TextEditingController();
  final TextEditingController gstController = TextEditingController();
  final TextEditingController yearsInBusinessController = TextEditingController();

  String? selectedHeadOffice;
  String baseUrl = THttpHelper.baseUrl;
  String? selectedLocation;
  String? selectedlatitude;
  String? selectedlongitude;
  bool isLoading = false; // For form submission loading
  bool isLoadingHeadOffices = false; // For head office loading
  List<dynamic> headOffices = [];
  String baseurl = THttpHelper.baseUrl;
  String headOfficeId="";
  List<Map<String, dynamic>> _annualTurnovers = List.generate(1,
        (index) => {
      "year": DateTime.now().year - index,
      "amount": 0,
    },
  );

  AuthManager authController = AuthManager();


  @override
  void initState() {
    super.initState();
    _fetchHeadOffices();
    //_fetchheadOfficeId();
  }

  Future<void> _fetchheadOfficeId()async {
    // headOfficeId = authController.getHeadOffice() as String;
  }

 */ /* Future<void> _fetchHeadOffices() async {
    setState(() {
      isLoadingHeadOffices = true; // Show loader while fetching head offices
    });
    try {
      final response = await http.get(Uri.parse("$baseurl/users/my-head-offices"));
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        setState(() {
          headOffices = data;
          isLoadingHeadOffices = false; // Hide loader when data is fetched
        });
      } else {
        setState(() {
          isLoadingHeadOffices = false; // Hide loader on error
        });
        Get.snackbar("Error", "Failed to fetch head offices Status Code: ${response.statusCode}");
      }
    } catch (e) {
      setState(() {
        isLoadingHeadOffices = false; // Hide loader on exception
      });
      Get.snackbar("Error", "Failed to fetch head offices: $e", backgroundColor: TColors.materialRed);
    }
  }*/ /*


  Future<void> _fetchHeadOffices() async {
    setState(() {
      isLoadingHeadOffices = true; // Show loader while fetching head offices
    });

    try {
      AuthManager authManager = AuthManager();
      final token = await authManager.getAuthToken();

      final response = await http.get(Uri.parse("$baseurl/users/my-head-offices"),
        headers: {
          "Authorization": "Bearer $token",  // Include Bearer token in the header
          "Accept": "application/json",  // Ensure the server expects JSON
        },);

      if (response.statusCode == 200) {
        // Decode the response body
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        // Check if the response was successful
        if (jsonResponse['success'] == true) {
          // Extract the 'data' list from the response
          final List<dynamic> data = jsonResponse['data'];

          // Map the 'data' list to head offices
          List<Map<String, dynamic>> headOfficesFromServer = data
              .map((city) => {
            'id': city['_id'].toString(),
            'name': city['name'].toString()
          })
              .toList();

          // Update the headOffices list and hide the loader
          setState(() {
            headOffices = headOfficesFromServer; // Assign the mapped data to headOffices
            isLoadingHeadOffices = false; // Hide loader when data is fetched
          });

          print("Head offices fetched from server: $headOfficesFromServer");
        } else {
          setState(() {
            isLoadingHeadOffices = false; // Hide loader if success is false
          });
          Get.snackbar("Error", "Failed to fetch head offices. Response success is false.");
        }
      } else {
        setState(() {
          isLoadingHeadOffices = false; // Hide loader on error
        });
        Get.snackbar("Error", "Failed to fetch head offices. Status Code: ${response.statusCode}");
      }
    } catch (e) {
      setState(() {
        isLoadingHeadOffices = false; // Hide loader on exception
      });
      Get.snackbar("Error", "Failed to fetch head offices: $e", backgroundColor: TColors.materialRed);
    }
  }








  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    // 🔒 Validate location
    if (selectedlatitude == null || selectedlongitude == null || selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("📍 Please select location before submitting.")),
      );
      return;
    }

    setState(() => isLoading = true);

    final body = {
      "firmName": firmNameController.text,
      "contactPersonName": contactPersonController.text,
      "designation": designationController.text,
      "mobileNo": phoneController.text,
      "emailId": emailController.text, // use dynamic input
      "drugLicenseNumber": drugLicenseNumberController.text,
      "gstNo": gstController.text,
      "address": addressController.text,
      "latitude": selectedlatitude ?? 0.0,
      "longitude": selectedlongitude ?? 0.0,
      "yearsInBusiness": int.tryParse(yearsInBusinessController.text) ?? 0,
      "annualTurnover": _annualTurnovers
          .map((e) => {
        "year": e["year"],
        "amount": e["amount"],
      })
          .toList(),
      "headOffice": selectedHeadOffice,
    };

    debugPrint("ChemistController: Submitting body => ${jsonEncode(body)}");
    AuthManager authManager = AuthManager();
    final token  = await authManager.getAuthToken();
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/chemists"),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        },
        body: jsonEncode(body),
      );

      debugPrint("ChemistController: Response code => ${response.statusCode}");
      debugPrint("ChemistController: Response body => ${response.body}");

      if (response.statusCode == 201) {
        await widget.controller.fetchClinicList();
        if (mounted) {
          Navigator.pop(context,true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Clinic added successfully")),
          );
        }
      } else {
        throw Exception("Failed with status: ${response.statusCode}");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to submit: $e")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }


  */ /*Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true); // Show loading while submitting the form

    final body = {
      "firmName": firmNameController.text,
      "contactPersonName": contactPersonController.text,
      "designation": designationController.text,
      "mobileNo": phoneController.text,
      "emailId": "test@gmail.com",
      "drugLicenseNumber": drugLicenseNumberController.text,
      "gstNo": gstController.text,
      "address": addressController.text,
      "latitude": selectedlatitude,
      "longitude": selectedlongitude,
      "yearsInBusiness": int.tryParse(yearsInBusinessController.text) ?? 0,
      "annualTurnover": _annualTurnovers.map((e) => {
        "year": e["year"],
        "amount": e["amount"]
      }).toList(),
      "headOffice": selectedHeadOffice,
    };


    */ /**/ /*final body = {
      "firmName": firmNameController.text,
      "contactPersonName": contactPersonController.text,
      "mobileNo": phoneController.text,
      "address": addressController.text,
      "headOffice": selectedHeadOffice,
      "location": selectedLocation,
      "latitude": selectedlatitude,
      "longitude": selectedlongitude,
      "designation": designationController.text,
      "drugLicenseNumber": drugLicenseNumberController.text,
      "gstNo": gstController.text,
      "yearsInBusiness": int.tryParse(yearsInBusinessController.text) ?? 0,
      "annualTurnover":_annualTurnovers.map((e) => {
        "year": e["year"],
        "amount": e["amount"]
      }).toList(),
    };*/ /**/ /*

    try {
      final response = await http.post(
        Uri.parse("$baseurl/chemists"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode == 201) {
        await widget.controller.fetchClinicList(); // Refresh list
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Clinic added successfully")),
          );
        }
      } else {
        throw Exception("Failed with status: ${response.statusCode}");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to submit: $e")),
      );
    } finally {
      setState(() => isLoading = false); // Hide loader after form submission
    }
  }*/ /*

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add New Chemist"),
        backgroundColor: TColors.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Firm Name (Required)
                _buildTextField(firmNameController, "Firm Name", required: true),

                // Contact Person (Required)
                _buildTextField(contactPersonController, "Contact Person", required: true),

                // Mobile Number (Required)
                _buildTextField(phoneController, "Mobile Number", keyboardType: TextInputType.phone, required: true),
                _buildTextField(emailController, "Email", keyboardType: TextInputType.emailAddress,required: true),

                _buildTextField(addressController, "Address",required: true),
                // Head Office Dropdown (Required)
                */ /*Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: isLoadingHeadOffices
                      ? const CircularProgressIndicator() // Show loader while fetching head offices
                      : DropdownButtonFormField<String>(
                    value: selectedHeadOffice,
                    decoration: const InputDecoration(
                      labelText: "Select Head Office",
                      border: OutlineInputBorder(),
                    ),
                    items: headOffices.map((office) {
                      final id = office['_id']?.toString() ?? '';
                      final name = office['name']?.toString() ?? '';
                      return DropdownMenuItem<String>(
                        value: id,
                        child: Text(name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedHeadOffice = value; // Make sure it's the actual id
                        print("Selected Head Office ID: $selectedHeadOffice");
                      });
                    },
                    validator: (value) => value == null || value.isEmpty
                        ? 'Head Office is required'
                        : null,
                  ),

                ),*/ /*

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: isLoadingHeadOffices
                    ? const Center(child: CircularProgressIndicator())
                    : DropdownButtonFormField<String>(
                  // Only set value if it exists in items
                  value: headOffices.any((o) => o['id'].toString() == (selectedHeadOffice ?? ''))
                      ? selectedHeadOffice
                      : null,
                  decoration: const InputDecoration(
                    labelText: "Select Head Office",
                    border: OutlineInputBorder(),
                  ),
                  items: headOffices.map((office) {
                    final id = office['id']?.toString() ?? '';     // ← use 'id'
                    final name = office['name']?.toString() ?? '';
                    return DropdownMenuItem<String>(
                      value: id,
                      child: Text(name.isNotEmpty ? name : id),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedHeadOffice = value;
                      // optional: also clear dependent fields here
                    });
                    debugPrint("Selected Head Office ID: $selectedHeadOffice");
                  },
                  validator: (value) =>
                  value == null || value.isEmpty ? 'Head Office is required' : null,
                ),
              ),

              // Designation (Optional)
                _buildTextField(designationController, "Designation", required: false),

                // Drug License Number (Optional)
                _buildTextField(drugLicenseNumberController, "Drug License Number", required: true),

                // GST No (Optional)
                _buildTextField(gstController, "GST No", required: false),



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
                // Select Location (Required)

                TextButton(
                  onPressed: () async {
                    try {
                      final result = await Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (_) => LocationPickerScreen()),
                                          );

                      print("🔄 Returned from Location Picker");
                      print("Result: $result");

                      if (result != null ) {
                                            setState(() {
                                              selectedlatitude = result['latitude'].toString();
                                              selectedlongitude = result['longitude'].toString();
                                              selectedLocation = result['address'].toString();
                                            });

                                            print("Location selected:");
                                            print("Address: Lat: $selectedlatitude");
                                            print("Address: Lng: $selectedlongitude");
                                            print("Address: $selectedLocation");

                                            Get.snackbar(
                                              "📍 Location Selected",
                                              "$selectedLocation\nLat: $selectedlatitude, Lng: $selectedlongitude",
                                              backgroundColor: TColors.materialGreen,
                                              duration: const Duration(seconds: 4),
                                            );
                                          } else {
                                            print("❌ Location selection failed or cancelled.");
                                            Get.snackbar(
                                              "Location Not Selected",
                                              "Please try again or cancel",
                                              backgroundColor: TColors.materialOrange,
                                            );
                                          }
                    } catch (e) {
                      print("Address: $e");
                    }

                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                    backgroundColor: TColors.primary, // Background color for the button
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 5, // Shadow for the button
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.location_on,
                        color: TColors.white,
                        size: 22,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Select Location',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: TColors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                */ /*TextButton(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => LocationPickerScreen()),
                    );

                    if (result != null &&
                        result['latitude'] != null &&
                        result['longitude'] != null &&
                        result['address'] != null) {
                      selectedlatitude = result['latitude'];
                      selectedlongitude = result['longitude'];
                      selectedLocation = result['address'];

                      print("location lat long chemist: lat $selectedlatitude");
                      print("location lat long chemist: long $selectedlongitude");
                      print("location lat long chemist: address $selectedLocation");

                      Get.snackbar(
                        "📍 Location Selected",
                        "$selectedLocation\nLat: $selectedlatitude, Lng: $selectedlongitude",
                        backgroundColor: TColors.materialGreen,
                        duration: const Duration(seconds: 4),
                      );


                    } else {
                      Get.snackbar(
                        "Location Not Selected",
                        "Please try again or cancel",
                        backgroundColor: TColors.materialOrange,
                      );
                    }
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                    backgroundColor: TColors.primary, // Background color for the button
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 5, // Shadow for the button
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.location_on,
                        color: TColors.white,
                        size: 22,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Select Location',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: TColors.white,
                        ),
                      ),
                    ],
                  ),
                ),*/ /*

                // Centered "Add Chemist" Button
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TColors.primary, // Background color
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      minimumSize: Size(double.infinity, 50), // Full-width button
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: TColors.white)
                        : const Text("Add Chemist", style: TextStyle(fontSize: 18)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {TextInputType keyboardType = TextInputType.text, int maxLines = 1, bool required = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: TColors.pureBlack),
          border: OutlineInputBorder(),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: TColors.primary, width: 2),
          ),
        ),
        validator: (value) {
          if (required && (value == null || value.isEmpty)) {
            return 'This field is required';
          }
          return null;
        },
      ),
    );
  }
}

Widget _sectionTitle(String title) => Padding(
  padding: const EdgeInsets.only(bottom: 8.0),
  child: Align(
    alignment: Alignment.centerLeft, // Align the title to the left
    child: Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: TColors.primary,
      ),
    ),
  ),
);*/
