import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../utils/helpers/upper_text_formator.dart';
import '../controllers/offline_doctor_create_controller.dart';
import 'package:medicle_sales_rbsh/utils/constants/colors.dart';
import 'package:medicle_sales_rbsh/utils/constants/text_strings.dart';
import 'package:medicle_sales_rbsh/utils/constants/sizes.dart';

class OfflineDoctorCreateScreen extends StatelessWidget {
  const OfflineDoctorCreateScreen({super.key, required this.controller});
  final OfflineDoctorCreateController controller;

  final String _companyLogoAsset = "assets/logos/doctor_banner.png";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColors.hex_FFF4F6F9,
      body: CustomScrollView(
        slivers: [
          // 1. APP BAR
          SliverAppBar(
            expandedHeight: 160.0,
            floating: false,
            pinned: true,
            backgroundColor: TColors.primary,
            elevation: TSizes.v0,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: TColors.pureBlack.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back,
                    color: TColors.white, size: TSizes.v20),
              ),
              onPressed: () => Get.back(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: const Text(
                TTexts.uiTextAddNewDoctor,
                style: TextStyle(
                  color: TColors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: TSizes.v16,
                  letterSpacing: 0.5,
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
                          TColors.pureBlack.withValues(alpha: 0.3),
                          TColors.transparent,
                          TColors.primary.withValues(alpha: 0.9),
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
                                  title: TTexts.uiTextBasicInformation,
                                  subtitle: TTexts.uiTextPersonalDetails),
                              const SizedBox(height: TSizes.v15),
                              _buildBasicInfoCard(controller, context),
                              const SizedBox(height: TSizes.v30),

                              // 02 Professional Info
                              _buildSectionHeader(
                                  number: "02",
                                  title: TTexts.uiTextProfessional,
                                  subtitle: TTexts.uiTextWorkDetails),
                              const SizedBox(height: TSizes.v15),
                              _buildProfessionalInfoCard(context, controller),
                              const SizedBox(height: TSizes.v30),

                              // 03 Contact Info
                              _buildSectionHeader(
                                  number: "03",
                                  title: TTexts.uiTextContactInfo,
                                  subtitle: TTexts.uiTextOptional),
                              const SizedBox(height: TSizes.v15),
                              _buildContactInfoCard(controller),
                              const SizedBox(height: TSizes.v30),

                              // 04 Address Details
                              _buildSectionHeader(
                                  number: "04",
                                  title: TTexts.uiTextAddressDetails,
                                  subtitle: TTexts.uiTextLocationAuto),
                              const SizedBox(height: TSizes.v15),
                              _buildAddressFieldsCard(context, controller),

                              const SizedBox(height: TSizes.v30),

                              // Submit Button
                              Center(
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                      maxWidth: isWide ? 500 : double.infinity),
                                  child: Obx(() =>
                                      _buildSubmitButton(controller, context)),
                                ),
                              ),
                              const SizedBox(height: TSizes.v50),
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
      BuildContext context, OfflineDoctorCreateController controller) {
    return Container(
      decoration: BoxDecoration(
        color: TColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
              color: TColors.black12,
              blurRadius: TSizes.v8,
              offset: Offset(0, 4))
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
                  const SizedBox(height: TSizes.v8),
                  Text(TTexts.uiTextProcessing_272bc02e,
                      style: TextStyle(
                          fontSize: TSizes.v10, color: TColors.materialGrey600))
                ],
              ),
            );
          }
          final img = controller.doctorImage.value;
          if (img != null) {
            return Stack(
              fit: StackFit.expand,
              children: [
                Container(color: TColors.pureBlack),
                Image.file(img, fit: BoxFit.contain),
                Center(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: TColors.pureBlack.withValues(alpha: 0.4),
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
                                color: TColors.white.withValues(alpha: 0.9),
                                shape: BoxShape.circle),
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
                                color: TColors.primary.withValues(alpha: 0.9),
                                shape: BoxShape.circle),
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
          } else {
            return GestureDetector(
              onTap: controller.captureImage,
              behavior: HitTestBehavior.opaque,
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_a_photo,
                      size: TSizes.v36, color: TColors.primary),
                  SizedBox(height: TSizes.v8),
                  Text(TTexts.uiTextCapturePhoto,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: TColors.pureBlack,
                          fontSize: TSizes.v13,
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
        backgroundColor: TColors.transparent,
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
                      color: TColors.black54, shape: BoxShape.circle),
                  child: const Icon(Icons.close,
                      color: TColors.white, size: TSizes.v20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSideBySideLocationPicker(
      OfflineDoctorCreateController controller) {
    return GestureDetector(
      onTap: controller.pickLocationOnMap,
      child: Container(
        decoration: BoxDecoration(
          color: TColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
                color: TColors.black12,
                blurRadius: TSizes.v8,
                offset: Offset(0, 4))
          ],
          border: Border.all(color: TColors.primary.withValues(alpha: 0.1)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                  color: TColors.primary, shape: BoxShape.circle),
              child: const Icon(Icons.location_on,
                  color: TColors.white, size: TSizes.v28),
            ),
            const SizedBox(height: TSizes.v10),
            const Text(TTexts.uiTextSetDoctorLocation,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: TColors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: TSizes.v13)),
            const SizedBox(height: TSizes.v5),
            Obx(() => Text(
                  controller.isLocationSet.value
                      ? " Coordinates Set"
                      : "(Tap to Open Map)",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: TSizes.v10,
                    color: controller.isLocationSet.value
                        ? TColors.materialGreen
                        : TColors.materialGrey500,
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
            color: TColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(number,
              style: const TextStyle(
                  color: TColors.primary,
                  fontWeight: FontWeight.w800,
                  fontSize: TSizes.v14)),
        ),
        const SizedBox(width: TSizes.v12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: TSizes.v15,
                    color: TColors.black87)),
            Text(subtitle,
                style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: TSizes.v11,
                    color: TColors.materialGrey500)),
          ],
        ),
        const Spacer(),
        Container(
            height: TSizes.v1,
            width: TSizes.v40,
            color: TColors.materialGrey300),
      ],
    );
  }

  // --- UPDATED: 01. BASIC INFO ---
  Widget _buildBasicInfoCard(
      OfflineDoctorCreateController controller, BuildContext context) {
    return _ModernCard(
      child: Column(
        children: [
          _ModernTextField(
            controller: controller.nameController,
            label: TTexts.uiTextFullName,
            hint: "John Doe",
            icon: Icons.person_outline_rounded,
            isRequired: true,
            prefixText: TTexts.uiTextDR,
          ),
          const SizedBox(height: TSizes.v16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: TColors.materialGrey200),
              borderRadius: BorderRadius.circular(12),
              color: TColors.hex_FFFAFAFA,
            ),
            child: Row(
              children: [
                Icon(Icons.people_outline_rounded,
                    color: TColors.materialGrey600, size: TSizes.v20),
                const SizedBox(width: TSizes.v12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Text(
                            TTexts.gender,
                            style: TextStyle(
                              fontSize: TSizes.v13,
                              fontWeight: FontWeight.w600,
                              color: TColors.hex_FF636E72,
                            ),
                          ),
                          Text(
                            TTexts.uiTextValue,
                            style: TextStyle(
                              color: TColors.materialRed,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: TSizes.v10),
                      Obx(
                        () => Row(
                          children: [
                            Expanded(
                              child: _genderButton(
                                title: TTexts.uiTextMale,
                                icon: Icons.male,
                                color: TColors.materialBlue,
                                selected:
                                    controller.selectedGender.value == "Male",
                                onTap: () =>
                                    controller.selectedGender.value = "Male",
                              ),
                            ),
                            const SizedBox(width: TSizes.v10),
                            Expanded(
                              child: _genderButton(
                                title: TTexts.uiTextFemale,
                                icon: Icons.female,
                                color: TColors.materialPink,
                                selected:
                                    controller.selectedGender.value == "Female",
                                onTap: () =>
                                    controller.selectedGender.value = "Female",
                              ),
                            ),
                            const SizedBox(width: TSizes.v10),
                            Expanded(
                              child: _genderButton(
                                title: TTexts.uiTextOther,
                                icon: Icons.transgender,
                                color: TColors.materialDeepPurple,
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
          const SizedBox(height: TSizes.v16),
          Row(
            children: [
              Expanded(
                child: _ModernTextField(
                  controller: controller.dobController,
                  label: TTexts.dob,
                  icon: Icons.cake_outlined,
                  isReadOnly: true,
                  onTap: () => controller.selectDate(context, false),
                  isRequired: false, // OPTIONAL
                ),
              ),
              const SizedBox(width: TSizes.v12),
              Expanded(
                child: _ModernTextField(
                  controller: controller.anniversaryController,
                  label: TTexts.anniversary,
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
      BuildContext context, OfflineDoctorCreateController controller) {
    return _ModernCard(
      child: Column(
        children: [
          _ModernTextField(
            controller: controller.specializationController,
            label: TTexts.specialization,
            hint: "e.g. Cardiologist",
            icon: Icons.medical_services_outlined,
            isRequired: true,
          ),
          const SizedBox(height: TSizes.v16),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: _ModernTextField(
                  controller: controller.registrationController,
                  label: TTexts.uiTextRegNumber,
                  icon: Icons.verified_user_outlined,
                  isRequired: false,
                ),
              ),
              const SizedBox(width: TSizes.v12),
              Expanded(
                flex: 1,
                child: _ModernTextField(
                  controller: controller.experienceController,
                  label: TTexts.uiTextExpYrs,
                  isNumber: true,
                  isRequired: false,
                ),
              ),
            ],
          ),
          const SizedBox(height: TSizes.v16),

          // --- HEAD OFFICE DROPDOWN (REQUIRED) ---
          Obx(() {
            if (controller.isLoadingHeadOffices.value &&
                controller.headOffices.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: SizedBox(
                    height: TSizes.v20,
                    width: TSizes.v20,
                    child: CircularProgressIndicator(
                        strokeWidth: TSizes.v2, color: TColors.primary),
                  ),
                ),
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(TTexts.uiTextSelectHeadOffice_ceb9cd5f,
                    style: TextStyle(
                        fontSize: TSizes.v13,
                        fontWeight: FontWeight.w600,
                        color: TColors.hex_FF636E72)),
                const SizedBox(height: TSizes.v8),
                const SizedBox(height: TSizes.v8),

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
                          color: TColors.primary.withValues(alpha: .08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: TColors.primary.withValues(alpha: .35),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.domain,
                              color: TColors.primary,
                            ),
                            const SizedBox(width: TSizes.v12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    TTexts.uiTextAssignedHeadOffice,
                                    style: TextStyle(
                                      fontSize: TSizes.v11,
                                      color: TColors.materialGrey,
                                    ),
                                  ),
                                  const SizedBox(height: TSizes.v2),
                                  Text(
                                    office['name'] ?? '',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: TSizes.v15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.check_circle,
                              color: TColors.materialGreen,
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
                      TTexts.uiTextSelectHeadOffice,
                      style: TextStyle(
                        fontSize: TSizes.v14,
                        color: TColors.materialGrey400,
                      ),
                    ),
                    icon: const Icon(Icons.keyboard_arrow_down_rounded),
                    style: const TextStyle(
                      fontSize: TSizes.v14,
                      fontWeight: FontWeight.w600,
                      color: TColors.hex_FF2D3436,
                    ),
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.domain,
                        color: TColors.primary.withValues(alpha: 0.8),
                        size: TSizes.v18,
                      ),
                      filled: true,
                      fillColor: TColors.hex_FFFAFAFA,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: TColors.materialGrey200,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: TColors.materialGrey200,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: TColors.primary,
                          width: TSizes.v1_5,
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

                const SizedBox(height: TSizes.v16),

                // --- PRIORITY DROPDOWN

                // --- AREA DROPDOWN (REQUIRED) ---
              ],
            );
          }),

          const SizedBox(height: TSizes.v16),

          // --- PRIORITY DROPDOWN (Optional) ---
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Text(
                    TTexts.uiTextPriority,
                    style: TextStyle(
                      fontSize: TSizes.v13,
                      fontWeight: FontWeight.w600,
                      color: TColors.hex_FF636E72,
                    ),
                  ),
                  Text(
                    TTexts.uiTextValue,
                    style: TextStyle(
                      color: TColors.materialRed,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: TSizes.v10),
              Obx(
                () => Row(
                  children: [
                    Expanded(
                      child: _priorityButton(
                        label: TTexts.uiTextA,
                        title: TTexts.uiTextHigh,
                        color: TColors.hex_FF2E7D32,
                        selected: controller.selectedPriority.value == "A",
                        onTap: () => controller.selectedPriority.value = "A",
                      ),
                    ),
                    const SizedBox(width: TSizes.v10),
                    Expanded(
                      child: _priorityButton(
                        label: TTexts.uiTextB,
                        title: TTexts.uiTextMedium,
                        color: TColors.materialOrange,
                        selected: controller.selectedPriority.value == "B",
                        onTap: () => controller.selectedPriority.value = "B",
                      ),
                    ),
                    const SizedBox(width: TSizes.v10),
                    Expanded(
                      child: _priorityButton(
                        label: TTexts.uiTextC,
                        title: TTexts.uiTextLow,
                        color: TColors.materialBlue,
                        selected: controller.selectedPriority.value == "C",
                        onTap: () => controller.selectedPriority.value = "C",
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
    OfflineDoctorCreateController controller,
  ) {
    final searchController = controller.areaSearchController;

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
              color: TColors.hex_FFFAFAFA,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: TColors.materialGrey200,
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        TTexts.uiTextArea_8862bb63,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (controller.isOnline.value)
                      IconButton(
                        tooltip: TTexts.uiTextCreateNewAreaOnlineOnly,
                        onPressed: () {
                          _showAddAreaDialog(
                            context,
                            controller,
                          );
                        },
                        icon: const Icon(Icons.add),
                      )
                    else
                      const Tooltip(
                        message:
                            TTexts.uiTextOfflineModeSelectAnExistingCachedArea,
                        child: Icon(Icons.lock_outline,
                            color: TColors.materialGrey),
                      ),
                  ],
                ),
                const SizedBox(height: TSizes.v8),
                TextField(
                  controller: searchController,
                  decoration: const InputDecoration(
                    hintText: TTexts.uiTextSearchExistingArea,
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
                      color: TColors.materialGreen50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: TColors.materialGreen300),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: TColors.materialGreen,
                        ),
                        const SizedBox(width: TSizes.v8),
                        Expanded(
                          child: Text(
                            controller.areaNameController.text.isNotEmpty
                                ? controller.areaNameController.text
                                : TTexts.uiTextAreaSelected,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: TSizes.v12),
                SizedBox(
                  height: TSizes.v220,
                  child: controller.isLoadingAreas.value &&
                          controller.areas.isEmpty
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : filtered.isEmpty
                          ? ListView(
                              children: [
                                if (controller.isOnline.value)
                                  ListTile(
                                    leading: const Icon(
                                      Icons.add_circle,
                                      color: TColors.materialGreen,
                                    ),
                                    title: Text(
                                      'Create "${searchController.text.trim()}"',
                                    ),
                                    subtitle: const Text(
                                      TTexts.uiTextAreaNotFound,
                                    ),
                                    onTap: () {
                                      _showAddAreaDialog(
                                        context,
                                        controller,
                                        prefilledAreaName:
                                            searchController.text.trim(),
                                      );
                                    },
                                  )
                                else
                                  const ListTile(
                                    leading: Icon(Icons.lock_outline),
                                    title: Text(TTexts.uiTextNoCachedAreaFound),
                                    subtitle: Text(
                                      TTexts
                                          .uiTextConnectToTheInternetToCreateANew,
                                    ),
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
                                      ? TColors.primary.withValues(alpha: 0.10)
                                      : TColors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  title: Text(
                                    area['name'],
                                  ),
                                  trailing: selected
                                      ? const Icon(
                                          Icons.check_circle,
                                          color: TColors.materialGreen,
                                        )
                                      : null,
                                  onTap: () {
                                    controller.selectExistingArea(area);
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

  Widget _buildContactInfoCard(OfflineDoctorCreateController controller) {
    return _ModernCard(
      child: Column(
        children: [
          _ModernTextField(
            controller: controller.emailController,
            label: TTexts.uiTextEmailAddress,
            hint: "doctor@hospital.com",
            icon: Icons.email_outlined,
            inputType: TextInputType.emailAddress,
            isRequired: false,
          ),
          const SizedBox(height: TSizes.v16),
          _ModernTextField(
            controller: controller.phoneController,
            label: TTexts.uiTextPhoneNumber,
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

  Widget _buildAddressFieldsCard(
      BuildContext context, OfflineDoctorCreateController controller) {
    return _ModernCard(
      child: Column(
        children: [
          _ModernTextField(
              controller: controller.clinicNameController,
              label: TTexts.uiTextClinicName,
              hint: 'Clinic name',
              icon: Icons.local_hospital_outlined),
          const SizedBox(height: TSizes.v16),
          _ModernTextField(
              controller: controller.locationController,
              label: TTexts.location,
              hint: 'City / locality',
              icon: Icons.location_city,
              isRequired: true),
          const SizedBox(height: TSizes.v16),
          _ModernTextField(
            controller: controller.address1Controller,
            label: TTexts.uiTextAddressLine1RequiredFullAddress,
            hint: "Please fill address in details",
            icon: Icons.place_outlined,
            isRequired: true,
          ),
          const SizedBox(height: TSizes.v16),
          _ModernTextField(
            controller: controller.address2Controller,
            label: TTexts.uiTextAddressLine2,
            hint: "House No, Building",
            icon: Icons.edit_location_alt_outlined,
          ),
          const SizedBox(height: TSizes.v16),
          _ModernTextField(
            controller: controller.landmarkController,
            label: TTexts.uiTextLandmark,
            hint: "Near Indian Oil Petrol Pump.",
            icon: Icons.edit_location_alt_outlined,
          ),
          const SizedBox(height: TSizes.v16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: TSizes.v16),
              Row(
                children: [
                  Expanded(
                    child: _ModernTextField(
                      controller: controller.blockController,
                      label: TTexts.uiTextBlock,
                      isReadOnly: false,
                    ),
                  ),
                  const SizedBox(width: TSizes.v12),
                  Expanded(
                    child: _ModernTextField(
                      controller: controller.districtController,
                      label: TTexts.uiTextDistrict,
                      isReadOnly: false,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: TSizes.v16),
              _ModernTextField(
                controller: controller.divisionController,
                label: TTexts.uiTextDivision,
                isReadOnly: false,
              ),
              Row(
                children: [
                  Expanded(
                    child: _ModernTextField(
                      controller: controller.stateController,
                      label: TTexts.uiTextState,
                      hint: "State",
                      isReadOnly: false,
                    ),
                  ),
                  const SizedBox(width: TSizes.v12),
                  Expanded(
                    child: _ModernTextField(
                      controller: controller.pincodeController,
                      label: TTexts.uiTextPincode,
                      hint: "XXXXXX",
                      isNumber: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: TSizes.v6),
              _buildAreaSelector(context, controller),
              const SizedBox(height: TSizes.v16),
              InkWell(
                onTap: controller.showPincodeDialog,
                child: const Row(
                  children: [
                    Icon(
                      Icons.edit_location_alt,
                      size: TSizes.v14,
                      color: TColors.materialBlue,
                    ),
                    SizedBox(width: TSizes.v4),
                    Expanded(
                      child: Text(
                        TTexts.uiTextLookUpAddressFromPincodeOnline,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: TColors.materialBlue,
                          fontSize: TSizes.v12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: TSizes.v16),
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
                    labelText: TTexts.uiTextPostOffice,
                    filled: true,
                    fillColor: TColors.hex_FFFAFAFA,
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
              )),
              const SizedBox(width: TSizes.v12),
              Expanded(
                child: _ModernTextField(
                  controller: controller.countryController,
                  label: TTexts.uiTextCountry,
                  hint: "Country",
                  isReadOnly: false,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(
      OfflineDoctorCreateController controller, BuildContext context) {
    return Container(
      width: double.infinity,
      height: TSizes.v55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: TColors.primary.withValues(alpha: 0.3),
              blurRadius: TSizes.v15,
              offset: const Offset(0, 8)),
        ],
      ),
      child: ElevatedButton(
        // Pass context to submit
        onPressed:
            controller.saving.value ? null : () => controller.submit(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: TColors.primary,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: TSizes.v0,
        ),
        child: Text(
          controller.saving.value ? 'SAVING…' : "COMPLETE REGISTRATION",
          style: const TextStyle(
              color: TColors.white,
              fontSize: TSizes.v15,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0),
        ),
      ),
    );
  }

  Future<void> _showAddAreaDialog(
    BuildContext context,
    OfflineDoctorCreateController controller, {
    String? prefilledAreaName,
  }) async {
    if (!await controller.ensureOnlineForAreaCreation() || !context.mounted) {
      return;
    }

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
      backgroundColor: TColors.transparent,
      builder: (_) {
        return AnimatedPadding(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            constraints: const BoxConstraints(
              maxWidth: TSizes.v700,
            ),
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: TColors.white,
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
                            color: TColors.primary.withValues(alpha: .1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.location_city,
                            color: TColors.primary,
                          ),
                        ),
                        const SizedBox(width: TSizes.v12),
                        const Expanded(
                          child: Text(
                            TTexts.uiTextCreateNewArea,
                            style: TextStyle(
                              fontSize: TSizes.v18,
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
                    const SizedBox(height: TSizes.v24),
                    _ModernTextField(
                      controller: areaController,
                      label: TTexts.uiTextAreaName,
                      hint: "Enter Area Name",
                      icon: Icons.location_city_outlined,
                      isRequired: true,
                    ),
                    const SizedBox(height: TSizes.v16),
                    Row(
                      children: [
                        Expanded(
                          child: _ModernTextField(
                            controller: pincodeController,
                            label: TTexts.uiTextPincode,
                            hint: "110001",
                            icon: Icons.pin_drop_outlined,
                            isRequired: true,
                            isReadOnly:
                                controller.pincodeController.text.isNotEmpty,
                          ),
                        ),
                        const SizedBox(width: TSizes.v12),
                        Expanded(
                          child: _ModernTextField(
                            controller: postOfficeController,
                            label: TTexts.uiTextPostOffice,
                            hint: "Connaught Place",
                            icon: Icons.local_post_office_outlined,
                            isRequired: true,
                            isReadOnly:
                                controller.postOfficeController.text.isNotEmpty,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: TSizes.v28),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Get.back(),
                            child: const Text(TTexts.cancel),
                          ),
                        ),
                        const SizedBox(width: TSizes.v12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.add),
                            label: const Text(TTexts.uiTextCreateArea),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: TColors.primary,
                              foregroundColor: TColors.white,
                              minimumSize: const Size(
                                double.infinity,
                                52,
                              ),
                            ),
                            onPressed: () async {
                              if (controller.selectedHeadOfficeId.value ==
                                  null) {
                                Get.snackbar(
                                  "Required",
                                  TTexts.uiTextPleaseSelectHeadOfficeFirst,
                                );
                                return;
                              }

                              final created = await controller.createArea(
                                name: areaController.text.trim(),
                                pincode: pincodeController.text.trim(),
                                postOffice: postOfficeController.text.trim(),
                              );

                              if (!created) return;

                              if (context.mounted) {
                                Navigator.pop(context);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: TSizes.v12),
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
          color: selected ? color.withValues(alpha: .12) : TColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? color : TColors.materialGrey300,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            CircleAvatar(
              radius: TSizes.v16,
              backgroundColor: color,
              child: Text(
                label,
                style: const TextStyle(
                  color: TColors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: TSizes.v8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: selected ? color : TColors.black87,
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
          color: selected ? color.withValues(alpha: .12) : TColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? color : TColors.materialGrey300,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: TSizes.v28,
              color: selected ? color : TColors.materialGrey,
            ),
            const SizedBox(height: TSizes.v8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: selected ? color : TColors.black87,
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
        color: TColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: TColors.materialGrey.withValues(alpha: 0.06),
              blurRadius: TSizes.v20,
              offset: const Offset(0, 5)),
          BoxShadow(
              color: TColors.materialGrey.withValues(alpha: 0.02),
              blurRadius: TSizes.v2,
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
  final TextInputType? inputType;
  final bool isRequired;
  final String? prefixText;

  const _ModernTextField({
    required this.label,
    required this.controller,
    this.hint,
    this.icon,
    this.isNumber = false,
    this.isReadOnly = false,
    this.onTap,
    this.inputType,
    this.isRequired = false,
    this.prefixText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: TSizes.v13,
                  fontWeight: FontWeight.w600,
                  color: TColors.hex_FF636E72,
                ),
              ),
            ),
            if (isRequired)
              const Text(TTexts.uiTextValue,
                  style: TextStyle(
                      color: TColors.materialRed, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: TSizes.v8),
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
              fontSize: TSizes.v14,
              color: TColors.hex_FF2D3436),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: TColors.materialGrey400,
              fontSize: TSizes.v13,
            ),
            prefixText: prefixText != null ? '$prefixText ' : null,
            prefixStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              color: TColors.black87,
              fontSize: TSizes.v14,
            ),
            prefixIcon: icon != null
                ? Icon(
                    icon,
                    color: TColors.primary.withValues(alpha: 0.8),
                    size: TSizes.v18,
                  )
                : null,
            filled: true,
            fillColor: TColors.hex_FFFAFAFA,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: TColors.materialGrey200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: TColors.materialGrey200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: TColors.primary,
                width: TSizes.v1_5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
