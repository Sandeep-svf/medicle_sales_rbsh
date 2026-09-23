import 'dart:async';
import 'package:flutter/material.dart';
import '../controllers/offline_doctor_create_controller.dart';
import 'offline_doctor_create_screen.dart';
import 'doctor_location_picker.dart';
import '../services/doctor_area_assignment_service.dart';
import 'doctor_area_assignment_screen.dart';
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
import 'package:medicle_sales_rbsh/utils/constants/text_strings.dart';

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
          backgroundColor: TColors.hex_FFF5F5F5,
          appBar: AppBar(
            title: const Text(
              TTexts.uiTextOfflineDoctors,
              style: TextStyle(color: TColors.white),
            ),
            backgroundColor: TColors.primary,
            foregroundColor: TColors.white,
            iconTheme: const IconThemeData(color: TColors.white),
            actions: [
              IconButton(
                tooltip: TTexts.uiTextRefreshDoctors,
                onPressed: controller.syncStatus.isBusy
                    ? null
                    : controller.refreshDoctors,
                icon: const Icon(Icons.refresh_rounded),
              ),
              PopupMenuButton<String>(
                tooltip: TTexts.uiTextDoctorOptions,
                onSelected: (value) {
                  if (value == 'rebuild') _confirmRebuild(context, controller);
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: 'rebuild',
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.cloud_download_outlined),
                      title: Text(TTexts.uiTextReDownloadOfflineList),
                    ),
                  ),
                ],
              ),
            ],
          ),
          floatingActionButton: controller.creationStore == null
              ? null
              : FloatingActionButton.extended(
                  onPressed: () => _addDoctor(context, controller),
                  backgroundColor: TColors.primary,
                  foregroundColor: TColors.white,
                  icon: const Icon(Icons.person_add_alt_1),
                  label: const Text(TTexts.addDoctorTitle),
                  tooltip: TTexts.uiTextAddDoctorOffline,
                ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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
                              if (controller.isUploading ||
                                  controller.uploadMessage != null)
                                Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(controller.isUploading
                                        ? 'Uploading saved doctors and photos…'
                                        : controller.uploadMessage!)),
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
                        onAddGeoImage: (doctor) =>
                            controller.addGeoImage(doctor),
                        onRequestLocation: (doctor) =>
                            _requestLocation(context, controller, doctor),
                        onAddArea: (doctor) =>
                            _assignArea(context, controller, doctor),
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

  Future<void> _addDoctor(
      BuildContext context, DoctorOfflineController controller) async {
    final form = OfflineDoctorCreateController(
        store: controller.creationStore!, cachedDoctors: controller.allDoctors);
    form.onInit();
    try {
      final saved = await Navigator.of(context).push<bool>(MaterialPageRoute(
          builder: (_) => OfflineDoctorCreateScreen(controller: form)));
      if (saved == true) {
        await controller.reloadCreations();
        unawaited(controller.refreshDoctors());
      }
    } finally {
      form.onClose();
    }
  }

  Future<void> _requestLocation(BuildContext context,
      DoctorOfflineController controller, Doctor doctor) async {
    final result = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(builder: (_) => const OfflineDoctorLocationPicker()),
    );
    if (result == null || !context.mounted) return;
    await controller.requestDoctorLocation(
      doctor,
      latitude: (result['latitude'] as num).toDouble(),
      longitude: (result['longitude'] as num).toDouble(),
    );
  }

  Future<void> _assignArea(BuildContext context,
      DoctorOfflineController controller, Doctor doctor) async {
    final service = DoctorAreaAssignmentService();
    try {
      List<DoctorAreaOption> areas = const [];
      try {
        areas = await service.fetchAreas();
      } catch (_) {
        // Pincode lookup can still create an area if the existing list fails.
      }
      if (!context.mounted) return;
      await Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => DoctorAreaAssignmentScreen(
          doctors: [PendingAreaDoctor.fromDoctor(doctor)],
          areas: areas,
          service: service,
        ),
      ));
      await controller.refreshDoctors();
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text(TTexts.uiTextCouldNotLoadAreasPleaseTryAgainOnline)),
        );
      }
    } finally {
      await service.close();
    }
  }

  Future<void> _confirmRebuild(
    BuildContext context,
    DoctorOfflineController controller,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(TTexts.uiTextReDownloadDoctorList),
          content: const Text(
            TTexts.uiTextTheCurrentOfflineListRemainsVisibleWhileA,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text(TTexts.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text(TTexts.uiTextReDownload),
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
            TTexts.uiTextLocalSearch,
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
          child: const Text(TTexts.uiTextDismiss),
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
    this.onAddGeoImage,
    this.onRequestLocation,
    this.onAddArea,
  });

  final DoctorOfflineController controller;
  final double availableWidth;
  final ValueChanged<Doctor> onDoctorTap;
  final ValueChanged<Doctor>? onAddGeoImage;
  final ValueChanged<Doctor>? onRequestLocation;
  final ValueChanged<Doctor>? onAddArea;

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
              imagePending:
                  controller.pendingImageIds.contains(doctor.geoImageUploadId),
              imageActionBusy: controller.isCapturingImageFor(doctor),
              doctor: doctor,
              selected: controller.selectedDoctor?.localId == doctor.localId,
              onTap: () => onDoctorTap(doctor),
              onAddGeoImage: doctor.geoImageUrl?.trim().isNotEmpty == true
                  ? null
                  : () => onAddGeoImage?.call(doctor),
              onRequestLocation: () => onRequestLocation?.call(doctor),
              onAddArea:
                  doctor.areaId == null ? () => onAddArea?.call(doctor) : null,
            );
          },
          separatorBuilder: (_, __) => const SizedBox(height: TSizes.md),
        ),
      );
    }

    final columns = availableWidth < 950 ? 2 : 3;
    final doctorColumns = List.generate(columns, (_) => <Doctor>[]);
    for (var index = 0; index < doctors.length; index++) {
      doctorColumns[index % columns].add(doctors[index]);
    }

    Widget buildCard(Doctor doctor) {
      return DoctorListCard(
        imagePending:
            controller.pendingImageIds.contains(doctor.geoImageUploadId),
        imageActionBusy: controller.isCapturingImageFor(doctor),
        doctor: doctor,
        selected: controller.selectedDoctor?.localId == doctor.localId,
        onTap: () => onDoctorTap(doctor),
        onAddGeoImage: doctor.geoImageUrl?.trim().isNotEmpty == true
            ? null
            : () => onAddGeoImage?.call(doctor),
        onRequestLocation: () => onRequestLocation?.call(doctor),
        onAddArea: doctor.areaId == null ? () => onAddArea?.call(doctor) : null,
        // The masonry column provides the card's natural height.
        fillHeight: false,
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.all(TSizes.md),
      sliver: SliverToBoxAdapter(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var column = 0; column < doctorColumns.length; column++) ...[
              if (column > 0) const SizedBox(width: TSizes.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var index = 0;
                        index < doctorColumns[column].length;
                        index++) ...[
                      if (index > 0) const SizedBox(height: TSizes.md),
                      buildCard(doctorColumns[column][index]),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
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
        constraints: const BoxConstraints(maxWidth: TSizes.v420),
        child: Padding(
          padding: const EdgeInsets.all(TSizes.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: TSizes.v56,
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
                label: const Text(TTexts.uiTextRetry),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
