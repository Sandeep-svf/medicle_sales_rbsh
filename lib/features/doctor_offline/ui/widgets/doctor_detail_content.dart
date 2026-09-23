import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:medicle_sales_rbsh/utils/constants/colors.dart';
import 'package:medicle_sales_rbsh/utils/constants/sizes.dart';
import '../../models/doctor.dart';
import 'package:medicle_sales_rbsh/utils/constants/text_strings.dart';

class DoctorDetailContent extends StatelessWidget {
  const DoctorDetailContent({
    super.key,
    required this.doctor,
    this.localPhoto,
    this.padding = const EdgeInsets.all(TSizes.md),
  });

  final Doctor doctor;
  final Widget? localPhoto;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final landscapeTablet = constraints.maxWidth >= 700 &&
            constraints.maxWidth > constraints.maxHeight;
        return SingleChildScrollView(
          key: PageStorageKey<String>('doctor_detail_${doctor.localId}'),
          padding: padding,
          child: Align(
            alignment: AlignmentDirectional.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: TSizes.v1200),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _ProfileHeader(doctor: doctor),
                  const SizedBox(height: TSizes.sm),
                  _ProfileQuickFacts(doctor: doctor),
                  SizedBox(height: landscapeTablet ? TSizes.lg : TSizes.md),
                  if (landscapeTablet)
                    _LandscapeTabbedDetails(
                      doctor: doctor,
                      localPhoto: localPhoto,
                    )
                  else ...[
                    if (localPhoto != null) localPhoto!,
                    if (localPhoto != null) const SizedBox(height: TSizes.md),
                    _CompactDetails(doctor: doctor),
                  ],
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

class _ProfileQuickFacts extends StatelessWidget {
  const _ProfileQuickFacts({required this.doctor});

  final Doctor doctor;

  @override
  Widget build(BuildContext context) {
    final facts = [
      _QuickFact(
        icon: Icons.local_hospital_outlined,
        label: TTexts.uiTextClinic,
        value: doctor.displayClinic,
      ),
      _QuickFact(
        icon: Icons.business_outlined,
        label: TTexts.uiTextHeadOffice_807fada4,
        value: _valueOrNotAvailable(doctor.headOfficeName),
      ),
      _QuickFact(
        icon: Icons.map_outlined,
        label: TTexts.uiTextArea,
        value: _valueOrNotAvailable(doctor.areaName),
      ),
      _QuickFact(
        icon: Icons.location_on_outlined,
        label: TTexts.uiTextCoordinates,
        value: doctor.hasValidCoordinates ? 'Available' : 'Not available',
      ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 700 ? 4 : 2;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: facts.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: TSizes.sm,
            mainAxisSpacing: TSizes.sm,
            mainAxisExtent: 76,
          ),
          itemBuilder: (context, index) => facts[index],
        );
      },
    );
  }
}

class _QuickFact extends StatelessWidget {
  const _QuickFact({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: TSizes.sm, vertical: 10),
      decoration: BoxDecoration(
        color: TColors.white,
        borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
        border: Border.all(color: TColors.primary.withValues(alpha: 0.16)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: TColors.primary.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: TSizes.v18, color: TColors.primary),
          ),
          const SizedBox(width: TSizes.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: TColors.materialGrey600,
                        fontWeight: FontWeight.w700,
                        letterSpacing: .4,
                      ),
                ),
                const SizedBox(height: TSizes.v3),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: TColors.textPrimary,
                        fontWeight: FontWeight.w700,
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

class _LandscapeTabbedDetails extends StatelessWidget {
  const _LandscapeTabbedDetails({
    required this.doctor,
    required this.localPhoto,
  });

