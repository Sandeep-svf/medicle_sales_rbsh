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
  List<String> selectedUserIds = [];
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
    selectedUserIds = List<String>.from(
      widget.day.jointWorkUserIds,
    );
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

      if (selectedUserIds.isEmpty) {
        Get.snackbar(
          "Validation",
          "Please select at least one Joint Work User.",
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

    final matchedUsers = controller.availableUsers
        .where((u) => selectedUserIds.contains(u.id))
        .toList();

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

        jointWorkUserIds:
        selectedType == DayType.jointWork
            ? List<String>.from(selectedUserIds)
            : const [],

        jointWorkUserNames:
        selectedType == DayType.jointWork
            ? matchedUsers.map((u) => u.name).toList()
            : const [],

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
                  Obx(
                        () {
                      final selectedBeat =
                      controller.beats.firstWhereOrNull(
                            (b) => b.id == selectedBeatId,
                      );

                      return InkWell(
                        onTap: () async {
                          final result =
                          await _showBeatSelectionDialog();

                          if (result != null) {
                            setState(() {
                              selectedBeatId = result;
                            });
                          }
                        },
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: TColors.light,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: selectedBeat != null
                                  ? TColors.primary.withOpacity(0.35)
                                  : TColors.borderSecondary,
                            ),
                          ),
                          child: selectedBeat == null
                              ? const Row(
                            children: [
                              Icon(
                                Icons.alt_route_outlined,
                                color: TColors.textSecondary,
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  "Select base route assignment",
                                  style: TextStyle(
                                    color: TColors.textSecondary,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: TColors.textSecondary,
                              ),
                            ],
                          )
                              : Row(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color:
                                  TColors.primary.withOpacity(0.10),
                                  borderRadius:
                                  BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.alt_route_rounded,
                                  color: TColors.primary,
                                ),
                              ),

                              const SizedBox(width: 12),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      selectedBeat.name,
                                      maxLines: 1,
                                      overflow:
                                      TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: TColors.textPrimary,
                                      ),
                                    ),

                                    const SizedBox(height: 4),

                                    Text(
                                      selectedBeat.areas.isEmpty
                                          ? "No areas assigned"
                                          : "${selectedBeat.areas.length} "
                                          "${selectedBeat.areas.length == 1 ? 'area' : 'areas'} included",
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color:
                                        TColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(width: 8),

                              const Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: TColors.textSecondary,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],

                if (selectedType == DayType.jointWork) ...[
                  const SizedBox(height: 24),
                  const Text("JOINT MANAGEMENT COLLABORATOR", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: TColors.textSecondary, letterSpacing: 1.2)),
                  const SizedBox(height: 10),
                  InkWell(
                    onTap: () async {
                      final result = await _showJointWorkUserDialog();

                      if (result != null) {
                        setState(() {
                          selectedUserIds = result;
                        });
                      }
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: TColors.light,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: selectedUserIds.isEmpty
                                ? const Text(
                              "Select Joint Work users",
                              style: TextStyle(
                                color: TColors.textSecondary,
                              ),
                            )
                                : Text(
                              _selectedUserNames(),
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.keyboard_arrow_down,
                          ),
                        ],
                      ),
                    ),
                  ),
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
            selectedUserIds = [];
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

  String _selectedUserNames() {
    final names = controller.availableUsers
        .where((u) => selectedUserIds.contains(u.id))
        .map((u) => u.name)
        .toList();

    if (names.isEmpty) {
      return "${selectedUserIds.length} user(s) selected";
    }

    return names.join(", ");
  }

  Future<List<String>?> _showJointWorkUserDialog() async {
    final tempSelectedIds = <String>{
      ...selectedUserIds,
    };

    return showDialog<List<String>>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text(
                "Select Joint Work Users",
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: controller.availableUsers.isEmpty
                    ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      "No users available.",
                    ),
                  ),
                )
                    : ListView.builder(
                  shrinkWrap: true,
                  itemCount:
                  controller.availableUsers.length,
                  itemBuilder: (context, index) {
                    final user =
                    controller.availableUsers[index];

                    final isSelected =
                    tempSelectedIds.contains(user.id);

                    return CheckboxListTile(
                      value: isSelected,
                      title: Text(
                        user.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(user.role),
                      onChanged: (checked) {
                        setDialogState(() {
                          if (checked == true) {
                            tempSelectedIds.add(user.id);
                          } else {
                            tempSelectedIds.remove(user.id);
                          }
                        });
                      },
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("CANCEL"),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(
                      context,
                      tempSelectedIds.toList(),
                    );
                  },
                  child: const Text("DONE"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<String?> _showBeatSelectionDialog() async {
    return showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        final screenSize = MediaQuery.of(context).size;

        final dialogWidth = screenSize.width > 900
            ? 760.0
            : screenSize.width * 0.92;

        final dialogHeight = screenSize.height * 0.82;

        return Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 24,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: SizedBox(
            width: dialogWidth,
            height: dialogHeight,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                22,
                20,
                22,
                14,
              ),
              child: Column(
                children: [

                  // ==================================================
                  // HEADER
                  // ==================================================

                  Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: TColors.primary.withOpacity(0.10),
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: const Icon(
                          Icons.alt_route_rounded,
                          color: TColors.primary,
                          size: 25,
                        ),
                      ),

                      const SizedBox(width: 12),

                      const Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Select Beat",
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w700,
                                color: TColors.textPrimary,
                              ),
                            ),

                            SizedBox(height: 4),

                            Text(
                              "Choose a beat to see the areas included in it",
                              style: TextStyle(
                                fontSize: 12,
                                color: TColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),

                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(
                          Icons.close_rounded,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  const Divider(height: 1),

                  const SizedBox(height: 14),

                  // ==================================================
                  // BEAT LIST
                  // ==================================================

                  Expanded(
                    child: controller.beats.isEmpty
                        ? const Center(
                      child: Text(
                        "No beats available.",
                        style: TextStyle(
                          color: TColors.textSecondary,
                        ),
                      ),
                    )
                        : ListView.separated(
                      padding: const EdgeInsets.only(
                        bottom: 8,
                      ),
                      itemCount: controller.beats.length,
                      separatorBuilder: (_, __) =>
                      const SizedBox(height: 10),

                      itemBuilder: (context, index) {
                        final beat =
                        controller.beats[index];

                        final isSelected =
                            beat.id == selectedBeatId;

                        return InkWell(
                          onTap: () {
                            Navigator.pop(
                              context,
                              beat.id,
                            );
                          },

                          borderRadius:
                          BorderRadius.circular(16),

                          child: Container(
                            padding:
                            const EdgeInsets.all(16),

                            decoration: BoxDecoration(
                              color: isSelected
                                  ? TColors.primary
                                  .withOpacity(0.06)
                                  : TColors.light,

                              borderRadius:
                              BorderRadius.circular(16),

                              border: Border.all(
                                color: isSelected
                                    ? TColors.primary
                                    : TColors
                                    .borderSecondary,

                                width:
                                isSelected ? 1.5 : 1,
                              ),
                            ),

                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [

                                // ==================================
                                // BEAT HEADER
                                // ==================================

                                Row(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.center,
                                  children: [

                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration:
                                      BoxDecoration(
                                        color: isSelected
                                            ? TColors
                                            .primary
                                            .withOpacity(
                                          0.12,
                                        )
                                            : TColors.white,

                                        borderRadius:
                                        BorderRadius
                                            .circular(
                                          12,
                                        ),
                                      ),

                                      child: Icon(
                                        Icons
                                            .alt_route_rounded,
                                        color: isSelected
                                            ? TColors
                                            .primary
                                            : TColors
                                            .textSecondary,
                                        size: 22,
                                      ),
                                    ),

                                    const SizedBox(
                                      width: 13,
                                    ),

                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment
                                            .start,
                                        children: [

                                          Text(
                                            beat.name,
                                            maxLines: 1,
                                            overflow:
                                            TextOverflow
                                                .ellipsis,
                                            style:
                                            const TextStyle(
                                              fontSize: 15,
                                              fontWeight:
                                              FontWeight
                                                  .w700,
                                              color: TColors
                                                  .textPrimary,
                                            ),
                                          ),

                                          const SizedBox(
                                            height: 5,
                                          ),

                                          Row(
                                            children: [

                                              const Icon(
                                                Icons
                                                    .location_on_outlined,
                                                size: 14,
                                                color: TColors
                                                    .textSecondary,
                                              ),

                                              const SizedBox(
                                                width: 4,
                                              ),

                                              Text(
                                                beat.areas.isEmpty
                                                    ? "No areas assigned"
                                                    : "${beat.areas.length} "
                                                    "${beat.areas.length == 1 ? 'area' : 'areas'} included",
                                                style:
                                                const TextStyle(
                                                  fontSize: 12,
                                                  color: TColors
                                                      .textSecondary,
                                                  fontWeight:
                                                  FontWeight
                                                      .w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),

                                    if (isSelected)
                                      const Icon(
                                        Icons
                                            .check_circle_rounded,
                                        color:
                                        TColors.primary,
                                        size: 23,
                                      ),
                                  ],
                                ),

                                // ==================================
                                // AREAS
                                // ==================================

                                if (beat.areas.isNotEmpty) ...[
                                  const SizedBox(height: 14),

                                  const Text(
                                    "AREAS INCLUDED",
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.8,
                                      color: TColors.textSecondary,
                                    ),
                                  ),

                                  const SizedBox(height: 8),

                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: _parseBeatColor(beat.color)
                                          .withOpacity(0.05),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: _parseBeatColor(beat.color)
                                            .withOpacity(0.12),
                                      ),
                                    ),
                                    child: Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: beat.areas.map(
                                            (area) {
                                          final areaColor =
                                          _parseBeatColor(beat.color);

                                          return Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 11,
                                              vertical: 8,
                                            ),
                                            decoration: BoxDecoration(
                                              color: areaColor.withOpacity(0.10),
                                              borderRadius: BorderRadius.circular(9),
                                              border: Border.all(
                                                color: areaColor.withOpacity(0.20),
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(
                                                  Icons.location_on_rounded,
                                                  size: 15,
                                                  color: TColors.primary,
                                                ),

                                                const SizedBox(width: 5),

                                                Text(
                                                  area.name,
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w600,
                                                    color: areaColor,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ).toList(),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Divider(height: 1),

                  const SizedBox(height: 10),

                  // ==================================================
                  // FOOTER
                  // ==================================================

                  Row(
                    children: [
                      const Icon(
                        Icons.info_outline_rounded,
                        size: 16,
                        color: TColors.textSecondary,
                      ),

                      const SizedBox(width: 7),

                      Expanded(
                        child: Text(
                          "${controller.beats.length} beats available",
                          style: const TextStyle(
                            fontSize: 12,
                            color: TColors.textSecondary,
                          ),
                        ),
                      ),

                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text("CLOSE"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Color _parseBeatColor(String? color) {
    if (color == null || color.isEmpty) {
      return TColors.primary;
    }

    try {
      final hex = color.replaceAll("#", "");

      if (hex.length == 6) {
        return Color(
          int.parse("FF$hex", radix: 16),
        );
      }

      if (hex.length == 8) {
        return Color(
          int.parse(hex, radix: 16),
        );
      }
    } catch (_) {
      // Ignore invalid backend color
    }

    return TColors.primary;
  }

  
}