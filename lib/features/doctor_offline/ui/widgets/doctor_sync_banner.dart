import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:medicle_sales_rbsh/utils/constants/colors.dart';
import 'package:medicle_sales_rbsh/utils/constants/sizes.dart';

import '../../controllers/doctor_offline_controller.dart';
import '../../models/doctor_sync_models.dart';

class DoctorSyncBanner extends StatelessWidget {
  const DoctorSyncBanner({
    super.key,
    required this.controller,
  });

  final DoctorOfflineController controller;

  @override
  Widget build(BuildContext context) {
    final presentation = _presentation();
    final status = controller.syncStatus;
    final lastUpdated = status.lastSuccessfulSyncUtc;
    final updatedLabel = lastUpdated == null
        ? null
        : 'Updated ${DateFormat('dd MMM yyyy, h:mm a').format(lastUpdated.toLocal())}';

    return Semantics(
      liveRegion: true,
      label: presentation.message,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(TSizes.md),
        decoration: BoxDecoration(
          color: presentation.color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(TSizes.borderRadiusLg),
          border: Border.all(
            color: presentation.color.withValues(alpha: 0.28),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  presentation.icon,
                  size: TSizes.iconMd,
                  color: presentation.color,
                ),
                const SizedBox(width: TSizes.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        presentation.title,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: presentation.color,
                                  fontWeight: FontWeight.w700,
                                ),
                      ),
                      const SizedBox(height: TSizes.xs),
                      Text(
                        presentation.message,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      if (updatedLabel != null) ...[
                        const SizedBox(height: TSizes.xs),
                        Text(
                          updatedLabel,
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Refresh doctors',
                  onPressed: status.isBusy ? null : controller.refreshDoctors,
                  icon: const Icon(Icons.refresh_rounded),
                  color: presentation.color,
                ),
              ],
            ),
            if (status.isBusy) ...[
              const SizedBox(height: TSizes.sm),
              ClipRRect(
                borderRadius: BorderRadius.circular(TSizes.borderRadiusSm),
                child: LinearProgressIndicator(
                  minHeight: 4,
                  color: TColors.primary,
                  backgroundColor: presentation.color.withValues(alpha: 0.12),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  _SyncPresentation _presentation() {
    final status = controller.syncStatus;
    if (!controller.networkAvailable) {
      return _SyncPresentation(
        title: status.hasCachedData ? 'Offline access' : 'Internet required',
        message: status.hasCachedData
            ? 'Showing the secure doctor list saved on this device.'
            : 'Connect to the internet to complete the first doctor download.',
        icon: Icons.cloud_off_rounded,
        color: status.hasCachedData ? TColors.warning : TColors.error,
      );
    }

    switch (status.phase) {
      case DoctorSyncPhase.initializing:
      case DoctorSyncPhase.downloading:
      case DoctorSyncPhase.syncing:
        return _SyncPresentation(
          title: status.phase == DoctorSyncPhase.downloading
              ? 'Preparing offline doctors'
              : 'Synchronizing doctors',
          message: status.message,
          icon: Icons.sync_rounded,
          color: TColors.info,
        );
      case DoctorSyncPhase.current:
        return const _SyncPresentation(
          title: 'Available offline',
          message: 'The local doctor list is current.',
          icon: Icons.offline_pin_rounded,
          color: TColors.success,
        );
      case DoctorSyncPhase.authenticationRequired:
        return _SyncPresentation(
          title: 'Sign-in required',
          message: status.message,
          icon: Icons.lock_outline_rounded,
          color: TColors.error,
        );
      case DoctorSyncPhase.storageUnavailable:
        return _SyncPresentation(
          title: 'Secure storage unavailable',
          message: status.message,
          icon: Icons.storage_rounded,
          color: TColors.error,
        );
      case DoctorSyncPhase.protocolBlocked:
        return _SyncPresentation(
          title: 'Backend confirmation needed',
          message: status.message,
          icon: Icons.rule_rounded,
          color: TColors.warning,
        );
      case DoctorSyncPhase.failed:
        return _SyncPresentation(
          title: 'Sync not completed',
          message: status.message,
          icon: Icons.sync_problem_rounded,
          color: TColors.error,
        );
      case DoctorSyncPhase.offline:
        return _SyncPresentation(
          title: status.hasCachedData ? 'Offline access' : 'Internet required',
          message: status.hasCachedData
              ? 'The last secure doctor download is still available.'
              : status.message,
          icon: Icons.cloud_off_rounded,
          color: status.hasCachedData ? TColors.warning : TColors.error,
        );
      case DoctorSyncPhase.idle:
        return const _SyncPresentation(
          title: 'Offline doctors',
          message: 'Secure local storage is ready.',
          icon: Icons.medical_services_outlined,
          color: TColors.info,
        );
    }
  }
}

class _SyncPresentation {
  const _SyncPresentation({
    required this.title,
    required this.message,
    required this.icon,
    required this.color,
  });

  final String title;
  final String message;
  final IconData icon;
  final Color color;
}
