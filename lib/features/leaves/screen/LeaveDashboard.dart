import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';

import '../../../utils/constants/colors.dart';
import '../controller/LeaveController.dart';
import '../model/LeaveType.dart';

class LeaveDashboard extends StatelessWidget {
  const LeaveDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LeaveController());

    return Scaffold(
      backgroundColor: TColors.light,

      // Floating Action Button
      floatingActionButton: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: TColors.primary.withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
          borderRadius: BorderRadius.circular(30),
        ),
        child: FloatingActionButton.extended(
          onPressed: () => _showApplyLeaveSheet(context, controller),
          label: const Text("Apply Leave",
              style:
                  TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.5,color: Colors.white)),
          icon: const Icon(Icons.add_circle_outline,color: Colors.white,),
          backgroundColor: TColors.primary,
          elevation: 0,
        ),
      ),

      body: Column(
        children: [
          _buildCustomHeader(controller),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                    child: CircularProgressIndicator(color: TColors.primary));
              }

              return RefreshIndicator(
                color: TColors.primary,
                backgroundColor: TColors.white,
                onRefresh: controller.fetchAllData,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  // Add bottom padding here directly (e.g. 100) to clear the Floating Button
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      _buildSectionTitle("Available Balance"),
                      const SizedBox(height: 15),

                      // Balance List
                      SizedBox(
                        height: 160,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          itemCount: controller.leaveBalances.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 15),
                          itemBuilder: (context, index) {
                            return _buildAnimatedWidget(
                              index: index,
                              child: _buildBalanceCard(
                                  controller.leaveBalances[index]),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 30),

                      // History Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildSectionTitle("Recent History"),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: TColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: TColors.primary.withOpacity(0.2)),
                            ),
                            child: Text(
                              "${controller.leaveHistory.length} Requests",
                              style: const TextStyle(
                                  color: TColors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),

                      // History List
                      if (controller.leaveHistory.isEmpty)
                        _buildEmptyState()
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: controller.leaveHistory.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 15),
                          itemBuilder: (context, index) {
                            return _buildAnimatedWidget(
                              index: index + 4,
                              child: _buildHistoryTile(
                                  controller.leaveHistory[index], controller),
                            );
                          },
                        ),

                      // FIX: Bottom padding to prevent blur/cut-off behind FAB
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // --- 1. Header Widget ---
  Widget _buildCustomHeader(LeaveController controller) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 30),
      decoration: const BoxDecoration(
        color: TColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(35),
          bottomRight: Radius.circular(35),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x40000000),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("My Leaves",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5)),
              SizedBox(height: 6),
              Text("Manage your time off",
                  style: TextStyle(
                      color: Color(0xFFF0F0F0),
                      fontSize: 14,
                      fontWeight: FontWeight.w400)),
            ],
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => controller.fetchAllData(),
              borderRadius: BorderRadius.circular(15),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: const Icon(Icons.refresh_rounded, color: Colors.white),
              ),
            ),
          )
        ],
      ),
    );
  }

  // --- 2. Balance Card ---
  Widget _buildBalanceCard(LeaveBalance balance) {
    return Container(
      width: 165,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: TColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: TColors.grey.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFF9E9E9E).withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                    color: TColors.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12)),
                child: Text(balance.leaveType.code,
                    style: const TextStyle(
                        color: TColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 13)),
              ),
              SizedBox(
                height: 28,
                width: 28,
                child: Stack(
                  children: [
                    CircularProgressIndicator(
                        value: 1.0,
                        color: TColors.grey.withOpacity(0.2),
                        strokeWidth: 3),
                    CircularProgressIndicator(
                        value: (balance.used /
                                (balance.allocated == 0
                                    ? 1
                                    : balance.allocated))
                            .toDouble(),
                        color: TColors.primary,
                        strokeWidth: 3,
                        strokeCap: StrokeCap.round),
                  ],
                ),
              )
            ],
          ),
          const Spacer(),
          Text("${balance.balance}",
              style: const TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  color: TColors.textPrimary,
                  height: 1.0)),
          const SizedBox(height: 5),
          Text(balance.leaveType.name,
              style: const TextStyle(
                  color: TColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  // --- 3. History Tile ---
  // --- 3. History Tile (FIXED) ---
  Widget _buildHistoryTile(LeaveHistory item, LeaveController controller) {
    Color statusColor;
    Color statusBg;

    switch (item.status.toLowerCase()) {
      case 'approved':
        statusColor = const Color(0xFF2E7D32);
        statusBg = const Color(0xFFE8F5E9);
        break;
      case 'rejected':
        statusColor = const Color(0xFFC62828);
        statusBg = const Color(0xFFFFEBEE);
        break;
      case 'cancelled':
        statusColor = Colors.grey.shade700;
        statusBg = Colors.grey.shade200;
        break;
      default:
        statusColor = const Color(0xFFEF6C00);
        statusBg = const Color(0xFFFFF3E0);
    }

    bool isPending = item.status.toLowerCase() == 'pending';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: TColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                  width: 5,
                  height: 50,
                  decoration: BoxDecoration(
                      color: TColors.primary.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(10))),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.leaveType.name,
                        style: const TextStyle(
                            color: TColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.date_range_rounded,
                            size: 14, color: TColors.textSecondary),
                        const SizedBox(width: 5),
                        Text(
                            "${_formatDate(item.startDate)} - ${_formatDate(item.endDate)}",
                            style: const TextStyle(
                                color: TColors.textSecondary,
                                fontSize: 13,
                                fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                    color: statusBg, borderRadius: BorderRadius.circular(12)),
                child: Text(item.status,
                    style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        letterSpacing: 0.3)),
              ),
            ],
          ),
          if (isPending) ...[
            const SizedBox(height: 12),
            Divider(height: 1, color: Colors.grey.withOpacity(0.1)),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  // FIX IS HERE: Use Get.context! instead of context
                  onTap: () => _showCancelDialog(Get.context!, controller, item.id),
                  borderRadius: BorderRadius.circular(8),
                  child: const Padding(
                    padding:
                    EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.cancel_outlined,
                            size: 16, color: TColors.error),
                        SizedBox(width: 6),
                        Text("Cancel Request",
                            style: TextStyle(
                                color: TColors.error,
                                fontWeight: FontWeight.w600,
                                fontSize: 13)),
                      ],
                    ),
                  ),
                ),
              ),
            )
          ]
        ],
      ),
    );
  }

  // --- 4. Apply Leave Bottom Sheet (Fixed Logic & UI) ---
  void _showApplyLeaveSheet(BuildContext context, LeaveController controller) {
    final reasonController = TextEditingController();
    Rx<LeaveType?> selectedType = Rx<LeaveType?>(null);
    Rx<DateTime?> startDate = Rx<DateTime?>(null);
    Rx<DateTime?> endDate = Rx<DateTime?>(null);
    RxBool isHalfDay = false.obs;
    Rx<String?> halfDayType = Rx<String?>(null); // NEW: Enum variable
    RxInt selectedTab = 0.obs;

    controller.calculatedDays.value = "0.0";
    controller.showSandwichNote.value = false;

    void recalculate() {
      controller.calculateDuration(
          startDate.value, endDate.value, isHalfDay.value);
    }

    Future<void> pickDate(bool isStart) async {
      final now = DateTime.now();
      final tomorrow = DateTime(now.year, now.month, now.day + 1);
      final lastDayOfYear = DateTime(now.year, 12, 31);

      DateTime firstDate = tomorrow;
      if (!isStart && startDate.value != null) firstDate = startDate.value!;

      DateTime initialDate = isStart
          ? (startDate.value ?? tomorrow)
          : (endDate.value ?? startDate.value ?? tomorrow);

      if (initialDate.isBefore(firstDate)) initialDate = firstDate;

      final date = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: firstDate,
        lastDate: lastDayOfYear,
        selectableDayPredicate: (DateTime val) {
          return !controller.isDateBlocked(val);
        },
        builder: (context, child) => Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
                primary: TColors.primary,
                onPrimary: Colors.white,
                onSurface: TColors.textPrimary),
          ),
          child: child!,
        ),
      );

      if (date != null) {
        if (isStart) {
          startDate.value = date;
          if (selectedTab.value == 0) {
            endDate.value = date;
          } else {
            if (endDate.value != null && date.isAfter(endDate.value!))
              endDate.value = null;
          }
        } else {
          endDate.value = date;
        }
        recalculate();
      }
    }

    Get.bottomSheet(
      Container(
        constraints: BoxConstraints(maxHeight: Get.height * 0.9),
        decoration: const BoxDecoration(
            color: TColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10))),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("New Request",
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: TColors.textPrimary)),
                    const SizedBox(height: 20),

                    // --- SUMMARY CARD + SANDWICH NOTE ---
                    Obx(() => Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: TColors.primary.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: TColors.primary.withOpacity(0.2)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: const BoxDecoration(
                                    color: TColors.white,
                                    shape: BoxShape.circle),
                                child: const Icon(Icons.calendar_month_outlined,
                                    color: TColors.primary),
                              ),
                              const SizedBox(width: 15),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("Total Leave Days",
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: TColors.textSecondary)),
                                  Text(
                                      "${controller.calculatedDays.value} Days",
                                      style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: TColors.textPrimary)),
                                ],
                              )
                            ],
                          ),
                        ),
                        if (controller.showSandwichNote.value)
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.orange.withOpacity(0.3)),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.info_outline, color: Colors.orange, size: 20),
                                  SizedBox(width: 10),
                                  Expanded(child: Text("Sandwich rule: Holidays/Sundays between leave dates are counted as leave.", style: TextStyle(color: Colors.orange, fontSize: 11, fontWeight: FontWeight.bold))),
                                ],
                              ),
                            ),
                          ),
                      ],
                    )),
                    const SizedBox(height: 25),

                    // --- TAB SWITCHER ---
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                          color: TColors.light,
                          borderRadius: BorderRadius.circular(12)),
                      child: Obx(() => Row(
                        children: [
                          _buildTab("One Day", 0, selectedTab, () {
                            selectedTab.value = 0;
                            endDate.value = startDate.value;
                            recalculate();
                          }),
                          _buildTab("Multiple Days", 1, selectedTab, () {
                            selectedTab.value = 1;
                            endDate.value = null;
                            recalculate();
                          }),
                        ],
                      )),
                    ),
                    const SizedBox(height: 25),

                    _buildLabel("Leave Type"),
                    DropdownButtonFormField<LeaveType>(
                      decoration: _inputDecoration(
                          "Select Type", Icons.category_outlined),
                      icon: const Icon(Icons.keyboard_arrow_down,
                          color: TColors.primary),
                      items: controller.leaveTypes
                          .map((type) => DropdownMenuItem(
                          value: type, child: Text(type.name)))
                          .toList(),
                      onChanged: (val) => selectedType.value = val,
                    ),
                    const SizedBox(height: 20),

                    // --- DATE PICKERS ---
                    Obx(() => Row(
                      children: [
                        Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel("Start Date"),
                                InkWell(
                                  onTap: () => pickDate(true),
                                  child: InputDecorator(
                                      decoration: _inputDecoration(
                                          "Select", Icons.calendar_today),
                                      child: Text(
                                          startDate.value != null
                                              ? DateFormat('dd MMM')
                                              .format(startDate.value!)
                                              : "Select",
                                          style: TextStyle(
                                              color: startDate.value != null
                                                  ? TColors.textPrimary
                                                  : TColors.textSecondary,
                                              fontWeight:
                                              FontWeight.w600))),
                                ),
                              ]),
                        ),
                        if (selectedTab.value == 1) ...[
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  _buildLabel("End Date"),
                                  InkWell(
                                    onTap: startDate.value == null
                                        ? null
                                        : () => pickDate(false),
                                    child: Opacity(
                                      opacity: startDate.value == null
                                          ? 0.5
                                          : 1.0,
                                      child: InputDecorator(
                                          decoration: _inputDecoration(
                                              "Select", Icons.event),
                                          child: Text(
                                              endDate.value != null
                                                  ? DateFormat('dd MMM')
                                                  .format(
                                                  endDate.value!)
                                                  : "Select",
                                              style: TextStyle(
                                                  color: endDate.value !=
                                                      null
                                                      ? TColors.textPrimary
                                                      : TColors
                                                      .textSecondary,
                                                  fontWeight:
                                                  FontWeight.w600))),
                                    ),
                                  ),
                                ]),
                          ),
                        ]
                      ],
                    )),
                    const SizedBox(height: 20),

                    _buildLabel("Reason"),
                    TextField(
                        controller: reasonController,
                        maxLines: 2,
                        decoration: _inputDecoration(
                            "Briefly explain...", Icons.edit_note)),
                    const SizedBox(height: 20),

                    // --- HALF DAY SECTION ---
                    Obx(() {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                                color: isHalfDay.value
                                    ? TColors.primary.withOpacity(0.05)
                                    : TColors.light,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                    color: isHalfDay.value
                                        ? TColors.primary
                                        : Colors.transparent)),
                            child: SwitchListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 0),
                              activeColor: TColors.primary,
                              title: const Text("Apply for Half Day",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700, fontSize: 15)),
                              value: isHalfDay.value,
                              onChanged: (val) {
                                isHalfDay.value = val;
                                if(!val) halfDayType.value = null;
                                recalculate();
                              },
                            ),
                          ),
                          if (isHalfDay.value) ...[
                            const SizedBox(height: 15),
                            _buildLabel("Half Day Session"),
                            DropdownButtonFormField<String>(
                              value: halfDayType.value,
                              decoration: _inputDecoration("Select Session", Icons.access_time_rounded),
                              items: ['First Half', 'Second Half']
                                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                                  .toList(),
                              onChanged: (val) => halfDayType.value = val,
                            ),
                          ]
                        ],
                      );
                    }),
                    const SizedBox(height: 30),

                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: Obx(() => ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: TColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 8,
                          shadowColor: TColors.primary.withOpacity(0.4),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18)),
                        ),
                        onPressed: controller.isSubmitting.value
                            ? null
                            : () {
                          if (selectedType.value == null ||
                              startDate.value == null ||
                              endDate.value == null) {
                            Get.snackbar(
                                "Required", "Please fill all fields",
                                backgroundColor:
                                TColors.error.withOpacity(0.1),
                                colorText: TColors.error);
                            return;
                          }
                          if (isHalfDay.value && halfDayType.value == null) {
                            Get.snackbar("Required", "Please select First or Second half session",
                                backgroundColor: TColors.error.withOpacity(0.1),
                                colorText: TColors.error);
                            return;
                          }

                          controller.applyLeave(
                            leaveTypeId: selectedType.value!.id,
                            startDate: DateFormat('yyyy-MM-dd')
                                .format(startDate.value!),
                            endDate: DateFormat('yyyy-MM-dd')
                                .format(endDate.value!),
                            reason: reasonController.text,
                            isHalfDay: isHalfDay.value,
                            halfDayType: halfDayType.value,
                          );
                        },
                        child: controller.isSubmitting.value
                            ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2.5))
                            : const Text("Submit Request",
                            style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold)),
                      )),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  // --- Helpers ---
  Widget _buildTab(
      String title, int index, RxInt selectedTab, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color:
                selectedTab.value == index ? TColors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: selectedTab.value == index
                ? [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.05), blurRadius: 4)
                  ]
                : [],
          ),
          alignment: Alignment.center,
          child: Text(title,
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: selectedTab.value == index
                      ? TColors.primary
                      : TColors.textSecondary)),
        ),
      ),
    );
  }



  void _showCancelDialog(BuildContext context, LeaveController controller, String leaveId) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.warning, // Shows a nice animated warning icon
      animType: AnimType.bottomSlide, // Slides in from bottom
      title: 'Cancel Request?',
      desc: 'Are you sure you want to cancel this leave application? This action cannot be undone.',
      btnCancelOnPress: () {}, // Auto-closes
      btnOkOnPress: () {
        controller.cancelLeave(leaveId);
      },
      btnOkText: 'Yes, Cancel',
      btnCancelText: 'Keep it',
      btnOkColor: TColors.error, // Red button for destructive action
      btnCancelColor: Colors.grey,
      buttonsTextStyle: const TextStyle(fontWeight: FontWeight.bold),
      descTextStyle: const TextStyle(color: TColors.textSecondary, fontSize: 14),
      titleTextStyle: const TextStyle(
          color: TColors.textPrimary,
          fontWeight: FontWeight.bold,
          fontSize: 20
      ),
    ).show();
  }

  Widget _buildSectionTitle(String title) => Text(title,
      style: const TextStyle(
          fontSize: 19,
          fontWeight: FontWeight.w800,
          color: TColors.textPrimary,
          letterSpacing: 0.3));

  Widget _buildLabel(String label) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(label,
          style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: TColors.textSecondary)));

  Widget _buildEmptyState() => Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 20),
      decoration: BoxDecoration(
          color: TColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: TColors.grey.withOpacity(0.3))),
      child: Column(children: [
        Icon(Icons.event_note_rounded,
            size: 60, color: TColors.primary.withOpacity(0.3)),
        const SizedBox(height: 15),
        const Text("No leaves found",
            style: TextStyle(
                color: TColors.textSecondary,
                fontSize: 16,
                fontWeight: FontWeight.w500))
      ]));

  // --- FIX: Updated Animation Logic ---
  Widget _buildAnimatedWidget({required int index, required Widget child}) {
    // 1. Cap the index to prevent "fade out" bug on long lists
    // Items after the 6th one will animate together, ensuring they are fully visible
    int effectiveIndex = index > 6 ? 6 : index;

    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      builder: (context, double value, _) {
        // 2. Optimized math to ensure final opacity is always 1.0
        double delayedValue = (value * 2.5) - (effectiveIndex * 0.2);
        delayedValue = delayedValue.clamp(0.0, 1.0);

        return Transform.translate(
          offset: Offset(0, 30 * (1 - delayedValue)),
          child: Opacity(
            opacity: delayedValue,
            child: child,
          ),
        );
      },
    );
  }

  InputDecoration _inputDecoration(String hint, IconData prefixIcon) {
    return InputDecoration(
        prefixIcon:
            Icon(prefixIcon, color: TColors.primary.withOpacity(0.6), size: 22),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
        filled: true,
        fillColor: TColors.light,
        contentPadding: const EdgeInsets.all(18),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: TColors.primary, width: 1.5)));
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd MMM').format(date);
    } catch (e) {
      return dateStr;
    }
  }
}
