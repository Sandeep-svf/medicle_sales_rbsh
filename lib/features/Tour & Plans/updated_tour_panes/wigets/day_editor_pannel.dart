import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../utils/constants/colors.dart';
import '../DayType.dart';
import '../controller/tour_plan_controller.dart';
import '../model/TourDay.dart';

class DayEditorPanel extends StatefulWidget {
  final TourDay day;
  final VoidCallback onClose;
  final Function(TourDay) onDayUpdated;

  const DayEditorPanel({
    super.key,
    required this.day,
    required this.onClose,
    required this.onDayUpdated,
  });

  @override
  State<DayEditorPanel> createState() => _DayEditorPanelState();
}

class _DayEditorPanelState extends State<DayEditorPanel> {
  final TourPlanController controller = Get.find<TourPlanController>();
  late DayType selectedType;
  String? selectedBeatId;
  String? selectedUserId;
  late TextEditingController notesController;

  @override
  void initState() {
    super.initState();
    _resetFormState();
  }

  String _mapDayTypeToApi(DayType type) {
    switch (type) {
      case DayType.field:
        return "Field";

      case DayType.jointWork:
        return "Joint work";

      case DayType.meeting:
        return "Meeting";

      case DayType.office:
        return "Office";

      case DayType.transit:
        return "Transit";

      case DayType.leave:
        return "Leave";

      case DayType.holiday:
        return "Holiday";

      case DayType.unassigned:
        return "";
    }
  }

