import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:medicle_sales_rbsh/features/order/models/order_models.dart';
import 'package:medicle_sales_rbsh/features/order/services/order_pdf_service.dart';

OrderDraft sampleOrder({int lines = 4}) => OrderDraft(
      doctorName: 'Dr. Asha Sharma',
      clinicName: 'City Care Clinic',
      contactPhone: '9800000000',
      area: 'South Delhi',
      deliveryAddress: '24, Market Road, New Delhi',
      stockistName: 'Example Medical Distributors',
      orderDate: DateTime(2026, 9, 21),
      paymentTerms: 'Credit',
      creditDays: 30,
      notes:
          'Sample order for layout review. Please confirm availability before dispatch.',
      attachmentBytes: Uint8List(0),
      attachmentName: '',
      attachmentMime: '',
      items: List.generate(
          lines,
          (i) => OrderItemDraft(
                productId: 'medicine-$i',
                productName: 'Example medicine ${i + 1}',
                salt: 'Sample composition',
                dosage: '200 mg',
                packDescription: '10 x 10 tablets',
                quantity: 10,
                freeQuantity: 2,
                unit: 'Boxes',
                unitRatePaise: i == 1 ? null : 12500,
                discountBasisPoints: 1000,
                taxBasisPoints: 500,
              )),
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('order without proof is valid for automatic PDF creation', () {
    expect(sampleOrder().validate(), isNull);
  });
  test('generates offline PDF with bundled fonts and many product rows',
      () async {
    final bytes = await OrderPdfService.build(
        draft: sampleOrder(lines: 70), reference: 'ORD-SAMPLE01');
    expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
    expect(bytes.length, greaterThan(10000));
  });
  test('sample document can be generated for visual review', () async {
    final bytes = await OrderPdfService.build(
        draft: sampleOrder(), reference: 'ORD-SAMPLE01');
    expect(bytes, isNotEmpty);
    const output = String.fromEnvironment('ORDER_PDF_SAMPLE');
    if (output.isNotEmpty) {
      await File(output).parent.create(recursive: true);
      await File(output).writeAsBytes(bytes);
    }
  });
}
