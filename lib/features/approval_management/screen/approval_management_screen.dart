import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medicle_sales_rbsh/features/approval_management/screen/wigets/beat_change_action_dialog.dart';
import 'package:medicle_sales_rbsh/features/approval_management/screen/wigets/beat_change_request_card.dart';
import 'package:medicle_sales_rbsh/features/approval_management/screen/wigets/empty_state.dart';
import 'package:medicle_sales_rbsh/features/approval_management/screen/wigets/loading_view.dart';

import 'package:medicle_sales_rbsh/utils/constants/sizes.dart';

import '../../../utils/constants/colors.dart';
import '../../Tour & Plans/updated_tour_panes/Screen/tour_plan_details_screen.dart';
import '../controller/approval_management_controller.dart';
import 'wigets/approve_dialog.dart';
import 'wigets/collaboration_request_card.dart';
import 'wigets/pending_approval_card.dart';
import 'wigets/return_dialog.dart';

class ApprovalManagementScreen extends StatelessWidget {
  ApprovalManagementScreen({super.key});

  final ApprovalManagementController controller =
  Get.put(ApprovalManagementController());

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Scaffold(
          body: LoadingView(
            message: "Loading approvals...",
          ),
        );
      }

      if (controller.isUser) {
        return Scaffold(
          backgroundColor: TColors.light,
          appBar: AppBar(
            elevation: 0,
            centerTitle: false,
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            title: const Text("Collaboration Requests"),
          ),
          body: RefreshIndicator(
            onRefresh: controller.refreshData,
            child: _ResponsiveContainer(
              child: _buildCollaborationList(),
            ),
          ),
        );
      }

      return DefaultTabController(
        length: 3,
        child: Scaffold(
          backgroundColor: TColors.light,
          appBar: AppBar(
            elevation: 0,
            centerTitle: false,
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
           // title: const Text("Approval Management"),
            bottom: TabBar(
              indicatorColor: TColors.primary,
              labelColor: TColors.primary,
              unselectedLabelColor: TColors.textSecondary,
              tabs: [

                Tab(
                  text:
                  "Pending (${controller.pendingApprovals.length})",
                ),

                Tab(
                  text:
                  "Beat Changes (${controller.beatChangeRequests.length})",
                ),

                Tab(
                  text:
                  "Collaboration (${controller.collaborations.length})",
                ),

              ],
            ),
          ),
          body: RefreshIndicator(
            onRefresh: controller.refreshData,
            child: _ResponsiveContainer(
              child: TabBarView(
                children: [

                  _buildPendingList(),

                  _buildBeatChangeList(),

                  _buildCollaborationList(),

                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildPendingList() {
    return Obx(() {
      if (controller.pendingApprovals.isEmpty) {
        return const EmptyState(
          icon: Icons.assignment_outlined,
          title: "No Pending Approvals",
          subtitle: "There are no pending approvals at the moment.",
        );
      }

      return LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 900;

          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(TSizes.lg),
            child: Wrap(
              spacing: TSizes.lg,
              runSpacing: TSizes.lg,
              children: controller.pendingApprovals.map((plan) {
                return SizedBox(
                  width: isWide
                      ? (constraints.maxWidth - TSizes.lg) / 2
                      : constraints.maxWidth,
                  child: PendingApprovalCard(
                    plan: plan,
                    loading: controller.isApproving.value ||
                        controller.isReturning.value,
                    onView: () {
                      Get.to(
                            () => TourPlanDetailsScreen(
                          planId: plan.id,
                        ),
                      );
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
                  ),
                );
              }).toList(),
            ),
          );
        },
      );
    });
  }

  Widget _buildBeatChangeList() {
    return Obx(() {

      if (controller.beatChangeRequests.isEmpty) {
        return const EmptyState(
          icon: Icons.swap_horiz,
          title: "No Beat Change Requests",
          subtitle: "There are no pending beat change requests.",
        );
      }

      return LayoutBuilder(
        builder: (context, constraints) {

          final isWide =
              constraints.maxWidth >= 900;

          return SingleChildScrollView(
            physics:
            const AlwaysScrollableScrollPhysics(),
            padding:
            const EdgeInsets.all(TSizes.lg),
            child: Wrap(
              spacing: TSizes.lg,
              runSpacing: TSizes.lg,
              children: controller.beatChangeRequests
                  .map((request) {

                return SizedBox(
                  width: isWide
                      ? (constraints.maxWidth -
                      TSizes.lg) /
                      2
                      : constraints.maxWidth,
                  child: BeatChangeRequestCard(
                    request: request,

                    loading:
                    controller.isBeatResponding.value,

                    onApprove: () {

                      Get.dialog(
                        BeatChangeActionDialog(
                          approve: true,
                          onSubmit: (comments) {

                            controller.respondBeatChangeRequest(
                              request: request,
                              approve: true,
                              comments: comments,
                            );

                          },
                        ),
                      );

                    },

                    onReject: () {

                      Get.dialog(
                        BeatChangeActionDialog(
                          approve: false,
                          onSubmit: (comments) {

                            controller.respondBeatChangeRequest(
                              request: request,
                              approve: false,
                              comments: comments,
                            );

                          },
                        ),
                      );

                    },
                  ),
                );

              }).toList(),
            ),
          );
        },
      );
    });
  }

  Widget _buildCollaborationList() {
    return Obx(() {
      if (controller.collaborations.isEmpty) {
        return const EmptyState(
          icon: Icons.handshake_outlined,
          title: "No Collaboration Requests",
          subtitle: "There are no collaboration requests available.",
        );
      }

      return LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 900;

          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(TSizes.lg),
            child: Wrap(
              spacing: TSizes.lg,
              runSpacing: TSizes.lg,
              children: controller.collaborations.map((request) {
                return SizedBox(
                  width: isWide
                      ? (constraints.maxWidth - TSizes.lg) / 2
                      : constraints.maxWidth,
                  child: CollaborationRequestCard(
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
                  ),
                );
              }).toList(),
            ),
          );
        },
      );
    });
  }
}

class _ResponsiveContainer extends StatelessWidget {
  const _ResponsiveContainer({
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 1200,
        ),
        child: child,
      ),
    );
  }
}