import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:medicle_sales_rbsh/utils/constants/colors.dart';
import 'package:medicle_sales_rbsh/utils/constants/sizes.dart';

import '../../models/doctor.dart';

class DoctorDetailContent extends StatelessWidget {
  const DoctorDetailContent({
    super.key,
    required this.doctor,
    this.padding = const EdgeInsets.all(TSizes.md),
  });

  final Doctor doctor;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 900;
        return SingleChildScrollView(
          key: PageStorageKey<String>('doctor_detail_${doctor.localId}'),
          padding: padding,
          child: Align(
            alignment: AlignmentDirectional.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _ProfileHeader(doctor: doctor),
                  SizedBox(height: wide ? TSizes.lg : TSizes.md),
                  if (wide)
                    _WideDetails(doctor: doctor)
                  else
                    _CompactDetails(doctor: doctor),
                  const SizedBox(height: TSizes.lg),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CompactDetails extends StatelessWidget {
  const _CompactDetails({required this.doctor});

  final Doctor doctor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ContactCard(doctor: doctor),
        const SizedBox(height: TSizes.md),
        _LocationCard(doctor: doctor),
        const SizedBox(height: TSizes.md),
        _GeoImageCard(doctor: doctor),
        const SizedBox(height: TSizes.md),
        _BasicInformationCard(doctor: doctor),
        const SizedBox(height: TSizes.md),
        _PracticeCard(doctor: doctor),
        const SizedBox(height: TSizes.md),
        _HeadOfficeCard(doctor: doctor),
        const SizedBox(height: TSizes.md),
        _AccountMetadataCard(doctor: doctor),
      ],
    );
  }
}

class _WideDetails extends StatelessWidget {
  const _WideDetails({required this.doctor});

