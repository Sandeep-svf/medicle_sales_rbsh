import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../utils/constants/colors.dart';
import '../../../utils/constants/sizes.dart';
import '../model/investment_request_model.dart';
import 'investment_status_chip.dart';

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
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(TSizes.cardRadiusLg),
        border: Border.all(
          color: TColors.primary.withOpacity(.12),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 14,
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
              padding:
              const EdgeInsets.all(TSizes.md),
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
            color: Colors.grey.shade200,
          ),
        ),
      ),

      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [

          CircleAvatar(
            radius: 26,

            backgroundColor: Colors.white,

            child: Text(
              request.avatarLetter,
              style: const TextStyle(
                color: TColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ),

          const SizedBox(
            width: TSizes.spaceBtwItems,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [

                Text(
                  request.displayDoctorName,

                  maxLines: 2,

                  overflow:
                  TextOverflow.ellipsis,

                  style: const TextStyle(
                    fontSize: TSizes.fontSizeLg,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(
                  height: TSizes.spaceBtwText,
                ),

                Wrap(
                  spacing: 10,
                  runSpacing: 10,

                  crossAxisAlignment:
                  WrapCrossAlignment.center,

                  children: [

                    Container(
                      padding:
                      const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),

                      decoration: BoxDecoration(
                        color: request.paymentColor
                            .withOpacity(.08),

                        borderRadius:
                        BorderRadius.circular(
                          30,
                        ),
                      ),

                      child: Row(
                        mainAxisSize:
                        MainAxisSize.min,

                        children: [

                          Icon(
                            request.paymentIcon,
                            size: 16,
                            color:
                            request.paymentColor,
                          ),

                          const SizedBox(width: 6),

                          Text(
                            request.paymentMode ??
                                "-",

                            style: TextStyle(
                              color:
                              request.paymentColor,

                              fontWeight:
                              FontWeight.bold,

                              fontSize: TSizes
                                  .fontSizeSm,
                            ),
                          ),

                        ],
                      ),
                    ),

                    InvestmentStatusChip(
                      status:
                      request.displayStatus,
                    ),

                  ],
                ),

                const SizedBox(
                  height: TSizes.spaceBtwItems,
                ),

                if (!request.isGift)

                  Container(
                    padding:
                    const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),

                    decoration: BoxDecoration(
                      color: Colors.green
                          .withOpacity(.08),

                      borderRadius:
                      BorderRadius.circular(
                        30,
                      ),
                    ),

                    child: Text(
                      request.displayAmount,

                      style: const TextStyle(
                        color: Colors.green,

                        fontSize:
                        TSizes.fontSizeMd,

                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),
                  ),

              ],
            ),
          ),

          if (onEdit != null)
            IconButton(
              tooltip: "Edit & Resubmit",
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
          child: Text("Unknown Payment Mode"),
        );
    }
  }

  Widget _infoRow(IconData icon,
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
            width: 90,
            child: Text(
              title,
              style: TextStyle(
                fontSize: TSizes.fontSizeSm,
                color: Colors.grey.shade600,
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
              color: Colors.orange,
            ),

            const SizedBox(width: TSizes.sm),

            Expanded(
              child: Text(
                "Cash payment request",
                style: TextStyle(
                  color: Colors.grey.shade700,
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
                icon: const Icon(Icons.visibility, size: 18),
                label: const Text("View"),
              ),

              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: TColors.primary,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  await launchUrl(
                    Uri.parse(request.paymentProof!),
                    mode: LaunchMode.externalApplication,
                  );
                },
                icon: const Icon(Icons.download, size: 18),
                label: const Text("Download"),
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

        const SizedBox(
          height: TSizes.spaceBtwItems,
        ),

        if (request.hasProof)

          Row(
            children: [

              Expanded(
                child: OutlinedButton.icon(

                  onPressed: () {
                    _showProof(context);
                  },

                  icon: const Icon(Icons.visibility),

                  label: const Text("View Proof"),

                ),
              ),

              const SizedBox(width: TSizes.sm),

              Expanded(
                child: ElevatedButton.icon(

                  style: ElevatedButton.styleFrom(
                    backgroundColor: TColors.primary,
                    foregroundColor: Colors.white,
                  ),

                  onPressed: () async {
                    await launchUrl(
                      Uri.parse(request.paymentProof!),
                      mode: LaunchMode.externalApplication,
                    );
                  },

                  icon: const Icon(Icons.download),

                  label: const Text("Download"),

                ),
              )

            ],
          )

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
          "Gift Items",
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
            separatorBuilder: (_, __) =>
            const SizedBox(
              height: TSizes.sm,
            ),
            itemBuilder: (_, index) {
              final item = request.items[index];

              return Container(
                padding: const EdgeInsets.all(TSizes.sm),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(.05),
                  borderRadius: BorderRadius.circular(
                    TSizes.cardRadiusSm,
                  ),
                  border: Border.all(
                    color: Colors.orange.withOpacity(.20),
                  ),
                ),
                child: Row(
                  children: [

                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(.10),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.card_giftcard,
                        color: Colors.orange,
                      ),
                    ),

                    const SizedBox(
                      width: TSizes.md,
                    ),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [

                          Text(
                            item.itemName ?? "-",
                            maxLines: 2,
                            overflow:
                            TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          Text(
                            "Qty : ${item.quantity}",
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize:
                              TSizes.fontSizeSm,
                            ),
                          ),

                        ],
                      ),
                    ),

                    Text(
                      "₹${item.value}",
                      style: const TextStyle(
                        color: Colors.green,
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

            width: 850,
            height: 600,

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
                        color: Colors.white,
                      ),

                      const SizedBox(
                        width: TSizes.sm,
                      ),

                      Expanded(
                        child: Text(
                          request.displayDoctorName,
                          style: const TextStyle(
                            color: Colors.white,
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
                          color: Colors.white,
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

                    mainAxisAlignment:
                    MainAxisAlignment.end,

                    children: [

                      OutlinedButton.icon(

                        icon: const Icon(
                          Icons.open_in_new,
                        ),

                        label: const Text("Open"),

                        onPressed: () async {
                          await launchUrl(
                            Uri.parse(
                              request.paymentProof!,
                            ),
                            mode: LaunchMode
                                .externalApplication,
                          );
                        },

                      ),

                      const SizedBox(
                        width: TSizes.md,
                      ),

                      ElevatedButton.icon(

                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                          TColors.primary,
                          foregroundColor:
                          Colors.white,
                        ),

                        icon: const Icon(
                          Icons.download,
                        ),

                        label:
                        const Text("Download"),

                        onPressed: () async {
                          await launchUrl(
                            Uri.parse(
                              request.paymentProof!,
                            ),
                            mode: LaunchMode
                                .externalApplication,
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
