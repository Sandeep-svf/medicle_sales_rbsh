import 'package:flutter_test/flutter_test.dart';
import 'package:medicle_sales_rbsh/features/order/models/order_models.dart';

void main() {
  test('order item serializes the pharma ordering fields', () {
    const item = OrderItemDraft(
      productId: 'p-1',
      productName: 'Cefixime 200',
      salt: 'Cefixime',
      dosage: '200 mg',
      quantity: 12,
      freeSample: true,
    );

    expect(item.toJson(), {
      'productId': 'p-1',
      'productName': 'Cefixime 200',
      'salt': 'Cefixime',
      'dosage': '200 mg',
      'quantity': 12,
      'unit': 'Units',
      'freeSample': true,
      'freeQuantity': 0,
      'packDescription': null,
      'unitRatePaise': null,
      'discountBasisPoints': 0,
      'taxBasisPoints': 0,
    });
  });

  test('local order exposes totals and recoverable sync states', () {
    final order = LocalOrder(
      localId: 'local-1',
      clientGeneratedId: 'local-1',
      doctorName: 'Dr. Verma',
      orderDate: DateTime(2026, 9, 19),
      createdAt: DateTime(2026, 9, 19),
      updatedAt: DateTime(2026, 9, 19),
      syncState: OrderSyncState.failed,
      attachmentName: 'proof.pdf',
      attachmentMime: 'application/pdf',
      attachmentPath: '/tmp/proof.pdf',
      items: const [
        LocalOrderItem(
            productId: 'p-1',
            productName: 'One',
            quantity: 2,
            unit: 'Units',
            freeSample: false),
        LocalOrderItem(
            productId: 'p-2',
            productName: 'Two',
            quantity: 3,
            unit: 'Units',
            freeSample: true),
      ],
    );

    expect(order.totalQuantity, 5);
    expect(order.attachmentIsPdf, isTrue);
    expect(order.statusLabel, 'Needs retry');
  });

  test('order totals include free stock but charge only paid quantity', () {
    const item = OrderItemDraft(
      productId: 'p-1',
      productName: 'Cefixime 200',
      quantity: 10,
      freeQuantity: 2,
      unitRatePaise: 12500,
      discountBasisPoints: 1000,
      taxBasisPoints: 500,
    );

    final totals = OrderTotals([item]);
    expect(item.dispatchQuantity, 12);
    expect(totals.quantityLabel, '12 units');
    expect(totals.subtotalPaise, 125000);
    expect(totals.discountPaise, 12500);
    expect(totals.taxPaise, 5625);
    expect(totals.totalPaise, 118125);
    expect(totals.fullyPriced, isTrue);
  });
}
