import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/order_models.dart';
import 'package:medicle_sales_rbsh/utils/constants/colors.dart';
import 'package:medicle_sales_rbsh/utils/constants/text_strings.dart';
import 'package:medicle_sales_rbsh/utils/constants/sizes.dart';

/// Bundled fonts keep PDF generation independent of internet access.
class OrderPdfService {
  static Future<Uint8List> fromOrder(LocalOrder order) => build(
      reference: order.reference,
      draft: OrderDraft(
        doctorName: order.doctorName,
        doctorId: order.doctorId,
        clinicName: order.clinicName,
        specialization: order.specialization,
        area: order.area,
        headOffice: order.headOffice,
        deliveryAddress: order.deliveryAddress,
        notes: order.notes,
        orderDate: order.orderDate,
        items: order.items,
        attachmentBytes: Uint8List(0),
        attachmentName: '',
        attachmentMime: '',
        customerType: order.customerType,
        contactPhone: order.contactPhone,
        stockistName: order.stockistName,
        purchaseOrderReference: order.purchaseOrderReference,
        requestedDeliveryDate: order.requestedDeliveryDate,
        priority: order.priority,
        paymentTerms: order.paymentTerms,
        creditDays: order.creditDays,
      ));

  static Future<Uint8List> build(
      {required OrderDraft draft, required String reference}) async {
    final regular = await rootBundle.load('assets/fonts/Poppins-Regular.ttf');
    final bold = await rootBundle.load('assets/fonts/Poppins-Bold.ttf');
    final document = pw.Document(
        theme: pw.ThemeData.withFont(
            base: pw.Font.ttf(regular), bold: pw.Font.ttf(bold)));
    final accent = PdfColor.fromInt(TColors.primary_shade700.toARGB32());
    String money(int value) =>
        'INR ${NumberFormat('#,##0.00', 'en_IN').format(value / 100)}';
    String date(DateTime value) =>
        DateFormat('dd MMM yyyy').format(value.toLocal());
    final totals = OrderTotals(draft.items);
    pw.Widget detail(String label, String? value) =>
        value == null || value.trim().isEmpty
            ? pw.SizedBox()
            : pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 5),
                child: pw.Text('$label: $value',
                    style: const pw.TextStyle(fontSize: TSizes.v9)));
    document.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      maxPages: 100,
      header: (_) =>
          pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
          pw.Text(TTexts.uiTextMEDICINEORDER,
              style: pw.TextStyle(
                  fontSize: TSizes.v21,
                  fontWeight: pw.FontWeight.bold,
                  color: accent)),
          pw.Text(reference, style: const pw.TextStyle(fontSize: TSizes.v9)),
        ]),
        pw.Text(
            'Order request | ${date(draft.orderDate)} | ${draft.priority} priority',
            style: const pw.TextStyle(fontSize: TSizes.v9)),
        pw.Divider(color: accent),
        pw.SizedBox(height: TSizes.v8),
      ]),
      footer: (context) => pw.Column(children: [
        pw.Divider(color: PdfColors.grey300),
        pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
          pw.Text(TTexts.uiTextOrderRequestNotATaxInvoice,
              style: const pw.TextStyle(fontSize: TSizes.v8)),
          pw.Text('Page ${context.pageNumber} of ${context.pagesCount}',
              style: const pw.TextStyle(fontSize: TSizes.v8)),
        ])
      ]),
      build: (_) => [
        pw.Text(draft.doctorName,
            style: pw.TextStyle(
                fontSize: TSizes.v16, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: TSizes.v8),
        detail('Customer type', draft.customerType),
        detail('Clinic / business', draft.clinicName),
        detail('Specialty', draft.specialization),
        detail('Contact', draft.contactPhone),
        detail('Delivery address', draft.deliveryAddress),
        detail('Area', draft.area),
        detail('Head office', draft.headOffice),
        detail('Stockist', draft.stockistName),
        detail('Customer reference', draft.purchaseOrderReference),
        detail(
            'Requested delivery',
            draft.requestedDeliveryDate == null
                ? null
                : date(draft.requestedDeliveryDate!)),
        detail(
            'Payment terms',
            draft.paymentTerms == 'Credit'
                ? '${draft.creditDays} days credit'
                : draft.paymentTerms),
        pw.SizedBox(height: TSizes.v16),
        pw.TableHelper.fromTextArray(
          headers: [
            'No.',
            'Medicine / pack',
            'Qty',
            'Free',
            'Unit',
            'Rate (INR)',
            'Disc %',
            'Tax %',
            'Total (INR)'
          ],
          data: [
            for (var i = 0; i < draft.items.length; i++)
              [
                '${i + 1}',
                [
                  draft.items[i].productName,
                  draft.items[i].salt,
                  draft.items[i].dosage,
                  draft.items[i].packDescription
                ].whereType<String>().where((s) => s.isNotEmpty).join('\n'),
                '${draft.items[i].paidQuantity}',
                '${draft.items[i].sampleQuantity}',
                draft.items[i].unit,
                draft.items[i].unitRatePaise == null
                    ? '-'
                    : (draft.items[i].unitRatePaise! / 100).toStringAsFixed(2),
                (draft.items[i].discountBasisPoints / 100).toStringAsFixed(2),
                (draft.items[i].taxBasisPoints / 100).toStringAsFixed(2),
                draft.items[i].hasPrice
                    ? (draft.items[i].totalPaise / 100).toStringAsFixed(2)
                    : '-',
              ]
          ],
          columnWidths: {
            0: const pw.FixedColumnWidth(22),
            1: const pw.FlexColumnWidth(3),
            2: const pw.FixedColumnWidth(28),
            3: const pw.FixedColumnWidth(28)
          },
          headerStyle: pw.TextStyle(
              fontSize: TSizes.v7,
              color: PdfColors.white,
              fontWeight: pw.FontWeight.bold),
          headerDecoration: pw.BoxDecoration(color: accent),
          cellStyle: const pw.TextStyle(fontSize: TSizes.v7),
          cellPadding: const pw.EdgeInsets.all(5),
          oddRowDecoration: const pw.BoxDecoration(color: PdfColors.grey100),
          border: pw.TableBorder.all(color: PdfColors.grey300, width: .4),
        ),
        pw.SizedBox(height: TSizes.v16),
        pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  detail('Subtotal', money(totals.subtotalPaise)),
                  detail('Discount', money(totals.discountPaise)),
                  detail('Tax estimate', money(totals.taxPaise)),
                  pw.Text('Estimated total: ${money(totals.totalPaise)}',
                      style: pw.TextStyle(
                          fontSize: TSizes.v14,
                          fontWeight: pw.FontWeight.bold,
                          color: accent)),
                ])),
        pw.SizedBox(height: TSizes.v12),
        if (!totals.fullyPriced)
          pw.Text(
              '${totals.unpricedLines} line(s) have no rate. The estimate includes priced lines only.',
              style: const pw.TextStyle(fontSize: TSizes.v9)),
        pw.SizedBox(height: TSizes.v12),
        detail('Remarks', draft.notes),
        pw.Text(TTexts.uiTextPricesTaxesStockAvailabilityAndDeliveryAreSubject,
            style: const pw.TextStyle(
                fontSize: TSizes.v8, color: PdfColors.grey700)),
      ],
    ));
    return document.save();
  }
}