  final Doctor doctor;
  final Widget? localPhoto;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Container(
        decoration: _cardDecoration(),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Material(
              color: TColors.primary.withValues(alpha: 0.05),
              child: TabBar(
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                labelColor: TColors.primary,
                unselectedLabelColor: TColors.materialGrey600,
                indicatorColor: TColors.primary,
                indicatorWeight: 3,
                indicatorSize: TabBarIndicatorSize.tab,
                labelStyle: const TextStyle(fontWeight: FontWeight.w800),
                unselectedLabelStyle:
                    const TextStyle(fontWeight: FontWeight.w600),
                labelPadding: const EdgeInsets.symmetric(horizontal: TSizes.md),
                dividerColor: TColors.transparent,
                tabs: const [
                  Tab(
                      icon: Icon(Icons.person_outline),
                      text: TTexts.uiTextOverview),
                  Tab(
                      icon: Icon(Icons.local_hospital_outlined),
                      text: TTexts.uiTextPractice),
                  Tab(
                      icon: Icon(Icons.location_on_outlined),
                      text: TTexts.uiTextLocationMedia),
                  Tab(
                      icon: Icon(Icons.sync_outlined),
                      text: TTexts.uiTextSystem),
                ],
              ),
            ),
            SizedBox(
              height: TSizes.v680,
              child: TabBarView(
                children: [
                  _DetailsTab(
                    children: [
                      _ContactCard(doctor: doctor),
                      const SizedBox(height: TSizes.md),
                      _BasicInformationCard(doctor: doctor),
                    ],
                  ),
                  _DetailsTab(
                    children: [
                      _PracticeCard(doctor: doctor),
                      const SizedBox(height: TSizes.md),
                      _HeadOfficeCard(doctor: doctor),
                    ],
                  ),
                  _DetailsTab(
                    children: [
                      _LocationCard(doctor: doctor, height: TSizes.v250),
                      const SizedBox(height: TSizes.md),
                      if (localPhoto != null) localPhoto!,
                      if (localPhoto != null) const SizedBox(height: TSizes.md),
                      _GeoImageCard(doctor: doctor, height: TSizes.v250),
                    ],
                  ),
                  _DetailsTab(
                    children: [
                      _AccountMetadataCard(doctor: doctor),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailsTab extends StatelessWidget {
  const _DetailsTab({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(TSizes.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.doctor});

  final Doctor doctor;

  @override
  Widget build(BuildContext context) {
    final priority = _PriorityPresentation.from(doctor.priority);
    final synced = doctor.localSyncState == DoctorLocalSyncState.synced;
    return Container(
      padding: const EdgeInsets.all(TSizes.lg),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            TColors.primary.withValues(alpha: 0.14),
            TColors.primary.withValues(alpha: 0.035),
            TColors.white,
          ],
        ),
        border: Border.all(color: TColors.primary.withValues(alpha: 0.28)),
        boxShadow: [
          BoxShadow(
            color: TColors.primary.withValues(alpha: 0.1),
            blurRadius: TSizes.v20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: TColors.white,
              border: Border.all(
                color: TColors.primary.withValues(alpha: 0.5),
                width: TSizes.v2,
              ),
              boxShadow: [
                BoxShadow(
                  color: TColors.primary.withValues(alpha: 0.16),
                  blurRadius: TSizes.v12,
                ),
              ],
            ),
            child: Hero(
              tag: 'doctor_avatar_${doctor.localId}',
              child: CircleAvatar(
                radius: TSizes.v38,
                backgroundColor: TColors.primary.withValues(alpha: 0.1),
                child: Text(
                  _initial(doctor.displayName),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: TColors.primary,
                        fontWeight: FontWeight.w800,
                      ),
                ),
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
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      doctor.displayName,
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: TColors.textPrimary,
                                fontWeight: FontWeight.w800,
                              ),
                    ),
                    _PriorityBadge(presentation: priority),
                  ],
                ),
                const SizedBox(height: TSizes.xs),
                Text(
                  _valueOrNotAvailable(doctor.specialization),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: TColors.primary_shade700,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: TSizes.md),
                Wrap(
                  spacing: TSizes.sm,
                  runSpacing: TSizes.sm,
                  children: [
                    _HeaderStatusChip(
                      icon: synced
                          ? Icons.cloud_done_outlined
                          : Icons.cloud_off_outlined,
                      label: synced ? 'Synced' : 'Offline pending',
                      color: synced ? TColors.success : TColors.warning,
                    ),
                    _HeaderStatusChip(
                      icon: Icons.location_on_outlined,
                      label: _valueOrNotAvailable(doctor.location),
                      color: TColors.primary,
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

  String _initial(String value) {
    final normalized = value.trim();
    return normalized.isEmpty ? '?' : normalized.substring(0, 1).toUpperCase();
  }
}

class _HeaderStatusChip extends StatelessWidget {
  const _HeaderStatusChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: TSizes.v15, color: color),
          const SizedBox(width: TSizes.v5),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
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
      title: TTexts.uiTextContactInformation,
      icon: Icons.contact_phone_outlined,
      children: [
        _InfoRow(
          icon: Icons.email_outlined,
          label: TTexts.email,
          value: doctor.email,
        ),
        _InfoRow(
          icon: Icons.phone_outlined,
          label: TTexts.phone,
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
      title: TTexts.uiTextBasicInformation,
      icon: Icons.info_outline,
      children: [
        _InfoRow(
          icon: Icons.badge_outlined,
          label: TTexts.uiTextRegistration,
          value: doctor.registrationNumber,
        ),
        _InfoRow(
          icon: Icons.school_outlined,
          label: TTexts.uiTextQualification,
          value: doctor.qualification,
        ),
        _InfoRow(
          icon: Icons.calendar_today_outlined,
          label: TTexts.uiTextDOB,
          value: _formatDate(doctor.dateOfBirth),
        ),
        _InfoRow(
          icon: Icons.cake_outlined,
          label: TTexts.anniversary,
          value: _formatDate(doctor.anniversary),
        ),
        _InfoRow(
          icon: Icons.work_history_outlined,
          label: TTexts.uiTextExperience,
          value: doctor.yearsOfExperience == null
              ? null
              : '${doctor.yearsOfExperience} Years',
        ),
        _InfoRow(
          icon: Icons.person_outline,
          label: TTexts.gender,
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
      title: TTexts.uiTextPracticeDetails,
      icon: Icons.local_hospital_outlined,
      children: [
        _InfoRow(
          icon: Icons.local_hospital_outlined,
          label: TTexts.uiTextClinic,
          value: doctor.clinicName,
        ),
        _InfoRow(
          icon: Icons.location_city_outlined,
          label: TTexts.uiTextClinicAddress,
          value: doctor.clinicAddress,
        ),
        _InfoRow(
          icon: Icons.schedule_outlined,
          label: TTexts.uiTextAvailableTimings,
          value: doctor.availableTimings,
        ),
        _InfoRow(
          icon: Icons.currency_rupee_outlined,
          label: TTexts.uiTextConsultationFee,
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
      title: TTexts.uiTextHeadOffice,
      icon: Icons.business_outlined,
      children: [
        _InfoRow(
          icon: Icons.store_mall_directory_outlined,
          label: TTexts.uiTextOfficeName,
          value: doctor.headOfficeName,
        ),
        _InfoRow(
          icon: Icons.map_outlined,
          label: TTexts.uiTextArea,
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
      title: TTexts.uiTextAccountMetadata,
      icon: Icons.manage_accounts_outlined,
      children: [
        _InfoRow(
          icon: Icons.person_pin_outlined,
          label: TTexts.uiTextCreatedBy,
          value: doctor.createdByName,
        ),
        _InfoRow(
          icon: Icons.access_time,
          label: TTexts.uiTextCreated,
          value: _formatTimestamp(doctor.createdAt),
        ),
        _InfoRow(
          icon: Icons.update,
          label: TTexts.uiTextLastUpdated,
          value: _formatTimestamp(doctor.updatedAt),
        ),
        _InfoRow(
          icon: Icons.offline_pin_outlined,
          label: TTexts.uiTextOfflineStatus,
          value: doctor.localSyncState == DoctorLocalSyncState.synced
              ? 'Downloaded from server'
              : 'Pending local creation',
        ),
        _InfoRow(
          icon: Icons.sync_outlined,
          label: TTexts.uiTextSyncVersion,
          value: doctor.syncVersion?.toString(),
        ),
        _InfoRow(
          icon: Icons.account_balance_wallet_outlined,
          label: TTexts.uiTextUCPMPAnnualCap,
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
            title: TTexts.uiTextLocationOnMap,
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
                        size: TSizes.v48,
                        color: hasLocation
                            ? TColors.primary
                            : TColors.materialGrey500,
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
                                    color: TColors.materialGrey700,
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
            title: TTexts.uiTextGeoLocationImage,
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
                    message: TTexts.uiTextNoGeoLocationImageAvailable,
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
        color: TColors.materialGrey50,
        borderRadius: BorderRadius.circular(TSizes.borderRadiusLg),
        border: Border.all(color: TColors.materialGrey300),
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
                message: TTexts.uiTextGeoImageIsUnavailable,
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
                  color: TColors.pureBlack.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.visibility,
                        color: TColors.white, size: TSizes.v18),
                    SizedBox(width: TSizes.v6),
                    Text(
                      TTexts.uiTextView,
                      style: TextStyle(
                        color: TColors.white,
                        fontSize: TSizes.v12,
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
          backgroundColor: TColors.transparent,
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
                        height: TSizes.v320,
                        child: _MissingGeoImage(
                          message: TTexts.uiTextGeoImageIsUnavailable,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: IconButton.filled(
                  tooltip: TTexts.uiTextCloseImage,
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
          color: TColors.materialGrey50,
          borderRadius: BorderRadius.circular(TSizes.borderRadiusLg),
          border: Border.all(color: TColors.materialGrey300),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(TSizes.md),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: TSizes.v72,
                  height: TSizes.v72,
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
                      size: TSizes.v36,
                    ),
                  ),
                ),
                const SizedBox(height: TSizes.v12),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: TColors.materialGrey700,
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
        Icon(icon, size: TSizes.v20, color: TColors.primary),
        const SizedBox(width: TSizes.sm),
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: TColors.hex_FF333333,
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
            child: Icon(icon, size: TSizes.v18, color: TColors.primary),
          ),
          const SizedBox(width: TSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: TColors.materialGrey500,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: TSizes.v2),
                SelectableText(
                  _valueOrNotAvailable(value),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: TColors.black87,
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
          label: TTexts.uiTextHighPriority,
          color: TColors.materialRed,
        );
      case 'B':
        return const _PriorityPresentation(
          label: TTexts.uiTextMediumPriority,
          color: TColors.materialOrange,
        );
      case 'C':
        return const _PriorityPresentation(
          label: TTexts.uiTextStandardPriority,
          color: TColors.materialBlueGrey,
        );
      default:
        return const _PriorityPresentation(
          label: TTexts.uiTextNotAdded_a5651658,
          color: TColors.materialGrey,
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
        color: TColors.pureBlack.withValues(alpha: 0.06),
        blurRadius: TSizes.v15,
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
