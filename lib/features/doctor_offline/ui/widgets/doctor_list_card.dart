import 'package:flutter/material.dart';
import 'package:medicle_sales_rbsh/utils/constants/colors.dart';
import 'package:medicle_sales_rbsh/utils/constants/sizes.dart';

import '../../models/doctor.dart';

class DoctorListCard extends StatelessWidget {
  const DoctorListCard({
    super.key,
    required this.doctor,
    required this.selected,
    required this.onTap,
    this.fillHeight = false,
  });

  final Doctor doctor;
  final bool selected;
  final VoidCallback onTap;
  final bool fillHeight;

  @override
  Widget build(BuildContext context) {
    final priority = _PriorityPresentation.from(doctor.priority);
    final cardBody = _CardBody(
      doctor: doctor,
      onTap: onTap,
      fillHeight: fillHeight,
    );
    final cardRow = Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(
          width: 5,
          child: ColoredBox(color: TColors.primary),
        ),
        Expanded(
          child: Column(
            mainAxisSize: fillHeight ? MainAxisSize.max : MainAxisSize.min,
            children: [
              _CardHeader(doctor: doctor, priority: priority),
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
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Material(
          color: Colors.transparent,
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
          bottom: BorderSide(color: Colors.grey.shade100),
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
                width: 2,
              ),
            ),
            child: CircleAvatar(
              radius: 24,
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
          const SizedBox(width: 12),
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
                        color: Colors.grey.shade800,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: TSizes.sm),
                _CompactInfoLine(
                  icon: Icons.location_on_rounded,
                  value: _location,
                  valueColor: Colors.grey.shade600,
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
  });

  final Doctor doctor;
  final VoidCallback onTap;
  final bool fillHeight;

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
                color: Colors.grey.shade700,
              ),
              const SizedBox(width: 6),
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
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    doctor.gender!.trim(),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.grey.shade700,
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
            valueColor: Colors.grey.shade700,
          ),
          if (fillHeight) const Spacer() else const SizedBox(height: TSizes.md),
          SizedBox(
            width: double.infinity,
            height: 40,
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
                'View Profile',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
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
        Icon(icon, size: 14, color: valueColor),
        const SizedBox(width: 5),
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
          label: 'Priority A',
          color: Colors.red,
        );
      case 'B':
        return const _PriorityPresentation(
          label: 'Priority B',
          color: Colors.orange,
        );
      case 'C':
        return const _PriorityPresentation(
          label: 'Priority C',
          color: Colors.blueGrey,
        );
      default:
        return const _PriorityPresentation(
          label: 'Not Added',
          color: Colors.grey,
        );
    }
  }
}

bool _hasText(String? value) => value != null && value.trim().isNotEmpty;

String _valueOrNotAvailable(String? value) {
  return _hasText(value) ? value!.trim() : 'N/A';
}
