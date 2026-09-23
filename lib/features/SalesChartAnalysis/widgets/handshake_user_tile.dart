import 'package:flutter/material.dart';
import 'package:medicle_sales_rbsh/utils/constants/colors.dart';
import '../model/handshake_available_user.dart';
import 'package:medicle_sales_rbsh/utils/constants/sizes.dart';

class HandshakeUserTile extends StatelessWidget {
  const HandshakeUserTile({
    super.key,
    required this.user,
    required this.selected,
    required this.onTap,
  });

  final HandshakeAvailableUser user;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = user.available && onTap != null;

    return Material(
      color: TColors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: selected ? TColors.primary_shade50 : TColors.lightGrey,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? TColors.primary : TColors.borderSecondary,
              width: selected ? 1.4 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: TSizes.v44,
                height: TSizes.v44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected ? TColors.primary : TColors.primary_shade100,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  user.initials,
                  style: TextStyle(
                    color: selected ? TColors.white : TColors.primary,
                    fontSize: TSizes.v13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: TSizes.v12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: TColors.textPrimary,
                        fontSize: TSizes.v13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: TSizes.v5),
                    Wrap(
                      spacing: TSizes.v6,
                      runSpacing: TSizes.v4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        _InfoBadge(
                          label: user.displayRole,
                          foregroundColor: TColors.primary,
                          backgroundColor: TColors.white,
                        ),
                        _InfoBadge(
                          label: 'Code: ${user.displayEmployeeCode}',
                          foregroundColor: TColors.textSecondary,
                          backgroundColor: TColors.white,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: TSizes.v8),
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                width: TSizes.v26,
                height: TSizes.v26,
                decoration: BoxDecoration(
                  color: selected ? TColors.primary : TColors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected ? TColors.primary : TColors.darkGrey,
                    width: TSizes.v1_5,
                  ),
                ),
                child: selected
                    ? const Icon(
                        Icons.check_rounded,
                        color: TColors.white,
                        size: TSizes.v17,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoBadge extends StatelessWidget {
  const _InfoBadge({
    required this.label,
    required this.foregroundColor,
    required this.backgroundColor,
  });

  final String label;
  final Color foregroundColor;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: foregroundColor,
          fontSize: TSizes.v9,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
