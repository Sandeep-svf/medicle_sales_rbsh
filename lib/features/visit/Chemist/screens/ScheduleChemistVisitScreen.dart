import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:medicle_sales_rbsh/utils/constants/colors.dart';
import 'package:medicle_sales_rbsh/utils/local_storage/auth_manager.dart';

// Adjust imports
import 'package:medicle_sales_rbsh/features/addClinic/controllers/ClinicListController.dart';
import '../controllers/ScheduleVisitcontroller.dart';

class ScheduleChemistVisitScreen extends StatefulWidget {
  const ScheduleChemistVisitScreen({super.key});

  @override
  State<ScheduleChemistVisitScreen> createState() => _ScheduleChemistVisitScreenState();
}

class _ScheduleChemistVisitScreenState extends State<ScheduleChemistVisitScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  // Use ClinicListController for Chemists
  final ClinicListController _clinicListController = Get.find<ClinicListController>();
  final AuthManager _authManager = AuthManager();

  String? _selectedChemistId;
  String? _selectedChemistName;
  bool _isSubmitting = false;

  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _dateController.text = DateFormat('dd-MM-yyyy').format(DateTime.now());

    // Ensure data is loaded
    if (_clinicListController.clinicList.isEmpty) {
      _clinicListController.fetchClinicList();
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
  void _openChemistSearchSheet() {
    _clinicListController.filterClinics(""); // Reset filter

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 12),
                    width: 40, height: 4,
                    decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Text("Select Chemist", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800])),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: "Search chemist name...",
                      prefixIcon: const Icon(Icons.search, color: TColors.primary),
                      filled: true, fillColor: Colors.grey[100],
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    ),
                    onChanged: (val) {
                      _clinicListController.filterClinics(val);
                    },
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: Obx(() {
                    var list = _clinicListController.filteredClinicList;

                    if (list.isEmpty) return const Center(child: Text("No chemists found"));

                    return ListView.separated(
                      controller: scrollController,
                      itemCount: list.length,
                      separatorBuilder: (_, __) => const Divider(height: 1, indent: 70),
                      itemBuilder: (context, index) {
                        final chemist = list[index];
                        final isSelected = chemist.id == _selectedChemistId;
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          leading: CircleAvatar(
                            backgroundColor: TColors.primary.withOpacity(0.1),
                            child: Text(
                                (chemist.firmName != null && chemist.firmName!.isNotEmpty)
                                    ? chemist.firmName![0].toUpperCase()
                                    : "C",
                                style: const TextStyle(color: TColors.primary, fontWeight: FontWeight.bold)
                            ),
                          ),
                          title: Text(chemist.firmName ?? "Unknown", style: TextStyle(fontWeight: FontWeight.w600, color: isSelected ? TColors.primary : Colors.black87)),
                          subtitle: Text("ID: ${chemist.id?.substring(0, 8)}...", style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                          trailing: isSelected ? const Icon(Icons.check_circle, color: TColors.primary) : null,
                          onTap: () {
                            setState(() {
                              _selectedChemistName = chemist.firmName;
                              _selectedChemistId = chemist.id;
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
            colorScheme: const ColorScheme.light(primary: TColors.primary, onPrimary: Colors.white, onSurface: Colors.black),
            dialogBackgroundColor: Colors.white,
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
      if (_selectedChemistId == null) {
        Get.snackbar("Required", "Please select a chemist", backgroundColor: Colors.orange.withOpacity(0.1), colorText: Colors.orange);
        return;
      }

      setState(() => _isSubmitting = true);

      try {
        await StockistVisitController.createDoctorVisit(
          doctorId: _selectedChemistId,
          date: _dateController.text,
          notes: _notesController.text,
          context: context,
          authManager: _authManager,
        );

        if (mounted) {
          Navigator.pop(context, true);
        }
      } catch (e) {
        Get.snackbar("Error", "Failed: $e", backgroundColor: Colors.red.withOpacity(0.1), colorText: Colors.red);
      } finally {
        if (mounted) setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: LayoutBuilder(builder: (context, constraints) {
          return MediaQuery.of(context).size.width < 600
              ? const Text("New Chemist Visit", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600))
              : const SizedBox.shrink();
        }),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
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

  // --- LAYOUTS ---
  Widget _buildMobileLayout(BoxConstraints constraints) {
    final size = MediaQuery.of(context).size;
    final headerHeight = size.height * 0.35;

    return SizedBox(
      height: size.height,
      child: Stack(
        children: [
          Positioned(top: 0, left: 0, right: 0, height: headerHeight, child: _buildGradientBanner(isMobile: true)),
          Positioned(
            top: headerHeight - 40,
            left: 0, right: 0, bottom: 0,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    _buildFormContent(),
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ),
          ),
          Positioned(bottom: 24, left: 24, right: 24, child: _buildSubmitButton()),
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
            color: const Color(0xFFF5F7FA),
            child: SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  Expanded(
                    child: Center(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 500),
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(32),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text("Visit Details", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.grey[800])),
                                const SizedBox(height: 32),
                                _buildFormContent(),
                                const SizedBox(height: 40),
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

  // --- WIDGETS ---
  Widget _buildGradientBanner({required bool isMobile}) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [TColors.primary, Color(0xFF4B68FF)], // Matches Doctor Screen
        ),
        borderRadius: isMobile ? const BorderRadius.only(bottomLeft: Radius.circular(32), bottomRight: Radius.circular(32)) : BorderRadius.zero,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!isMobile) ...[const Icon(Icons.store_mall_directory_outlined, size: 60, color: Colors.white24), const SizedBox(height: 32)],

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                    SizedBox(width: 4),
                    Text("High Priority", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text("Schedule Visit", style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text("Plan your chemist interaction.", style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 16)),
              if(isMobile) const SizedBox(height: 60),
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
            onTap: _openChemistSearchSheet,
            child: _buildInputCard(
              title: "Select Chemist", icon: Icons.store_rounded,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _selectedChemistName ?? "Tap to search chemist...",
                      style: TextStyle(fontSize: 16, fontWeight: _selectedChemistName != null ? FontWeight.w600 : FontWeight.normal, color: _selectedChemistName != null ? Colors.black87 : Colors.grey[500]),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_down_rounded, color: TColors.primary),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _AnimatedEntry(
          controller: _animController, index: 2,
          child: GestureDetector(
            onTap: _pickDate,
            child: _buildInputCard(
              title: "Date", icon: Icons.calendar_today,
              child: Row(
                children: [
                  Text(_dateController.text, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[800])),
                  const Spacer(),
                  const Icon(Icons.edit_calendar, color: TColors.primary, size: 20)
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _AnimatedEntry(
          controller: _animController, index: 3,
          child: _buildInputCard(
            title: "Notes", icon: Icons.note_alt,
            child: TextFormField(
              controller: _notesController,
              maxLines: 4,
              decoration: InputDecoration(hintText: "Enter visit notes...", border: InputBorder.none, contentPadding: EdgeInsets.zero),
              validator: (v) => v!.isEmpty ? "Notes required" : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return _AnimatedEntry(
      controller: _animController, index: 4,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: TColors.primary.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 10)),
          ],
        ),
        child: ElevatedButton(
          onPressed: _isSubmitting ? null : _submitForm,
          style: ElevatedButton.styleFrom(
            backgroundColor: TColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0,
          ),
          child: _isSubmitting
              ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Confirm Schedule", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(width: 8),
              Icon(Icons.check_circle_outline_rounded, size: 20)
            ],
          ),
        ),
      ),
    );
  }

  Widget _decorativeCircle(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.08)),
    );
  }

  Widget _buildInputCard({required String title, required IconData icon, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.06), blurRadius: 15, offset: const Offset(0, 5))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Icon(icon, size: 18, color: TColors.primary), const SizedBox(width: 8), Text(title.toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey))]),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _AnimatedEntry extends StatelessWidget {
  final AnimationController controller;
  final int index;
  final Widget child;
  const _AnimatedEntry({required this.controller, required this.index, required this.child});
  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(CurvedAnimation(parent: controller, curve: Interval(index * 0.1, 1.0, curve: Curves.easeOutCubic))),
      child: FadeTransition(opacity: Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: controller, curve: Interval(index * 0.1, 1.0, curve: Curves.easeOut))), child: child),
    );
  }
}