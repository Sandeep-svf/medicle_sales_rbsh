import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medicle_sales_rbsh/features/approval_management/screen/wigets/approve_dialog.dart';
import 'package:medicle_sales_rbsh/features/approval_management/screen/wigets/collaboration_request_card.dart';
import 'package:medicle_sales_rbsh/features/approval_management/screen/wigets/pending_approval_card.dart';
import 'package:medicle_sales_rbsh/features/approval_management/screen/wigets/return_dialog.dart';

import '../controller/approval_management_controller.dart';


// import your existing details screen
// import '../../tour_plan_details/tour_plan_details_screen.dart';

class ApprovalManagementScreen extends StatelessWidget {
  ApprovalManagementScreen({super.key});

  final ApprovalManagementController controller =
  Get.put(ApprovalManagementController());

  @override
  Widget build(BuildContext context) {
    return Obx(() {

      if (controller.isLoading.value) {
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      }

      /// USER
      if (controller.isUser) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Collaboration Requests"),
            centerTitle: true,
          ),
          body: RefreshIndicator(
            onRefresh: controller.refreshData,
            child: _buildCollaborationList(),
          ),
        );
      }

      /// MANAGER
      return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: const Text("Approval Management"),
            centerTitle: true,
            bottom: const TabBar(
              tabs: [
                Tab(text: "Pending"),
                Tab(text: "Collaboration"),
              ],
            ),
          ),
          body: RefreshIndicator(
            onRefresh: controller.refreshData,
            child: TabBarView(
              children: [

                _buildPendingList(),

                _buildCollaborationList(),

              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildPendingList() {
    return Obx(() {

      if (controller.pendingApprovals.isEmpty) {
        return const Center(
          child: Text("No Pending Approvals"),
        );
      }

      return ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: controller.pendingApprovals.length,
        itemBuilder: (_, index) {

          final plan = controller.pendingApprovals[index];

          return PendingApprovalCard(

            plan: plan,

            loading:
            controller.isApproving.value ||
                controller.isReturning.value,

            onView: () {

              /// Open your existing details screen

              // Get.to(
              //   ()=>TourPlanDetailsScreen(
              //      plan: plan,
              //   ),
              // );

            },

            onApprove: () {

              Get.dialog(

                ApproveDialog(

                  onApprove: (comments) {

                    controller.approveTour(
                      plan: plan,
                      comments: comments,
                    );

                  },

                ),

              );

            },

            onReturn: () {

              Get.dialog(

                ReturnDialog(

                  onReturn: (comments) {

                    controller.returnTour(
                      plan: plan,
                      comments: comments,
                    );

                  },

                ),

              );

            },

          );

        },
      );
    });
  }

  Widget _buildCollaborationList() {

    return Obx(() {

      if (controller.collaborations.isEmpty) {

        return const Center(
          child: Text(
            "No Collaboration Requests",
          ),
        );

      }

      return ListView.builder(

        physics: const AlwaysScrollableScrollPhysics(),

        itemCount: controller.collaborations.length,

        itemBuilder: (_, index) {

          final request =
          controller.collaborations[index];

          return CollaborationRequestCard(

            request: request,

            loading: controller.isResponding.value,

            onAccept: () {

              controller.respondCollaboration(

                request: request,

                accept: true,

              );

            },

            onReject: () {

              controller.respondCollaboration(

                request: request,

                accept: false,

              );

            },

          );

        },

      );

    });

  }
}