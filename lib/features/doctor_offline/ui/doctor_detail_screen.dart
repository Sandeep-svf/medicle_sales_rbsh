import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medicle_sales_rbsh/utils/constants/colors.dart';

import '../controllers/doctor_offline_controller.dart';
import 'widgets/doctor_detail_content.dart';

class DoctorOfflineDetailScreen extends StatefulWidget {
  const DoctorOfflineDetailScreen({
    super.key,
    required this.controller,
    required this.localId,
  });

  final DoctorOfflineController controller;
  final String localId;

  @override
  State<DoctorOfflineDetailScreen> createState() =>
      _DoctorOfflineDetailScreenState();
}

class _DoctorOfflineDetailScreenState extends State<DoctorOfflineDetailScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    final curve = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );
    _fade = curve;
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.045),
      end: Offset.zero,
    ).animate(curve);
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DoctorOfflineController>(
      init: widget.controller,
      global: false,
      autoRemove: false,
      builder: (doctorController) {
        final doctor = doctorController.allDoctors
            .where((candidate) => candidate.localId == widget.localId)
            .firstOrNull;
        return Scaffold(
          backgroundColor: TColors.light,
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
                : FadeTransition(
                    opacity: _fade,
                    child: SlideTransition(
                      position: _slide,
                      child: DoctorDetailContent(
                        doctor: doctor,
                        localPhoto: doctorController.creationStore == null
                            ? null
                            : FutureBuilder<Uint8List?>(
                                future: doctorController.creationStore!
                                    .readImage(doctor.geoImageUploadId),
                                builder: (context, snapshot) => snapshot.hasData
                                    ? Padding(
                                        padding: const EdgeInsets.only(top: 16),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          child: Image.memory(
                                            snapshot.data!,
                                            height: 240,
                                            fit: BoxFit.contain,
                                            errorBuilder: (_, __, ___) =>
                                                const Text(
                                              'Saved photo could not be displayed.',
                                            ),
                                          ),
                                        ),
                                      )
                                    : const SizedBox.shrink(),
                              ),
                      ),
                    ),
                  ),
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
