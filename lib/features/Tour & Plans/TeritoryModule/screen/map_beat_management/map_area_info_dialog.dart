import 'package:flutter/material.dart';
import '../../../../../utils/constants/colors.dart';
import 'map_beat_browser.dart';

Future<void> showMapAreaInfo(
  BuildContext context, {
  required String title,
  required String pincode,
  required int doctors,
  required int chemists,
  required int stockists,
  required List<MapBeatBrowserEntry> beats,
  required bool dataAvailable,
}) =>
    showGeneralDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Area information',
      barrierColor: TColors.black.withValues(alpha: 0.35),
      transitionDuration: const Duration(milliseconds: 320),
      transitionBuilder: (_, animation, __, child) => FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
          child: ScaleTransition(
              scale: Tween<double>(begin: 0.92, end: 1).animate(CurvedAnimation(
                  parent: animation, curve: Curves.easeOutCubic)),
              child: child)),
      pageBuilder: (context, _, __) => Dialog(
        backgroundColor: TColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: ConstrainedBox(
          constraints: BoxConstraints(
              maxWidth: 480,
              maxHeight: MediaQuery.sizeOf(context).height * 0.78),
          child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                              color: TColors.primary.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(16)),
                          child: const Icon(Icons.location_on_outlined,
                              color: TColors.primary)),
                      const SizedBox(width: 12),
                      Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            Text(title,
                                style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: TColors.textPrimary)),
                            Text('Pincode $pincode',
                                style: const TextStyle(
                                    color: TColors.textSecondary)),
                          ])),
                    ]),
                    const SizedBox(height: 20),
                    Flexible(
                        child: SingleChildScrollView(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                          if (!dataAvailable)
                            const Text(
                                'Area data is unavailable. Refresh beat data and try again.'),
                          if (dataAvailable)
                            Wrap(spacing: 8, runSpacing: 8, children: [
                              for (final stat in [
                                (
                                  Icons.medical_services_outlined,
                                  'Doctors',
                                  doctors
                                ),
                                (
                                  Icons.local_pharmacy_outlined,
                                  'Chemists',
                                  chemists
                                ),
                                (
                                  Icons.inventory_2_outlined,
                                  'Stockists',
                                  stockists
                                )
                              ])
                                Container(
                                    width: 112,
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                        color: TColors.light,
                                        borderRadius:
                                            BorderRadius.circular(16)),
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Icon(stat.$1,
                                              color: TColors.primary, size: 22),
                                          const SizedBox(height: 8),
                                          Text('${stat.$3}',
                                              style: const TextStyle(
                                                  fontSize: 26,
                                                  fontWeight: FontWeight.bold,
                                                  color: TColors.textPrimary)),
                                          Text(stat.$2,
                                              style: const TextStyle(
                                                  color:
                                                      TColors.textSecondary)),
                                        ])),
                            ]),
                          const SizedBox(height: 20),
                          Text('Assigned beats (${beats.length})',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  color: TColors.textPrimary)),
                          const SizedBox(height: 12),
                          if (dataAvailable && beats.isEmpty)
                            const Text('This area is not linked to any beat.',
                                style: TextStyle(color: TColors.textSecondary)),
                          for (final beat in beats)
                            Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                      color: beat.color.withValues(alpha: 0.10),
                                      borderRadius: BorderRadius.circular(12)),
                                  child: Row(children: [
                                    CircleAvatar(
                                        radius: 7, backgroundColor: beat.color),
                                    const SizedBox(width: 10),
                                    Expanded(
                                        child: Text(beat.name,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                color: TColors.textPrimary)))
                                  ]),
                                )),
                        ]))),
                    const SizedBox(height: 16),
                    SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(
                              backgroundColor: TColors.primary,
                              foregroundColor: TColors.white),
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                          label: const Text('Close'),
                        )),
                  ])),
        ),
      ),
    );
