import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medicle_sales_rbsh/utils/constants/colors.dart';
import 'package:medicle_sales_rbsh/utils/constants/sizes.dart';

import '../controllers/doctor_offline_controller.dart';
import '../models/doctor.dart';
import '../models/doctor_sync_models.dart';
import 'doctor_detail_screen.dart';
import 'widgets/doctor_filter_bar.dart';
import 'widgets/doctor_list_card.dart';
import 'widgets/doctor_sync_banner.dart';

class DoctorOfflineScreen extends StatefulWidget {
  const DoctorOfflineScreen({
    super.key,
    required this.controller,
  });

  final DoctorOfflineController controller;

  @override
  State<DoctorOfflineScreen> createState() => _DoctorOfflineScreenState();
}

class _DoctorOfflineScreenState extends State<DoctorOfflineScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: widget.controller.query.search,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DoctorOfflineController>(
      init: widget.controller,
      global: false,
      autoRemove: false,
      builder: (controller) {
        return Scaffold(
          backgroundColor: const Color(0xFFF5F5F5),
          appBar: AppBar(
            title: const Text(
              'Offline Doctors',
              style: TextStyle(color: TColors.white),
            ),
            backgroundColor: TColors.primary,
            foregroundColor: TColors.white,
            iconTheme: const IconThemeData(color: TColors.white),
            actions: [
              IconButton(
                tooltip: 'Refresh doctors',
                onPressed: controller.syncStatus.isBusy
                    ? null
                    : controller.refreshDoctors,
                icon: const Icon(Icons.refresh_rounded),
              ),
              PopupMenuButton<String>(
                tooltip: 'Doctor options',
                onSelected: (value) {
                  if (value == 'rebuild') _confirmRebuild(context, controller);
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: 'rebuild',
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.cloud_download_outlined),
                      title: Text('Re-download offline list'),
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return RefreshIndicator(
                  onRefresh: controller.refreshDoctors,
                  child: CustomScrollView(
                    key: const PageStorageKey<String>('doctor_offline_list'),
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(
                            constraints.maxWidth >= 900 ? TSizes.lg : TSizes.md,
                            TSizes.md,
                            constraints.maxWidth >= 900 ? TSizes.lg : TSizes.md,
                            TSizes.sm,
                          ),
                          child: Column(
                            children: [
                              DoctorSyncBanner(controller: controller),
                              const SizedBox(height: TSizes.md),
                              DoctorFilterBar(
                                controller: controller,
                                searchController: _searchController,
                              ),
                              const SizedBox(height: TSizes.sm),
                              _ResultSummary(controller: controller),
                            ],
                          ),
                        ),
                      ),
                      if (controller.selectionNotice != null)
                        SliverToBoxAdapter(
                          child: _SelectionNotice(controller: controller),
                        ),
                      _DoctorCollection(
                        controller: controller,
                        availableWidth: constraints.maxWidth,
                        onDoctorTap: (doctor) {
                          controller.selectDoctor(doctor.localId);
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => DoctorOfflineDetailScreen(
                                controller: controller,
                                localId: doctor.localId,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmRebuild(
    BuildContext context,
    DoctorOfflineController controller,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Re-download doctor list?'),
          content: const Text(
            'The current offline list remains visible while a fresh secure copy downloads.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Re-download'),
            ),
          ],
        );
      },
    );
    if (confirmed == true) await controller.rebuildOfflineCache();
  }
}

class _ResultSummary extends StatelessWidget {
  const _ResultSummary({required this.controller});

  final DoctorOfflineController controller;

  @override
  Widget build(BuildContext context) {
    final filtered = controller.visibleDoctors.length;
    final total = controller.allDoctors.length;
    final text = filtered == total
        ? '$total ${total == 1 ? 'doctor' : 'doctors'}'
        : '$filtered of $total doctors';
    return Row(
      children: [
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        if (controller.query.search.isNotEmpty)
          Text(
            'Local search',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: TColors.success,
                ),
          ),
      ],
    );
  }
}

class _SelectionNotice extends StatelessWidget {
  const _SelectionNotice({required this.controller});

  final DoctorOfflineController controller;

  @override
  Widget build(BuildContext context) {
    return MaterialBanner(
      content: Text(controller.selectionNotice!),
      leading: const Icon(Icons.info_outline_rounded),
      actions: [
        TextButton(
          onPressed: controller.clearSelectionNotice,
          child: const Text('Dismiss'),
        ),
      ],
    );
  }
}

class _DoctorCollection extends StatelessWidget {
  const _DoctorCollection({
    required this.controller,
    required this.availableWidth,
    required this.onDoctorTap,
  });

  final DoctorOfflineController controller;
  final double availableWidth;
  final ValueChanged<Doctor> onDoctorTap;

  @override
  Widget build(BuildContext context) {
    final doctors = controller.visibleDoctors;
    if (doctors.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: _EmptyDoctorState(controller: controller),
      );
    }

    if (availableWidth < 650) {
      return SliverPadding(
        padding: const EdgeInsets.all(TSizes.md),
        sliver: SliverList.separated(
          itemCount: doctors.length,
          itemBuilder: (context, index) {
            final doctor = doctors[index];
            return DoctorListCard(
              doctor: doctor,
              selected: controller.selectedDoctor?.localId == doctor.localId,
              onTap: () => onDoctorTap(doctor),
            );
          },
          separatorBuilder: (_, __) => const SizedBox(height: TSizes.md),
        ),
      );
    }

    final columns = availableWidth < 950 ? 2 : 3;
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final extraHeight = ((textScale - 1).clamp(0, 1) * 120).toDouble();
    return SliverPadding(
      padding: const EdgeInsets.all(TSizes.md),
      sliver: SliverGrid.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          crossAxisSpacing: TSizes.md,
          mainAxisSpacing: TSizes.md,
          mainAxisExtent: 300 + extraHeight,
        ),
        itemCount: doctors.length,
        itemBuilder: (context, index) {
          final doctor = doctors[index];
          return DoctorListCard(
            doctor: doctor,
            selected: controller.selectedDoctor?.localId == doctor.localId,
            onTap: () => onDoctorTap(doctor),
            fillHeight: true,
          );
        },
      ),
    );
  }
}

class _EmptyDoctorState extends StatelessWidget {
  const _EmptyDoctorState({required this.controller});

  final DoctorOfflineController controller;

  @override
  Widget build(BuildContext context) {
    final hasDoctors = controller.allDoctors.isNotEmpty;
    final firstDownload = !controller.syncStatus.hasCachedData &&
        controller.syncStatus.phase != DoctorSyncPhase.current;
    final icon = hasDoctors
        ? Icons.search_off_rounded
        : firstDownload
            ? Icons.cloud_download_outlined
            : Icons.medical_services_outlined;
    final title = hasDoctors
        ? 'No matching doctors'
        : firstDownload
            ? 'Offline list not downloaded yet'
            : 'No doctors available';
    final message = hasDoctors
        ? 'Change the search or filters to see more results.'
        : firstDownload
            ? 'Connect to the internet, then pull down or tap retry.'
            : 'The completed offline dataset is empty.';
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(TSizes.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 56,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: TSizes.md),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: TSizes.sm),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: TSizes.md),
              OutlinedButton.icon(
                onPressed: controller.syncStatus.isBusy
                    ? null
                    : controller.refreshDoctors,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
