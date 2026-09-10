import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medicle_sales_rbsh/utils/constants/colors.dart';

import '../controllers/doctor_offline_controller.dart';
import 'widgets/doctor_detail_content.dart';

class DoctorOfflineDetailScreen extends StatelessWidget {
  const DoctorOfflineDetailScreen({
    super.key,
    required this.controller,
    required this.localId,
  });

  final DoctorOfflineController controller;
  final String localId;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DoctorOfflineController>(
      init: controller,
      global: false,
      autoRemove: false,
      builder: (doctorController) {
        final doctor = doctorController.allDoctors
            .where((candidate) => candidate.localId == localId)
            .firstOrNull;
        return Scaffold(
          backgroundColor: const Color(0xFFF5F5F5),
          appBar: AppBar(
            title: Text(
              doctor?.displayName ?? 'Doctor Details',
              style: const TextStyle(color: TColors.white),
            ),
            backgroundColor: TColors.primary,
            foregroundColor: TColors.white,
            iconTheme: const IconThemeData(color: TColors.white),
          ),
          body: SafeArea(
            child: doctor == null
                ? const _DoctorUnavailable()
                : DoctorDetailContent(doctor: doctor),
          ),
        );
      },
    );
  }
}

class _DoctorUnavailable extends StatelessWidget {
  const _DoctorUnavailable();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.person_off_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'This doctor is no longer available.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}