  final Doctor doctor;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 5,
          child: Column(
            children: [
              _ContactCard(doctor: doctor),
              const SizedBox(height: TSizes.lg),
              _BasicInformationCard(doctor: doctor),
              const SizedBox(height: TSizes.lg),
              _HeadOfficeCard(doctor: doctor),
              const SizedBox(height: TSizes.lg),
              _AccountMetadataCard(doctor: doctor),
            ],
          ),
        ),
        const SizedBox(width: TSizes.lg),
        Expanded(
          flex: 7,
          child: Column(
            children: [
              _LocationCard(doctor: doctor, height: 280),
              const SizedBox(height: TSizes.lg),
              _GeoImageCard(doctor: doctor, height: 280),
              const SizedBox(height: TSizes.lg),
              _PracticeCard(doctor: doctor),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.doctor});

  final Doctor doctor;

  @override
  Widget build(BuildContext context) {
    final priority = _PriorityPresentation.from(doctor.priority);
    return _StyledCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: TColors.primary.withValues(alpha: 0.5),
                width: 2,
              ),
            ),
            child: CircleAvatar(
              radius: 35,
              backgroundColor: TColors.primary.withValues(alpha: 0.1),
              child: const Icon(
                Icons.person,
                color: TColors.primary,
                size: 40,
              ),
            ),
          ),
          const SizedBox(width: TSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: TSizes.sm,
                  runSpacing: TSizes.sm,
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      doctor.displayName,
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Colors.black87,
                                fontWeight: FontWeight.w700,
                              ),
                    ),
                    _PriorityBadge(presentation: priority),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  _valueOrNotAvailable(doctor.specialization),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: TSizes.sm),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 14,
                      color: Colors.grey.shade500,
                    ),
                    const SizedBox(width: TSizes.xs),
                    Expanded(
                      child: Text(
                        _valueOrNotAvailable(doctor.location),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  const _ContactCard({required this.doctor});

  final Doctor doctor;

  @override
  Widget build(BuildContext context) {
    return _InformationCard(
      title: 'Contact Information',
      icon: Icons.contact_phone_outlined,
      children: [
        _InfoRow(
          icon: Icons.email_outlined,
          label: 'Email',
          value: doctor.email,
        ),
        _InfoRow(
          icon: Icons.phone_outlined,
          label: 'Phone',
          value: doctor.phone,
        ),
      ],
    );
  }
}

class _BasicInformationCard extends StatelessWidget {
  const _BasicInformationCard({required this.doctor});

  final Doctor doctor;

  @override
  Widget build(BuildContext context) {
    return _InformationCard(
      title: 'Basic Information',
      icon: Icons.info_outline,
      children: [
        _InfoRow(
          icon: Icons.badge_outlined,
          label: 'Registration',
          value: doctor.registrationNumber,
        ),
        _InfoRow(
          icon: Icons.school_outlined,
          label: 'Qualification',
          value: doctor.qualification,
        ),
        _InfoRow(
          icon: Icons.calendar_today_outlined,
          label: 'DOB',
          value: _formatDate(doctor.dateOfBirth),
        ),
        _InfoRow(
          icon: Icons.cake_outlined,
          label: 'Anniversary',
          value: _formatDate(doctor.anniversary),
        ),
        _InfoRow(
          icon: Icons.work_history_outlined,
          label: 'Experience',
          value: doctor.yearsOfExperience == null
              ? null
              : '${doctor.yearsOfExperience} Years',
        ),
        _InfoRow(
          icon: Icons.person_outline,
          label: 'Gender',
          value: doctor.gender,
        ),
      ],
    );
  }
}

class _PracticeCard extends StatelessWidget {
  const _PracticeCard({required this.doctor});

  final Doctor doctor;

  @override
  Widget build(BuildContext context) {
    return _InformationCard(
      title: 'Practice Details',
      icon: Icons.local_hospital_outlined,
      children: [
        _InfoRow(
          icon: Icons.local_hospital_outlined,
          label: 'Clinic',
          value: doctor.clinicName,
        ),
        _InfoRow(
          icon: Icons.location_city_outlined,
          label: 'Clinic Address',
          value: doctor.clinicAddress,
        ),
        _InfoRow(
          icon: Icons.schedule_outlined,
          label: 'Available Timings',
          value: doctor.availableTimings,
        ),
        _InfoRow(
          icon: Icons.currency_rupee_outlined,
          label: 'Consultation Fee',
          value: _formatCurrency(doctor.consultationFee),
        ),
      ],
    );
  }
}

class _HeadOfficeCard extends StatelessWidget {
  const _HeadOfficeCard({required this.doctor});

  final Doctor doctor;

  @override
  Widget build(BuildContext context) {
    return _InformationCard(
      title: 'Head Office',
      icon: Icons.business_outlined,
      children: [
        _InfoRow(
          icon: Icons.store_mall_directory_outlined,
          label: 'Office Name',
          value: doctor.headOfficeName,
        ),
        _InfoRow(
          icon: Icons.map_outlined,
          label: 'Area',
          value: doctor.areaName,
        ),
      ],
    );
  }
}

class _AccountMetadataCard extends StatelessWidget {
  const _AccountMetadataCard({required this.doctor});

  final Doctor doctor;

  @override
  Widget build(BuildContext context) {
    return _InformationCard(
      title: 'Account Metadata',
      icon: Icons.manage_accounts_outlined,
      children: [
        _InfoRow(
          icon: Icons.person_pin_outlined,
          label: 'Created By',
          value: doctor.createdByName,
        ),
        _InfoRow(
          icon: Icons.access_time,
          label: 'Created',
          value: _formatTimestamp(doctor.createdAt),
        ),
        _InfoRow(
          icon: Icons.update,
          label: 'Last Updated',
          value: _formatTimestamp(doctor.updatedAt),
        ),
        _InfoRow(
          icon: Icons.offline_pin_outlined,
          label: 'Offline Status',
          value: doctor.localSyncState == DoctorLocalSyncState.synced
              ? 'Downloaded from server'
              : 'Pending local creation',
        ),
        _InfoRow(
          icon: Icons.sync_outlined,
          label: 'Sync Version',
          value: doctor.syncVersion?.toString(),
        ),
        _InfoRow(
          icon: Icons.account_balance_wallet_outlined,
          label: 'UCPMP Annual Cap',
          value: _formatCurrency(doctor.ucpmpAnnualCap),
        ),
      ],
    );
  }
}

class _LocationCard extends StatelessWidget {
  const _LocationCard({
    required this.doctor,
    this.height = 220,
  });

  final Doctor doctor;
  final double height;

  @override
  Widget build(BuildContext context) {
    final hasLocation = doctor.hasValidCoordinates;
    return Container(
      decoration: _cardDecoration(),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          const _CardTitleBar(
            title: 'Location on Map',
            icon: Icons.map_outlined,
          ),
          SizedBox(
            height: height,
            width: double.infinity,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    TColors.primary.withValues(alpha: 0.04),
                    TColors.primary.withValues(alpha: 0.12),
                  ],
                ),
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(TSizes.lg),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        hasLocation
                            ? Icons.location_on_rounded
                            : Icons.location_off_outlined,
                        size: 48,
                        color: hasLocation
                            ? TColors.primary
                            : Colors.grey.shade500,
                      ),
                      const SizedBox(height: TSizes.sm),
                      Text(
                        hasLocation
                            ? _valueOrNotAvailable(doctor.location)
                            : 'Location coordinates are not available',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      if (hasLocation) ...[
                        const SizedBox(height: TSizes.xs),
                        Text(
                          '${doctor.latitude}, ${doctor.longitude}',
                          textAlign: TextAlign.center,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey.shade700,
                                  ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GeoImageCard extends StatelessWidget {
  const _GeoImageCard({
    required this.doctor,
    this.height = 250,
  });

  final Doctor doctor;
  final double height;

  @override
  Widget build(BuildContext context) {
    final imageUrl = doctor.geoImageUrl?.trim();
    final hasImage = imageUrl != null && imageUrl.isNotEmpty;
    return _StyledCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            title: 'Geo Location Image',
            icon: Icons.image_outlined,
          ),
          const Divider(),
          const SizedBox(height: TSizes.sm),
          SizedBox(
            height: height,
            width: double.infinity,
            child: hasImage
                ? _NetworkGeoImage(imageUrl: imageUrl)
                : const _MissingGeoImage(
                    message: 'No Geo Location Image available',
                  ),
          ),
        ],
      ),
    );
  }
}

class _NetworkGeoImage extends StatelessWidget {
  const _NetworkGeoImage({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(TSizes.borderRadiusLg),
        border: Border.all(color: Colors.grey.shade300),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _showFullImage(context, imageUrl),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              imageUrl,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const Center(
                  child: CircularProgressIndicator(color: TColors.primary),
                );
              },
              errorBuilder: (_, __, ___) => const _MissingGeoImage(
                message: 'Geo image is unavailable',
              ),
            ),
            Positioned(
              right: 12,
              bottom: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.visibility, color: TColors.white, size: 18),
                    SizedBox(width: 6),
                    Text(
                      'View',
                      style: TextStyle(
                        color: TColors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFullImage(BuildContext context, String url) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(12),
          child: Stack(
            alignment: Alignment.topRight,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(TSizes.borderRadiusLg),
                child: ColoredBox(
                  color: TColors.white,
                  child: InteractiveViewer(
                    minScale: 1,
                    maxScale: 4,
                    child: Image.network(
                      url,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const SizedBox(
                        height: 320,
                        child: _MissingGeoImage(
                          message: 'Geo image is unavailable',
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: IconButton.filled(
                  tooltip: 'Close image',
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  icon: const Icon(Icons.close),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MissingGeoImage extends StatelessWidget {
  const _MissingGeoImage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      image: true,
      label: message,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(TSizes.borderRadiusLg),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(TSizes.md),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: TColors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: TColors.primary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Image.asset(
                    'assets/logos/faviicons_glucks_care_dark.jpg',
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.image_not_supported_outlined,
                      color: TColors.primary,
                      size: 36,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InformationCard extends StatelessWidget {
  const _InformationCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return _StyledCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(title: title, icon: icon),
          const Divider(),
          ...children,
        ],
      ),
    );
  }
}

class _StyledCard extends StatelessWidget {
  const _StyledCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(TSizes.md),
      decoration: _cardDecoration(),
      child: child,
    );
  }
}

class _CardTitleBar extends StatelessWidget {
  const _CardTitleBar({
    required this.title,
    required this.icon,
  });

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: TSizes.md,
        vertical: 12,
      ),
      color: TColors.primary.withValues(alpha: 0.04),
      child: _SectionTitle(title: title, icon: icon),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    required this.icon,
  });

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: TColors.primary),
        const SizedBox(width: TSizes.sm),
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: const Color(0xFF333333),
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: TSizes.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(TSizes.sm),
            decoration: BoxDecoration(
              color: TColors.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(TSizes.borderRadiusMd),
            ),
            child: Icon(icon, size: 18, color: TColors.primary),
          ),
          const SizedBox(width: TSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 2),
                SelectableText(
                  _valueOrNotAvailable(value),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PriorityBadge extends StatelessWidget {
  const _PriorityBadge({required this.presentation});

  final _PriorityPresentation presentation;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: presentation.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: presentation.color.withValues(alpha: 0.3),
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
  const _PriorityPresentation({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  factory _PriorityPresentation.from(String? value) {
    switch (value?.trim().toUpperCase()) {
      case 'A':
        return const _PriorityPresentation(
          label: 'High Priority',
          color: Colors.red,
        );
      case 'B':
        return const _PriorityPresentation(
          label: 'Medium Priority',
          color: Colors.orange,
        );
      case 'C':
        return const _PriorityPresentation(
          label: 'Standard Priority',
          color: Colors.blueGrey,
        );
      default:
        return const _PriorityPresentation(
          label: 'Not added',
          color: Colors.grey,
        );
    }
  }
}

BoxDecoration _cardDecoration() {
  return BoxDecoration(
    color: TColors.white,
    borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
    border: Border.all(
      color: TColors.primary.withValues(alpha: 0.3),
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.06),
        blurRadius: 15,
        offset: const Offset(0, 6),
      ),
    ],
  );
}

bool _hasText(String? value) => value != null && value.trim().isNotEmpty;

String _valueOrNotAvailable(String? value) {
  return _hasText(value) ? value!.trim() : 'N/A';
}

String? _formatDate(DateTime? value) {
  return value == null ? null : DateFormat('dd MMM yyyy').format(value);
}

String? _formatTimestamp(DateTime? value) {
  return value == null
      ? null
      : DateFormat('dd MMM yyyy, hh:mm a').format(value.toLocal());
}

String? _formatCurrency(num? value) {
  if (value == null) return null;
  return NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: value % 1 == 0 ? 0 : 2,
  ).format(value);
}
