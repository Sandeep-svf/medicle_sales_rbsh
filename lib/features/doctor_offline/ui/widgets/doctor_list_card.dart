import 'package:flutter/material.dart';
import 'package:medicle_sales_rbsh/utils/constants/colors.dart';
import 'package:medicle_sales_rbsh/utils/constants/sizes.dart';
import '../../models/doctor.dart';
import 'package:medicle_sales_rbsh/utils/constants/text_strings.dart';

class DoctorListCard extends StatelessWidget {
  const DoctorListCard({
    super.key,
    required this.doctor,
    required this.selected,
    required this.onTap,
    this.fillHeight = false,
    this.imagePending = false,
    this.imageActionBusy = false,
    this.onAddGeoImage,
    this.onRequestLocation,
    this.onAddArea,
  });

  final Doctor doctor;
  final bool selected;
  final VoidCallback onTap;
  final bool fillHeight;
  final bool imagePending;
  final bool imageActionBusy;
  final VoidCallback? onAddGeoImage;
  final VoidCallback? onRequestLocation;
  final VoidCallback? onAddArea;

  @override
  Widget build(BuildContext context) {
    final priority = _PriorityPresentation.from(doctor.priority);
    final cardBody = _CardBody(
      doctor: doctor,
      onTap: onTap,
      fillHeight: fillHeight,
      onAddGeoImage: onAddGeoImage,
      imageActionBusy: imageActionBusy,
      onRequestLocation: onRequestLocation,
      onAddArea: onAddArea,
    );
    final cardRow = Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(
          width: TSizes.v5,
          child: ColoredBox(color: TColors.primary),
        ),
        Expanded(
          child: Column(
            mainAxisSize: fillHeight ? MainAxisSize.max : MainAxisSize.min,
            children: [
              _CardHeader(doctor: doctor, priority: priority),
              if (doctor.localSyncState == DoctorLocalSyncState.pendingCreate ||
                  imagePending)
                Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: Text(
                        doctor.localSyncState ==
                                DoctorLocalSyncState.pendingCreate
                            ? 'Offline stored only'
                            : 'Photo upload pending',
                        style: const TextStyle(
                            color: TColors.materialDeepOrange,
                            fontSize: TSizes.v12,
                            fontWeight: FontWeight.w600))),
              if (fillHeight) Expanded(child: cardBody) else cardBody,
            ],
          ),
        ),
      ],
    );
    return Semantics(
      button: true,
      selected: selected,
      label: 'View ${doctor.displayName}',
      child: Container(
        decoration: BoxDecoration(
          color: TColors.white,
          borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
          border: Border.all(
            color: selected
                ? TColors.primary
                : TColors.primary.withValues(alpha: 0.35),
            width: selected ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: TColors.pureBlack.withValues(alpha: 0.05),
              blurRadius: TSizes.v12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Material(
          color: TColors.transparent,
          child: InkWell(
            onTap: onTap,
            child: fillHeight ? cardRow : IntrinsicHeight(child: cardRow),
          ),
        ),
      ),
    );
  }
}

class _CardHeader extends StatelessWidget {
  const _CardHeader({
    required this.doctor,
    required this.priority,
  });

  final Doctor doctor;
  final _PriorityPresentation priority;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(TSizes.md),
      decoration: BoxDecoration(
        color: TColors.primary.withValues(alpha: 0.04),
        border: Border(
          bottom: BorderSide(color: TColors.materialGrey100),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: TColors.primary.withValues(alpha: 0.3),
                width: TSizes.v2,
              ),
            ),
            child: CircleAvatar(
              radius: TSizes.v24,
              backgroundColor: TColors.white,
              child: Text(
                _initial,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: TColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
          ),
          const SizedBox(width: TSizes.v12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        doctor.displayName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                      ),
                    ),
                    const SizedBox(width: TSizes.xs),
                    _PriorityBadge(presentation: priority),
                  ],
                ),
                const SizedBox(height: TSizes.sm),
                Text(
                  _valueOrNotAvailable(doctor.specialization),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: TColors.materialGrey800,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: TSizes.sm),
                _CompactInfoLine(
                  icon: Icons.location_on_rounded,
                  value: _location,
                  valueColor: TColors.materialGrey600,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String get _initial {
    final name = doctor.displayName.trim();
    return name.isEmpty ? '?' : name.substring(0, 1).toUpperCase();
  }

  String get _location {
    if (_hasText(doctor.location)) return doctor.location!.trim();
    if (_hasText(doctor.clinicAddress)) return doctor.clinicAddress!.trim();
    return 'N/A';
  }
}

class _CardBody extends StatelessWidget {
  const _CardBody({
    required this.doctor,
    required this.onTap,
    required this.fillHeight,
    this.onAddGeoImage,
    this.imageActionBusy = false,
    this.onRequestLocation,
    this.onAddArea,
  });

