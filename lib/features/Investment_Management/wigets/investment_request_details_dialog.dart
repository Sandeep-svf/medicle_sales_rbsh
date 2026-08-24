import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../utils/constants/colors.dart';
import '../model/investment_request_model.dart';
import 'investment_status_chip.dart';

class InvestmentRequestDetailsDialog extends StatelessWidget {
  const InvestmentRequestDetailsDialog({
    super.key,
    required this.request,
  });

  final InvestmentRequest request;

  static Future<void> show(
    BuildContext context,
    InvestmentRequest request,
  ) {
    return showDialog<void>(
      context: context,
      builder: (_) => InvestmentRequestDetailsDialog(request: request),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 720,
          maxHeight: screenHeight * .88,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _section(
                      "Request Details",
                      [
                        _detailRow("Request ID", request.id ?? "-"),
                        _detailRow("Doctor", request.displayDoctorName),
                        _detailRow("Requested By", _requestedBy),
                        if ((request.user?.email ?? "").isNotEmpty)
                          _detailRow("User Email", request.user!.email!),
                        _detailRow("Payment Mode", request.paymentMode ?? "-"),
                        _detailRow("Status", request.displayStatus),
                        if (!request.isGift)
                          _detailRow("Amount", request.displayAmount),
                        _detailRow(
                          "Support MTD",
                          _money(request.supportValueMtd),
                        ),
                        _detailRow("Purpose", request.displayPurpose),
                        if ((request.upiId ?? "").isNotEmpty)
                          _detailRow("UPI ID", request.upiId!),
                        if ((request.bankDetails ?? "").isNotEmpty)
                          _detailRow("Bank Details", request.bankDetails!),
                        if ((request.justification ?? "").isNotEmpty)
                          _detailRow(
                            "Justification",
                            request.justification!,
                          ),
                      ],
                    ),
                    if (request.items.isNotEmpty) ...[
                      const SizedBox(height: 18),
                      _itemsSection(),
                    ],
                    if ((request.rejectionReason ?? "").isNotEmpty) ...[
                      const SizedBox(height: 18),
                      _section(
                        "Rejection Details",
                        [
                          _detailRow(
                            "Reason",
                            request.rejectionReason!,
                            valueColor: Colors.red.shade700,
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 18),
                    _section(
                      "Timeline",
                      [
                        _detailRow("Created", _dateTime(request.createdAt)),
                        _detailRow("Updated", _dateTime(request.updatedAt)),
                      ],
                    ),
                    if (request.hasProof) ...[
                      const SizedBox(height: 18),
                      _proofSection(),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: TColors.primary,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(
        children: [
          const Icon(Icons.receipt_long_outlined, color: Colors.white),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              "Investment Request",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          InvestmentStatusChip(status: request.displayStatus),
          const SizedBox(width: 4),
          IconButton(
            tooltip: "Close",
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _section(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Divider(height: 24),
          ...children,
        ],
      ),
    );
  }

  Widget _detailRow(
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 125,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value.trim().isEmpty ? "-" : value,
              style: TextStyle(
                color: valueColor ?? Colors.black87,
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _itemsSection() {
    return _section(
      "Items / Gifts",
      request.items.map((item) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              const Icon(Icons.card_giftcard, color: Colors.orange),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  item.itemName ?? "-",
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              Text("Qty: ${item.quantity ?? 0}"),
              const SizedBox(width: 14),
              Text(
                _money(item.value),
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _proofSection() {
    return _section(
      "Payment Proof",
      [
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _openPaymentProof,
            icon: const Icon(Icons.open_in_new),
            label: const Text("Open Payment Proof"),
          ),
        ),
      ],
    );
  }

  String get _requestedBy =>
      request.user?.name ?? request.userName ?? "Unknown User";

  String _money(double? value) {
    if (value == null) {
      return "-";
    }

    final decimals = value == value.truncateToDouble() ? 0 : 2;
    return "₹${value.toStringAsFixed(decimals)}";
  }

  String _dateTime(DateTime? value) {
    if (value == null) {
      return "-";
    }

    return DateFormat("dd MMM yyyy, hh:mm a").format(value.toLocal());
  }

  Future<void> _openPaymentProof() async {
    final url = request.paymentProof;
    final uri = url == null ? null : Uri.tryParse(url);

    if (uri == null) {
      return;
    }

    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