  @override
  void didUpdateWidget(covariant DayEditorPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.day.date != widget.day.date || oldWidget.day.type != widget.day.type) {
      _resetFormState();
    }
  }

  void _resetFormState() {
    if (widget.day.type == DayType.unassigned ||
        widget.day.type == DayType.holiday) {
      selectedType = DayType.field;
    } else {
      selectedType = widget.day.type;
    }
    selectedBeatId = widget.day.beatId;
    selectedUserId = widget.day.jointWorkUserId;
    notesController = TextEditingController(text: widget.day.notes ?? '');
  }

  @override
  void dispose() {
    notesController.dispose();
    super.dispose();
  }

  void _dispatchChanges() {

    //------------------------------------------------------------
    // Validation - Field
    //------------------------------------------------------------

    if (selectedType == DayType.field &&
        (selectedBeatId == null || selectedBeatId!.isEmpty)) {
      Get.snackbar(
        "Validation",
        "Please select a Beat.",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    //------------------------------------------------------------
    // Validation - Joint Work
    //------------------------------------------------------------

    if (selectedType == DayType.jointWork) {

      if (selectedBeatId == null || selectedBeatId!.isEmpty) {
        Get.snackbar(
          "Validation",
          "Please select a Beat.",
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      if (selectedUserId == null || selectedUserId!.isEmpty) {
        Get.snackbar(
          "Validation",
          "Please select Joint Work User.",
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
    }

    //------------------------------------------------------------
    // Validation - Remarks Required
    //------------------------------------------------------------

    if ((selectedType == DayType.meeting ||
        selectedType == DayType.office ||
        selectedType == DayType.transit ||
        selectedType == DayType.leave) &&
        notesController.text.trim().isEmpty) {

      Get.snackbar(
        "Validation",
        "Remarks are required.",
        snackPosition: SnackPosition.BOTTOM,
      );

      return;
    }

    //------------------------------------------------------------
    // Existing Logic (UNCHANGED)
    //------------------------------------------------------------

    final matchedBeat = controller.beats.firstWhereOrNull(
          (b) => b.id == selectedBeatId,
    );

    final matchedUser = controller.availableUsers.firstWhereOrNull(
          (u) => u.id == selectedUserId,
    );

    widget.onDayUpdated(
      widget.day.copyWith(
        type: selectedType,

        apiDayType: _mapDayTypeToApi(selectedType),

        beatId: (selectedType == DayType.field ||
            selectedType == DayType.jointWork)
            ? selectedBeatId
            : null,

        beatName: (selectedType == DayType.field ||
            selectedType == DayType.jointWork)
            ? matchedBeat?.name
            : null,

        jointWorkUserId:
        selectedType == DayType.jointWork
            ? selectedUserId
            : null,

        jointWorkUserName:
        selectedType == DayType.jointWork
            ? matchedUser?.name
            : null,

        notes: notesController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.day.type == DayType.holiday) {
      return Container(
        color: TColors.white,
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: TColors.warning.withOpacity(0.1), shape: BoxShape.circle),
              child: const Icon(Icons.lock_outline, size: 40, color: TColors.warning),
            ),
            const SizedBox(height: 20),
            Text(widget.day.holidayName ?? "System Holiday Block", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: TColors.textPrimary)),
            const SizedBox(height: 8),
            const Text("Sundays and national calendar holiday modules are non-editable parameters.", textAlign: TextAlign.center, style: TextStyle(color: TColors.textSecondary, fontSize: 13)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(onPressed: widget.onClose, style: ElevatedButton.styleFrom(backgroundColor: TColors.softGrey, foregroundColor: TColors.textPrimary), child: const Text("Dismiss Panel")),
            )
          ],
        ),
      );
    }

    return Container(
      color: TColors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Day ${widget.day.date.day} Setup", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: TColors.textPrimary)),
                  const Text("Configure operational workspace settings", style: TextStyle(fontSize: 12, color: TColors.textSecondary)),
                ],
              ),
              IconButton(icon: const Icon(Icons.close), style: IconButton.styleFrom(backgroundColor: TColors.softGrey), onPressed: widget.onClose),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(height: 1),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 20),
              children: [
                const Text("SELECT OPERATION TYPE", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: TColors.textSecondary, letterSpacing: 1.2)),
                const SizedBox(height: 12),
                _buildDayTypeList(),

                if (selectedType == DayType.field ||
                    selectedType == DayType.jointWork) ...[
                  const SizedBox(height: 24),
                  const Text("TARGET VISITATION BEAT", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: TColors.textSecondary, letterSpacing: 1.2)),
                  const SizedBox(height: 10),
                  Obx(() => DropdownButtonFormField<String>(
                    value: selectedBeatId,
                    decoration: InputDecoration(fillColor: TColors.light, filled: true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
                    hint: const Text("Select base route assignment"),
                    items: controller.beats.map((b) => DropdownMenuItem(value: b.id, child: Text(b.name, style: const TextStyle(fontWeight: FontWeight.w600)))).toList(),
                    onChanged: (val) => setState(() => selectedBeatId = val),
                  )),
                ],

                if (selectedType == DayType.jointWork) ...[
                  const SizedBox(height: 24),
                  const Text("JOINT MANAGEMENT COLLABORATOR", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: TColors.textSecondary, letterSpacing: 1.2)),
                  const SizedBox(height: 10),
                  Obx(() => DropdownButtonFormField<String>(
                    value: selectedUserId,
                    decoration: InputDecoration(fillColor: TColors.light, filled: true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
                    hint: const Text("Select available authority configuration"),
                    items: controller.availableUsers.map((u) => DropdownMenuItem(value: u.id, child: Text("${u.name} (${u.role})", style: const TextStyle(fontWeight: FontWeight.w600)))).toList(),
                    onChanged: (val) => setState(() => selectedUserId = val),
                  )),
                ],

                if (selectedType != DayType.field &&
                    selectedType != DayType.jointWork) ...[

                  const SizedBox(height: 24),

                  const Text(
                    "REMARKS",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      color: TColors.textSecondary,
                      letterSpacing: 1.2,
                    ),
                  ),

                  const SizedBox(height: 10),

                  TextFormField(
                    controller: notesController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: "Enter remarks...",
                      filled: true,
                      fillColor: TColors.light,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ]
              ],
            ),
          ),

          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: TColors.primary, foregroundColor: TColors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                onPressed: () {
                  _dispatchChanges(); // 1. Commit values to state
                  widget.onClose();   // 2. FIXED: Auto-closes side panel or bottom panel smoothly
                },
                icon: const Icon(Icons.check_circle_outline, size: 20),
                label: const Text("APPLY CHANGES TO CALENDAR", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 0.5)),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTypeCard(DayType type, String label, IconData icon, Color themeColor) {
    final bool isSelected = selectedType == type;
    return GestureDetector(
      onTap: () async {
        setState(() {
          selectedType = type;

          if (type != DayType.field &&
              type != DayType.jointWork) {
            selectedBeatId = null;
          }

          if (type != DayType.jointWork) {
            selectedUserId = null;
          }
        });
        if (type == DayType.jointWork &&
            controller.availableUsers.isEmpty) {
          await controller.loadAvailableUsers(widget.day.date);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? themeColor.withOpacity(0.08) : TColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? themeColor : TColors.borderSecondary, width: isSelected ? 2 : 1),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? themeColor : TColors.darkGrey, size: 22),
            const SizedBox(width: 14),
            Text(label, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? themeColor : TColors.textPrimary, fontSize: 14)),
            const Spacer(),
            if (isSelected) Icon(Icons.radio_button_checked, color: themeColor, size: 18) else const Icon(Icons.radio_button_off, color: TColors.grey, size: 18)
          ],
        ),
      ),
    );
  }

  Widget _buildDayTypeList() {
    return Obx(() {
      return Column(
        children: controller.dayTypes
            .where((e) =>
        e != "Holiday" &&
            e != "Weekly off")
            .map((type) {

          final dayType = mapApiDayType(type);

          IconData icon;
          Color color;

          switch (dayType) {
            case DayType.field:
              icon = Icons.location_on_outlined;
              color = TColors.primary;
              break;

            case DayType.jointWork:
              icon = Icons.people_outline;
              color = TColors.info;
              break;

            case DayType.meeting:
              icon = Icons.groups_outlined;
              color = TColors.success;
              break;

            case DayType.office:
              icon = Icons.business_center_outlined;
              color = Colors.indigo;
              break;

            case DayType.transit:
              icon = Icons.route_outlined;
              color = Colors.orange;
              break;

            case DayType.leave:
              icon = Icons.event_busy_outlined;
              color = TColors.warning;
              break;

            case DayType.holiday:
            case DayType.unassigned:
              return const SizedBox.shrink();
          }

          return _buildTypeCard(
            dayType,
            type,
            icon,
            color,
          );

        }).toList(),
      );
    });
  }

  
}