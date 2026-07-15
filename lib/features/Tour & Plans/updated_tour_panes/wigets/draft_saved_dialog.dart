import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../controller/tour_plan_controller.dart';

class DraftSavedDialog extends StatelessWidget {
  const DraftSavedDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TourPlanController>();

    final summaryItems = [
      _SummaryItem(
        title: "Field Work",
        count: controller.fieldCount,
        icon: Icons.location_on_rounded,
        color: Colors.blue,
      ),
      _SummaryItem(
        title: "Joint Work",
        count: controller.jointWorkCount,
        icon: Icons.people_alt_rounded,
        color: Colors.deepPurple,
      ),
      _SummaryItem(
        title: "Meeting",
        count: controller.meetingCount,
        icon: Icons.groups_rounded,
        color: Colors.orange,
      ),
      _SummaryItem(
        title: "Office",
        count: controller.officeCount,
        icon: Icons.business_center_rounded,
        color: Colors.teal,
      ),
      _SummaryItem(
        title: "Transit",
        count: controller.transitCount,
        icon: Icons.route_rounded,
        color: Colors.indigo,
      ),
      _SummaryItem(
        title: "Leave",
        count: controller.leaveCount,
        icon: Icons.beach_access_rounded,
        color: Colors.redAccent,
      ),
      _SummaryItem(
        title: "Holiday",
        count: controller.holidayCount,
        icon: Icons.celebration_rounded,
        color: Colors.green,
      ),
      _SummaryItem(
        title: "Weekly Off",
        count: controller.weeklyOffCount,
        icon: Icons.weekend_rounded,
        color: Colors.brown,
      ),
    ];

    final visibleItems =
    summaryItems.where((e) => e.count > 0).toList();

    final totalDays = visibleItems.fold<int>(
      0,
          (sum, e) => sum + e.count,
    );

    return Dialog(
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
        width: 720,
        constraints: const BoxConstraints(
        maxWidth: 720,
    ),
    decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(24),
    ),
    child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [

    //-------------------------------------------------
    // Header
    //-------------------------------------------------

    Container(
    padding: const EdgeInsets.all(24),
    decoration: const BoxDecoration(
    color: TColors.primary,
    borderRadius: BorderRadius.vertical(
    top: Radius.circular(24),
    ),
    ),
    child: Row(
    children: [

    Container(
    width: 70,
    height: 70,
    decoration: BoxDecoration(
    color: Colors.white.withOpacity(.18),
    shape: BoxShape.circle,
    ),
    child: const Icon(
    Icons.check_circle,
    color: Colors.white,
    size: 42,
    ),
    ),

    const SizedBox(width: 18),

    const Expanded(
    child: Column(
    crossAxisAlignment:
    CrossAxisAlignment.start,
    children: [

    Text(
    "Draft Saved Successfully",
    style: TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    ),
    ),

    SizedBox(height: 6),

    Text(
    "Your Tour Plan has been saved successfully.\n"
    "Review the summary below before submission.",
    style: TextStyle(
    color: Colors.white70,
    height: 1.5,
    ),
    ),
    ],
    ),
    ),

    IconButton(
    onPressed: () {
    Get.back();
    },
    icon: const Icon(
    Icons.close,
    color: Colors.white,
    ),
    ),
    ],
    ),
    ),

    //-------------------------------------------------
    // Body
    //-------------------------------------------------

    Padding(
    padding: const EdgeInsets.all(24),
    child: Column(
    children: [

    Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
    color: TColors.primary.withOpacity(.05),
    borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
    children: [

    const Icon(
    Icons.info_outline,
    color: TColors.primary,
    ),

    const SizedBox(width: 12),

    Expanded(
    child: Text(
    "You can submit this Tour Plan now or later from the Tour Plan list.",
    style: TextStyle(
    color: Colors.grey.shade700,
    height: 1.5,
    ),
    ),
    ),
    ],
    ),
    ),

    const SizedBox(height: 24),

    Row(
    children: [

    const Icon(
    Icons.analytics_outlined,
    color: TColors.primary,
    ),

    const SizedBox(width: 8),

    const Text(
    "Planning Summary",
    style: TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    ),
    ),

    const Spacer(),

    Text(
    "$totalDays Days",
    style: const TextStyle(
    color: TColors.primary,
    fontWeight: FontWeight.bold,
    ),
    ),
    ],
    ),

    const SizedBox(height: 18),

    GridView.builder(
    shrinkWrap: true,
    physics:
    const NeverScrollableScrollPhysics(),
    itemCount: visibleItems.length,
    gridDelegate:
    const SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    crossAxisSpacing: 16,
    mainAxisSpacing: 16,
    childAspectRatio: 2.9,
    ),
    itemBuilder: (_, index) {

    final item = visibleItems[index];

    return _SummaryCard(item: item);
    },
    ),

    const SizedBox(height: 20),
      const Divider(height: 1),

      const SizedBox(height: 20),

      Row(
        children: [

          Expanded(
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () {

                Get.back();

                Get.back(result: true);

              },
              icon: const Icon(Icons.arrow_back),
              label: const Text(
                "Later",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Obx(() {

              return ElevatedButton.icon(

                style: ElevatedButton.styleFrom(
                  backgroundColor: TColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),

                onPressed: controller.isSubmitting.value
                    ? null
                    : () async {

                  final success =
                  await controller.submitPlan();

                  if (success) {

                    Get.back();

                    Get.back(result: true);

                  }
                },

                icon: controller.isSubmitting.value
                    ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : const Icon(Icons.send_rounded),

                label: Text(
                  controller.isSubmitting.value
                      ? "Submitting..."
                      : "Submit Tour Plan",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    ],
    ),
    ),
    ],
    ),
        ),
    );
  }
}

///--------------------------------------------------------------
/// Summary Model
///--------------------------------------------------------------

class _SummaryItem {

  final String title;

  final int count;

  final IconData icon;

  final Color color;

  const _SummaryItem({
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
  });
}

///--------------------------------------------------------------
/// Summary Card
///--------------------------------------------------------------

class _SummaryCard extends StatelessWidget {

  final _SummaryItem item;

  const _SummaryCard({
    required this.item,
  });

  @override
  Widget build(BuildContext context) {

    return Container(

      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),

      decoration: BoxDecoration(
        color: item.color.withOpacity(.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: item.color.withOpacity(.20),
        ),
      ),

      child: Row(

        children: [

          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: item.color.withOpacity(.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              item.icon,
              color: item.color,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              mainAxisAlignment:
              MainAxisAlignment.center,
              children: [

                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  item.count == 1
                      ? "1 Day"
                      : "${item.count} Days",
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          Text(
            "${item.count}",
            style: TextStyle(
              color: item.color,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}