import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/add_doctor_new_controller.dart';
import '../../../utils/constants/colors.dart';

class AddDoctorNewScreen extends StatelessWidget {
  const AddDoctorNewScreen({Key? key}) : super(key: key);

  final String _companyLogoAsset = "assets/logos/doctor_banner.png";

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AddDoctorNewController());
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      body: CustomScrollView(
        slivers: [
          // 1. APP BAR
          SliverAppBar(
            expandedHeight: 160.0,
            floating: false,
            pinned: true,
            backgroundColor: TColors.primary,
            elevation: 0,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
              ),
              onPressed: () => Get.back(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: const Text(
                "Add New Doctor",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  letterSpacing: 0.5,
                  shadows: [
                    Shadow(offset: Offset(0, 1), blurRadius: 3.0, color: Colors.black45)
                  ],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    _companyLogoAsset,
                    fit: BoxFit.fill,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(color: TColors.primary);
                    },
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.3),
                          Colors.transparent,
                          TColors.primary.withOpacity(0.9),
                        ],
                        stops: const [0.0, 0.4, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. BODY CONTENT
          SliverToBoxAdapter(
            child: LayoutBuilder(
              builder: (context, constraints) {
                bool isWide = constraints.maxWidth > 700;
                double horizontalPadding = isWide ? 30 : 20;
                double spacing = 15.0;
                double singleCardWidth = (constraints.maxWidth - (horizontalPadding * 2) - spacing) / 2;
                double dynamicHeight = (singleCardWidth * 0.85).clamp(160.0, 280.0);

                return Column(
                  children: [
                    // --- TOP SECTION: IMAGE & LOCATION (REQUIRED) ---
                    Transform.translate(
                      offset: const Offset(0, -50),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                        child: SizedBox(
                          height: dynamicHeight,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Image is Required
                              Expanded(child: _buildSideBySideImagePicker(context, controller)),
                              SizedBox(width: spacing),
                              // Location is Required
                              Expanded(child: _buildSideBySideLocationPicker(controller)),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // --- FORM FIELDS ---
                    Transform.translate(
                      offset: const Offset(0, -20),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                        child: Form(
                          key: controller.formKey,
                          child: Column(
                            children: [
                              // 01 Basic Info
                              _buildSectionHeader(number: "01", title: "Basic Information", subtitle: "Personal Details"),
                              const SizedBox(height: 15),
                              _buildBasicInfoCard(controller, context),
                              const SizedBox(height: 30),

                              // 02 Professional Info
                              _buildSectionHeader(number: "02", title: "Professional", subtitle: "Work Details"),
                              const SizedBox(height: 15),
                              _buildProfessionalInfoCard(controller),
                              const SizedBox(height: 30),

                              // 03 Contact Info
                              _buildSectionHeader(number: "03", title: "Contact Info", subtitle: "Optional"),
                              const SizedBox(height: 15),
                              _buildContactInfoCard(controller),
                              const SizedBox(height: 30),

                              // 04 Address Details
                              _buildSectionHeader(number: "04", title: "Address Details", subtitle: "Location (Auto)"),
                              const SizedBox(height: 15),
                              _buildAddressFieldsCard(controller),

                              const SizedBox(height: 40),

                              // Submit Button
                              Center(
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(maxWidth: isWide ? 500 : double.infinity),
                                  child: _buildSubmitButton(controller,context),
                                ),
                              ),
                              const SizedBox(height: 50),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // WIDGET BUILDERS (Helpers)
  // ===========================================================================

  Widget _buildSideBySideImagePicker(BuildContext context, AddDoctorNewController controller) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Obx(() {
          if (controller.isImageProcessing.value) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(color: TColors.primary),
                  const SizedBox(height: 8),
                  Text("Processing...", style: TextStyle(fontSize: 10, color: Colors.grey[600]))
                ],
              ),
            );
          }
          final img = controller.doctorImage.value;
          if (img != null) {
            return Stack(
              fit: StackFit.expand,
              children: [
                Container(color: Colors.black),
                Image.file(img, fit: BoxFit.contain),
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: () => _showFullImage(context, img),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9), shape: BoxShape.circle),
                            child: const Icon(Icons.visibility, color: TColors.primary, size: 20),
                          ),
                        ),
                        const SizedBox(width: 15),
                        GestureDetector(
                          onTap: controller.captureImage,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                                color: TColors.primary.withOpacity(0.9), shape: BoxShape.circle),
                            child: const Icon(Icons.refresh, color: Colors.white, size: 20),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            );
          } else {
            return GestureDetector(
              onTap: controller.captureImage,
              behavior: HitTestBehavior.opaque,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_a_photo, size: 36, color: TColors.primary.withOpacity(0.6)),
                  const SizedBox(height: 8),
                  Text("Capture\nPhoto *",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600], fontSize: 13, fontWeight: FontWeight.bold)),
                ],
              ),
            );
          }
        }),
      ),
    );
  }

  void _showFullImage(BuildContext context, File imageFile) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(10),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: InteractiveViewer(
                minScale: 1.0, maxScale: 4.0, panEnabled: true,
                child: Image.file(imageFile, fit: BoxFit.contain),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                  child: const Icon(Icons.close, color: Colors.white, size: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSideBySideLocationPicker(AddDoctorNewController controller) {
    return GestureDetector(
      onTap: controller.pickLocationOnMap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))],
          border: Border.all(color: TColors.primary.withOpacity(0.1)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: TColors.primary.withOpacity(0.1), shape: BoxShape.circle),
              child: const Icon(Icons.location_on, color: TColors.primary, size: 28),
            ),
            const SizedBox(height: 10),
            const Text("Set Doctor\nLocation *",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 5),
            Obx(() => Text(
              controller.isLocationSet.value ? " Coordinates Set" : "(Tap to Open Map)",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                color: controller.isLocationSet.value ? Colors.green : Colors.grey[500],
                fontWeight: FontWeight.w500,
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader({required String number, required String title, required String subtitle}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: TColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(number,
              style: const TextStyle(color: TColors.primary, fontWeight: FontWeight.w800, fontSize: 14)),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87)),
            Text(subtitle, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 11, color: Colors.grey[500])),
          ],
        ),
        const Spacer(),
        Container(height: 1, width: 40, color: Colors.grey[300]),
      ],
    );
  }

  // --- UPDATED: 01. BASIC INFO ---
  Widget _buildBasicInfoCard(AddDoctorNewController controller, BuildContext context) {
    return _ModernCard(
      child: Column(
        children: [
          _ModernTextField(
            controller: controller.nameController,
            label: "Full Name *",
            hint: "Dr. John Doe",
            icon: Icons.person_outline_rounded,
            isRequired: true,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(12),
              color: const Color(0xFFFAFAFA),
            ),
            child: Row(
              children: [
                Icon(Icons.people_outline_rounded, color: Colors.grey[600], size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Obx(() => DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: controller.selectedGender.value,
                      isExpanded: true,
                      hint: Text("Select Gender", style: TextStyle(fontSize: 14, color: Colors.grey[400])),
                      icon: const Icon(Icons.keyboard_arrow_down_rounded),
                      items: controller.genders.map((String value) {
                        return DropdownMenuItem<String>(value: value, child: Text(value, style: const TextStyle(fontSize: 14)));
                      }).toList(),
                      onChanged: (newValue) => controller.selectedGender.value = newValue!,
                    ),
                  )),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _ModernTextField(
                  controller: controller.dobController,
                  label: "Date of Birth",
                  icon: Icons.cake_outlined,
                  isReadOnly: true,
                  onTap: () => controller.selectDate(context, false),
                  isRequired: false, // OPTIONAL
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ModernTextField(
                  controller: controller.anniversaryController,
                  label: "Anniversary",
                  icon: Icons.celebration_outlined,
                  isReadOnly: true,
                  onTap: () => controller.selectDate(context, true),
                  isRequired: false, // OPTIONAL
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- UPDATED: 02. PROFESSIONAL ---
  Widget _buildProfessionalInfoCard(AddDoctorNewController controller) {
    return _ModernCard(
      child: Column(
        children: [
          _ModernTextField(
            controller: controller.specializationController,
            label: "Specialization",
            hint: "e.g. Cardiologist",
            icon: Icons.medical_services_outlined,
            isRequired: false,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: _ModernTextField(
                  controller: controller.registrationController,
                  label: "Reg. Number",
                  icon: Icons.verified_user_outlined,
                  isRequired: false,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 1,
                child: _ModernTextField(
                  controller: controller.experienceController,
                  label: "Exp (Yrs)",
                  isNumber: true,
                  isRequired: false, // OPTIONAL
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // --- HEAD OFFICE DROPDOWN (REQUIRED) ---
          Obx(() {
            if (controller.isLoadingHeadOffices.value) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: TColors.primary),
                  ),
                ),
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Select Head Office *",
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF636E72))),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: controller.selectedHeadOfficeId.value,
                  isExpanded: true,
                  hint: Text("Select Head Office", style: TextStyle(fontSize: 14, color: Colors.grey[400])),
                  icon: const Icon(Icons.keyboard_arrow_down_rounded),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF2D3436)),
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.domain, color: TColors.primary.withOpacity(0.8), size: 18),
                    filled: true,
                    fillColor: const Color(0xFFFAFAFA),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: TColors.primary, width: 1.5)),
                  ),
                  items: controller.headOffices.toList().map((item) {
                    return DropdownMenuItem<String>(
                      value: item['id'],
                      child: Text(item['name'] ?? "Unknown"),
                    );
                  }).toList(),
                  onChanged: (val) {
                    controller.selectedHeadOfficeId.value = val;
                  },
                  validator: (v) => v == null ? "Required" : null,
                ),
              ],
            );
          }),

          const SizedBox(height: 16),

          // --- PRIORITY DROPDOWN (Optional) ---
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(12),
              color: const Color(0xFFFAFAFA),
            ),
            child: Row(
              children: [
                Icon(Icons.star_outline_rounded, color: TColors.primary.withOpacity(0.8), size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Obx(() => DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: controller.selectedPriority.value,
                      isExpanded: true,
                      hint: Text("Priority (Optional)", style: TextStyle(fontSize: 14, color: Colors.grey[400])),
                      icon: const Icon(Icons.keyboard_arrow_down_rounded),
                      items: controller.priorities.map((String value) {
                        return DropdownMenuItem<String>(
                            value: value,
                            child: Text("Priority $value", style: const TextStyle(fontSize: 14))
                        );
                      }).toList(),
                      onChanged: (newValue) => controller.selectedPriority.value = newValue!,
                    ),
                  )),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfoCard(AddDoctorNewController controller) {
    return _ModernCard(
      child: Column(
        children: [
          _ModernTextField(
            controller: controller.emailController,
            label: "Email Address",
            hint: "doctor@hospital.com",
            icon: Icons.email_outlined,
            inputType: TextInputType.emailAddress,
            isRequired: false,
          ),
          const SizedBox(height: 16),
          _ModernTextField(
            controller: controller.phoneController,
            label: "Phone Number",
            hint: "+91 XXXXX XXXXX",
            icon: Icons.phone_android_rounded,
            inputType: TextInputType.phone,
            isNumber: true,
            isRequired: false,
          ),
        ],
      ),
    );
  }

  Widget _buildAddressFieldsCard(AddDoctorNewController controller) {
    return _ModernCard(
      child: Column(
        children: [
          _ModernTextField(
            controller: controller.address1Controller,
            label: "Address Line 1 (Auto-filled)",
            hint: "Auto-filled from Map",
            icon: Icons.map,
            filledColor: Colors.blue[50],
            isRequired: false, // Not strictly required as text, but Map pin is required
          ),
          const SizedBox(height: 16),
          _ModernTextField(
            controller: controller.address2Controller,
            label: "Address Line 2",
            hint: "Floor, Unit No, Landmark",
            icon: Icons.edit_location_alt_outlined,
            isRequired: false,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _ModernTextField(
                  controller: controller.stateController,
                  label: "State",
                  hint: "State",
                  isRequired: false,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ModernTextField(
                  controller: controller.pincodeController,
                  label: "Pincode",
                  hint: "XXXXXX",
                  isNumber: true,
                  isRequired: false,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _ModernTextField(
                  controller: controller.postOfficeController,
                  label: "Post Office",
                  hint: "PO Name",
                  isRequired: false,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ModernTextField(
                  controller: controller.countryController,
                  label: "Country",
                  hint: "Country",
                  isRequired: false,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(AddDoctorNewController controller, BuildContext context) {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: TColors.primary.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8)),
        ],
      ),
      child: ElevatedButton(
        // Pass context to submit
        onPressed: () => controller.submit(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: TColors.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: const Text(
          "COMPLETE REGISTRATION",
          style: TextStyle(
              color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 1.0),
        ),
      ),
    );
  }
}

// ===========================================================================
// STYLE HELPERS
// ===========================================================================

class _ModernCard extends StatelessWidget {
  final Widget child;
  const _ModernCard({required this.child});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.06), blurRadius: 20, offset: const Offset(0, 5)),
          BoxShadow(color: Colors.grey.withOpacity(0.02), blurRadius: 2, offset: const Offset(0, 1)),
        ],
      ),
      child: child,
    );
  }
}

class _ModernTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? hint;
  final IconData? icon;
  final bool isNumber;
  final bool isReadOnly;
  final VoidCallback? onTap;
  final Color? filledColor;
  final TextInputType? inputType;
  final bool isRequired;

  const _ModernTextField({
    Key? key,
    required this.label,
    required this.controller,
    this.hint,
    this.icon,
    this.isNumber = false,
    this.isReadOnly = false,
    this.onTap,
    this.filledColor,
    this.inputType,
    this.isRequired = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF636E72))),
            if(isRequired)
              const Text(" *", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: isReadOnly,
          onTap: onTap,
          keyboardType: inputType ?? (isNumber ? TextInputType.number : TextInputType.text),
          validator: (v) {
            if (isRequired && (v == null || v.trim().isEmpty)) {
              return 'Required';
            }
            return null;
          },
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF2D3436)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
            prefixIcon: icon != null ? Icon(icon, color: TColors.primary.withOpacity(0.8), size: 18) : null,
            filled: true,
            fillColor: filledColor ?? const Color(0xFFFAFAFA),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: TColors.primary, width: 1.5)),
          ),
        ),
      ],
    );
  }
}