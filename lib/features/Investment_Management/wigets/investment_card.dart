import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:medicle_sales_rbsh/utils/constants/colors.dart';
import 'package:medicle_sales_rbsh/utils/constants/sizes.dart';
import '../model/investment_request_model.dart';
import 'investment_status_chip.dart';
import 'package:medicle_sales_rbsh/utils/constants/text_strings.dart';

class InvestmentRequestCard extends StatelessWidget {
  final InvestmentRequest request;
  final VoidCallback? onEdit;

  const InvestmentRequestCard({
    super.key,
    required this.request,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: TColors.white,
        borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
        border: Border.all(
          color: TColors.primary.withOpacity(.12),
        ),
        boxShadow: [
          BoxShadow(
            color: TColors.pureBlack.withOpacity(.05),
            blurRadius: TSizes.v14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          ///===========================
          /// HEADER
          ///===========================

          _buildHeader(),

          ///===========================
          /// BODY
          ///===========================

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(TSizes.md),
              child: _buildDynamicBody(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(TSizes.md),
      decoration: BoxDecoration(
        color: TColors.primary.withOpacity(.04),
        border: Border(
          bottom: BorderSide(
            color: TColors.materialGrey200,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: TSizes.v26,
            backgroundColor: TColors.white,
            child: Text(
              request.avatarLetter,
              style: const TextStyle(
                color: TColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: TSizes.v22,
              ),
            ),
          ),
          const SizedBox(
            width: TSizes.spaceBtwItems,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request.displayDoctorName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: TSizes.fontSizeLg,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: TSizes.spaceBtwText,
                ),
                Wrap(
                  spacing: TSizes.v10,
                  runSpacing: TSizes.v10,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: request.paymentColor.withOpacity(.08),
                        borderRadius: BorderRadius.circular(
                          30,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            request.paymentIcon,
                            size: TSizes.v16,
                            color: request.paymentColor,
                          ),
                          const SizedBox(width: TSizes.v6),
                          Text(
                            request.paymentMode ?? "-",
                            style: TextStyle(
                              color: request.paymentColor,
                              fontWeight: FontWeight.bold,
                              fontSize: TSizes.fontSizeSm,
                            ),
                          ),
                        ],
                      ),
                    ),
                    InvestmentStatusChip(
                      status: request.displayStatus,
                    ),
                  ],
                ),
                const SizedBox(
                  height: TSizes.spaceBtwItems,
                ),
                if (!request.isGift)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: TColors.materialGreen.withOpacity(.08),
                      borderRadius: BorderRadius.circular(
                        30,
                      ),
                    ),
                    child: Text(
                      request.displayAmount,
                      style: const TextStyle(
                        color: TColors.materialGreen,
                        fontSize: TSizes.fontSizeMd,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (onEdit != null)
            IconButton(
              tooltip: TTexts.uiTextEditResubmit,
              onPressed: onEdit,
              icon: const Icon(
                Icons.edit_outlined,
                color: TColors.primary,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDynamicBody(BuildContext context) {
    switch (request.paymentMode) {
      case "Cash":
        return _cashBody(context);

      case "NEFT":
        return _neftBody(context);

      case "UPI":
        return _upiBody(context);

      case "Items/Gift":
        return _giftBody(context);

      default:
        return const Center(
          child: Text(TTexts.uiTextUnknownPaymentMode),
        );
    }
  }

  Widget _infoRow(
    IconData icon,
    String title,
    String value, {
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: TSizes.spaceBtwItems,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: TSizes.iconSm,
            color: color ?? TColors.primary,
          ),
          const SizedBox(width: TSizes.sm),
          SizedBox(
            width: TSizes.v90,
            child: Text(
              title,
              style: TextStyle(
                fontSize: TSizes.fontSizeSm,
                color: TColors.materialGrey600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? "-" : value,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: TSizes.fontSizeSm,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cashBody(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _infoRow(
          Icons.currency_rupee,
          "Amount",
          request.displayAmount,
        ),
        _infoRow(
          Icons.description_outlined,
          "Purpose",
          request.displayPurpose,
        ),
        _infoRow(
          Icons.calendar_month_outlined,
          "Submitted",
          request.displayDate,
        ),
        const Spacer(),
        Row(
          children: [
            const Icon(
              Icons.info_outline,
              color: TColors.materialOrange,
            ),
            const SizedBox(width: TSizes.sm),
            Expanded(
              child: Text(
                TTexts.uiTextCashPaymentRequest,
                style: TextStyle(
                  color: TColors.materialGrey700,
                ),
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget _neftBody(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _infoRow(
          Icons.currency_rupee,
          "Amount",
          request.displayAmount,
        ),
        _infoRow(
          Icons.description,
          "Purpose",
          request.displayPurpose,
        ),
        if ((request.bankDetails ?? "").isNotEmpty)
          _infoRow(
            Icons.account_balance,
            "Bank",
            request.bankDetails!,
          ),
        _infoRow(
          Icons.calendar_today,
          "Submitted",
          request.displayDate,
        ),
        const SizedBox(
          height: TSizes.spaceBtwItems,
        ),
        if (request.hasProof)
          Wrap(
            spacing: TSizes.sm,
            runSpacing: TSizes.sm,
            children: [
              OutlinedButton.icon(
                onPressed: () => _showProof(context),
                icon: const Icon(Icons.visibility, size: TSizes.v18),
                label: const Text(TTexts.uiTextView),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: TColors.primary,
                  foregroundColor: TColors.white,
                ),
                onPressed: () async {
                  await launchUrl(
                    Uri.parse(request.paymentProof!),
                    mode: LaunchMode.externalApplication,
                  );
                },
                icon: const Icon(Icons.download, size: TSizes.v18),
                label: const Text(TTexts.download),
              ),
            ],
          )
      ],
    );
  }

  Widget _upiBody(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _infoRow(
                  Icons.currency_rupee,
                  "Amount",
                  request.displayAmount,
                ),
                _infoRow(
                  Icons.description,
                  "Purpose",
                  request.displayPurpose,
                ),
                if ((request.upiId ?? "").isNotEmpty)
                  _infoRow(
                    Icons.qr_code,
                    "UPI ID",
                    request.upiId!,
                  ),
                _infoRow(
                  Icons.calendar_today,
                  "Submitted",
                  request.displayDate,
                ),
              ],
            ),
          ),
        ),
        if (request.hasProof) ...[
          const SizedBox(height: TSizes.sm),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    _showProof(context);
                  },
                  icon: const Icon(Icons.visibility),
                  label: const Text(TTexts.uiTextViewProof),
                ),
              ),
              const SizedBox(width: TSizes.sm),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TColors.primary,
                    foregroundColor: TColors.white,
                  ),
                  onPressed: () async {
                    await launchUrl(
                      Uri.parse(request.paymentProof!),
                      mode: LaunchMode.externalApplication,
                    );
                  },
                  icon: const Icon(Icons.download),
                  label: const Text(TTexts.download),
                ),
              )
            ],
          ),
        ],
      ],
    );
  }

  Widget _giftBody(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _infoRow(
          Icons.description_outlined,
          "Reason",
          request.justification ?? "-",
        ),
        const SizedBox(
          height: TSizes.spaceBtwItems,
        ),
        const Text(
          TTexts.uiTextGiftItems,
          style: TextStyle(
            fontSize: TSizes.fontSizeMd,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(
          height: TSizes.spaceBtwText,
        ),
        Expanded(
          child: ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            itemCount: request.items.length,
            separatorBuilder: (_, __) => const SizedBox(
              height: TSizes.sm,
            ),
            itemBuilder: (_, index) {
              final item = request.items[index];

              return Container(
                padding: const EdgeInsets.all(TSizes.sm),
                decoration: BoxDecoration(
                  color: TColors.materialOrange.withOpacity(.05),
                  borderRadius: BorderRadius.circular(
                    TSizes.cardRadiusSm,
                  ),
                  border: Border.all(
                    color: TColors.materialOrange.withOpacity(.20),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: TSizes.v40,
                      height: TSizes.v40,
                      decoration: BoxDecoration(
                        color: TColors.materialOrange.withOpacity(.10),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.card_giftcard,
                        color: TColors.materialOrange,
                      ),
                    ),
                    const SizedBox(
                      width: TSizes.md,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.itemName ?? "-",
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "Qty : ${item.quantity}",
                            style: TextStyle(
                              color: TColors.materialGrey600,
                              fontSize: TSizes.fontSizeSm,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      "₹${item.value}",
                      style: const TextStyle(
                        color: TColors.materialGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(
          height: TSizes.spaceBtwItems,
        ),
        _infoRow(
          Icons.calendar_today,
          "Submitted",
          request.displayDate,
        ),
      ],
    );
  }

  Future<void> _showProof(BuildContext context) async {
    showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          insetPadding: const EdgeInsets.all(30),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              TSizes.cardRadiusLg,
            ),
          ),
          child: SizedBox(
            width: TSizes.v850,
            height: TSizes.v600,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(
                    TSizes.md,
                  ),
                  decoration: const BoxDecoration(
                    color: TColors.primary,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.image,
                        color: TColors.white,
                      ),
                      const SizedBox(
                        width: TSizes.sm,
                      ),
                      Expanded(
                        child: Text(
                          request.displayDoctorName,
                          style: const TextStyle(
                            color: TColors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: TSizes.fontSizeLg,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(
                          Icons.close,
                          color: TColors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: InteractiveViewer(
                    maxScale: 6,
                    child: Image.network(
                      request.paymentProof!,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(
                    TSizes.md,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton.icon(
                        icon: const Icon(
                          Icons.open_in_new,
                        ),
                        label: const Text(TTexts.uiTextOpen),
                        onPressed: () async {
                          await launchUrl(
                            Uri.parse(
                              request.paymentProof!,
                            ),
                            mode: LaunchMode.externalApplication,
                          );
                        },
                      ),
                      const SizedBox(
                        width: TSizes.md,
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: TColors.primary,
                          foregroundColor: TColors.white,
                        ),
                        icon: const Icon(
                          Icons.download,
                        ),
                        label: const Text(TTexts.download),
                        onPressed: () async {
                          await launchUrl(
                            Uri.parse(
                              request.paymentProof!,
                            ),
                            mode: LaunchMode.externalApplication,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
