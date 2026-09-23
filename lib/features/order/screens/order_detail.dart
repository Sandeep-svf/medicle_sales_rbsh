import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_filex/open_filex.dart';
import 'package:printing/printing.dart';
import '../services/order_pdf_service.dart';
import 'package:medicle_sales_rbsh/utils/constants/colors.dart';
import '../models/order_models.dart';
import '../widgets/order_widgets.dart';
import 'package:medicle_sales_rbsh/utils/constants/text_strings.dart';
import 'package:medicle_sales_rbsh/utils/constants/sizes.dart';

class OrderDetailScreen extends StatefulWidget {
  const OrderDetailScreen({super.key, required this.order});
  final LocalOrder order;
  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  bool _opening = false;
  bool _sharing = false;

  Future<void> _sharePdf() async {
    if (_sharing) return;
    setState(() => _sharing = true);
    try {
      final bytes = await OrderPdfService.fromOrder(widget.order);
      if (!mounted) return;
      final box = context.findRenderObject() as RenderBox?;
      await Printing.sharePdf(
          bytes: bytes,
          filename: '${widget.order.reference}.pdf',
          bounds:
              box == null ? null : box.localToGlobal(Offset.zero) & box.size);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(TTexts.uiTextCouldNotShareThePDFYourOrderIs)));
      }
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  void _previewPdf() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => Scaffold(
                  appBar: AppBar(title: const Text(TTexts.uiTextOrderPDF)),
                  body: PdfPreview(
                    build: (_) => OrderPdfService.fromOrder(widget.order),
                    pdfFileName: '${widget.order.reference}.pdf',
                    canChangeOrientation: false,
                    canChangePageFormat: false,
                    canDebug: false,
                  ),
                )));
  }

  Future<void> _openProof() async {
    setState(() => _opening = true);
    try {
      final result = await OpenFilex.open(widget.order.attachmentPath);
      if (result.type != ResultType.done && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content:
                Text(TTexts.uiTextTheAttachmentCouldNotBeOpenedCheckThat)));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content:
                Text(TTexts.uiTextThisAttachmentIsNoLongerAvailableOnThe)));
      }
    } finally {
      if (mounted) setState(() => _opening = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    return Theme(
        data: orderTheme(context),
        child: Scaffold(
          appBar: AppBar(
              title: Text(order.reference),
              backgroundColor: TColors.white,
              actions: [
                IconButton(
                    tooltip: TTexts.uiTextCopyOrderReference,
                    onPressed: () async {
                      await Clipboard.setData(
                          ClipboardData(text: order.clientGeneratedId));
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text(TTexts.uiTextOrderReferenceCopied)));
                      }
                    },
                    icon: const Icon(Icons.copy_outlined))
              ]),
          body: ListView(padding: const EdgeInsets.all(20), children: [
            Center(
                child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: TSizes.v1000),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          OrderSection(
                              title: TTexts.uiTextYourOrderIsSaved,
                              subtitle: TTexts
                                  .uiTextPreviewPrintOrShareAMedicineOrderPDF,
                              icon: Icons.task_alt,
                              child: Wrap(
                                  spacing: TSizes.v12,
                                  runSpacing: TSizes.v8,
                                  children: [
                                    FilledButton.icon(
                                        onPressed: _sharing ? null : _sharePdf,
                                        icon: const Icon(Icons.share_outlined),
                                        label: Text(_sharing
                                            ? 'Preparing PDF…'
                                            : 'Share PDF')),
                                    OutlinedButton.icon(
                                        onPressed: _previewPdf,
                                        icon: const Icon(
                                            Icons.picture_as_pdf_outlined),
                                        label: const Text(
                                            TTexts.uiTextPreviewPDF)),
                                  ])),
                          const SizedBox(height: TSizes.v18),
                          OrderSection(
                              title: order.doctorName,
                              subtitle:
                                  '${order.customerType} · ${orderDateLabel(order.orderDate)}',
                              icon: Icons.person_outline,
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Wrap(
                                        spacing: TSizes.v8,
                                        runSpacing: TSizes.v8,
                                        children: [
                                          const OrderTag('Saved on this device',
                                              icon: Icons.phone_android),
                                          OrderTag(
                                              order.priority == 'Urgent'
                                                  ? 'Urgent priority'
                                                  : 'Normal priority',
                                              color: order.priority == 'Urgent'
                                                  ? TColors.warning
                                                  : TColors.textSecondary)
                                        ]),
                                    const SizedBox(height: TSizes.v18),
                                    ...{
                                      'Clinic / business': order.clinicName,
                                      'Contact': order.contactPhone,
                                      'Area': order.area,
                                      'Head office': order.headOffice,
                                      'Delivery address': order.deliveryAddress,
                                      'Supplying stockist': order.stockistName,
                                      'Customer reference':
                                          order.purchaseOrderReference,
                                      'Requested delivery':
                                          order.requestedDeliveryDate == null
                                              ? null
                                              : orderDateLabel(
                                                  order.requestedDeliveryDate!),
                                      'Payment terms': order.paymentTerms ==
                                              'Credit'
                                          ? '${order.creditDays} days credit'
                                          : order.paymentTerms,
                                      'Remarks': order.notes
                                    }
                                        .entries
                                        .where(
                                            (e) => e.value?.isNotEmpty == true)
                                        .map((e) => Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 14),
                                            child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(e.key,
                                                      style: const TextStyle(
                                                          fontSize: TSizes.v11,
                                                          color: TColors
                                                              .textSecondary)),
                                                  const SizedBox(
                                                      height: TSizes.v3),
                                                  Text(e.value!,
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.w600))
                                                ]))),
                                  ])),
                          const SizedBox(height: TSizes.v18),
                          OrderSection(
                              title: TTexts.uiTextProducts,
                              subtitle: TTexts
                                  .uiTextRecordedQuantitiesAndEstimatedRates,
                              icon: Icons.medication_outlined,
                              child: Column(
                                  children: order.items
                                      .map((item) => Container(
                                          margin:
                                              const EdgeInsets.only(bottom: 12),
                                          padding: const EdgeInsets.all(14),
                                          decoration: BoxDecoration(
                                              color: TColors.hex_FFFAF8F9,
                                              borderRadius:
                                                  BorderRadius.circular(12)),
                                          child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.stretch,
                                              children: [
                                                Text(item.productName,
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w800)),
                                                const SizedBox(
                                                    height: TSizes.v4),
                                                Text(
                                                    [
                                                      item.salt,
                                                      item.dosage,
                                                      item.packDescription
                                                    ]
                                                        .whereType<String>()
                                                        .where(
                                                            (s) => s.isNotEmpty)
                                                        .join(' · '),
                                                    style: const TextStyle(
                                                        fontSize: TSizes.v12,
                                                        color: TColors
                                                            .textSecondary)),
                                                const SizedBox(
                                                    height: TSizes.v12),
                                                Wrap(
                                                    spacing: TSizes.v8,
                                                    runSpacing: TSizes.v8,
                                                    children: [
                                                      OrderTag(
                                                          '${item.paidQuantity} ordered · ${item.unit}'),
                                                      if (item.sampleQuantity >
                                                          0)
                                                        OrderTag(
                                                            '${item.sampleQuantity} free · ${item.unit}',
                                                            color:
                                                                TColors.success)
                                                    ]),
                                                const SizedBox(
                                                    height: TSizes.v10),
                                                Text(
                                                    item.hasPrice
                                                        ? '${orderMoney(item.unitRatePaise ?? 0)} / ${item.unit.toLowerCase()} · ${(item.discountBasisPoints / 100).toStringAsFixed(2)}% discount · ${(item.taxBasisPoints / 100).toStringAsFixed(2)}% tax'
                                                        : 'Rate not entered',
                                                    style: const TextStyle(
                                                        fontSize: TSizes.v11,
                                                        color: TColors
                                                            .textSecondary)),
                                              ])))
                                      .toList())),
                          const SizedBox(height: TSizes.v18),
                          OrderSummary(items: order.items),
                          const SizedBox(height: TSizes.v18),
                          OrderSection(
                              title: TTexts.uiTextOrderAttachment,
                              subtitle: order.attachmentName,
                              icon: order.attachmentIsPdf
                                  ? Icons.picture_as_pdf_outlined
                                  : Icons.image_outlined,
                              child: OutlinedButton.icon(
                                  onPressed: _opening ? null : _openProof,
                                  icon: const Icon(Icons.open_in_new),
                                  label: Text(_opening
                                      ? 'Opening…'
                                      : 'View attachment'))),
                        ])))
          ]),
        ));
  }
}