  final Doctor doctor;
  final VoidCallback onTap;
  final bool fillHeight;
  final VoidCallback? onAddGeoImage;
  final bool imageActionBusy;
  final VoidCallback? onRequestLocation;
  final VoidCallback? onAddArea;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(TSizes.md),
      child: Column(
        mainAxisSize: fillHeight ? MainAxisSize.max : MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                Icons.work_history_rounded,
                size: TSizes.iconSm,
                color: TColors.materialGrey700,
              ),
              const SizedBox(width: TSizes.v6),
              Expanded(
                child: Text(
                  doctor.yearsOfExperience == null
                      ? 'Experience: N/A'
                      : '${doctor.yearsOfExperience} Years Exp.',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              if (_hasText(doctor.gender)) ...[
                const SizedBox(width: TSizes.xs),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: TColors.materialGrey100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    doctor.gender!.trim(),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: TColors.materialGrey700,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: TSizes.sm),
          _CompactInfoLine(
            icon: Icons.local_hospital_outlined,
            value: doctor.displayClinic,
            valueColor: TColors.materialGrey700,
          ),
          // Grid cards use a fixed height, but actions should follow the
          // doctor information instead of being pushed down by a large gap.
          const SizedBox(height: TSizes.md),
          SizedBox(
            width: double.infinity,
            height: TSizes.v40,
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: TColors.primary,
                foregroundColor: TColors.white,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(TSizes.borderRadiusMd),
                ),
              ),
              child: const Text(
                TTexts.uiTextViewProfile,
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
          if (onAddGeoImage != null) ...[
            const SizedBox(height: TSizes.sm),
            _CardActionButton(
              icon: Icons.add_a_photo_outlined,
              label: TTexts.uiTextAddGeoImage,
              onPressed: imageActionBusy ? null : onAddGeoImage!,
              busy: imageActionBusy,
            ),
          ],
          if (onRequestLocation != null) ...[
            const SizedBox(height: TSizes.sm),
            _CardActionButton(
              icon: Icons.my_location_outlined,
              label: TTexts.uiTextRequestLocationUpdate,
              onPressed: onRequestLocation!,
            ),
          ],
          if (onAddArea != null) ...[
            const SizedBox(height: TSizes.sm),
            _CardActionButton(
              icon: Icons.location_city_outlined,
              label: TTexts.uiTextAssignArea,
              onPressed: onAddArea!,
            ),
          ],
        ],
      ),
    );
  }
}

class _CardActionButton extends StatelessWidget {
  const _CardActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.busy = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: TSizes.v40,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: busy
            ? const SizedBox.square(
                dimension: 17,
                child: CircularProgressIndicator(strokeWidth: TSizes.v2),
              )
            : Icon(icon, size: TSizes.v17),
        label: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
        style: OutlinedButton.styleFrom(
          foregroundColor: TColors.primary,
          backgroundColor: TColors.primary.withValues(alpha: .04),
          side: BorderSide(color: TColors.primary.withValues(alpha: .35)),
          padding: const EdgeInsets.symmetric(horizontal: TSizes.sm),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(TSizes.borderRadiusMd),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class _CompactInfoLine extends StatelessWidget {
  const _CompactInfoLine({
    required this.icon,
    required this.value,
    required this.valueColor,
  });

  final IconData icon;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: TSizes.v14, color: valueColor),
        const SizedBox(width: TSizes.v5),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: valueColor,
                ),
          ),
        ),
      ],
    );
  }
}

class _PriorityBadge extends StatelessWidget {
  const _PriorityBadge({required this.presentation});

  final _PriorityPresentation presentation;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: presentation.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(TSizes.cardRadiusXs),
        border: Border.all(
          color: presentation.color.withValues(alpha: 0.35),
        ),
      ),
      child: Text(
        presentation.label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: presentation.color,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _PriorityPresentation {
  const _PriorityPresentation({required this.label, required this.color});

  final String label;
  final Color color;

  factory _PriorityPresentation.from(String? value) {
    switch (value?.trim().toUpperCase()) {
      case 'A':
        return const _PriorityPresentation(
          label: TTexts.uiTextPriorityA,
          color: TColors.materialRed,
        );
      case 'B':
        return const _PriorityPresentation(
          label: TTexts.uiTextPriorityB,
          color: TColors.materialOrange,
        );
      case 'C':
        return const _PriorityPresentation(
          label: TTexts.uiTextPriorityC,
          color: TColors.materialBlueGrey,
        );
      default:
        return const _PriorityPresentation(
          label: TTexts.uiTextNotAdded,
          color: TColors.materialGrey,
        );
    }
  }
}

bool _hasText(String? value) => value != null && value.trim().isNotEmpty;

String _valueOrNotAvailable(String? value) {
  return _hasText(value) ? value!.trim() : 'N/A';
}
