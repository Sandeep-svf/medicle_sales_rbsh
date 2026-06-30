import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../utils/constants/colors.dart';
import '../model/investment_request_model.dart';
import 'investment_status_chip.dart';

class InvestmentRequestTableRow extends StatefulWidget {
  final InvestmentRequest request;
  final int index;

  const InvestmentRequestTableRow({
    super.key,
    required this.request,
    required this.index,
  });

  @override
  State<InvestmentRequestTableRow> createState() =>
      _InvestmentRequestTableRowState();
}

class _InvestmentRequestTableRowState
    extends State<InvestmentRequestTableRow> {

  bool hovering = false;

  InvestmentRequest get request => widget.request;

  @override
  Widget build(BuildContext context) {

    return MouseRegion(

      onEnter: (_) => setState(() => hovering = true),

      onExit: (_) => setState(() => hovering = false),

      child: AnimatedContainer(

        duration: const Duration(milliseconds: 180),

        color: hovering
            ? TColors.primary.withOpacity(.04)
            : widget.index.isEven
            ? Colors.white
            : Colors.grey.shade50,

        child: InkWell(

          onTap: () {},

          child: Padding(

            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),

            child: LayoutBuilder(

              builder: (_, constraints) {

                final landscape =
                    constraints.maxWidth > 900;

                return Row(

                  crossAxisAlignment:
                  CrossAxisAlignment.start,

                  children: [

                    ///================================================
                    /// Doctor
                    ///================================================

                    Expanded(

                      flex: 4,

                      child: Row(

                        crossAxisAlignment:
                        CrossAxisAlignment.start,

                        children: [

                          CircleAvatar(

                            radius: 23,

                            backgroundColor:
                            request.paymentColor
                                .withOpacity(.10),

                            child: Text(

                              request.avatarLetter,

                              style: TextStyle(
                                color: request.paymentColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          const SizedBox(width: 14),

                          Expanded(

                            child: Column(

                              crossAxisAlignment:
                              CrossAxisAlignment.start,

                              children: [

                                Text(

                                  request.displayDoctorName,

                                  maxLines: 1,

                                  overflow:
                                  TextOverflow.ellipsis,

                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),

                                const SizedBox(height: 6),

                                Text(

                                  request.displayPurpose,

                                  maxLines: 3,

                                  overflow:
                                  TextOverflow.ellipsis,

                                  style: TextStyle(
                                    fontSize: 12,
                                    color:
                                    Colors.grey.shade600,
                                    height: 1.35,
                                  ),
                                ),

                              ],
                            ),
                          )

                        ],
                      ),
                    ),

                    if (landscape)

                      Expanded(

                        flex: 2,

                        child: Center(

                          child: Container(

                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),

                            decoration: BoxDecoration(

                              color: request.paymentColor
                                  .withOpacity(.08),

                              borderRadius:
                              BorderRadius.circular(20),

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

                                Flexible(
                                  child: Text(

                                    request.paymentMode ??
                                        "-",

                                    maxLines: 1,

                                    overflow:
                                    TextOverflow
                                        .ellipsis,

                                    style: TextStyle(

                                      color:
                                      request.paymentColor,

                                      fontWeight:
                                      FontWeight.w600,

                                    ),
                                  ),
                                )

                              ],
                            ),
                          ),
                        ),
                      ),

                    ///======================================
                    /// Amount
                    ///======================================

                    Expanded(

                      flex: 2,

                      child: Center(

                        child: SizedBox(

                          width: 110,

                          child: Container(

                            alignment: Alignment.center,

                            padding:
                            const EdgeInsets.symmetric(
                              vertical: 9,
                            ),

                            decoration: BoxDecoration(

                              color: TColors.primary
                                  .withOpacity(.08),

                              borderRadius:
                              BorderRadius.circular(10),

                            ),

                            child: Text(

                              request.isGift
                                  ? "${request.items.length} Items"
                                  : request.displayAmount,

                              textAlign: TextAlign.center,

                              maxLines: 1,

                              overflow:
                              TextOverflow.ellipsis,

                              style: const TextStyle(

                                color: TColors.primary,

                                fontWeight:
                                FontWeight.bold,

                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    if (landscape)

                      Expanded(

                        flex: 2,

                        child: Center(

                          child: Text(

                            DateFormat(
                              "dd MMM yyyy",
                            ).format(
                              request.createdAt ??
                                  DateTime.now(),
                            ),

                            style: TextStyle(
                              color:
                              Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ),

                    ///======================================
                    /// Status
                    ///======================================

                    SizedBox(

                      width: 145,

                      child: Center(

                        child: InvestmentStatusChip(

                          status:
                          request.displayStatus,

                        ),
                      ),
                    ),

                    ///======================================
                    /// Proof
                    ///======================================

                    SizedBox(

                      width: 55,

                      child: request.hasProof

                          ? IconButton(

                        tooltip:
                        "Payment Proof",

                        icon: const Icon(

                          Icons.image_outlined,

                          color: Colors.blue,

                        ),

                        onPressed:
                        _showProofDialog,

                      )

                          : const SizedBox(),

                    ),

                    ///======================================
                    /// Menu
                    ///======================================

                    SizedBox(

                      width: 50,

                      child: PopupMenuButton<int>(

                        onSelected: _menuSelected,

                        itemBuilder: (_) => const [

                          PopupMenuItem(
                            value: 1,
                            child: Text("View"),
                          ),

                          PopupMenuItem(
                            value: 2,
                            child: Text("Edit"),
                          ),

                          PopupMenuItem(
                            value: 3,
                            child: Text("Download"),
                          ),

                        ],

                      ),

                    ),

                  ],
                );

              },

            ),

          ),

        ),

      ),

    );

  }
  void _menuSelected(int value) async {
    switch (value) {
      case 1:
      // TODO: View Details
        break;

      case 2:
      // TODO: Edit Request
        break;

      case 3:
        if (request.hasProof) {
          await launchUrl(
            Uri.parse(request.paymentProof!),
            mode: LaunchMode.externalApplication,
          );
        }
        break;
    }
  }

  Future<void> _showProofDialog() async {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) {
        return Dialog(
          insetPadding: const EdgeInsets.all(30),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: SizedBox(
            width: 900,
            height: 650,
            child: Column(
              children: [

                /// HEADER
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  decoration: const BoxDecoration(
                    color: TColors.primary,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(18),
                      topRight: Radius.circular(18),
                    ),
                  ),
                  child: Row(
                    children: [

                      Icon(
                        request.paymentIcon,
                        color: Colors.white,
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [

                            const Text(
                              "Payment Proof",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),

                            Text(
                              request.displayDoctorName,
                              style: const TextStyle(
                                color: Colors.white70,
                              ),
                            ),

                          ],
                        ),
                      ),

                      IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white,
                        ),
                        onPressed: () => Navigator.pop(context),
                      )

                    ],
                  ),
                ),

                /// IMAGE
                Expanded(
                  child: Container(
                    width: double.infinity,
                    color: Colors.grey.shade100,
                    child: InteractiveViewer(
                      minScale: .5,
                      maxScale: 6,
                      child: Center(
                        child: Image.network(
                          request.paymentProof!,
                          fit: BoxFit.contain,
                          loadingBuilder:
                              (context, child, progress) {
                            if (progress == null) {
                              return child;
                            }

                            return const Center(
                              child:
                              CircularProgressIndicator(),
                            );
                          },
                          errorBuilder:
                              (_, __, ___) =>
                          const Icon(
                            Icons.broken_image,
                            size: 120,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                /// FOOTER
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: Colors.grey.shade300,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [

                      Expanded(
                        child: Text(
                          request.paymentMode ?? "",
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      OutlinedButton.icon(
                        icon:
                        const Icon(Icons.open_in_new),
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

                      const SizedBox(width: 12),

                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                          TColors.primary,
                          foregroundColor:
                          Colors.white,
                        ),
                        icon:
                        const Icon(Icons.download),
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