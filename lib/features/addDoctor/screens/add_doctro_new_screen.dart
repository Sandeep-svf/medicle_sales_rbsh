import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../utils/helpers/upper_text_formator.dart';
import '../controllers/add_doctor_new_controller.dart';
import '../../../utils/constants/colors.dart';

class AddDoctorNewScreen extends StatelessWidget {
  const AddDoctorNewScreen({Key? key}) : super(key: key);

  final String _companyLogoAsset = "assets/logos/doctor_banner.png";

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AddDoctorNewController());
    final screenWidth = MediaQuery.of(context).size.width;
    final BuildContext pageContext = context;

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
                child:
                    const Icon(Icons.arrow_back, color: Colors.white, size: 20),
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
                    Shadow(
                        offset: Offset(0, 1),
                        blurRadius: 3.0,
                        color: Colors.black45)
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
                double singleCardWidth =
                    (constraints.maxWidth - (horizontalPadding * 2) - spacing) /
                        2;
                double dynamicHeight =
                    (singleCardWidth * 0.85).clamp(160.0, 280.0);

                return Column(
                  children: [
                    // --- TOP SECTION: IMAGE & LOCATION (REQUIRED) ---
                    Transform.translate(
                      offset: const Offset(0, -50),
                      child: Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: horizontalPadding),
                        child: SizedBox(
                          height: dynamicHeight,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Image is Required
                              Expanded(
                                  child: _buildSideBySideImagePicker(
                                      context, controller)),
                              SizedBox(width: spacing),
                              // Location is Required
                              Expanded(
                                  child: _buildSideBySideLocationPicker(
                                      controller)),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // --- FORM FIELDS ---
                    Transform.translate(
                      offset: const Offset(0, -20),
                      child: Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: horizontalPadding),
                        child: Form(
                          key: controller.formKey,
                          child: Column(
                            children: [
                              // 01 Basic Info
                              _buildSectionHeader(
                                  number: "01",
                                  title: "Basic Information",
                                  subtitle: "Personal Details"),
                              const SizedBox(height: 15),
                              _buildBasicInfoCard(controller, context),
                              const SizedBox(height: 30),

                              // 02 Professional Info
                              _buildSectionHeader(
                                  number: "02",
                                  title: "Professional",
                                  subtitle: "Work Details"),
                              const SizedBox(height: 15),
                              _buildProfessionalInfoCard(context, controller),
                              const SizedBox(height: 30),

                              // 03 Contact Info
                              _buildSectionHeader(
                                  number: "03",
                                  title: "Contact Info",
                                  subtitle: "Optional"),
                              const SizedBox(height: 15),
                              _buildContactInfoCard(controller),
                              const SizedBox(height: 30),

                              // 04 Address Details
                              _buildSectionHeader(
                                  number: "04",
                                  title: "Address Details",
                                  subtitle: "Location (Auto)"),
                              const SizedBox(height: 15),
                              _buildAddressFieldsCard(controller),

                              const SizedBox(height: 30),

// 05 Area Assignment
                              // 05 Area Assignment
                              _buildSectionHeader(
                                number: "05",
                                title: "Area Assignment",
                                subtitle: "Auto Assigned",
                              ),
                              const SizedBox(height: 15),

                              Obx(() {
                                final area = controller.areas.firstWhereOrNull(
                                      (e) => e['id'] == controller.selectedAreaId.value,
                                );

                                return Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.green.shade300,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.location_city,
                                        color: Colors.green,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              "Assigned Area",
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.grey,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              area?['name'] ?? "Detecting area...",
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (controller.selectedAreaId.value != null)
                                        const Icon(
                                          Icons.check_circle,
                                          color: Colors.green,
                                        )
                                      else
                                        const SizedBox(
                                          height: 18,
                                          width: 18,
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        ),
                                    ],
                                  ),
                                );
                              }),

                              const SizedBox(height: 40),

                             /* _buildAreaSelector(
                                context,
                                controller,
                              ),*/

                           //   const SizedBox(height: 40),

                              // Submit Button
                              Center(
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                      maxWidth: isWide ? 500 : double.infinity),
                                  child:
                                      _buildSubmitButton(controller, context),
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

  Widget _buildSideBySideImagePicker(
      BuildContext context, AddDoctorNewController controller) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))
        ],
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
                  Text("Processing...",
                      style: TextStyle(fontSize: 10, color: Colors.grey[600]))
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                                color: Colors.white.withOpacity(0.9),
                                shape: BoxShape.circle),
                            child: const Icon(Icons.visibility,
                                color: TColors.primary, size: 20),
                          ),
                        ),
                        const SizedBox(width: 15),
                        GestureDetector(
                          onTap: controller.captureImage,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                                color: TColors.primary.withOpacity(0.9),
                                shape: BoxShape.circle),
                            child: const Icon(Icons.refresh,
                                color: Colors.white, size: 20),
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
                  Icon(Icons.add_a_photo,
                      size: 36, color: TColors.primary),
                  const SizedBox(height: 8),
                  Text("Capture\nPhoto *",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 13,
                          fontWeight: FontWeight.bold)),
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
                minScale: 1.0,
                maxScale: 4.0,
                panEnabled: true,
                child: Image.file(imageFile, fit: BoxFit.contain),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                      color: Colors.black54, shape: BoxShape.circle),
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
          boxShadow: const [
            BoxShadow(
                color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))
          ],
          border: Border.all(color: TColors.primary.withOpacity(0.1)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: TColors.primary,
                  shape: BoxShape.circle),
              child: const Icon(Icons.location_on,
                  color: TColors.white, size: 28),
            ),
            const SizedBox(height: 10),
            const Text("Set Doctor\nLocation *",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 13)),
            const SizedBox(height: 5),
            Obx(() => Text(
                  controller.isLocationSet.value
                      ? " Coordinates Set"
                      : "(Tap to Open Map)",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    color: controller.isLocationSet.value
                        ? Colors.green
                        : Colors.grey[500],
                    fontWeight: FontWeight.w500,
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
      {required String number,
      required String title,
      required String subtitle}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: TColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(number,
              style: const TextStyle(
                  color: TColors.primary,
                  fontWeight: FontWeight.w800,
                  fontSize: 14)),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.black87)),
            Text(subtitle,
                style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 11,
                    color: Colors.grey[500])),
          ],
        ),
        const Spacer(),
        Container(height: 1, width: 40, color: Colors.grey[300]),
      ],
    );
  }

  // --- UPDATED: 01. BASIC INFO ---
  Widget _buildBasicInfoCard(
      AddDoctorNewController controller, BuildContext context) {
    return _ModernCard(
      child: Column(
        children: [
          _ModernTextField(
            controller: controller.nameController,
            label: "Full Name",
            hint: "John Doe",
            icon: Icons.person_outline_rounded,
            isRequired: true,
            prefixText: "DR.",
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
                Icon(Icons.people_outline_rounded,
                    color: Colors.grey[600], size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      const Row(
                        children: [
                          Text(
                            "Gender",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF636E72),
                            ),
                          ),
                          Text(
                            " *",
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      Obx(
                            () => Row(
                          children: [

                            Expanded(
                              child: _genderButton(
                                title: "Male",
                                icon: Icons.male,
                                color: Colors.blue,
                                selected:
                                controller.selectedGender.value == "Male",
                                onTap: () =>
                                controller.selectedGender.value = "Male",
                              ),
                            ),

                            const SizedBox(width: 10),

                            Expanded(
                              child: _genderButton(
                                title: "Female",
                                icon: Icons.female,
                                color: Colors.pink,
                                selected:
                                controller.selectedGender.value == "Female",
                                onTap: () =>
                                controller.selectedGender.value = "Female",
                              ),
                            ),

                            const SizedBox(width: 10),

                            Expanded(
                              child: _genderButton(
                                title: "Other",
                                icon: Icons.transgender,
                                color: Colors.deepPurple,
                                selected:
                                controller.selectedGender.value == "Other",
                                onTap: () =>
                                controller.selectedGender.value = "Other",
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
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
  Widget _buildProfessionalInfoCard(
      BuildContext context, AddDoctorNewController controller) {
    return _ModernCard(
      child: Column(
        children: [
          _ModernTextField(
            controller: controller.specializationController,
            label: "Specialization",
            hint: "e.g. Cardiologist",
            icon: Icons.medical_services_outlined,
            isRequired: true,
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
                  isRequired: true, // OPTIONAL
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
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: TColors.primary),
                  ),
                ),
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Select Head Office *",
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF636E72))),
                const SizedBox(height: 8),
                const SizedBox(height: 8),

                if (controller.headOffices.length == 1) ...[
                  Builder(
                    builder: (_) {
                      final office = controller.headOffices.first;

                      // Auto select the only head office
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (controller.selectedHeadOfficeId.value == null) {
                          controller.selectedHeadOfficeId.value = office['id'];
                        }
                      });

                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: TColors.primary.withOpacity(.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: TColors.primary.withOpacity(.35),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.domain,
                              color: TColors.primary,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Assigned Head Office",
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    office['name'] ?? '',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ] else ...[
                  DropdownButtonFormField<String>(
                    value: controller.selectedHeadOfficeId.value,
                    isExpanded: true,
                    hint: Text(
                      "Select Head Office",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[400],
                      ),
                    ),
                    icon: const Icon(Icons.keyboard_arrow_down_rounded),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D3436),
                    ),
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.domain,
                        color: TColors.primary.withOpacity(0.8),
                        size: 18,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFFAFAFA),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.grey.shade200,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.grey.shade200,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: TColors.primary,
                          width: 1.5,
                        ),
                      ),
                    ),
                    items: controller.headOffices.map((item) {
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

                const SizedBox(height: 16),

                // --- PRIORITY DROPDOWN

                // --- AREA DROPDOWN (REQUIRED) ---

              ],
            );
          }),

          const SizedBox(height: 16),

          // --- PRIORITY DROPDOWN (Optional) ---
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Text(
                    "Priority",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF636E72),
                    ),
                  ),
                  Text(
                    " *",
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              Obx(
                    () => Row(
                  children: [
                    Expanded(
                      child: _priorityButton(
                        label: "A",
                        title: "High",
                        color:Color(0xFF2E7D32),
                        selected:
                        controller.selectedPriority.value == "A",
                        onTap: () =>
                        controller.selectedPriority.value = "A",
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _priorityButton(
                        label: "B",
                        title: "Medium",
                        color: Colors.orange,
                        selected:
                        controller.selectedPriority.value == "B",
                        onTap: () =>
                        controller.selectedPriority.value = "B",
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _priorityButton(
                        label: "C",
                        title: "Low",
                        color: Colors.blue,
                        selected:
                        controller.selectedPriority.value == "C",
                        onTap: () =>
                        controller.selectedPriority.value = "C",
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAreaSelector(
    BuildContext context,
    AddDoctorNewController controller,
  ) {
    final searchController = TextEditingController();

    return StatefulBuilder(
      builder: (context, setState) {
        List<Map<String, dynamic>> filtered = controller.areas.toList();

        return Obx(() {
          filtered = controller.areas
              .where((area) => area['name'].toString().toLowerCase().contains(
                    searchController.text.toLowerCase(),
                  ))
              .toList();

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFAFAFA),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.grey.shade200,
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        "Area *",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        _showAddAreaDialog(
                          context,
                          controller,
                        );
                      },
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: searchController,
                  decoration: const InputDecoration(
                    hintText: "Search Area",
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (_) {
                    setState(() {});
                  },
                ),
                if (controller.selectedAreaId.value != null)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.green.shade300),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            filtered.firstWhereOrNull(
                                  (e) =>
                                      e['id'] ==
                                      controller.selectedAreaId.value,
                                )?['name'] ??
                                "Area Selected",
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 220,
                  child: controller.isLoadingAreas.value
                      ? const Center(
                    child: CircularProgressIndicator(),
                  )
                      : filtered.isEmpty
                      ? ListView(
                    children: [
                      ListTile(
                        leading: const Icon(
                          Icons.add_circle,
                          color: Colors.green,
                        ),
                        title: Text(
                          'Create "${searchController.text.trim()}"',
                        ),
                        subtitle: const Text(
                          'Area not found',
                        ),
                        onTap: () {
                          _showAddAreaDialog(
                            context,
                            controller,
                            prefilledAreaName: searchController.text.trim(),
                          );
                        },
                      ),
                    ],
                  )
                      : ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (_, index) {
                      final area = filtered[index];

                      final selected =
                          controller.selectedAreaId.value ==
                              area['id'];

                      return ListTile(
                        selected: selected,
                        tileColor: selected
                            ? TColors.primary.withOpacity(0.10)
                            : Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(10),
                        ),
                        title: Text(
                          area['name'],
                        ),
                        trailing: selected
                            ? const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                        )
                            : null,
                        onTap: () {
                          controller.selectedAreaId.value =
                          area['id'];
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        });
      },
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
            label: "Address Line 1 (Required full address)",
            hint: "Please fill address in details",
            icon: Icons.place_outlined,
            isRequired: true,
          ),
          const SizedBox(height: 16),

          _ModernTextField(
            controller: controller.address2Controller,
            label: "Address Line 2",
            hint: "House No, Building",
            icon: Icons.edit_location_alt_outlined,
          ),
          const SizedBox(height: 16),

          _ModernTextField(
            controller: controller.address2Controller,
            label: "Landmark",
            hint: "Near Indian Oil Petrol Pump.",
            icon: Icons.edit_location_alt_outlined,
          ),
          const SizedBox(height: 16),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _ModernTextField(
                      controller: controller.blockController,
                      label: "Block",
                      isReadOnly: true,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: _ModernTextField(
                      controller: controller.districtController,
                      label: "District",
                      isReadOnly: true,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              _ModernTextField(
                controller: controller.divisionController,
                label: "Division",
                isReadOnly: true,
              ),

              Row(
                children: [
                  Expanded(
                    child: _ModernTextField(
                      controller: controller.stateController,
                      label: "State",
                      hint: "State",
                      isReadOnly: true,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: GestureDetector(
                      onTap: controller.showPincodeDialog,
                      child: AbsorbPointer(
                        child: _ModernTextField(
                          controller: controller.pincodeController,
                          label: "Pincode",
                          hint: "XXXXXX",
                          isReadOnly: true,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 6),

              InkWell(
                onTap: controller.showPincodeDialog,
                child: const Row(
                  children: [
                    Icon(
                      Icons.edit_location_alt,
                      size: 14,
                      color: Colors.blue,
                    ),
                    SizedBox(width: 4),
                    Text(
                      "Tap pincode to change location",
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: Obx(
                      () => DropdownButtonFormField<String>(
                    isExpanded: true,

                    value: controller.postOfficeList.any(
                          (e) => e['Name'] == controller.selectedPostOffice.value,
                    )
                        ? controller.selectedPostOffice.value
                        : null,

                    decoration: InputDecoration(
                      labelText: "Post Office",
                      filled: true,
                      fillColor: const Color(0xFFFAFAFA),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),

                    items: controller.postOfficeList.map((office) {
                      return DropdownMenuItem<String>(
                        value: office['Name'],
                        child: Text(office['Name']),
                      );
                    }).toList(),

                    onChanged: (value) {

                      final office = controller.postOfficeList.firstWhere(
                            (e) => e['Name'] == value,
                      );

                      controller.fillAddress(
                        office,
                        controller.pincodeController.text,
                      );
                    },
                  ),
                )
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ModernTextField(
                  controller: controller.countryController,
                  label: "Country",
                  hint: "Country",
                  isReadOnly: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(
      AddDoctorNewController controller, BuildContext context) {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: TColors.primary.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8)),
        ],
      ),
      child: ElevatedButton(
        // Pass context to submit
        onPressed: () => controller.submit(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: TColors.primary,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: const Text(
          "COMPLETE REGISTRATION",
          style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0),
        ),
      ),
    );
  }



  void _showAddAreaDialog(
      BuildContext context,
      AddDoctorNewController controller, {
        String? prefilledAreaName,
      }) {
    final areaController = TextEditingController(
      text: prefilledAreaName ?? '',
    );

    final pincodeController = TextEditingController(
      text: controller.pincodeController.text,
    );

    final postOfficeController = TextEditingController(
      text: controller.postOfficeController.text,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return AnimatedPadding(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            constraints: const BoxConstraints(
              maxWidth: 700,
            ),
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(28),
              ),
            ),
            child: SafeArea(
              top: false,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: TColors.primary.withOpacity(.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.location_city,
                            color: TColors.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            "Create New Area",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Get.back(),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    _ModernTextField(
                      controller: areaController,
                      label: "Area Name",
                      hint: "Enter Area Name",
                      icon: Icons.location_city_outlined,
                      isRequired: true,
                    ),

                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: _ModernTextField(
                            controller: pincodeController,
                            label: "Pincode",
                            hint: "110001",
                            icon: Icons.pin_drop_outlined,
                            isRequired: true,
                            isReadOnly:
                            controller.pincodeController.text.isNotEmpty,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _ModernTextField(
                            controller: postOfficeController,
                            label: "Post Office",
                            hint: "Connaught Place",
                            icon: Icons.local_post_office_outlined,
                            isRequired: true,
                            isReadOnly:
                            controller.postOfficeController.text.isNotEmpty,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Get.back(),
                            child: const Text("Cancel"),
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          flex: 2,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.add),
                            label: const Text("Create Area"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: TColors.primary,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(
                                double.infinity,
                                52,
                              ),
                            ),
                            onPressed: () async {
                              if (controller.selectedHeadOfficeId.value == null) {
                                Get.snackbar(
                                  "Required",
                                  "Please select Head Office first",
                                );
                                return;
                              }

                              await controller.createArea(
                                name: areaController.text.trim(),
                                pincode: pincodeController.text.trim(),
                                postOffice: postOfficeController.text.trim(),
                              );

                              await controller.fetchAreas(); // <-- ADD THIS

                              if (context.mounted) {
                                Navigator.pop(context);
                              }
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }



  Widget _priorityButton({
    required String label,
    required String title,
    required Color color,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(.12) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? color : Colors.grey.shade300,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: color,
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: selected ? color : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _genderButton({
    required String title,
    required IconData icon,
    required Color color,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          vertical: 14,
        ),
        decoration: BoxDecoration(
          color: selected
              ? color.withOpacity(.12)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? color
                : Colors.grey.shade300,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [

            Icon(
              icon,
              size: 28,
              color: selected
                  ? color
                  : Colors.grey,
            ),

            const SizedBox(height: 8),

            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: selected
                    ? color
                    : Colors.black87,
              ),
            ),
          ],
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
          BoxShadow(
              color: Colors.grey.withOpacity(0.06),
              blurRadius: 20,
              offset: const Offset(0, 5)),
          BoxShadow(
              color: Colors.grey.withOpacity(0.02),
              blurRadius: 2,
              offset: const Offset(0, 1)),
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
  final String? prefixText;

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
    this.prefixText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF636E72))),
            if (isRequired)
              const Text(" *",
                  style: TextStyle(
                      color: Colors.red, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: isReadOnly,
          onTap: onTap,
          textCapitalization: TextCapitalization.characters,
          inputFormatters: [
            UpperCaseTextFormatter(),
          ],
          keyboardType: inputType ??
              (isNumber ? TextInputType.number : TextInputType.text),
          validator: (v) {
            if (isRequired && (v == null || v.trim().isEmpty)) {
              return 'Required';
            }
            return null;
          },
          style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Color(0xFF2D3436)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: Colors.grey[400],
              fontSize: 13,
            ),

            prefixText: prefixText != null ? '$prefixText ' : null,
            prefixStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              fontSize: 14,
            ),

            prefixIcon: icon != null
                ? Icon(
              icon,
              color: TColors.primary.withOpacity(0.8),
              size: 18,
            )
                : null,

            filled: true,
            fillColor: filledColor ?? const Color(0xFFFAFAFA),
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: TColors.primary,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
