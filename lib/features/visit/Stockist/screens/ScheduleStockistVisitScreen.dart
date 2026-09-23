import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:medicle_sales_rbsh/utils/constants/colors.dart';
import 'package:medicle_sales_rbsh/utils/local_storage/auth_manager.dart';
import '../../../addStokist/controllers/StokistListController.dart';
import '../controllers/ScheduleVisitcontroller.dart';
import 'package:medicle_sales_rbsh/utils/constants/text_strings.dart';
import 'package:medicle_sales_rbsh/utils/constants/sizes.dart';

// Imports

class ScheduleStockistVisitScreen extends StatefulWidget {
  const ScheduleStockistVisitScreen({super.key});

  @override
  State<ScheduleStockistVisitScreen> createState() =>
      _ScheduleStockistVisitScreenState();
}

class _ScheduleStockistVisitScreenState
    extends State<ScheduleStockistVisitScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  // Controller
  final StokistListController _stokistListController =
      Get.find<StokistListController>();
  final AuthManager _authManager = AuthManager();

  String? _selectedStockistId;
  String? _selectedStockistName;
  bool _isSubmitting = false;

  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _dateController.text = DateFormat('dd-MM-yyyy').format(DateTime.now());

    // Ensure data is loaded
    if (_stokistListController.stokistList.isEmpty) {
      _stokistListController.fetchStokist();
    }

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  // --- SEARCH SHEET ---
  void _openStockistSearchSheet() {
    _stokistListController.filterStockists("");

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: TColors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: TColors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 12),
                    width: TSizes.v40,
                    height: TSizes.v4,
                    decoration: BoxDecoration(
                        color: TColors.materialGrey300,
                        borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Text(TTexts.uiTextSelectStockist,
                      style: TextStyle(
                          fontSize: TSizes.v18,
                          fontWeight: FontWeight.bold,
                          color: TColors.materialGrey800)),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: TTexts.uiTextSearchStockist_3d14d4b6,
                      prefixIcon:
                          const Icon(Icons.search, color: TColors.primary),
                      filled: true,
                      fillColor: TColors.materialGrey100,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 0, horizontal: 16),
                    ),
                    onChanged: (val) {
                      _stokistListController.filterStockists(val);
                    },
                  ),
                ),
                const SizedBox(height: TSizes.v10),
                Expanded(
                  child: Obx(() {
                    var list = _stokistListController.filteredStokistList;
                    if (list.isEmpty)
                      return const Center(
                          child: Text(TTexts.uiTextNoStockistsFound_68e438d3));

                    return ListView.separated(
                      controller: scrollController,
                      itemCount: list.length,
                      separatorBuilder: (_, __) =>
                          const Divider(height: TSizes.v1, indent: 70),
                      itemBuilder: (context, index) {
                        final stockist = list[index];
                        final isSelected = stockist.id == _selectedStockistId;
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 8),
                          leading: CircleAvatar(
                            backgroundColor: TColors.primary.withOpacity(0.1),
                            child: Text(
                                (stockist.firmName != null &&
                                        stockist.firmName!.isNotEmpty)
                                    ? stockist.firmName![0].toUpperCase()
                                    : "S",
                                style: const TextStyle(
                                    color: TColors.primary,
                                    fontWeight: FontWeight.bold)),
                          ),
                          title: Text(stockist.firmName ?? "Unknown",
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? TColors.primary
                                      : TColors.black87)),
                          subtitle: Text(
                              "ID: ${stockist.id?.substring(0, 8)}...",
                              style: TextStyle(
                                  color: TColors.materialGrey500,
                                  fontSize: TSizes.v12)),
                          trailing: isSelected
                              ? const Icon(Icons.check_circle,
                                  color: TColors.primary)
                              : null,
                          onTap: () {
                            setState(() {
                              _selectedStockistName = stockist.firmName;
                              _selectedStockistId = stockist.id;
                            });
                            Navigator.pop(context);
                          },
                        );
                      },
                    );
                  }),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
                primary: TColors.primary,
                onPrimary: TColors.white,
                onSurface: TColors.pureBlack),
            dialogBackgroundColor: TColors.white,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dateController.text = DateFormat('dd-MM-yyyy').format(picked);
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedStockistId == null) {
        Get.snackbar("Required", TTexts.uiTextPleaseSelectAStockist,
            backgroundColor: TColors.materialOrange.withOpacity(0.1),
            colorText: TColors.materialOrange);
        return;
      }

      setState(() => _isSubmitting = true);

      try {
        await StockistVisitController.createDoctorVisit(
          doctorId: _selectedStockistId,
          date: _dateController.text,
          notes: _notesController.text,
          context: context,
          authManager: _authManager,
        );

        if (mounted) {
          Navigator.pop(context, true);
        }
      } catch (e) {
        Get.snackbar("Error", "Failed: $e",
            backgroundColor: TColors.materialRed.withOpacity(0.1),
            colorText: TColors.materialRed);
      } finally {
        if (mounted) setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColors.hex_FFF5F7FA,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: TColors.transparent,
        elevation: TSizes.v0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: TColors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: LayoutBuilder(builder: (context, constraints) {
          return MediaQuery.of(context).size.width < 600
              ? const Text(TTexts.uiTextNewStockistVisit,
                  style: TextStyle(
                      color: TColors.white, fontWeight: FontWeight.w600))
              : const SizedBox.shrink();
        }),
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 800) {
            return _buildTabletLayout(constraints);
          } else {
            return _buildMobileLayout(constraints);
          }
        },
      ),
    );
  }

  Widget _buildMobileLayout(BoxConstraints constraints) {
    final size = MediaQuery.of(context).size;
    final headerHeight = size.height * 0.35;
    return SizedBox(
      height: size.height,
      child: Stack(
        children: [
          Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: headerHeight,
              child: _buildGradientBanner(isMobile: true)),
          Positioned(
            top: headerHeight - 40,
            left: 0,
            right: 0,
            bottom: 0,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: TSizes.v10),
                    _buildFormContent(),
                    const SizedBox(height: TSizes.v120),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
              bottom: 24, left: 24, right: 24, child: _buildSubmitButton()),
        ],
      ),
    );
  }

  Widget _buildTabletLayout(BoxConstraints constraints) {
    return Row(
      children: [
        Expanded(flex: 4, child: _buildGradientBanner(isMobile: false)),
        Expanded(
          flex: 6,
          child: Container(
            color: TColors.hex_FFF5F7FA,
            child: SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: TSizes.v40),
                  Expanded(
                    child: Center(
                      child: Container(
                        constraints:
                            const BoxConstraints(maxWidth: TSizes.v500),
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(32),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(TTexts.uiTextVisitDetails,
                                    style: TextStyle(
                                        fontSize: TSizes.v28,
                                        fontWeight: FontWeight.bold,
                                        color: TColors.materialGrey800)),
                                const SizedBox(height: TSizes.v32),
                                _buildFormContent(),
                                const SizedBox(height: TSizes.v40),
                                _buildSubmitButton(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGradientBanner({required bool isMobile}) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [TColors.primary, TColors.hex_FF4B68FF]),
        borderRadius: isMobile
            ? const BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32))
            : BorderRadius.zero,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!isMobile) ...[
                const Icon(Icons.inventory_2_outlined,
                    size: TSizes.v60, color: TColors.white24),
                const SizedBox(height: TSizes.v32)
              ],
              const Text(TTexts.scheduleVisit,
                  style: TextStyle(
                      color: TColors.white,
                      fontSize: TSizes.v32,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: TSizes.v8),
              Text(TTexts.uiTextPlanYourStockistInteraction,
                  style: TextStyle(
                      color: TColors.white.withOpacity(0.9),
                      fontSize: TSizes.v16)),
              if (isMobile) const SizedBox(height: TSizes.v60),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormContent() {
    return Column(
      children: [
        _AnimatedEntry(
          controller: _animController,
          index: 1,
          child: GestureDetector(
            onTap: _openStockistSearchSheet,
            child: _buildInputCard(
              title: TTexts.uiTextSelectStockist,
              icon: Icons.storefront_rounded,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                        _selectedStockistName ?? "Tap to search stockist...",
                        style: TextStyle(
                            fontSize: TSizes.v16,
                            fontWeight: _selectedStockistName != null
                                ? FontWeight.w600
                                : FontWeight.normal,
                            color: _selectedStockistName != null
                                ? TColors.black87
                                : TColors.materialGrey500),
                        overflow: TextOverflow.ellipsis),
                  ),
                  const Icon(Icons.keyboard_arrow_down_rounded,
                      color: TColors.primary),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: TSizes.v16),
        _AnimatedEntry(
          controller: _animController,
          index: 2,
          child: GestureDetector(
            onTap: _pickDate,
            child: _buildInputCard(
              title: TTexts.date,
              icon: Icons.calendar_today,
              child: Row(
                children: [
                  Text(_dateController.text,
                      style: TextStyle(
                          fontSize: TSizes.v16,
                          fontWeight: FontWeight.bold,
                          color: TColors.materialGrey800)),
                  const Spacer(),
                  const Icon(Icons.edit_calendar,
                      color: TColors.primary, size: TSizes.v20)
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: TSizes.v16),
        _AnimatedEntry(
          controller: _animController,
          index: 3,
          child: _buildInputCard(
            title: TTexts.notes,
            icon: Icons.note_alt,
            child: TextFormField(
              controller: _notesController,
              maxLines: 4,
              decoration: InputDecoration(
                  hintText: TTexts.uiTextEnterVisitNotes,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero),
              validator: (v) => v!.isEmpty ? "Notes required" : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return _AnimatedEntry(
      controller: _animController,
      index: 4,
      child: Container(
        decoration:
            BoxDecoration(borderRadius: BorderRadius.circular(16), boxShadow: [
          BoxShadow(
              color: TColors.primary.withOpacity(0.4),
              blurRadius: TSizes.v20,
              offset: const Offset(0, 10))
        ]),
        child: ElevatedButton(
          onPressed: _isSubmitting ? null : _submitForm,
          style: ElevatedButton.styleFrom(
              backgroundColor: TColors.primary,
              foregroundColor: TColors.white,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16))),
          child: _isSubmitting
              ? const SizedBox(
                  height: TSizes.v24,
                  width: TSizes.v24,
                  child: CircularProgressIndicator(color: TColors.white))
              : const Text(TTexts.uiTextConfirmSchedule,
                  style: TextStyle(
                      fontSize: TSizes.v16, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildDecorativeCircle(double size) {
    return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
            shape: BoxShape.circle, color: TColors.white.withOpacity(0.08)));
  }

  Widget _buildInputCard(
      {required String title, required IconData icon, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: TColors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: TColors.materialGrey.withOpacity(0.06),
                blurRadius: TSizes.v15,
                offset: const Offset(0, 5))
          ]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, size: TSizes.v18, color: TColors.primary),
          const SizedBox(width: TSizes.v8),
          Text(title.toUpperCase(),
              style: const TextStyle(
                  fontSize: TSizes.v12,
                  fontWeight: FontWeight.bold,
                  color: TColors.materialGrey))
        ]),
        const SizedBox(height: TSizes.v12),
        child
      ]),
    );
  }
}

class _AnimatedEntry extends StatelessWidget {
  final AnimationController controller;
  final int index;
  final Widget child;
  const _AnimatedEntry(
      {required this.controller, required this.index, required this.child});
  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
          .animate(CurvedAnimation(
              parent: controller,
              curve: Interval(index * 0.1, 1.0, curve: Curves.easeOutCubic))),
      child: FadeTransition(
          opacity: Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
              parent: controller,
              curve: Interval(index * 0.1, 1.0, curve: Curves.easeOut))),
          child: child),
    );
  }
}
